import 'dart:convert';
import 'dart:ui';
import '../models/danmaku.dart';

/// 弹幕解析器接口
abstract class DanmakuParser {
  /// 解析弹幕数据
  List<Danmaku> parse(dynamic data);

  /// 弹幕类型
  String get type;
}

/// ASS 字幕格式解析器
class AssParser implements DanmakuParser {
  @override
  String get type => 'ass';

  @override
  List<Danmaku> parse(dynamic data) {
    final danmakuList = <Danmaku>[];
    final lines = data.toString().split('\n');

    for (final line in lines) {
      final trimmed = line.trim();
      if (!trimmed.startsWith('Dialogue:')) continue;

      try {
        final parts = trimmed.substring(9).split(',');
        if (parts.length < 10) continue;

        // 解析时间
        final startTime = _parseAssTime(parts[1].trim());
        final text = parts[9].trim();

        // 解析样式

        danmakuList.add(
          Danmaku(
            id: 'ass_${danmakuList.length}',
            text: _stripAssTags(text),
            time: startTime,
            mode: DanmakuMode.top,
            color: _parseAssColor(parts.length > 3 ? parts[3].trim() : ''),
          ),
        );
      } catch (e) {
        // 跳过无效行
        continue;
      }
    }

    return danmakuList;
  }

  double _parseAssTime(String time) {
    final parts = time.split(':');
    final hours = double.parse(parts[0]);
    final minutes = double.parse(parts[1]);
    final seconds = double.parse(parts[2]);
    return hours * 3600 + minutes * 60 + seconds;
  }

  String _stripAssTags(String text) {
    // 移除 ASS 标签
    return text
        .replaceAll(RegExp(r'\{[^}]*\}'), '')
        .replaceAll(r'\h', ' ')
        .replaceAll(r'\N', '\n');
  }

  Color _parseAssColor(String colorStr) {
    if (colorStr.isEmpty) return DanmakuColors.white;

    try {
      // ASS 颜色格式 &HBBGGRR&
      if (colorStr.startsWith('&H') && colorStr.endsWith('&')) {
        final hex = colorStr.substring(2, colorStr.length - 1);
        final intValue = int.parse(hex, radix: 16);
        final r = (intValue & 0xFF);
        final g = (intValue >> 8) & 0xFF;
        final b = (intValue >> 16) & 0xFF;
        return Color.fromARGB(255, r, g, b);
      }
    } catch (e) {
      // 忽略颜色解析错误
    }
    return DanmakuColors.white;
  }
}

/// 通用格式解析器（支持 JSON、XML 等）
class GeneralParser implements DanmakuParser {
  @override
  String get type => 'general';

  @override
  List<Danmaku> parse(dynamic data) {
    final danmakuList = <Danmaku>[];

    try {
      if (data is String) {
        // 尝试解析为 JSON
        final jsonData = jsonDecode(data);
        if (jsonData is List) {
          for (var i = 0; i < jsonData.length; i++) {
            final item = jsonData[i];
            danmakuList.add(_parseJsonItem(item, 'gen_$i'));
          }
        } else if (jsonData is Map && jsonData.containsKey('data')) {
          final items = jsonData['data'];
          if (items is List) {
            for (var i = 0; i < items.length; i++) {
              final item = items[i];
              danmakuList.add(_parseJsonItem(item, 'gen_$i'));
            }
          }
        }
      } else if (data is List) {
        for (var i = 0; i < data.length; i++) {
          danmakuList.add(_parseJsonItem(data[i], 'gen_$i'));
        }
      }
    } catch (e) {
      // 解析失败，返回空列表
    }

    return danmakuList;
  }

  Danmaku _parseJsonItem(dynamic item, String id) {
    if (item is Map<String, dynamic>) {
      return Danmaku(
        id: item['id']?.toString() ?? id,
        text:
            item['text']?.toString() ??
            item['content']?.toString() ??
            item['message']?.toString() ??
            '',
        time: _parseDouble(item['time'] ?? item['begin'] ?? 0),
        mode: _parseMode(item['mode']),
        fontSize: _parseDouble(item['fontSize'] ?? 25),
        color: _parseColor(item['color']),
        senderId: item['senderId']?.toString() ?? item['user_id']?.toString(),
      );
    }

    // 如果是简单字符串数组，直接使用
    if (item is String) {
      return Danmaku(id: id, text: item, time: 0);
    }

    return Danmaku(id: id, text: '', time: 0);
  }

  double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  DanmakuMode _parseMode(dynamic value) {
    if (value is int) {
      switch (value) {
        case 1:
          return DanmakuMode.rolling;
        case 2:
          return DanmakuMode.top;
        case 3:
          return DanmakuMode.bottom;
        default:
          return DanmakuMode.rolling;
      }
    }
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'rolling':
        case 'scroll':
          return DanmakuMode.rolling;
        case 'top':
        case 'top固定':
          return DanmakuMode.top;
        case 'bottom':
        case 'bottom固定':
          return DanmakuMode.bottom;
      }
    }
    return DanmakuMode.rolling;
  }

  Color _parseColor(dynamic value) {
    if (value is int) {
      return Color(value);
    }
    if (value is String) {
      return DanmakuColors.fromHex(value);
    }
    return DanmakuColors.white;
  }
}

/// 弹幕格式自动检测
class DanmakuParserFactory {
  static final Map<String, DanmakuParser> _parsers = {
    'ass': AssParser(),
    'general': GeneralParser(),
  };

  /// 根据数据自动选择合适的解析器
  static List<Danmaku> parse(dynamic data, {String? hint}) {
    if (hint != null && _parsers.containsKey(hint)) {
      return _parsers[hint]!.parse(data);
    }

    // 自动检测格式
    if (data is String) {
      if (data.contains('Dialogue:')) {
        return _parsers['ass']!.parse(data);
      }
      if (data.trim().startsWith('{')) {
        return _parsers['general']!.parse(data);
      }
    }

    return _parsers['general']!.parse(data);
  }

  /// 注册自定义解析器
  static void register(String type, DanmakuParser parser) {
    _parsers[type] = parser;
  }
}
