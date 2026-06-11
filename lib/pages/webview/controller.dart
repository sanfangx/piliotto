import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:piliotto/utils/event_bus.dart';

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

  /// 是否显示加载进度条
  RxBool loadShow = true.obs;

  /// 是否正在加载
  RxBool isLoading = true.obs;

  /// 是否加载失败
  RxBool hasError = false.obs;

  /// 错误信息
  RxString errorMessage = ''.obs;

  /// 事件总线
  EventBus eventBus = EventBus();

  @override
  void onInit() {
    super.onInit();
    url = Get.parameters['url'] ?? '';
    type.value = Get.parameters['type'] ?? '';
    pageTitle = Get.parameters['pageTitle'] ?? '';

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

    // 加载 URL
    controller.loadUrl(
      urlRequest: URLRequest(
        url: WebUri(url.startsWith('http') ? url : 'https://$url'),
      ),
    );
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
    loadShow.value = false;
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
  }

  /// 加载完成回调
  void onLoadStop(Uri? uri) {
    isLoading.value = false;
    loadShow.value = false;
  }

  /// 加载错误回调
  void onLoadError(WebResourceRequest? request, WebResourceError error) {
    isLoading.value = false;
    hasError.value = true;
    errorMessage.value = error.description;
    SmartDialog.showToast('加载失败: ${error.description}');
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
}
