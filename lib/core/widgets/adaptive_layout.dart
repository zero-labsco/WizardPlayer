import 'package:flutter/material.dart';

/// 设备类型
enum DeviceType {
  /// 手机
  mobile,

  /// 平板
  tablet,

  /// 桌面
  desktop,
}

/// 屏幕尺寸断点
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1200;
}

/// 自适应布局 Widget
class AdaptiveLayout extends StatelessWidget {
  /// 移动端布局
  final Widget mobile;

  /// 平板布局
  final Widget? tablet;

  /// 桌面端布局
  final Widget desktop;

  /// 当前设备类型
  final DeviceType? forcedDevice;

  const AdaptiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
    this.forcedDevice,
  });

  /// 根据屏幕宽度获取设备类型
  static DeviceType getDeviceType(double width) {
    if (width < Breakpoints.mobile) {
      return DeviceType.mobile;
    } else if (width < Breakpoints.tablet) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  @override
  Widget build(BuildContext context) {
    final device =
        forcedDevice ?? getDeviceType(MediaQuery.of(context).size.width);

    switch (device) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? desktop;
      case DeviceType.desktop:
        return desktop;
    }
  }
}

/// 自适应 builder
class AdaptiveBuilder extends StatelessWidget {
  /// 构建器函数
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  /// 当前设备类型
  final DeviceType? forcedDevice;

  const AdaptiveBuilder({super.key, required this.builder, this.forcedDevice});

  @override
  Widget build(BuildContext context) {
    final device =
        forcedDevice ??
        AdaptiveLayout.getDeviceType(MediaQuery.of(context).size.width);
    return builder(context, device);
  }
}

/// 响应式 builder
class ResponsiveBuilder extends StatelessWidget {
  /// 小屏幕布局（< 600）
  final Widget Function(BuildContext context)? small;

  /// 中等屏幕布局（600 - 1200）
  final Widget Function(BuildContext context)? medium;

  /// 大屏幕布局（> 1200）
  final Widget Function(BuildContext context)? large;

  /// 通用布局（所有尺寸）
  final Widget Function(BuildContext context)? builder;

  const ResponsiveBuilder({
    super.key,
    this.small,
    this.medium,
    this.large,
    this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (builder != null) {
      return builder!(context);
    }

    if (width < Breakpoints.mobile && small != null) {
      return small!(context);
    } else if (width < Breakpoints.tablet && medium != null) {
      return medium!(context);
    } else if (large != null) {
      return large!(context);
    }

    // 默认返回大屏幕布局
    return large!(context);
  }
}

/// 导航类型
enum NavigationType {
  /// 底部导航（移动端）
  bottom,

  /// 侧边导航（桌面端）
  side,

  /// 顶部导航
  top,
}

/// 自适应导航布局
class AdaptiveNavigation extends StatelessWidget {
  /// 导航项
  final List<AdaptiveNavigationItem> items;

  /// 当前选中索引
  final int selectedIndex;

  /// 选中回调
  final ValueChanged<int> onSelected;

  /// 导航类型
  NavigationType get navigationType {
    final width = MediaQuery.of(this as BuildContext).size.width;
    return width >= Breakpoints.tablet
        ? NavigationType.side
        : NavigationType.bottom;
  }

  const AdaptiveNavigation({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.tablet) {
          // 桌面端：侧边导航
          return NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onSelected,
            labelType: NavigationRailLabelType.all,
            destinations: items.map((item) {
              return NavigationRailDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: Text(item.label),
              );
            }).toList(),
          );
        } else {
          // 移动端：底部导航
          return NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onSelected,
            destinations: items.map((item) {
              return NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: item.label,
              );
            }).toList(),
          );
        }
      },
    );
  }
}

/// 导航项数据
class AdaptiveNavigationItem {
  /// 图标
  final IconData icon;

  /// 选中图标
  final IconData selectedIcon;

  /// 标签
  final String label;

  /// 提示
  final String? tooltip;

  const AdaptiveNavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.tooltip,
  });
}
