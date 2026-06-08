/// 语言枚举
///
/// 定义应用支持的语言
///
/// @author AmisKwok
library;

/// 应用语言枚举
enum AppLanguage {
  /// 英语
  english('en', 'English'),

  /// 简体中文
  chinese('zh', '中文');

  /// 语言代码
  final String code;

  /// 语言名称
  final String name;

  const AppLanguage(this.code, this.name);

  /// 从语言代码获取语言枚举
  static AppLanguage fromCode(String code) {
    // 处理中文方言，都视为简体中文
    if (code.startsWith('zh')) {
      if (code == 'zh_TW' || code == 'zh_HK' || code == 'zh_MO') {
        return english;
      } else {
        return chinese;
      }
    }
    // 其他语言默认返回英语
    return supportedLanguages.firstWhere(
      (language) => language.code == code,
      orElse: () => english,
    );
  }

  /// 支持的语言列表
  static List<AppLanguage> get supportedLanguages => [
        english,
        chinese,
      ];
}
