import 'package:get/get.dart';
import 'package:piliotto/utils/event_bus.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  final WebViewController controller = WebViewController();

  /// 加载进度（0-100）
  RxInt loadProgress = 0.obs;

  /// 是否显示加载进度条
  RxBool loadShow = true.obs;

  /// 事件总线
  EventBus eventBus = EventBus();

  @override
  void onInit() {
    super.onInit();
    url = Get.parameters['url']!;
    type.value = Get.parameters['type']!;
    pageTitle = Get.parameters['pageTitle']!;

    if (type.value == 'login') {
      controller.clearCache();
      controller.clearLocalStorage();
      WebViewCookieManager().clearCookies();
    }

    webviewInit();
  }

  void webviewInit() {
    controller
      ..setUserAgent(
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            loadProgress.value = progress;
          },
          onPageStarted: (String url) {},
          onUrlChange: (UrlChange urlChange) async {
            loadShow.value = false;
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('ottohub://')) {
              if (request.url.startsWith('ottohub://video/')) {
                final uri = Uri.parse(request.url);
                if (uri.pathSegments.isNotEmpty) {
                  final vid = int.tryParse(uri.pathSegments[0]);
                  if (vid != null) {
                    Get.offAndToNamed('/video?vid=$vid', arguments: {
                      'pic': '',
                      'heroTag': 'video_$vid',
                    });
                  }
                }
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url.startsWith('http') ? url : 'https://$url'));
  }
}
