/// 播放器 ViewModel
///
/// @author AmisKwok
library;

import 'dart:async';
import 'package:amis_flutter_utils/utils.dart';
import 'package:get/get.dart';
import 'package:wizard_player_datasource/wizard_player_datasource.dart';
import 'package:wizard_player_media/wizard_player_media.dart';
import 'package:wizard_player_torrent/wizard_player_torrent.dart';
import 'package:wizardplayer/data/models/play_history_model.dart';
import 'package:wizardplayer/data/repositories/play_history_repository.dart';
import 'package:wizardplayer/data/repositories/video_repository.dart';

/// 播放器 ViewModel
class PlayerViewModel extends GetxController {
  /// 播放历史仓库
  final PlayHistoryRepository _historyRepository;

  /// 视频仓库
  final VideoRepository _videoRepository;

  /// BT 播放器
  final WizardPlayerTorrent? _wizardPlayerTorrent;

  /// 当前视频
  final Rx<VideoInfo?> _currentVideo = Rx(null);

  /// 当前剧集
  final Rx<EpisodeInfo?> _currentEpisode = Rx(null);

  /// 当前可播放的媒体信息
  final Rx<PlayableMedia?> _currentMedia = Rx(null);

  /// 当前种子信息（如果是 BT 源）
  final Rx<int?> _currentTorrentId = Rx(null);

  /// 播放器
  late final WizardPlayer _player;

  /// 是否正在加载
  final RxBool _isLoading = false.obs;

  /// 播放位置保存定时器
  Timer? _savePositionTimer;

  /// 播放状态监听器
  Worker? _playbackStateListener;

  /// 获取播放器
  WizardPlayer get player => _player;

  /// 获取当前视频
  VideoInfo? get currentVideo => _currentVideo.value;

  /// 获取当前剧集
  EpisodeInfo? get currentEpisode => _currentEpisode.value;

  /// 获取当前可播放的媒体信息
  PlayableMedia? get currentMedia => _currentMedia.value;

  /// 获取是否正在加载
  bool get isLoading => _isLoading.value;

  /// 构造函数
  PlayerViewModel(
    this._historyRepository,
    this._videoRepository,
    this._wizardPlayerTorrent,
  ) {
    _player = Get.put(VideoPlayerWizard());
  }

  @override
  void onClose() {
    _dispose();
    super.onClose();
  }

