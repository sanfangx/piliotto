import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:piliotto/utils/event_bus.dart';
import 'package:piliotto/utils/storage.dart';

/// Webview 页面控制器
///
/// 支持通过 Get.parameters 传递以下参数：
/// - `url`: 网页 URL（必填）
/// - `type`: 页面类型，如 'login'（可选）
/// - `pageTitle`: 页面标题（可选）
///
/// 支持通过 Get.arguments 传递以下配置：
/// - `showAppBar`: 是否显示 AppBar（默认 true）
/// - `appBarTitle`: 自定义 AppBar 标题
/// - `appBarActions`: 自定义 AppBar 操作按钮
///
/// 支持通过 Get.arguments 或 Get.parameters 传递以下配置（调用时参数优先，默认配置兜底）：
/// - `titleMode`: 主标题模式 (fixed/webTitle)
/// - `subtitleMode`: 副标题模式 (fixed/webTitle/webUrl/none)
/// - `enableJs`: 启用 JavaScript
/// - `enableCache`: 启用缓存
/// - `allowZoom`: 允许缩放
/// - `autoPlayMedia`: 自动播放媒体
/// - `userAgent`: User-Agent
/// - `jsInjection`: 调用时 JS 代码
/// - `jsInjectionMode`: JS 注入模式 (override/merge/globalOnly/callOnly)
///
/// 使用示例：
/// ```dart
/// // 基本用法
/// Get.toNamed('/webview?url=https://example.com&pageTitle=示例页面');
///
/// // 登录页面
/// Get.toNamed('/webview?url=https://login.example.com&type=login&pageTitle=登录');
///
/// // 无 AppBar 模式
/// Get.toNamed('/webview?url=https://example.com', arguments: {'showAppBar': false});
///
/// // 自定义配置
/// Get.toNamed('/webview?url=https://example.com', arguments: {
///   'enableJs': false,
///   'userAgent': 'CustomUserAgent',
///   'jsInjection': 'console.log("Hello");',
///   'jsInjectionMode': 'callOnly',
/// });
/// ```
class WebviewController extends GetxController {
  /// 网页 URL
  String url = '';

  /// 页面类型（如 'login'）
  RxString type = ''.obs;

  /// 页面标题
  String pageTitle = '';

  /// WebView 控制器
  InAppWebViewController? webViewController;

  /// 加载进度（0-100）
  RxInt loadProgress = 0.obs;

  /// 是否正在加载
  RxBool isLoading = true.obs;

  /// 是否加载失败
  RxBool hasError = false.obs;

  /// 错误信息
  RxString errorMessage = ''.obs;

  /// 网页标题（响应式）
  RxString webTitle = ''.obs;

  /// 网页链接（响应式）
  RxString webUrl = ''.obs;

  /// 主标题模式 (fixed/webTitle)
  String titleMode = 'fixed';

  /// 副标题模式 (fixed/webTitle/webUrl/none)
  String subtitleMode = 'none';

  /// 启用 JavaScript
  bool enableJs = true;

  /// 启用缓存
  bool enableCache = true;

  /// 允许缩放
  bool allowZoom = true;

  /// 自动播放媒体
  bool autoPlayMedia = false;

  /// User-Agent
  String userAgent = '';

  /// 调用时 JS 代码
  String jsInjection = '';

  /// JS 注入模式 (override/merge/globalOnly/callOnly)
  String jsInjectionMode = 'merge';

  /// 事件总线
  EventBus eventBus = EventBus();

  /// JavaScript Handler 映射表
  final Map<String, Function> _jsHandlers = {};

