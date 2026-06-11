import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amis_flutter_utils/utils.dart';
import 'package:wizardplayer/core/l10n/app_localizations.dart';
import 'package:wizardplayer/core/abstractions/di.dart';
import 'package:wizardplayer/core/abstractions/nav.dart';
import 'package:wizardplayer/data/repositories/video_repository.dart';
import 'package:wizardplayer/presentation/screens/subject_detail_screen.dart';
import 'package:wizardplayer/presentation/screens/search_screen.dart';
import 'package:wizardplayer/presentation/widgets/home_content_widget.dart';
import 'package:wizardplayer/presentation/widgets/discover_content_widget.dart';
import 'package:wizardplayer/presentation/widgets/history_content_widget.dart';
import 'package:wizardplayer/presentation/widgets/favorite_content_widget.dart';
import 'package:wizardplayer/core/widgets/video_grid.dart';
import 'package:wizardplayer/core/managers/theme_manager.dart';
import 'package:wizardplayer/core/managers/language_manager.dart';
import 'package:wizardplayer/enum/language.dart';
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

  // 排行榜数据
  List<VideoGridItem> _rankingList = [];
  bool _rankingLoading = true;

  // 最新番剧数据
  List<VideoGridItem> _latestList = [];
  bool _latestLoading = true;

  // 每日放送数据
  final Map<String, List<VideoGridItem>> _calendarData = {};
  bool _calendarLoading = true;

  @override
  void initState() {
    super.initState();
    // 并行加载所有数据，但页面结构立即显示
    _loadRanking();
    _loadLatest();
    _loadCalendar();
  }

  Future<void> _loadRanking() async {
    try {
      final videoRepository = DI.get<VideoRepository>();
      final videos = await videoRepository.getRanking();
      if (mounted) {
        setState(() {
          _rankingList = videos.map((video) {
            return VideoGridItem(
              title: video.title,
              subtitle: video.subtitle,
              coverUrl: video.coverUrl,
              rating: video.rating,
              viewCount: video.viewCount?.toString(),
              tags: video.tags.take(3).toList(),
              onTap: () =>
                  Nav.to(() => SubjectDetailScreen(subjectId: video.id)),
            );
          }).toList();
          _rankingLoading = false;
        });
      }
      AppLogger().d('排行榜数据加载完成: ${_rankingList.length}');
    } catch (e, stackTrace) {
      AppLogger().e('排行榜加载失败', error: e, stackTrace: stackTrace);
      if (mounted) setState(() => _rankingLoading = false);
    }
  }

  Future<void> _loadLatest() async {
    try {
      final videoRepository = DI.get<VideoRepository>();
      final videos = await videoRepository.getLatest();
      if (mounted) {
        setState(() {
          _latestList = videos.map(_videoInfoToGridItem).toList();
          _latestLoading = false;
        });
      }
      AppLogger().d('最新番剧数据加载完成: ${_latestList.length}');
    } catch (e, stackTrace) {
      AppLogger().e('最新番剧加载失败', error: e, stackTrace: stackTrace);
      if (mounted) setState(() => _latestLoading = false);
    }
  }

  Future<void> _loadCalendar() async {
    try {
      // TODO: 调用日历接口
      if (mounted) {
        setState(() => _calendarLoading = false);
      }
    } catch (e, stackTrace) {
      AppLogger().e('每日放送加载失败', error: e, stackTrace: stackTrace);
      if (mounted) setState(() => _calendarLoading = false);
    }
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
      onTap: () => Nav.to(() => SubjectDetailScreen(subjectId: info.id)),
    );
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
              Nav.to(() => const SearchScreen());
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
    switch (_selectedIndex) {
      case 0:
        return HomeContentWidget(
          latestList: _latestList,
          rankingList: _rankingList,
          calendarData: _calendarData,
          latestLoading: _latestLoading,
          rankingLoading: _rankingLoading,
          calendarLoading: _calendarLoading,
        );
      case 1:
        return const DiscoverContentWidget();
      case 2:
        return const HistoryContentWidget();
      case 3:
        return const FavoriteContentWidget();
      default:
        return HomeContentWidget(
          latestList: _latestList,
          rankingList: _rankingList,
          calendarData: _calendarData,
          latestLoading: _latestLoading,
          rankingLoading: _rankingLoading,
          calendarLoading: _calendarLoading,
        );
    }
  }

  /// 显示设置对话框
  void _showSettingsDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeManager = DI.get<ThemeManager>();
    final languageManager = DI.get<LanguageManager>();

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
              GetBuilder<ThemeManager>(
                init: themeManager,
                builder: (_) {
                  final isDark =
                      themeManager.themeMode.value == ThemeMode.dark ||
                      (themeManager.themeMode.value == ThemeMode.system &&
                          MediaQuery.of(context).platformBrightness ==
                              Brightness.dark);
                  return ListTile(
                    leading: const Icon(Icons.dark_mode),
                    title: Text(l10n.darkMode),
                    trailing: Switch(
                      value: isDark,
                      onChanged: (value) {
                        themeManager.changeTheme(
                          value ? ThemeMode.dark : ThemeMode.light,
                        );
                      },
                    ),
                  );
                },
              ),
              const Divider(),
              // 语言设置
              GetBuilder<LanguageManager>(
                init: languageManager,
                builder: (_) {
                  return ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(l10n.language),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          languageManager.language.value == AppLanguage.chinese
                              ? '中文'
                              : 'English',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () {
                      _showLanguageDialog(context, languageManager, l10n);
                    },
                  );
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
                  _showAboutDialog(context, l10n);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// 显示语言选择对话框
  void _showLanguageDialog(
    BuildContext context,
    LanguageManager languageManager,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.language),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(l10n.chinese),
                leading: Radio<AppLanguage>(
                  value: AppLanguage.chinese,
                  groupValue: languageManager.language.value,
                ),
                onTap: () {
                  languageManager.changeLanguage(AppLanguage.chinese);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(l10n.english),
                leading: Radio<AppLanguage>(
                  value: AppLanguage.english,
                  groupValue: languageManager.language.value,
                ),
                onTap: () {
                  languageManager.changeLanguage(AppLanguage.english);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// 显示关于对话框
  void _showAboutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.about),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wizard Player',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text('v1.0.0', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              Text(
                l10n.appDescription,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.ok),
            ),
          ],
        );
      },
    );
  }
}
