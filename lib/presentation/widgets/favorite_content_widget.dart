import 'package:flutter/material.dart';
import 'package:wizardplayer/core/l10n/app_localizations.dart';

/// 收藏页面内容组件
class FavoriteContentWidget extends StatelessWidget {
  const FavoriteContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Theme.of(context).hintColor,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noResults,
            style: TextStyle(color: Theme.of(context).hintColor, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
