/// Wizard Player Torrent
///
/// 跨平台 BT 播放封装，基于 libtorrent_flutter。
/// 提供简洁的 API 来添加种子、选择文件和获取播放 URL。
library;

import 'dart:async';

import 'package:amis_flutter_utils/utils.dart';
import 'package:libtorrent_flutter/libtorrent_flutter.dart' as lt;
import 'models/torrent_info.dart';
import 'models/download_status.dart';
export 'models/torrent_info.dart';
export 'models/download_status.dart';

/// 下载进度回调类型
typedef DownloadProgressCallback = void Function(DownloadProgress progress);

/// Wizard Player Torrent 主类
///
/// 提供 BT 播放的核心功能，包括：
/// - 初始化引擎
/// - 添加种子（磁链或文件）
/// - 选择文件
/// - 下载进度监听
/// - 获取 HTTP 播放 URL
class WizardPlayerTorrent {
  bool _initialized = false;
  final Map<int, StreamSubscription> _torrentSubscriptions = {};

  /// 是否已初始化
  bool get isInitialized => _initialized;

  /// 初始化 BT 引擎
  ///
  /// [cacheDir] - 缓存目录，默认为系统临时目录
  /// [port] - 监听端口，默认为 0（自动选择）
  Future<void> initialize({String? cacheDir, int? port}) async {
    if (_initialized) return;

    await lt.LibtorrentFlutter.init(defaultSavePath: cacheDir);

    _initialized = true;
  }

  /// 添加种子（磁链或文件路径）
  ///
  /// [torrentUrl] - 磁链或 .torrent 文件路径
  /// [startImmediately] - 是否立即开始下载，默认为 true
  Future<TorrentInfo> addTorrent({
    required String torrentUrl,
    bool startImmediately = true,
  }) async {
    _ensureInitialized();

    int torrentId;
    if (torrentUrl.startsWith('magnet:')) {
      torrentId = lt.LibtorrentFlutter.instance.addMagnet(
        torrentUrl,
        null,
        !startImmediately,
      );
    } else {
      torrentId = lt.LibtorrentFlutter.instance.addTorrentFile(
        torrentUrl,
        null,
        !startImmediately,
      );
    }

    // 等待获取元数据
    await _waitForMetadata(torrentId);

    // 获取种子信息
    final ltTorrentInfo = await _getTorrentInfo(torrentId);

    return ltTorrentInfo;
  }

  /// 选择要下载的文件
  ///
  /// [infoHash] - 种子 ID
  /// [fileIndices] - 要选择的文件索引列表
  Future<void> selectFiles({
    required int infoHash,
    required List<int> fileIndices,
  }) async {
    _ensureInitialized();

    // 获取所有文件
    final files = lt.LibtorrentFlutter.instance.getFiles(infoHash);

    // 创建优先级列表，只选择指定的文件
    final priorities = List<int>.filled(files.length, 0);
    for (final index in fileIndices) {
      if (index >= 0 && index < priorities.length) {
        priorities[index] = 1;
      }
    }

    lt.LibtorrentFlutter.instance.setFilePriorities(infoHash, priorities);
  }

  /// 开始下载
  ///
  /// [infoHash] - 种子 ID
  Future<void> startDownload(int infoHash) async {
    _ensureInitialized();
    lt.LibtorrentFlutter.instance.resumeTorrent(infoHash);
  }

  /// 暂停下载
  ///
  /// [infoHash] - 种子 ID
  Future<void> pauseDownload(int infoHash) async {
    _ensureInitialized();
    lt.LibtorrentFlutter.instance.pauseTorrent(infoHash);
  }

  /// 移除种子
  ///
  /// [infoHash] - 种子 ID
  /// [deleteFiles] - 是否删除下载的文件，默认为 false
  Future<void> removeTorrent({
    required int infoHash,
    bool deleteFiles = false,
  }) async {
    _ensureInitialized();
    _torrentSubscriptions.remove(infoHash)?.cancel();
    lt.LibtorrentFlutter.instance.disposeTorrent(infoHash);
  }

