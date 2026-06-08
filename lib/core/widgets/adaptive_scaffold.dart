import 'package:flutter/material.dart';
import 'adaptive_layout.dart';

/// 自适应脚手架组件
class AdaptiveScaffold extends StatelessWidget {
  /// 标题
  final String? title;

  /// 导航项
  final List<AdaptiveNavigationItem> navigationItems;

  /// 当前选中索引
  final int selectedIndex;

  /// 导航选中回调
  final ValueChanged<int> onNavigationSelected;

  /// 主体内容
  final Widget body;

  /// 浮动操作按钮
  final Widget? floatingActionButton;

  const AdaptiveScaffold({
    super.key,
    this.title,
    required this.navigationItems,
    required this.selectedIndex,
    required this.onNavigationSelected,
    required this.body,
    this.floatingActionButton,
  });

  /// 底部导航栏（移动端）
  Widget _buildBottomNavigation(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onNavigationSelected,
      destinations: navigationItems.map((item) {
        return NavigationDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.selectedIcon),
          label: item.label,
        );
      }).toList(),
    );
  }

  /// 侧边导航栏（桌面端）
  Widget _buildSideNavigation(BuildContext context) {
    return NavigationRail(
      extended: MediaQuery.of(context).size.width > 1400,
      selectedIndex: selectedIndex,
      onDestinationSelected: onNavigationSelected,
      leading: title != null
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                title!,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            )
          : null,
      destinations: navigationItems.map((item) {
        return NavigationRailDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.selectedIcon),
          label: Text(item.label),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 平板及以上使用侧边导航
        if (constraints.maxWidth >= Breakpoints.tablet) {
          return Row(
            children: [
              _buildSideNavigation(context),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: body),
            ],
          );
        }

        // 手机使用底部导航
        return Scaffold(
          appBar: title != null
              ? AppBar(title: Text(title!), centerTitle: false)
              : null,
          body: body,
          bottomNavigationBar: _buildBottomNavigation(context),
          floatingActionButton: floatingActionButton,
        );
      },
    );
  }
}
