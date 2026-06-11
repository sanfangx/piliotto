import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

// 忽略 GetX Response 的隐藏警告
// ignore: unused_import

/// 网络请求日志模型
class NetworkLog {
  final String id;
  final String method;
  final String url;
  final Map<String, dynamic> headers;
  final dynamic requestBody;
  final int? statusCode;
  final String? statusMessage;
  final Map<String, dynamic>? responseHeaders;
  final dynamic responseBody;
  final int durationMs;
  final DateTime timestamp;
  final bool isError;
  final String? errorMessage;

  NetworkLog({
    required this.id,
    required this.method,
    required this.url,
    required this.headers,
    this.requestBody,
    this.statusCode,
    this.statusMessage,
    this.responseHeaders,
    this.responseBody,
    required this.durationMs,
    required this.timestamp,
    this.isError = false,
    this.errorMessage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'method': method,
      'url': url,
      'headers': headers,
      'requestBody': requestBody,
      'statusCode': statusCode,
      'statusMessage': statusMessage,
      'responseHeaders': responseHeaders,
      'responseBody': responseBody,
      'durationMs': durationMs,
      'timestamp': timestamp.toIso8601String(),
      'isError': isError,
      'errorMessage': errorMessage,
    };
  }

  String get statusText {
    if (isError) return 'Error';
    if (statusCode == null) return 'Pending';
    return '$statusCode';
  }

  String get durationText {
    if (durationMs < 1000) return '${durationMs}ms';
    return '${(durationMs / 1000).toStringAsFixed(2)}s';
  }
}

/// 网络调试服务
///
/// 捕获和存储网络请求日志，提供查询和过滤功能
class NetworkDebugService extends GetxService {
  static NetworkDebugService get to => Get.find();

  /// 最大日志数量
  static const int maxLogCount = 200;

  /// 网络请求日志列表
  final RxList<NetworkLog> logs = <NetworkLog>[].obs;

  /// 是否启用网络调试
  final RxBool isEnabled = true.obs;

  /// 过滤类型：all, success, error, pending
  final RxString filterType = 'all'.obs;

  /// 搜索关键词
  final RxString searchKeyword = ''.obs;

  /// 添加日志
  void addLog(NetworkLog log) {
    if (!isEnabled.value) return;
    logs.insert(0, log);
    // 限制日志数量
    if (logs.length > maxLogCount) {
      logs.removeLast();
    }
  }

  /// 清空日志
  void clearLogs() {
    logs.clear();
  }

  /// 获取过滤后的日志
  List<NetworkLog> getFilteredLogs() {
    var filtered = logs.toList();

    // 按类型过滤
    if (filterType.value == 'success') {
      filtered = filtered.where((log) => !log.isError && log.statusCode != null && log.statusCode! < 400).toList();
    } else if (filterType.value == 'error') {
      filtered = filtered.where((log) => log.isError || (log.statusCode != null && log.statusCode! >= 400)).toList();
    } else if (filterType.value == 'pending') {
      filtered = filtered.where((log) => log.statusCode == null && !log.isError).toList();
    }

    // 按关键词搜索
    if (searchKeyword.value.isNotEmpty) {
      final keyword = searchKeyword.value.toLowerCase();
      filtered = filtered.where((log) {
        return log.url.toLowerCase().contains(keyword) ||
            log.method.toLowerCase().contains(keyword) ||
            (log.requestBody?.toString().toLowerCase().contains(keyword) ?? false) ||
            (log.responseBody?.toString().toLowerCase().contains(keyword) ?? false);
      }).toList();
    }

    return filtered;
  }

  /// 获取统计信息
  Map<String, int> getStatistics() {
    final total = logs.length;
    final success = logs.where((log) => !log.isError && log.statusCode != null && log.statusCode! < 400).length;
    final error = logs.where((log) => log.isError || (log.statusCode != null && log.statusCode! >= 400)).length;
    final pending = logs.where((log) => log.statusCode == null && !log.isError).length;

    return {
      'total': total,
      'success': success,
      'error': error,
      'pending': pending,
    };
  }
}

/// 网络调试拦截器
///
/// Dio 拦截器，用于捕获请求和响应信息
/// 当 isEnabled 为 false 时，几乎无性能开销
class NetworkDebugInterceptor extends dio.Interceptor {
  final NetworkDebugService _service;

  NetworkDebugInterceptor(this._service);

  @override
  void onRequest(dio.RequestOptions options, dio.RequestInterceptorHandler handler) {
    // 如果未启用，直接跳过，避免性能开销
    if (!_service.isEnabled.value) {
      return handler.next(options);
    }

    // 存储请求开始时间
    options.extra['debug_start_time'] = DateTime.now().millisecondsSinceEpoch;
    options.extra['debug_id'] = DateTime.now().microsecondsSinceEpoch.toString();

    super.onRequest(options, handler);
  }

  @override
  void onResponse(dio.Response response, dio.ResponseInterceptorHandler handler) {
    // 如果未启用，直接跳过
    if (!_service.isEnabled.value) {
      return handler.next(response);
    }

    final startTime = response.requestOptions.extra['debug_start_time'] as int?;
    final id = response.requestOptions.extra['debug_id'] as String?;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (startTime != null && id != null) {
      final log = NetworkLog(
        id: id,
        method: response.requestOptions.method,
        url: response.requestOptions.uri.toString(),
        headers: _convertHeaders(response.requestOptions.headers),
        requestBody: _parseBody(response.requestOptions.data),
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        responseHeaders: _convertHeaders(response.headers),
        responseBody: _parseBody(response.data),
        durationMs: now - startTime,
        timestamp: DateTime.fromMillisecondsSinceEpoch(startTime),
      );
      _service.addLog(log);
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(dio.DioException err, dio.ErrorInterceptorHandler handler) {
    // 如果未启用，直接跳过
    if (!_service.isEnabled.value) {
      return handler.next(err);
    }

    final startTime = err.requestOptions.extra['debug_start_time'] as int?;
    final id = err.requestOptions.extra['debug_id'] as String?;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (startTime != null && id != null) {
      final log = NetworkLog(
        id: id,
        method: err.requestOptions.method,
        url: err.requestOptions.uri.toString(),
        headers: _convertHeaders(err.requestOptions.headers),
        requestBody: _parseBody(err.requestOptions.data),
        statusCode: err.response?.statusCode,
        statusMessage: err.response?.statusMessage,
        responseHeaders: err.response?.headers != null
            ? _convertHeaders(err.response!.headers)
            : null,
        responseBody: _parseBody(err.response?.data),
        durationMs: now - startTime,
        timestamp: DateTime.fromMillisecondsSinceEpoch(startTime),
        isError: true,
        errorMessage: err.message ?? err.type.toString(),
      );
      _service.addLog(log);
    }

    super.onError(err, handler);
  }

  /// 转换 headers 类型
  Map<String, dynamic> _convertHeaders(dynamic headers) {
    if (headers is dio.Headers) {
      return headers.map.map((key, value) => MapEntry(key, value.join(', ')));
    }
    if (headers is Map<String, dynamic>) {
      return headers.map((key, value) {
        if (value is List) {
          return MapEntry(key, value.join(', '));
        }
        return MapEntry(key, value.toString());
      });
    }
    return {};
  }

  /// 解析请求/响应体
  dynamic _parseBody(dynamic data) {
    if (data == null) return null;

    if (data is String) {
      // 尝试解析 JSON
      try {
        return json.decode(data);
      } catch (e) {
        return data;
      }
    }

    if (data is Map || data is List) {
      return data;
    }

    // 其他类型转换为字符串
    return data.toString();
  }
}
