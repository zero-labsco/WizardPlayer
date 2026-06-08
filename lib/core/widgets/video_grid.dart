import 'package:flutter/material.dart';
import 'ani_video_card.dart';
import 'adaptive_layout.dart';

/// 响应式视频网格
class VideoGrid extends StatelessWidget {
  /// 视频列表
  final List<VideoGridItem> items;

  /// 加载更多回调
  final VoidCallback? onLoadMore;

  /// 是否正在加载
  final bool isLoading;

  /// 网格列数配置
  final Map<DeviceType, int>? columnCount;

  /// 网格间距
  final double spacing;

  /// 加载更多指示器
  final Widget? loadMoreIndicator;

  const VideoGrid({
    super.key,
    required this.items,
    this.onLoadMore,
    this.isLoading = false,
    this.columnCount,
    this.spacing = 16,
    this.loadMoreIndicator,
  });

  /// 获取设备类型的列数
  int _getColumnCount(DeviceType deviceType) {
    if (columnCount != null && columnCount!.containsKey(deviceType)) {
      return columnCount![deviceType]!;
    }

    switch (deviceType) {
      case DeviceType.mobile:
        return 2;
      case DeviceType.tablet:
        return 3;
      case DeviceType.desktop:
        return 5;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = AdaptiveLayout.getDeviceType(constraints.maxWidth);
        final crossAxisCount = _getColumnCount(deviceType);

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollEndNotification &&
                notification.metrics.extentAfter < 200 &&
                onLoadMore != null &&
                !isLoading) {
              onLoadMore!();
            }
            return false;
          },
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.all(spacing),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: spacing,
                    crossAxisSpacing: spacing,
                    childAspectRatio: 0.55, // 3:4 比例
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = items[index];
                    return VideoCard(
                      title: item.title,
                      subtitle: item.subtitle,
                      coverUrl: item.coverUrl,
                      rating: item.rating,
                      viewCount: item.viewCount,
                      tags: item.tags,
                      onTap: item.onTap,
                    );
                  }, childCount: items.length),
                ),
              ),
              // 加载更多指示器
              if (isLoading || loadMoreIndicator != null)
                SliverToBoxAdapter(
                  child: Center(
                    child:
                        loadMoreIndicator ??
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// 视频网格项
class VideoGridItem {
  /// 标题
  final String title;

  /// 副标题
  final String? subtitle;

  /// 封面图片 URL
  final String? coverUrl;

  /// 评分
  final double? rating;

  /// 观看人数
  final String? viewCount;

  /// 标签
  final List<String> tags;

  /// 点击回调
  final VoidCallback? onTap;

  const VideoGridItem({
    required this.title,
    this.subtitle,
    this.coverUrl,
    this.rating,
    this.viewCount,
    this.tags = const [],
    this.onTap,
  });
}
