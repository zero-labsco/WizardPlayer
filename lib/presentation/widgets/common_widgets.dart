import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wizardplayer/core/theme/app_colors.dart';

/// 区块标题组件
class SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionTitle({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// 带加载状态的区块组件
class LoadingSection extends StatelessWidget {
  final bool isLoading;
  final double height;
  final Widget child;

  const LoadingSection({
    super.key,
    required this.isLoading,
    this.height = 200,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: height,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    return child;
  }
}

/// 空状态组件
class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final double? height;
  final BorderRadius? borderRadius;

  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).disabledColor),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Theme.of(context).disabledColor),
            ),
          ],
        ),
      ),
    );
  }
}

/// 网络图片组件（封装 CachedNetworkImage）
/// 使用 NetImg 避免与 Flutter 内置 NetworkImage 冲突
class NetImg extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const NetImg({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final defaultPlaceholder = Container(
      width: width,
      height: height,
      color: AppColors.grey300,
      child: const Icon(Icons.image, color: AppColors.grey600),
    );

    final defaultErrorWidget = Container(
      width: width,
      height: height,
      color: AppColors.grey300,
      child: const Icon(Icons.broken_image, color: AppColors.grey600),
    );

    Widget image;
    if (imageUrl == null || imageUrl!.isEmpty) {
      image = placeholder ?? defaultPlaceholder;
    } else {
      image = CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, __) => placeholder ?? defaultPlaceholder,
        errorWidget: (_, __, ___) => errorWidget ?? defaultErrorWidget,
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }
}
