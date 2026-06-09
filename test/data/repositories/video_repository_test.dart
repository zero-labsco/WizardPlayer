import 'package:flutter_test/flutter_test.dart';
import 'package:amis_flutter_utils/utils.dart';
import 'package:wizard_player_datasource/wizard_player_datasource.dart';
import 'package:wizardplayer/data/repositories/video_repository.dart';

/// 手动 Mock VideoDataSource 实现
class MockVideoDataSource implements VideoDataSource {
  @override
  final DataSourceConfig config;
  List<VideoInfo> searchResult = [];
  List<VideoInfo> latestResult = [];
  List<VideoInfo> rankingResult = [];
  VideoInfo? getDetailResult;
  Exception? searchError;
  Exception? getDetailError;
  bool throwOnSearch = false;
  bool throwOnGetDetail = false;
  bool throwOnLatest = false;
  bool throwOnRanking = false;

  MockVideoDataSource({
    required this.config,
    this.searchResult = const [],
    this.latestResult = const [],
    this.rankingResult = const [],
    this.getDetailResult,
    this.searchError,
    this.getDetailError,
    this.throwOnSearch = false,
    this.throwOnGetDetail = false,
    this.throwOnLatest = false,
    this.throwOnRanking = false,
  });

  @override
  Future<List<VideoInfo>> search(
    String query, {
    int page = 1,
    int pageSize = 20,
  }) async {
    if (throwOnSearch && searchError != null) {
      throw searchError!;
    }
    return searchResult;
  }

  @override
  Future<VideoInfo> getDetail(String videoId) async {
    if (throwOnGetDetail && getDetailError != null) {
      throw getDetailError!;
    }
    if (getDetailResult == null) {
      throw Exception('No mock data set');
    }
    return getDetailResult!;
  }

  @override
  Future<List<EpisodeInfo>> getEpisodes(String videoId) async => [];

  @override
  Future<PlayableMedia> getPlayableMedia(String episodeId) async =>
      const PlayableMedia(url: '', type: MediaType.mp4, sourceName: 'mock');

  @override
  Future<bool> testAvailability() async => true;

  @override
  Future<List<String>> getCategories() async => [];

  @override
  Future<List<VideoInfo>> getVideosByCategory(
    String category, {
    int page = 1,
    int pageSize = 20,
  }) async => [];

  @override
  Future<List<VideoInfo>> getRanking({
    String? category,
    int page = 1,
    int pageSize = 20,
  }) async {
    if (throwOnRanking) {
      throw Exception('Ranking error');
    }
    return rankingResult;
  }

  @override
  Future<List<VideoInfo>> getLatest({int page = 1, int pageSize = 20}) async {
    if (throwOnLatest) {
      throw Exception('Latest error');
    }
    return latestResult;
  }
}

