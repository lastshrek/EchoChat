import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../utils/storage_util.dart';

class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  static HttpClient get instance => _instance;

  late Dio dio;

  // 基础URL
  static const String baseUrl = 'http://192.168.50.84:3000/';

  HttpClient._internal() {
    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {},
      contentType: 'application/json; charset=utf-8',
      responseType: ResponseType.json,
    );

    dio = Dio(options);

    // 添加拦截器
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 添加token到请求头
        final token = await StorageUtil.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        if (kDebugMode) {
          print('请求: ${options.uri}');
          print('请求头: ${options.headers}');
          print('请求参数: ${options.data}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('响应数据: ${response.data}');
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        if (kDebugMode) {
          print('请求错误: $e');
        }
        return handler.next(e);
      },
    ));
  }

  // GET 请求
  Future<dynamic> get(String path, {Map<String, dynamic>? params}) async {
    try {
      Response response = await dio.get(path, queryParameters: params);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // POST 请求
  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      Response response = await dio.post(path, data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