  /// 从参数中读取字符串值（优先 arguments，其次 parameters，最后默认值）
  String _getStringParam(String key, String defaultValue) {
    // 1. 优先从 arguments 读取（必须非空）
    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;
      if (args[key] != null) {
        final value = args[key].toString();
        if (value.isNotEmpty) return value; // 只有非空才返回
      }
    }
    // 2. 其次从 parameters 读取（必须非空）
    if (Get.parameters[key] != null) {
      final value = Get.parameters[key]!;
      if (value.isNotEmpty) return value; // 只有非空才返回
    }
    // 3. 最后使用默认值
    return defaultValue;
  }

  /// 从参数中读取布尔值（优先 arguments，其次 parameters，最后默认值）
  bool _getBoolParam(String key, bool defaultValue) {
    // 1. 优先从 arguments 读取（必须非空）
    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;
      if (args[key] != null) {
        if (args[key] is bool) {
          return args[key] as bool;
        }
        final value = args[key].toString();
        if (value.isNotEmpty) {
          return value.toLowerCase() == 'true'; // 只有非空才返回
        }
      }
    }
    // 2. 其次从 parameters 读取（必须非空）
    if (Get.parameters[key] != null) {
      final value = Get.parameters[key]!;
      if (value.isNotEmpty) {
        return value.toLowerCase() == 'true'; // 只有非空才返回
      }
    }
    // 3. 最后使用默认值
    return defaultValue;
  }

  @override
  void onInit() {
    super.onInit();
    url = Get.parameters['url'] ?? '';
    type.value = Get.parameters['type'] ?? '';
    pageTitle = Get.parameters['pageTitle'] ?? '';

    // 读取配置参数（调用时参数优先，默认配置兜底）
    titleMode = _getStringParam(
      'titleMode',
      GStorage.setting.get(SettingBoxKey.titleMode, defaultValue: 'fixed')
          as String,
    );

    subtitleMode = _getStringParam(
      'subtitleMode',
      GStorage.setting.get(SettingBoxKey.subtitleMode, defaultValue: 'none')
          as String,
    );

    enableJs = _getBoolParam(
      'enableJs',
      GStorage.setting.get('browserEnableJs', defaultValue: true) as bool,
    );

    enableCache = _getBoolParam(
      'enableCache',
      GStorage.setting.get('browserEnableCache', defaultValue: true) as bool,
    );

    allowZoom = _getBoolParam(
      'allowZoom',
      GStorage.setting.get('browserAllowZoom', defaultValue: true) as bool,
    );

    autoPlayMedia = _getBoolParam(
      'autoPlayMedia',
      GStorage.setting.get('browserAutoPlayMedia', defaultValue: false) as bool,
    );

    userAgent = _getStringParam(
      'userAgent',
      GStorage.setting.get('browserUserAgent', defaultValue: '') as String,
    );

    jsInjection = _getStringParam('jsInjection', '');

    jsInjectionMode = _getStringParam('jsInjectionMode', 'merge');

    // 如果 URL 为空，返回上一页
    if (url.isEmpty) {
      SmartDialog.showToast('URL 参数缺失');
      Get.back();
      return;
    }
  }

  /// WebView 创建完成回调
  void onWebViewCreated(InAppWebViewController controller) {
    webViewController = controller;

    if (type.value == 'login') {
      clearCache();
    }

    // 注册默认的通信通道
    registerJsHandler('flutterChannel', handleJsCall);

    // 注入 JS 代码
    _injectJs(controller);

    // 加载 URL
    controller.loadUrl(
      urlRequest: URLRequest(
        url: WebUri(url.startsWith('http') ? url : 'https://$url'),
      ),
    );
  }

  /// 注入 JS 代码
  ///
  /// 根据 jsInjectionMode 决定执行哪些 JS：
  /// - override: 只执行调用时传入的 jsInjection
  /// - merge: 先执行全局 globalJsInjection，再执行调用时 jsInjection
  /// - globalOnly: 只执行全局 globalJsInjection
  /// - callOnly: 只执行调用时 jsInjection
  Future<void> _injectJs(InAppWebViewController controller) async {
    try {
      // 从设置中读取全局 JS 代码
      final globalJs = GStorage.setting.get(SettingBoxKey.globalJsInjection);
      final hasGlobalJs = globalJs != null && globalJs.toString().isNotEmpty;
      final hasCallJs = jsInjection.isNotEmpty;

      // 根据 jsInjectionMode 决定执行哪些 JS
      switch (jsInjectionMode) {
        case 'override':
          // 只执行调用时传入的 jsInjection
          if (hasCallJs) {
            await controller.evaluateJavascript(source: jsInjection);
          }
          break;
        case 'merge':
          // 先执行全局 globalJsInjection，再执行调用时 jsInjection
          if (hasGlobalJs) {
            await controller.evaluateJavascript(source: globalJs.toString());
          }
          if (hasCallJs) {
            await controller.evaluateJavascript(source: jsInjection);
          }
          break;
        case 'globalOnly':
          // 只执行全局 globalJsInjection
          if (hasGlobalJs) {
            await controller.evaluateJavascript(source: globalJs.toString());
          }
          break;
        case 'callOnly':
          // 只执行调用时 jsInjection
          if (hasCallJs) {
            await controller.evaluateJavascript(source: jsInjection);
          }
          break;
        default:
          // 默认使用 merge 模式
          if (hasGlobalJs) {
            await controller.evaluateJavascript(source: globalJs.toString());
          }
          if (hasCallJs) {
            await controller.evaluateJavascript(source: jsInjection);
          }
      }
    } catch (e) {
      // 注入失败不影响页面正常加载，仅打印日志
      debugPrint('JS 注入失败: $e');
    }
  }

  /// 清除缓存
  Future<void> clearCache() async {
    await InAppWebViewController.clearAllCache();
    await CookieManager.instance().deleteAllCookies();
  }

  /// 刷新页面
  Future<void> reload() async {
    if (webViewController != null) {
      await webViewController!.reload();
    }
  }

  /// 加载进度回调
  void onProgressChanged(int progress) {
    loadProgress.value = progress;
    if (progress == 100) {
      isLoading.value = false;
    }
  }

  /// URL 变化回调
  void onUrlChanged(Uri? uri) {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
    loadProgress.value = 0;
    // 更新网页链接
    if (uri != null) {
      webUrl.value = uri.toString();
    }
  }

  /// 加载完成回调
  void onLoadStop(Uri? uri) {
    isLoading.value = false;
    loadProgress.value = 100;
  }

  /// 标题变化回调
  void onTitleChanged(String? title) {
    if (title != null && title.isNotEmpty) {
      webTitle.value = title;
    }
  }

  /// 生成用户友好的错误提示信息
  ///
  /// 根据错误类型分析并返回用户可读的提示信息
  Map<String, String> getErrorMessage(
    WebResourceRequest? request,
    WebResourceError error,
  ) {
    String title = '加载失败';
    String message = error.description;

    // 根据错误类型生成友好的提示信息
    if (error.type == WebResourceErrorType.HOST_LOOKUP) {
      title = '网络连接失败';
      message = '无法解析服务器地址，请检查网络连接或网址是否正确。';
    } else if (error.type == WebResourceErrorType.CANNOT_CONNECT_TO_HOST) {
      title = '连接失败';
      message = '无法连接到服务器，请检查网络连接后重试。';
    } else if (error.type == WebResourceErrorType.TIMEOUT) {
      title = '连接超时';
      message = '服务器响应超时，请检查网络状况后重试。';
    } else if (error.type == WebResourceErrorType.SECURE_CONNECTION_FAILED) {
      title = '安全连接失败';
      message = '无法建立安全连接，该网站的证书可能存在问题。';
    } else if (error.type == WebResourceErrorType.TOO_MANY_REQUESTS) {
      title = '请求过多';
      message = '服务器请求过于频繁，请稍后再试。';
    } else if (error.type == WebResourceErrorType.USER_AUTHENTICATION_FAILED) {
      title = '认证失败';
      message = '访问该页面需要身份验证，请登录后重试。';
    } else if (error.type == WebResourceErrorType.PROXY_AUTHENTICATION) {
      title = '代理认证失败';
      message = '代理服务器需要身份验证。';
    } else if (error.type == WebResourceErrorType.IO) {
      title = '网络错误';
      message = '网络输入输出错误，请检查网络连接后重试。';
    } else if (error.type == WebResourceErrorType.BAD_URL) {
      title = '网址无效';
      message = '网址格式不正确，请检查输入的网址。';
    } else if (error.type == WebResourceErrorType.FILE_NOT_FOUND) {
      title = '资源未找到';
      message = '请求的资源不存在，请检查网址是否正确。';
    } else if (error.type == WebResourceErrorType.TOO_MANY_REDIRECTS) {
      title = '重定向过多';
      message = '页面重定向次数过多，无法完成加载。';
    } else if (error.type == WebResourceErrorType.UNSUPPORTED_SCHEME) {
      title = '不支持的协议';
      message = '网址使用了不支持的协议，请使用 http 或 https 协议。';
    } else if (error.type == WebResourceErrorType.FAILED_SSL_HANDSHAKE) {
      title = 'SSL 握手失败';
      message = '无法完成安全连接握手，服务器证书可能存在问题。';
    } else if (error.type == WebResourceErrorType.CANCELLED) {
      title = '请求已取消';
      message = '页面加载请求已被取消。';
    } else {
      // 对于通用错误，保留原始错误描述
      if (error.description.isNotEmpty) {
        message = error.description;
      } else {
        message = '发生未知错误，请稍后重试。';
      }
    }

    return {'title': title, 'message': message};
  }

  /// 加载错误回调
  void onLoadError(WebResourceRequest? request, WebResourceError error) {
    isLoading.value = false;
    hasError.value = true;

    // 使用用户友好的错误提示
    final errorInfo = getErrorMessage(request, error);
    errorMessage.value = '${errorInfo['title']}\n${errorInfo['message']}';

    SmartDialog.showToast('加载失败: ${errorInfo['title']}');
  }

  /// 重新加载
  void retry() {
    hasError.value = false;
    errorMessage.value = '';
    isLoading.value = true;
    reload();
  }

  /// 导航请求处理
  Future<NavigationActionPolicy?> shouldOverrideUrlLoading(
    InAppWebViewController controller,
    NavigationAction navigationAction,
  ) async {
    final requestUrl = navigationAction.request.url?.toString() ?? '';

    if (requestUrl.startsWith('ottohub://')) {
      if (requestUrl.startsWith('ottohub://video/')) {
        final uri = navigationAction.request.url;
        if (uri != null && uri.pathSegments.isNotEmpty) {
          final vid = int.tryParse(uri.pathSegments[0]);
          if (vid != null) {
            Get.offAndToNamed('/video?vid=$vid', arguments: {
              'pic': '',
              'heroTag': 'video_$vid',
            });
          }
        }
      }
      return NavigationActionPolicy.CANCEL;
    }
    return NavigationActionPolicy.ALLOW;
  }

  /// 执行 JavaScript 代码
  ///
  /// [jsCode] 要执行的 JS 代码
  /// 返回执行结果或错误信息
  Future<Map<String, dynamic>> executeJs(String jsCode) async {
    if (webViewController == null) {
      return {'success': false, 'error': 'WebView 未初始化'};
    }

    try {
      final result =
          await webViewController!.evaluateJavascript(source: jsCode);
      return {'success': true, 'result': result};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// 注册 JavaScript Handler
  ///
  /// [handlerName] Handler 名称
  /// [handler] 处理函数，接收 `List<dynamic>` 参数
  void registerJsHandler(String handlerName, Function handler) {
    _jsHandlers[handlerName] = handler;

    webViewController?.addJavaScriptHandler(
      handlerName: handlerName,
      callback: (args) {
        return handler(args);
      },
    );
  }

  /// Flutter 调用 JavaScript 函数
  ///
  /// [jsCode] JavaScript 代码字符串
  /// 返回执行结果
  Future<dynamic> callJsFunction(String jsCode) async {
    if (webViewController == null) {
      SmartDialog.showToast('WebView 未初始化');
      return null;
    }

    try {
      final result =
          await webViewController!.evaluateJavascript(source: jsCode);
      return result;
    } catch (e) {
      SmartDialog.showToast('JS 执行失败: $e');
      return null;
    }
  }

  /// 处理 JS 调用 Flutter
  ///
  /// [data] JS 传递的数据
  /// 返回处理结果
  dynamic handleJsCall(dynamic data) {
    // 解析数据
    if (data is List && data.isNotEmpty) {
      final message = data.first;

      // 触发事件总线，通知其他组件
      eventBus.emit('jsMessage', message);

      // 返回确认消息
      return {'success': true, 'message': 'Message received'};
    }

    return {'success': false, 'message': 'Invalid data'};
  }
}
