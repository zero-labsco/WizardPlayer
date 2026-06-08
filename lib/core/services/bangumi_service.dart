import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:amis_flutter_utils/utils.dart';
import 'bangumi_models.dart';

/// Bangumi API 服务
/// 官方 API 文档：https://bangumi.github.io/api/
class BangumiService extends GetxService {
  /// API 基础地址
  static const String _baseUrl = 'https://api.bgm.tv';

  /// Dio 实例
  late final Dio _dio;

  /// 用户访问令牌（可选）
  String? _accessToken;

  /// 初始化服务
  Future<BangumiService> init({String? accessToken}) async {
    _accessToken = accessToken;

    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'WizardPlayer/1.0',
        },
      ),
    );

    // 添加响应拦截器
    _dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          AppLogger().d('Bangumi API 响应: ${response.requestOptions.path}');
          handler.next(response);
        },
        onError: (error, handler) {
          AppLogger().e('Bangumi API 错误: ${error.message}');
          handler.next(error);
        },
      ),
    );

    AppLogger().d('BangumiService 初始化完成');
    return this;
  }

  /// 设置访问令牌
  void setAccessToken(String token) {
    _accessToken = token;
  }

  /// 清除访问令牌
  void clearAccessToken() {
    _accessToken = null;
  }

  /// 搜索番剧
  /// [keyword] 搜索关键词
  /// [type] 类型：1=动画、2=书籍、3=音乐、4=游戏、6=三次元
  /// [responseGroup] 返回数据量：small、medium、large
  Future<BangumiSearchResult> searchSubject(
    String keyword, {
    int page = 1,
    int type = 1,
    String responseGroup = 'medium',
  }) async {
    try {
      final response = await _dio.get(
        '/search/subject',
        queryParameters: {
          'keyword': keyword,
          'type': type,
          'responseGroup': responseGroup,
          'page': page,
          'max_results': 20,
        },
      );

      return BangumiSearchResult.fromJson(response.data);
    } on DioException catch (e) {
      AppLogger().e('搜索失败: ${e.message}');
      return const BangumiSearchResult(
        list: [],
        total: 0,
        page: 1,
        pageSize: 20,
      );
    }
  }

  /// 获取番剧详情
  /// [id] 番剧 ID
  /// [responseGroup] 返回数据量：small、medium、large
  Future<BangumiSubject?> getSubjectDetail(
    int id, {
    String responseGroup = 'medium',
  }) async {
    try {
      final response = await _dio.get(
        '/subject/$id',
        queryParameters: {'responseGroup': responseGroup},
      );

      return BangumiSubject.fromJson(response.data);
    } on DioException catch (e) {
      AppLogger().e('获取详情失败: ${e.message}');
      return null;
    }
  }

  /// 获取正在观看的番剧列表
  Future<List<BangumiCollection>> getWatchingCollection() async {
    if (_accessToken == null) {
      AppLogger().w('未登录，无法获取收藏信息');
      return [];
    }

    try {
      final response = await _dio.get(
        '/user/$_accessToken/collection',
        queryParameters: {'status': 'watching', 'type': 1},
      );

      final data = response.data as List<dynamic>? ?? [];
      return data
          .map((e) => BangumiCollection.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      AppLogger().e('获取收藏列表失败: $e');
      return [];
    }
  }

  /// 获取用户的所有收藏
  Future<List<BangumiCollection>> getAllCollection() async {
    if (_accessToken == null) {
      return [];
    }

    try {
      final response = await _dio.get(
        '/user/$_accessToken/collection',
        queryParameters: {'type': 1},
      );

      final data = response.data as List<dynamic>? ?? [];
      return data
          .map((e) => BangumiCollection.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      AppLogger().e('获取收藏列表失败: $e');
      return [];
    }
  }

  /// 更新观看进度
  Future<bool> updateProgress(int subjectId, int episode) async {
    if (_accessToken == null) {
      // 未登录时保存到本地
      await _saveLocalProgress(subjectId, episode);
      return true;
    }

    try {
      await _dio.post(
        '/subject/$subjectId/update',
        data: {'ep_id': episode, 'status': 'watching'},
      );
      return true;
    } on DioException catch (e) {
      AppLogger().e('更新进度失败: ${e.message}');
      // 降级到本地存储
      await _saveLocalProgress(subjectId, episode);
      return false;
    }
  }

  /// 标记为看过
  Future<bool> markAsWatched(int subjectId) async {
    if (_accessToken == null) {
      return false;
    }

    try {
      await _dio.post('/subject/$subjectId/update', data: {'status': 'done'});
      return true;
    } on DioException catch (e) {
      AppLogger().e('标记失败: ${e.message}');
      return false;
    }
  }

  /// 获取排行榜
  /// [type] 排行榜类型：weekly、monthly、quarterly、yearly、all
  Future<List<BangumiSubject>> getRanking({
    String type = 'weekly',
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/ranking/subject',
        queryParameters: {'type': type, 'page': page, 'limit': limit},
      );

      final data = response.data['ranking'] as List<dynamic>? ?? [];
      return data
          .map((e) => BangumiSubject.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      AppLogger().e('获取排行榜失败: ${e.message}');
      return [];
    }
  }

  /// 获取每日放送
  Future<Map<String, List<BangumiSubject>>> getCalendar() async {
    try {
      final response = await _dio.get('/calendar');

      final result = <String, List<BangumiSubject>>{};
      final weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];

      for (var i = 0; i < 7; i++) {
        final dayData = response.data[i];
        final items = (dayData['items'] as List<dynamic>? ?? [])
            .map((e) => BangumiSubject.fromJson(e as Map<String, dynamic>))
            .toList();
        result[weekdays[i]] = items;
      }

      return result;
    } on DioException catch (e) {
      AppLogger().e('获取每日放送失败: ${e.message}');
      return {};
    }
  }

  /// 获取相似番剧推荐
  Future<List<BangumiSubject>> getSimilarSubject(
    int subjectId, {
    int limit = 6,
  }) async {
    try {
      final response = await _dio.get(
        '/subject/$subjectId/similar',
        queryParameters: {'limit': limit},
      );

      // 处理可能的返回格式
      List<dynamic> data;
      if (response.data is List) {
        data = response.data as List<dynamic>;
      } else if (response.data is Map) {
        final map = response.data as Map<String, dynamic>;
        data =
            map['list'] as List<dynamic>? ??
            map['data'] as List<dynamic>? ??
            [];
      } else {
        data = [];
      }

      return data
          .map((e) => BangumiSubject.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      AppLogger().e('获取相似推荐失败: ${e.message}');
      return [];
    }
  }

  /// 保存本地观看进度
  Future<void> _saveLocalProgress(int subjectId, int episode) async {
    final key = 'progress_$subjectId';
    await SpUtil.put(key, episode);
    AppLogger().d('保存本地进度: $subjectId - 第 $episode 集');
  }

  /// 获取本地观看进度
  Future<int?> getLocalProgress(int subjectId) async {
    final key = 'progress_$subjectId';
    final progress = SpUtil.get(key);
    if (progress != null) {
      return progress as int;
    }
    return null;
  }

  @override
  void onClose() {
    _dio.close();
    super.onClose();
  }
}
