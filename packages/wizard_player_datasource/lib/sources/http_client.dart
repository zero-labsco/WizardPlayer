import 'dart:io';

import 'package:dio/dio.dart';
import 'package:amis_flutter_utils/utils.dart';

/// HTTP 客户端封装（支持备用域名）
class HttpClient {
  late final Dio _dio;

  /// 备用域名列表
  final List<String>? backupBaseUrls;

  /// 当前使用的域名索引
  int _currentUrlIndex = 0;

  HttpClient({
    String? baseUrl,
    this.backupBaseUrls,
    Map<String, String>? headers,
    int timeout = 30000,
  }) {
    final allBaseUrls = [
      if (baseUrl != null) baseUrl,
      ...?backupBaseUrls,
    ];

    _dio = Dio(
      BaseOptions(
        baseUrl: allBaseUrls.isNotEmpty ? allBaseUrls.first : '',
        connectTimeout: Duration(milliseconds: timeout),
        receiveTimeout: Duration(milliseconds: timeout),
        sendTimeout: Duration(milliseconds: timeout),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
          'Referer': allBaseUrls.isNotEmpty ? allBaseUrls.first : '',
          ...?headers,
        },
      ),
    );

    // 添加日志拦截器
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        error: true,
      ),
    );
  }

  /// 切换到备用域名
  void _switchToBackupUrl() {
    final allBaseUrls = [
      if (_dio.options.baseUrl.isNotEmpty) _dio.options.baseUrl,
      ...?backupBaseUrls,
    ];

    if (allBaseUrls.isNotEmpty && _currentUrlIndex < allBaseUrls.length - 1) {
      _currentUrlIndex++;
      final newUrl = allBaseUrls[_currentUrlIndex];
      _dio.options.baseUrl = newUrl;
      _dio.options.headers['Referer'] = newUrl;
    }
  }

  /// 执行请求（支持备用域名切换）
  Future<Response<T>> _executeRequest<T>(
    Future<Response<T>> Function() request,
  ) async {
    int attempt = 0;
    final allBaseUrls = [
      if (_dio.options.baseUrl.isNotEmpty) _dio.options.baseUrl,
      ...?backupBaseUrls,
    ];

    while (attempt < allBaseUrls.length) {
      try {
        return await request();
      } on DioException catch (e) {
        // 如果是网络错误且还有备用域名，切换后重试
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.unknown ||
            (e.error is SocketException)) {
          AppLogger().d('Request failed, switching to backup URL');
          if (attempt < allBaseUrls.length - 1) {
            _switchToBackupUrl();
            attempt++;
            continue;
          }
        }
        rethrow;
      }
    }
    // 理论上不会到达这里
    throw Exception('All base URLs failed');
  }

  /// GET 请求
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _executeRequest(() => _dio.get<T>(
          path,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        ));
  }

  /// POST 请求
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _executeRequest(() => _dio.post<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        ));
  }

  /// HEAD 请求（测试资源可用性）
  Future<Response<T>> head<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _executeRequest(() => _dio.head<T>(
          path,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        ));
  }

  /// 下载文件
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
    bool deleteOnError = true,
  }) async {
    return _executeRequest(() => _dio.download(
          urlPath,
          savePath,
          onReceiveProgress: onReceiveProgress,
          cancelToken: cancelToken,
          deleteOnError: deleteOnError,
        ));
  }

  /// 设置代理
  void setProxy(String proxy) {
    _dio.httpClientAdapter;
    // 可根据需要配置代理
  }

  /// 关闭客户端
  void close() {
    _dio.close();
  }
}