void main() {
  /// VideoRepository - searchVideo 测试组
  /// 测试多数据源搜索功能的正确性
  group('VideoRepository - searchVideo', () {
    const keyword = 'test';

    setUp(() {
      AppLogger().initialize();
    });

    /// 测试场景：三个数据源都返回结果
    /// 验证点：所有源的结果都被正确合并
    test('返回合并后所有数据源的结果', () async {
      final mockBtSource = MockVideoDataSource(
        config: const DataSourceConfig(
          id: 'bt',
          name: 'BT',
          type: SourceType.torrent,
        ),
        searchResult: [
          const VideoInfo(id: 'bt1', title: 'BT Video', sourceType: 'mikan'),
        ],
      );
      final mockBtBackupSource = MockVideoDataSource(
        config: const DataSourceConfig(
          id: 'bt-backup',
          name: 'BT Backup',
          type: SourceType.torrent,
        ),
        searchResult: [
          const VideoInfo(id: 'dmhy1', title: 'DMHY Video', sourceType: 'dmhy'),
        ],
      );
      final mockOnlineSource = MockVideoDataSource(
        config: const DataSourceConfig(
          id: 'online',
          name: 'Online',
          type: SourceType.online,
        ),
        searchResult: [
          const VideoInfo(
            id: 'online1',
            title: 'Online Video',
            sourceType: 'anispace',
          ),
        ],
      );

      final videoRepository = VideoRepository(
        btSource: mockBtSource,
        btBackupSource: mockBtBackupSource,
        onlineSource: mockOnlineSource,
      );

      final result = await videoRepository.searchVideo(keyword);

      // 验证三个源的结果都被合并
      expect(result.length, 3);
      expect(result.any((v) => v.id == 'bt1'), isTrue);
      expect(result.any((v) => v.id == 'dmhy1'), isTrue);
      expect(result.any((v) => v.id == 'online1'), isTrue);
    });

    /// 测试场景：BT源失败，在线源成功
    /// 验证点：单个源失败不影响其他源，返回可用结果
    test('一个数据源失败时返回其他源的可用结果', () async {
      final mockBtSource = MockVideoDataSource(
        config: const DataSourceConfig(
          id: 'bt',
          name: 'BT',
          type: SourceType.torrent,
        ),
        throwOnSearch: true,
        searchError: Exception('BT source error'),
      );
      final mockBtBackupSource = MockVideoDataSource(
        config: const DataSourceConfig(
          id: 'bt-backup',
          name: 'BT Backup',
          type: SourceType.torrent,
        ),
        searchResult: [
          const VideoInfo(id: 'dmhy1', title: 'DMHY Video', sourceType: 'dmhy'),
        ],
      );
      final mockOnlineSource = MockVideoDataSource(
        config: const DataSourceConfig(
          id: 'online',
          name: 'Online',
          type: SourceType.online,
        ),
        searchResult: [
          const VideoInfo(
            id: 'online1',
            title: 'Online Video',
            sourceType: 'anispace',
          ),
        ],
      );

      final videoRepository = VideoRepository(
        btSource: mockBtSource,
        btBackupSource: mockBtBackupSource,
        onlineSource: mockOnlineSource,
      );

      final result = await videoRepository.searchVideo(keyword);

      // 验证失败源不影响其他源
      expect(result.length, 2);
      expect(result.any((v) => v.id == 'dmhy1'), isTrue);
      expect(result.any((v) => v.id == 'online1'), isTrue);
    });

    /// 测试场景：所有数据源都失败
    /// 验证点：返回空列表而不是抛出异常
    test('所有数据源失败时返回空列表', () async {
      final mockBtSource = MockVideoDataSource(
        config: const DataSourceConfig(
          id: 'bt',
          name: 'BT',
          type: SourceType.torrent,
        ),
        throwOnSearch: true,
        searchError: Exception('BT error'),
      );
      final mockBtBackupSource = MockVideoDataSource(
        config: const DataSourceConfig(
          id: 'bt-backup',
          name: 'BT Backup',
          type: SourceType.torrent,
        ),
        throwOnSearch: true,
        searchError: Exception('DMHY error'),
      );
      final mockOnlineSource = MockVideoDataSource(
        config: const DataSourceConfig(
          id: 'online',
          name: 'Online',
          type: SourceType.online,
        ),
        throwOnSearch: true,
        searchError: Exception('Online error'),
      );

      final videoRepository = VideoRepository(
        btSource: mockBtSource,
        btBackupSource: mockBtBackupSource,
        onlineSource: mockOnlineSource,
      );

      final result = await videoRepository.searchVideo(keyword);

      expect(result, isEmpty);
    });

    /// 测试场景：所有数据源都返回空结果
    /// 验证点：返回空列表，不抛异常
    test('所有数据源返回空结果时返回空列表', () async {
      final mockBtSource = MockVideoDataSource(
        config: const DataSourceConfig(
          id: 'bt',
          name: 'BT',
          type: SourceType.torrent,
        ),
        searchResult: const [],
      );
      final mockBtBackupSource = MockVideoDataSource(
        config: const DataSourceConfig(
          id: 'bt-backup',
          name: 'BT Backup',
          type: SourceType.torrent,
        ),
        searchResult: const [],
      );
      final mockOnlineSource = MockVideoDataSource(
        config: const DataSourceConfig(
          id: 'online',
          name: 'Online',
          type: SourceType.online,
        ),
        searchResult: const [],
      );

      final videoRepository = VideoRepository(
        btSource: mockBtSource,
        btBackupSource: mockBtBackupSource,
        onlineSource: mockOnlineSource,
      );

      final result = await videoRepository.searchVideo(keyword);

      expect(result, isEmpty);
    });
  });

  /// VideoRepository - getVideoDetailFromSource 测试组
  /// 测试按指定源获取视频详情的功能
  group('VideoRepository - getVideoDetailFromSource', () {
    const videoId = 'test-id';

    setUp(() {
      AppLogger().initialize();
    });

    /// 测试场景：指定从 Mikan 获取详情
    /// 验证点：正确调用 Mikan 源并返回结果
    test('指定Mikan源时正确获取视频详情', () async {
      const expectedDetail = VideoInfo(
        id: videoId,
        title: 'Mikan Video',
        sourceType: 'mikan',
        episodes: [
          EpisodeInfo(
            id: 'ep1',
            title: 'Ep 1',
            episodeNumber: 1,
            sourceType: 'mikan',
          ),
        ],
      );

      final mockBtSource = MockVideoDataSource(
        config: const DataSourceConfig(
          id: 'bt',
          name: 'BT',
          type: SourceType.torrent,
        ),
        getDetailResult: expectedDetail,
      );

      final videoRepository = VideoRepository(btSource: mockBtSource);

      final result = await videoRepository.getVideoDetailFromSource(
        videoId,
        'mikan',
      );

      expect(result?.id, expectedDetail.id);
      expect(result?.title, expectedDetail.title);
    });

    /// 测试场景：指定从 DMHY 获取详情
    /// 验证点：正确调用 DMHY 源并返回结果
    test('指定DMHY源时正确获取视频详情', () async {
      const expectedDetail = VideoInfo(
        id: videoId,
        title: 'DMHY Video',
        sourceType: 'dmhy',
        episodes: [
          EpisodeInfo(
            id: 'ep1',
            title: 'Ep 1',
            episodeNumber: 1,
            sourceType: 'dmhy',
          ),
        ],
      );

      final mockBtBackupSource = MockVideoDataSource(
        config: const DataSourceConfig(
          id: 'bt-backup',
          name: 'BT Backup',
          type: SourceType.torrent,
        ),
        getDetailResult: expectedDetail,
      );

      final videoRepository = VideoRepository(
        btBackupSource: mockBtBackupSource,
      );

      final result = await videoRepository.getVideoDetailFromSource(
        videoId,
        'dmhy',
      );

      expect(result?.id, expectedDetail.id);
      expect(result?.title, expectedDetail.title);
    });

    /// 测试场景：指定从 AniSpace 获取详情
    /// 验证点：正确调用 AniSpace 源并返回结果
    test('指定AniSpace源时正确获取视频详情', () async {
      const expectedDetail = VideoInfo(
        id: videoId,
        title: 'AniSpace Video',
        sourceType: 'anispace',
        episodes: [
          EpisodeInfo(
            id: 'ep1',
            title: 'Ep 1',
            episodeNumber: 1,
            sourceType: 'anispace',
          ),
        ],
      );

      final mockOnlineSource = MockVideoDataSource(
        config: const DataSourceConfig(
          id: 'online',
          name: 'Online',
          type: SourceType.online,
        ),
        getDetailResult: expectedDetail,
      );

      final videoRepository = VideoRepository(onlineSource: mockOnlineSource);

      final result = await videoRepository.getVideoDetailFromSource(
        videoId,
        'anispace',
      );

      expect(result?.id, expectedDetail.id);
      expect(result?.title, expectedDetail.title);
    });

    /// 测试场景：指定源失败，自动降级到备用源
    /// 验证点：Mikan 失败后自动尝试 DMHY
    test('指定源失败时自动降级到备用源', () async {
      const expectedDetail = VideoInfo(
        id: videoId,
        title: 'DMHY Video',
        sourceType: 'dmhy',
        episodes: [
          EpisodeInfo(
            id: 'ep1',
            title: 'Ep 1',
            episodeNumber: 1,
            sourceType: 'dmhy',
          ),
        ],
      );

      final mockBtSource = MockVideoDataSource(
        config: const DataSourceConfig(
          id: 'bt',
          name: 'BT',
          type: SourceType.torrent,
        ),
        throwOnGetDetail: true,
        getDetailError: Exception('Mikan error'),
      );
      final mockBtBackupSource = MockVideoDataSource(
        config: const DataSourceConfig(
          id: 'bt-backup',
          name: 'BT Backup',
          type: SourceType.torrent,
        ),
        getDetailResult: expectedDetail,
      );

      final videoRepository = VideoRepository(
        btSource: mockBtSource,
        btBackupSource: mockBtBackupSource,
      );

      final result = await videoRepository.getVideoDetailFromSource(
        videoId,
        'mikan',
      );

      // 验证自动降级到备用源
      expect(result?.id, expectedDetail.id);
    });

    /// 测试场景：所有源都失败
    /// 验证点：返回 null 而不是抛出异常
    test('所有数据源失败时返回null', () async {
      final mockBtSource = MockVideoDataSource(
        config: const DataSourceConfig(
          id: 'bt',
          name: 'BT',
          type: SourceType.torrent,
        ),
        throwOnGetDetail: true,
        getDetailError: Exception('Mikan error'),
      );
      final mockBtBackupSource = MockVideoDataSource(
        config: const DataSourceConfig(
          id: 'bt-backup',
          name: 'BT Backup',
          type: SourceType.torrent,
        ),
        throwOnGetDetail: true,
        getDetailError: Exception('DMHY error'),
      );
      final mockOnlineSource = MockVideoDataSource(
        config: const DataSourceConfig(
          id: 'online',
          name: 'Online',
          type: SourceType.online,
        ),
        throwOnGetDetail: true,
        getDetailError: Exception('Online error'),
      );

      final videoRepository = VideoRepository(
        btSource: mockBtSource,
        btBackupSource: mockBtBackupSource,
        onlineSource: mockOnlineSource,
      );

      final result = await videoRepository.getVideoDetailFromSource(
        videoId,
        null,
      );

      expect(result, isNull);
    });
  });

  /// VideoRepository - getVideoList 测试组
  /// 测试获取视频列表功能
  group('VideoRepository - getVideoList', () {
    setUp(() {
      AppLogger().initialize();
    });

    /// 测试场景：正常获取视频列表
    /// 验证点：正确调用元数据源并返回结果
    test('正确获取视频列表', () async {
      final expectedList = <VideoInfo>[
        const VideoInfo(id: '1', title: 'Video 1', sourceType: 'bangumi'),
      ];

      final mockMetaSource = MockVideoDataSource(
        config: const DataSourceConfig(
          id: 'meta',
          name: 'Meta',
          type: SourceType.online,
        ),
        latestResult: expectedList,
      );

      final videoRepository = VideoRepository(metaSource: mockMetaSource);

      final result = await videoRepository.getVideoList(VideoType.anime);

      expect(result.length, 1);
      expect(result[0].id, '1');
    });

    /// 测试场景：获取视频列表失败
    /// 验证点：返回空列表而不是抛出异常
    test('获取视频列表失败时返回空列表', () async {
      final mockMetaSource = MockVideoDataSource(
        config: const DataSourceConfig(
          id: 'meta',
          name: 'Meta',
          type: SourceType.online,
        ),
        throwOnLatest: true,
      );

      final videoRepository = VideoRepository(metaSource: mockMetaSource);

      final result = await videoRepository.getVideoList(VideoType.anime);

      expect(result, isEmpty);
    });
  });

  /// VideoRepository - getRanking 测试组
  /// 测试获取排行榜功能
  group('VideoRepository - getRanking', () {
    setUp(() {
      AppLogger().initialize();
    });

    /// 测试场景：正常获取排行榜
    /// 验证点：正确调用元数据源并返回排行榜数据
    test('正确获取排行榜数据', () async {
      final expectedList = <VideoInfo>[
        const VideoInfo(id: '1', title: 'Top 1', sourceType: 'bangumi'),
      ];

      final mockMetaSource = MockVideoDataSource(
        config: const DataSourceConfig(
          id: 'meta',
          name: 'Meta',
          type: SourceType.online,
        ),
        rankingResult: expectedList,
      );

      final videoRepository = VideoRepository(metaSource: mockMetaSource);

      final result = await videoRepository.getRanking();

      expect(result.length, 1);
      expect(result[0].id, '1');
    });

    /// 测试场景：获取排行榜失败
    /// 验证点：返回空列表而不是抛出异常
    test('获取排行榜失败时返回空列表', () async {
      final mockMetaSource = MockVideoDataSource(
        config: const DataSourceConfig(
          id: 'meta',
          name: 'Meta',
          type: SourceType.online,
        ),
        throwOnRanking: true,
      );

      final videoRepository = VideoRepository(metaSource: mockMetaSource);

      final result = await videoRepository.getRanking();

      expect(result, isEmpty);
    });
  });
}
