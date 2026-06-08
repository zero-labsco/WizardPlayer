import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amis_flutter_utils/utils.dart';
import 'package:wizardplayer/core/l10n/app_localizations.dart';
import 'package:wizardplayer/core/widgets/video_grid.dart';
import 'package:wizardplayer/core/services/play_history_service.dart';
import 'package:wizardplayer/data/repositories/video_repository.dart';
import 'package:wizardplayer/presentation/screens/search_screen.dart';
import 'package:wizardplayer/presentation/screens/subject_detail_screen.dart';
import 'package:wizardplayer/presentation/screens/player_screen.dart';
import 'package:wizard_player_datasource/wizard_player_datasource.dart';

/// 首页 - 自适应布局
/// 移动端：底部导航 + 单列内容
/// 桌面端：侧边导航 + 网格内容
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;

  // 排行榜数据
  List<VideoGridItem> _rankingList = [];

  // 最新番剧数据
  List<VideoGridItem> _latestList = [];

  // 每日放送数据
  final Map<String, List<VideoGridItem>> _calendarData = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// 将 VideoInfo 转换为 VideoGridItem
  VideoGridItem _videoInfoToGridItem(VideoInfo info) {
    return VideoGridItem(
      title: info.title,
      subtitle: info.subtitle ?? '',
      coverUrl: info.coverUrl ?? '',
      rating: info.rating,
      viewCount: info.viewCount?.toString(),
      tags: info.tags.take(3).toList(),
      onTap: () => Get.to(() => SubjectDetailScreen(subjectId: info.id)),
    );
  }

  Future<void> _loadData() async {
    try {
      final videoRepository = Get.find<VideoRepository>();

      // 并行加载数据
      final results = await Future.wait([
        videoRepository.getRanking(),
        videoRepository.getLatest(),
      ]);

      setState(() {
        // 将 VideoInfo 列表转换为 VideoGridItem（排行榜）
        final rankingVideos = results[0];
        _rankingList = rankingVideos.map((video) {
          return VideoGridItem(
            title: video.title,
            subtitle: video.subtitle,
            coverUrl: video.coverUrl,
            rating: video.rating,
            viewCount: video.viewCount?.toString(),
            tags: video.tags.take(3).toList(),
            onTap: () => Get.to(() => SubjectDetailScreen(subjectId: video.id)),
          );
        }).toList();

        // 将 VideoInfo 列表转换为 VideoGridItem（最新番剧）
        final latestVideos = results[1];
        _latestList = latestVideos.map(_videoInfoToGridItem).toList();

        _isLoading = false;
      });

      AppLogger().d(
        '首页数据加载完成，排行榜: ${_rankingList.length}，最新: ${_latestList.length}',
      );
    } catch (e, stackTrace) {
      AppLogger().e('首页数据加载失败', error: e, stackTrace: stackTrace);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // 桌面端侧边导航
            if (isDesktop || isTablet) _buildNavigationRail(isDesktop),
            // 主内容
            Expanded(
              child: Column(
                children: [
                  // 顶部栏
                  _buildTopBar(context),
                  // 内容区域
                  Expanded(child: _buildContent(context)),
                ],
              ),
            ),
          ],
        ),
      ),
      // 移动端底部导航
      bottomNavigationBar: (isDesktop || isTablet)
          ? null
          : _buildBottomNavigation(),
    );
  }

  /// 构建顶部栏
  Widget _buildTopBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : 16,
        vertical: 16,
      ),
      child: Row(
        children: [
          // Logo / 标题
          Text(
            '🎬 ${l10n.appTitle}',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          // 搜索按钮
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: l10n.search,
            onPressed: () {
              Get.to(() => const SearchScreen());
            },
          ),
          // 设置按钮
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settings,
            onPressed: () {
              _showSettingsDialog(context);
            },
          ),
        ],
      ),
    );
  }

  /// 构建导航轨道（桌面/平板）
  Widget _buildNavigationRail(bool isExtended) {
    final l10n = AppLocalizations.of(context)!;
    return NavigationRail(
      extended: isExtended,
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      leading: Padding(
        padding: EdgeInsets.symmetric(vertical: isExtended ? 24 : 16),
        child: isExtended
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_circle_filled, size: 32),
                  const SizedBox(width: 8),
                  Text(
                    l10n.appTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : const Icon(Icons.play_circle_filled, size: 32),
      ),
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: Text(l10n.home),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.explore_outlined),
          selectedIcon: const Icon(Icons.explore),
          label: Text(l10n.discover),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.history_outlined),
          selectedIcon: const Icon(Icons.history),
          label: Text(l10n.history),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.favorite_outline),
          selectedIcon: const Icon(Icons.favorite),
          label: Text(l10n.favorites),
        ),
      ],
    );
  }

  /// 构建底部导航（移动端）
  Widget _buildBottomNavigation() {
    final l10n = AppLocalizations.of(context)!;
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: const Icon(Icons.home),
          label: l10n.home,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.explore_outlined),
          activeIcon: const Icon(Icons.explore),
          label: l10n.discover,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.history_outlined),
          activeIcon: const Icon(Icons.history),
          label: l10n.history,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.favorite_outline),
          activeIcon: const Icon(Icons.favorite),
          label: l10n.favorites,
        ),
      ],
    );
  }

  /// 构建内容区域
  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent(context);
      case 1:
        return _buildDiscoverContent(context);
      case 2:
        return _buildHistoryContent(context);
      case 3:
        return _buildFavoriteContent(context);
      default:
        return _buildHomeContent(context);
    }
  }

  /// 首页内容
  Widget _buildHomeContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 正在观看
          _buildSectionTitle(context, '📺 ${l10n.continueWatching}'),
          const SizedBox(height: 12),
          _buildWatchingSection(context),
          const SizedBox(height: 32),

          // 最新番剧（来自 VideoRepository）
          if (_latestList.isNotEmpty) ...[
            _buildSectionTitle(context, '✨ ${l10n.latestUpdate}'),
            const SizedBox(height: 12),
            SizedBox(height: 280, child: VideoGrid(items: _latestList)),
            const SizedBox(height: 32),
          ],

          // 每日放送
          _buildSectionTitle(context, '📅 ${l10n.todayUpdate}'),
          const SizedBox(height: 12),
          _buildCalendarSection(context),
          const SizedBox(height: 32),

          // 周排行榜
          _buildSectionTitle(context, '🏆 ${l10n.weeklyRanking}'),
          const SizedBox(height: 12),
          SizedBox(height: 280, child: VideoGrid(items: _rankingList)),
        ],
      ),
    );
  }

  /// 发现页面
  Widget _buildDiscoverContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 搜索框
          GestureDetector(
            onTap: () {
              Get.to(() => const SearchScreen());
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    l10n.searchPlaceholder,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // 测试视频
          _buildTestVideoSection(context),
          const SizedBox(height: 32),

          // 分类
          _buildCategorySection(context),
        ],
      ),
    );
  }

  /// 测试视频区域
  Widget _buildTestVideoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('🧪 测试视频', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 80,
                height: 60,
                color: Colors.blue.shade200,
                child: const Icon(Icons.play_circle_filled, size: 32),
              ),
            ),
            title: const Text('Big Buck Bunny'),
            subtitle: const Text('测试在线视频播放'),
            trailing: ElevatedButton.icon(
              onPressed: () => _playTestVideo(context),
              icon: const Icon(Icons.play_arrow),
              label: const Text('播放'),
            ),
          ),
        ),
      ],
    );
  }

  /// 播放测试视频
  void _playTestVideo(BuildContext context) {
    // 创建测试用的 VideoInfo
    const testVideo = VideoInfo(
      id: 'test_video_001',
      title: '测试视频',
      subtitle: '国内可播放',
      coverUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Big_buck_bunny_poster_big.jpg/220px-Big_buck_bunny_poster_big.jpg',
      sourceType: 'test',
      episodes: [
        EpisodeInfo(
          id: 'test_ep_001',
          title: '测试视频',
          episodeNumber: 1,
          sourceType: 'test',
        ),
      ],
      tags: ['测试', '动画'],
      rating: 5.0,
      viewCount: 1000000,
    );

    // 跳转到播放器
    Get.to(() => const PlayerScreen(video: testVideo, startEpisode: 1));
  }

  /// 历史页面
  Widget _buildHistoryContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final historyManager = Get.find<PlayHistoryManager>();
    final histories = historyManager.histories;

    if (histories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              l10n.noResults,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: histories.length,
      itemBuilder: (context, index) {
        final history = histories[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: history.coverUrl != null
                  ? Image.network(
                      history.coverUrl!,
                      width: 60,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 60,
                      height: 80,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.movie),
                    ),
            ),
            title: Text(
              history.subjectName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.episodeNumber(history.currentEpisode)),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: history.progress,
                  backgroundColor: Colors.grey.shade300,
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () {
                // TODO: 跳转到播放页
              },
            ),
          ),
        );
      },
    );
  }

  /// 收藏页面
  Widget _buildFavoriteContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            l10n.noResults,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  /// 正在观看区域
  Widget _buildWatchingSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final historyManager = Get.find<PlayHistoryManager>();
    final watching = historyManager.getWatching();

    if (watching.isEmpty) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(child: Text(l10n.noResults)),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: watching.length,
        itemBuilder: (context, index) {
          final history = watching[index];
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                // TODO: 跳转到播放页
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: history.coverUrl != null
                            ? Image.network(
                                history.coverUrl!,
                                width: 120,
                                height: 140,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 120,
                                height: 140,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.movie),
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.8),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Text(
                            l10n.episodeNumber(history.currentEpisode),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    history.subjectName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 每日放送区域
  Widget _buildCalendarSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final today = DateTime.now().weekday;
    final weekdays = [
      l10n.sunday,
      l10n.monday,
      l10n.tuesday,
      l10n.wednesday,
      l10n.thursday,
      l10n.friday,
      l10n.saturday,
    ];
    final todayName = weekdays[today == 7 ? 0 : today];

    final todayAnimes = _calendarData[todayName] ?? [];

    if (todayAnimes.isEmpty) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(child: Text(l10n.noUpdateToday)),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: todayAnimes.length,
        itemBuilder: (context, index) {
          final anime = todayAnimes[index];
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: anime.onTap,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: anime.coverUrl != null
                        ? Image.network(
                            anime.coverUrl!,
                            width: 80,
                            height: 70,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 80,
                            height: 70,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.movie),
                          ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    anime.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 分类区域
  Widget _buildCategorySection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = [
      {'icon': '🎬', 'name': l10n.anime},
      {'icon': '🎭', 'name': l10n.movie},
      {'icon': '📺', 'name': l10n.tvSeries},
      {'icon': '🎮', 'name': l10n.category},
      {'icon': '🎵', 'name': l10n.latest},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: categories.map((cat) {
        return InkWell(
          onTap: () {
            // TODO: 跳转到分类页
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: (MediaQuery.of(context).size.width - 48) / 2,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(cat['icon']!, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Text(
                  cat['name']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 区块标题
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }

  /// 显示设置对话框
  void _showSettingsDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 主题设置
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: Text(l10n.darkMode),
                trailing: Switch(
                  value: Theme.of(context).brightness == Brightness.dark,
                  onChanged: (value) {
                    // TODO: 切换主题
                    Navigator.pop(context);
                  },
                ),
              ),
              const Divider(),
              // 语言设置
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.language),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 跳转到语言设置
                },
              ),
              const Divider(),
              // 关于
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.about),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 显示关于信息
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