  /// 初始化播放器
  Future<void> initPlayer(VideoInfo video, int? startEpisode) async {
    _isLoading.value = true;
    try {
      _currentVideo.value = video;

      // 监听播放状态
      _playbackStateListener = ever(
        _player.playbackState,
        _onPlaybackStateChanged,
      );

      // 确定起始剧集
      final episodeNumber = startEpisode ?? 1;
      final episode = video.episodes.firstWhere(
        (e) => e.episodeNumber == episodeNumber,
        orElse: () => video.episodes.first,
      );
      _currentEpisode.value = episode;

      // 获取可播放的媒体
      await _loadPlayableMedia(episode);

      // 加载历史播放位置
      await _loadPlayPosition(video.id);

      // 启动位置保存定时器
      _startSavePositionTimer();
    } catch (e, stackTrace) {
      AppLogger().e(
        'Failed to initialize player',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// 加载可播放的媒体
  Future<void> _loadPlayableMedia(EpisodeInfo episode) async {
    try {
      AppLogger().d(
        '_loadPlayableMedia: episodeId=${episode.id}, extra=${episode.extra}',
      );

      // 检查是否是测试视频
      if (episode.sourceType == 'test') {
        AppLogger().d('✅ 使用测试视频');
        final media = PlayableMedia(
          url: 'https://vjs.zencdn.net/v/oceans.mp4',
          type: MediaType.mp4,
          quality: '1080p',
          sourceName: 'test',
          episode: episode,
        );
        _currentMedia.value = media;
        await _initializeVideoPlayer(media);
        return;
      }

      // 先检查 episode 里有没有直接保存的 magnet 链接
      if (episode.extra != null && episode.extra!['magnet'] != null) {
        final magnet = episode.extra!['magnet'] as String;
        AppLogger().d('✅ 从 episode extra 找到 magnet 链接: $magnet');

        if (magnet.isEmpty) {
          AppLogger().w('⚠️ magnet 链接为空！');
        }

        final media = PlayableMedia(
          url: magnet,
          type: MediaType.bt,
          quality: 'default',
          sourceName: episode.sourceType,
          episode: episode,
        );
        _currentMedia.value = media;
        await _initializeVideoPlayer(media);
        return;
      }

      AppLogger().d('⚠️ episode extra 没有 magnet，从数据源获取');

      // 否则从数据源获取
      final media = await _videoRepository.getPlayableMedia(episode.id);
      _currentMedia.value = media;

      // 初始化视频播放器
      await _initializeVideoPlayer(media);
    } catch (e, stackTrace) {
      AppLogger().e(
        'Failed to load playable media',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// 初始化视频播放器
  Future<void> _initializeVideoPlayer(PlayableMedia media) async {
    try {
      // 释放旧的播放器
      await _player.release();

      String playUrl = media.url;

      // 如果是 BT 媒体类型，处理 BT 播放
      if (media.type == MediaType.bt && _wizardPlayerTorrent != null) {
        AppLogger().d('Initializing BT playback for: ${media.url}');
        // 添加 BT 种子
        final torrentInfo = await _wizardPlayerTorrent.addTorrent(
          torrentUrl: media.url,
          startImmediately: true,
        );
        _currentTorrentId.value = torrentInfo.infoHash;
        // 选择第一个可播放的视频文件
        int fileIndex = -1; // -1 表示自动选择

        // 获取播放 URL
        playUrl = await _wizardPlayerTorrent.getStreamUrl(
          infoHash: torrentInfo.infoHash,
          fileIndex: fileIndex,
        );
        AppLogger().d('Got stream URL: $playUrl');
      }

      // 使用 WizardPlayer 播放
      await _player.playUri(playUrl);

      update(['player']);
    } catch (e, stackTrace) {
      AppLogger().e(
        'Failed to initialize video player',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 播放状态变更监听
  void _onPlaybackStateChanged(PlaybackState state) {
    // 检查是否播放完成
    if (state == PlaybackState.completed) {
      _onPlayComplete();
    }
  }

  /// 播放完成处理
  void _onPlayComplete() {
    // 自动播放下一集
    if (_currentVideo.value != null && _currentEpisode.value != null) {
      final nextEpisode = _currentVideo.value!.episodes.firstWhereOrNull(
        (e) => e.episodeNumber == _currentEpisode.value!.episodeNumber + 1,
      );
      if (nextEpisode != null) {
        AppLogger().d(
          'Auto playing next episode: ${nextEpisode.episodeNumber}',
        );
        playEpisode(nextEpisode.episodeNumber);
      }
    }
  }

  /// 加载历史播放位置
  Future<void> _loadPlayPosition(String videoId) async {
    try {
      final history = await _historyRepository.getHistoryByVideoId(videoId);
      if (history != null && _player.duration.value > Duration.zero) {
        // 如果上次观看的是同一集，则恢复播放位置
        if (history.episodeNumber == _currentEpisode.value?.episodeNumber) {
          final position = Duration(milliseconds: history.position);
          // 确保不超过视频时长
          final safePosition = position <= _player.duration.value
              ? position
              : Duration.zero;
          await _player.seekTo(safePosition);
          AppLogger().d(
            'Resumed playback position: ${safePosition.inSeconds}s',
          );
        }
      }
    } catch (e, stackTrace) {
      AppLogger().e(
        'Failed to load playback position',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 启动位置保存定时器
  void _startSavePositionTimer() {
    _savePositionTimer?.cancel();
    // 每10秒保存一次位置
    _savePositionTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _saveCurrentPosition(),
    );
  }

  /// 保存当前播放位置
  Future<void> _saveCurrentPosition() async {
    if (_currentVideo.value == null ||
        _currentEpisode.value == null ||
        _player.duration.value <= Duration.zero) {
      return;
    }

    try {
      final position = _player.currentPosition.value;
      final duration = _player.duration.value;

      final history = PlayHistoryModel(
        id: _currentVideo.value!.id,
        videoId: _currentVideo.value!.id,
        videoTitle: _currentVideo.value!.title,
        coverUrl: _currentVideo.value!.coverUrl ?? '',
        episodeNumber: _currentEpisode.value!.episodeNumber,
        position: position.inMilliseconds,
        duration: duration.inMilliseconds,
        lastWatchTime: DateTime.now(),
      );

      await _historyRepository.saveHistory(history);
    } catch (e, stackTrace) {
      AppLogger().e(
        'Failed to save playback position',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 切换剧集
  Future<void> playEpisode(int episodeNumber) async {
    if (_currentVideo.value == null) return;

    final episode = _currentVideo.value!.episodes.firstWhereOrNull(
      (e) => e.episodeNumber == episodeNumber,
    );
    if (episode == null) {
      AppLogger().w('Episode $episodeNumber not found');
      return;
    }

    _isLoading.value = true;
    try {
      _currentEpisode.value = episode;
      await _loadPlayableMedia(episode);
    } catch (e, stackTrace) {
      AppLogger().e(
        'Failed to switch episode',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// 上一集
  void previousEpisode() {
    if (_currentVideo.value == null || _currentEpisode.value == null) return;

    final previousEpisodeNumber = _currentEpisode.value!.episodeNumber - 1;
    if (previousEpisodeNumber >= 1) {
      playEpisode(previousEpisodeNumber);
    }
  }

  /// 下一集
  void nextEpisode() {
    if (_currentVideo.value == null || _currentEpisode.value == null) return;

    final nextEpisodeNumber = _currentEpisode.value!.episodeNumber + 1;
    if (nextEpisodeNumber <= _currentVideo.value!.episodes.length) {
      playEpisode(nextEpisodeNumber);
    }
  }

  /// 检查是否有上一集
  bool get hasPreviousEpisode {
    if (_currentVideo.value == null || _currentEpisode.value == null) {
      return false;
    }
    return _currentEpisode.value!.episodeNumber > 1;
  }

  /// 检查是否有下一集
  bool get hasNextEpisode {
    if (_currentVideo.value == null || _currentEpisode.value == null) {
      return false;
    }
    return _currentEpisode.value!.episodeNumber <
        _currentVideo.value!.episodes.length;
  }

  /// 清理 BT 播放资源
  Future<void> _cleanupTorrent() async {
    if (_currentTorrentId.value != null && _wizardPlayerTorrent != null) {
      try {
        await _wizardPlayerTorrent.stopStream(_currentTorrentId.value!);
        await _wizardPlayerTorrent.removeTorrent(
          infoHash: _currentTorrentId.value!,
          deleteFiles: true,
        );
        AppLogger().d('Removed torrent: ${_currentTorrentId.value}');
      } catch (e) {
        AppLogger().w('Failed to remove torrent', error: e);
      }
      _currentTorrentId.value = null;
    }
  }

  /// 销毁资源
  Future<void> _dispose() async {
    _savePositionTimer?.cancel();
    _playbackStateListener?.dispose();
    // 最后保存一次位置
    await _saveCurrentPosition();
    await _player.release();

    // 清理 BT 播放资源
    await _cleanupTorrent();
  }
}
