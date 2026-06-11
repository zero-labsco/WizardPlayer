import 'dart:convert';
import 'dart:io';

/// 检查中英文 arb 文件一致性脚本
///
/// 检查项：
/// 1. Key 的数量是否一致
/// 2. Key 的顺序是否一致
/// 3. ARB 中的 key 是否在代码中被使用
void main() async {
  print('=== ARB 文件一致性检查 ===\n');

  // 加载中英文 arb 文件
  final zhFile = File('lib/l10n/app_zh.arb');
  final enFile = File('lib/l10n/app_en.arb');

  if (!zhFile.existsSync() || !enFile.existsSync()) {
    print('[错误] arb 文件不存在！');
    return;
  }

  final zhContent =
      json.decode(zhFile.readAsStringSync()) as Map<String, dynamic>;
  final enContent =
      json.decode(enFile.readAsStringSync()) as Map<String, dynamic>;

  // 获取所有 key 列表（排除 locale 字段）
  final zhKeys = zhContent.keys.where((key) => key != '@@locale').toList();
  final enKeys = enContent.keys.where((key) => key != '@@locale').toList();

  // ========== 检查 1: Key 数量和顺序 ==========
  print('--- 检查 1: Key 数量和顺序 ---');

  if (zhKeys.length != enKeys.length) {
    print('[错误] Key 数量不一致：');
    print('  中文有 ${zhKeys.length} 个 key');
    print('  英文有 ${enKeys.length} 个 key');

    final zhOnly = zhKeys.where((k) => !enKeys.contains(k)).toList();
    final enOnly = enKeys.where((k) => !zhKeys.contains(k)).toList();

    if (zhOnly.isNotEmpty) {
      print('  仅在中文中存在: ${zhOnly.join(', ')}');
    }
    if (enOnly.isNotEmpty) {
      print('  仅在英文中存在: ${enOnly.join(', ')}');
    }
  } else {
    // 检查 key 顺序
    final mismatches = <MapEntry<int, String>>[];
    for (var i = 0; i < zhKeys.length; i++) {
      if (zhKeys[i] != enKeys[i]) {
        mismatches.add(MapEntry(i, zhKeys[i]));
      }
    }

    if (mismatches.isEmpty) {
      print('[OK] 所有 key 都对齐了！共 ${zhKeys.length} 个');
    } else {
      print('[错误] Key 顺序不匹配：');
      for (final entry in mismatches) {
        final i = entry.key;
        final zhKey = zhKeys[i];
        final enKey = enKeys[i];
        print('  位置 $i: 中文="$zhKey" vs 英文="$enKey"');
      }
    }
  }

  // ========== 检查 2: 未使用的 key ==========
  print('\n--- 检查 2: 未使用的 key ---');

  // 收集所有代码中使用的 key
  final usedKeys = <String>{};

  // 遍历 lib 目录下的所有 dart 文件
  final libDir = Directory('lib');
  await for (final entity in libDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = await entity.readAsString();
      // 匹配 localizations?.xxx 或 AppLocalizations.of(context)?.xxx 模式
      // 支持带默认值的情况，如 localizations?.xxx ?? 'default'
      final regex = RegExp(
        r'(localizations|AppLocalizations(?:\([^)]*\))?)\?\.\w+',
      );
      for (final match in regex.allMatches(content)) {
        final key = match.group(0)!.replaceFirst(RegExp(r'^.*\?\.'), '');
        usedKeys.add(key);
      }
    }
  }

  // 找出未使用的 key
  final unusedKeys = zhKeys.where((key) => !usedKeys.contains(key)).toList();

  if (unusedKeys.isEmpty) {
    print('[OK] 所有 ARB key 都在代码中被使用');
  } else {
    print('[警告] 以下 ${unusedKeys.length} 个 key 未在代码中使用：');
    for (final key in unusedKeys) {
      print('  - $key');
    }
  }

  print('\n=== 检查完成 ===');
}
