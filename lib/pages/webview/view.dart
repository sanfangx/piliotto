import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/utils/login.dart';
import 'package:url_launcher/url_launcher.dart';
import 'controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 通用网页界面组件
///
/// 支持自定义 AppBar 配置，包括标题、操作按钮，以及无 AppBar 模式。
///
/// 使用示例：
/// ```dart
/// // 默认模式（显示 AppBar）
/// Get.toNamed('/webview?url=...&pageTitle=...');
///
/// // 无 AppBar 模式
/// Get.toNamed('/webview?url=...', arguments: {'showAppBar': false});
///
/// // 自定义标题和操作按钮
/// Get.toNamed('/webview?url=...', arguments: {
///   'appBarTitle': '自定义标题',
///   'appBarActions': [IconButton(...)],
/// });
/// ```
class WebviewPage extends StatefulWidget {
  /// 是否显示 AppBar，默认为 true
  final bool showAppBar;

  /// 自定义 AppBar 标题
  ///
  /// 如果为 null，则使用 pageTitle 参数或网页标题
  final String? appBarTitle;

  /// 自定义 AppBar 操作按钮
  ///
  /// 如果为 null，则使用默认的操作按钮（刷新、在浏览器打开等）
  final List<Widget>? appBarActions;

  const WebviewPage({
    super.key,
    this.showAppBar = true,
    this.appBarTitle,
    this.appBarActions,
  });

  @override
  State<WebviewPage> createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {
  final WebviewController _webviewController = Get.put(WebviewController());

  /// 构建默认的 AppBar 操作按钮
  List<Widget> _buildDefaultActions(BuildContext context) {
    return [
      const SizedBox(width: 4),
      IconButton(
        onPressed: () {
          _webviewController.controller.reload();
        },
        icon: Icon(Icons.refresh_outlined,
            color: Theme.of(context).colorScheme.primary),
      ),
      IconButton(
        onPressed: () {
          launchUrl(Uri.parse(_webviewController.url));
        },
        icon: Icon(Icons.open_in_browser_outlined,
            color: Theme.of(context).colorScheme.primary),
      ),
      Obx(
        () => _webviewController.type.value == 'login'
            ? TextButton(
                onPressed: () => LoginUtils.confirmLogin(
                    null, _webviewController.controller),
                child: const Text('刷新登录状态'),
              )
            : const SizedBox(),
      ),
      const SizedBox(width: 12)
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: widget.showAppBar
            ? AppBar(
                centerTitle: false,
                titleSpacing: 0,
                title: Text(
                  widget.appBarTitle ?? _webviewController.pageTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                actions:
                    widget.appBarActions ?? _buildDefaultActions(context),
              )
            : null,
        body: Column(
          children: [
            Obx(
              () => AnimatedContainer(
                curve: Curves.easeInOut,
                duration: const Duration(milliseconds: 350),
                height: _webviewController.loadShow.value ? 4 : 0,
                child: LinearProgressIndicator(
                  key: ValueKey(_webviewController.loadProgress),
                  value: _webviewController.loadProgress / 100,
                ),
              ),
            ),
            if (_webviewController.type.value == 'login')
              Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.onInverseSurface,
                padding: const EdgeInsets.only(
                    left: 12, right: 12, top: 6, bottom: 6),
                child: const Text('登录成功未自动跳转?  请点击右上角「刷新登录状态」'),
              ),
            Expanded(
              child: WebViewWidget(controller: _webviewController.controller),
            ),
          ],
        ));
  }
}