  /// 获取下载进度流
  ///
  /// [infoHash] - 种子 ID
  Stream<DownloadProgress> getProgressStream(int infoHash) {
    _ensureInitialized();

    return lt.LibtorrentFlutter.instance.torrentUpdates.map((torrents) {
      final torrent = torrents[infoHash];
      if (torrent == null) {
        return DownloadProgress(
          infoHash: infoHash,
          progress: 0.0,
          downloadRate: 0,
          uploadRate: 0,
          isPaused: true,
          isFinished: false,
        );
      }
      return DownloadProgress(
        infoHash: infoHash,
        progress: torrent.progress,
        downloadRate: torrent.downloadRate,
        uploadRate: torrent.uploadRate,
        isPaused: torrent.isPaused,
        isFinished: torrent.isFinished,
      );
    });
  }

  /// 获取播放 URL
  ///
  /// [infoHash] - 种子 ID
  /// [fileIndex] - 文件索引，默认为 -1（自动选择最大的视频文件）
  Future<String> getStreamUrl({
    required int infoHash,
    int fileIndex = -1,
  }) async {
    _ensureInitialized();

    // 开始流式播放
    final streamInfo = lt.LibtorrentFlutter.instance.startStream(
      infoHash,
      fileIndex: fileIndex,
    );

    return streamInfo.url;
  }

  /// 停止流播放
  ///
  /// [infoHash] - 种子 ID
  Future<void> stopStream(int infoHash) async {
    _ensureInitialized();
    lt.LibtorrentFlutter.instance.stopAllStreamsForTorrent(infoHash);
  }

  /// 获取种子中的文件列表
  ///
  /// [infoHash] - 种子 ID
  Future<List<TorrentFileInfo>> getFiles(int infoHash) async {
    _ensureInitialized();

    final files = lt.LibtorrentFlutter.instance.getFiles(infoHash);
    return files
        .map(
          (file) => TorrentFileInfo(
            index: file.index,
            path: file.path,
            size: file.size,
            selected: file.isStreamable,
          ),
        )
        .toList();
  }

  // ─── 私有辅助方法 ────────────────────────────────────────────────────

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'WizardPlayerTorrent not initialized. Call initialize() first.',
      );
    }
  }

  Future<void> _waitForMetadata(int torrentId) async {
    const maxWait = Duration(seconds: 120); // 增加到 120 秒
    final startTime = DateTime.now();
    int logCount = 0;

    while (DateTime.now().difference(startTime) < maxWait) {
      final torrents = lt.LibtorrentFlutter.instance.torrents;
      final torrent = torrents[torrentId];

      // 每 10 秒打印一次状态
      if (logCount % 50 == 0) {
        AppLogger().d(
          'Waiting for metadata... torrent=$torrent, hasMetadata=${torrent?.hasMetadata}, peers=${torrent?.numPeers}',
        );
      }
      logCount++;

      if (torrent != null && torrent.hasMetadata) {
        AppLogger().d('✅ Got metadata!');
        return;
      }
      await Future.delayed(const Duration(milliseconds: 200));
    }

    throw TimeoutException(
      'Failed to get metadata for torrent after 120 seconds',
    );
  }

  Future<TorrentInfo> _getTorrentInfo(int torrentId) async {
    final torrents = lt.LibtorrentFlutter.instance.torrents;
    final torrent = torrents[torrentId];
    if (torrent == null) {
      throw StateError('Torrent not found');
    }

    final files = await getFiles(torrentId);

    return TorrentInfo(
      infoHash: torrentId,
      name: torrent.name,
      totalSize: torrent.totalWanted,
      files: files,
    );
  }

  /// 清理资源
  Future<void> dispose() async {
    for (final sub in _torrentSubscriptions.values) {
      await sub.cancel();
    }
    _torrentSubscriptions.clear();
    if (_initialized) {
      await lt.LibtorrentFlutter.instance.dispose();
      _initialized = false;
    }
  }
}
