import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/constants/app_styles.dart';
import 'package:piliotto/utils/login.dart';
import 'package:url_launcher/url_launcher.dart';
import 'controller.dart';

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
          _webviewController.reload();
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
                    null, _webviewController.webViewController),
                child: const Text('刷新登录状态'),
              )
            : const SizedBox(),
      ),
      const SizedBox(width: 12)
    ];
  }

  /// 构建标题 widget
  ///
  /// 根据 titleMode 和 subtitleMode 模式动态显示主标题和副标题：
  /// - 主标题模式：
  ///   - 'fixed': 显示固定文本
  ///   - 'webTitle': 显示网页名称
  /// - 副标题模式：
  ///   - 'fixed': 显示固定文本
  ///   - 'webTitle': 显示网页名称
  ///   - 'webUrl': 显示网页链接
  ///   - 'none': 无副标题
  Widget _buildTitle() {
    final String fixedTitle =
        widget.appBarTitle ?? _webviewController.pageTitle;

    // 获取主标题内容
    Widget buildMainTitle() {
      if (_webviewController.titleMode == 'webTitle') {
        return Obx(() {
          final webTitle = _webviewController.webTitle.value;
          return Text(
            webTitle.isNotEmpty ? webTitle : fixedTitle,
            style: Theme.of(context).textTheme.titleMedium,
          );
        });
      } else {
        // fixed 模式
        return Text(
          fixedTitle,
          style: Theme.of(context).textTheme.titleMedium,
        );
      }
    }

    // 获取副标题内容
    Widget? buildSubtitle() {
      if (_webviewController.subtitleMode == 'none') {
        return null;
      }

      return Obx(() {
        String subtitleText = '';
        switch (_webviewController.subtitleMode) {
          case 'fixed':
            subtitleText = fixedTitle;
            break;
          case 'webTitle':
            subtitleText = _webviewController.webTitle.value;
            break;
          case 'webUrl':
            subtitleText = _webviewController.webUrl.value;
            break;
        }

        if (subtitleText.isEmpty) {
          return const SizedBox.shrink();
        }

        return Text(
          subtitleText,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        );
      });
    }

    // 组合主标题和副标题
    final subtitle = buildSubtitle();
    if (subtitle != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildMainTitle(),
          subtitle,
        ],
      );
    } else {
      return buildMainTitle();
    }
  }

  /// 构建错误状态
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.base),
            Obx(() {
              // 解析错误信息（格式：title\nmessage）
              final errorText = _webviewController.errorMessage.value;
              final parts = errorText.split('\n');
              final title = parts.isNotEmpty ? parts[0] : '加载失败';
              final message =
                  parts.length > 1 ? parts.sublist(1).join('\n') : '';

              return Column(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppFontSize.xl,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  if (message.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              );
            }),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: _webviewController.retry,
              icon: const Icon(Icons.refresh_outlined),
              label: const Text('重新加载'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton.icon(
              onPressed: () => launchUrl(Uri.parse(_webviewController.url)),
              icon: const Icon(Icons.open_in_browser_outlined),
              label: const Text('在浏览器中打开'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: widget.showAppBar
            ? AppBar(
                centerTitle: false,
                titleSpacing: 0,
                title: _buildTitle(),
                actions: widget.appBarActions ?? _buildDefaultActions(context),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(2),
                  child: Obx(
                    () => LinearProgressIndicator(
                      value: _webviewController.loadProgress.value > 0
                          ? _webviewController.loadProgress.value / 100
                          : null,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
              )
            : null,
        body: Column(
          children: [
            if (_webviewController.type.value == 'login')
              Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.onInverseSurface,
                padding: const EdgeInsets.only(
                    left: 12, right: 12, top: 6, bottom: 6),
                child: const Text('登录成功未自动跳转?  请点击右上角「刷新登录状态」'),
              ),
            Expanded(
              child: Stack(
                children: [
                  // WebView
                  InAppWebView(
                    initialSettings: InAppWebViewSettings(
                      userAgent: _webviewController.userAgent.isNotEmpty
                          ? _webviewController.userAgent
                          : 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                      javaScriptEnabled: _webviewController.enableJs,
                      cacheEnabled: _webviewController.enableCache,
                      supportZoom: _webviewController.allowZoom,
                      mediaPlaybackRequiresUserGesture:
                          !_webviewController.autoPlayMedia,
                    ),
                    onWebViewCreated: _webviewController.onWebViewCreated,
                    onProgressChanged: (controller, progress) {
                      _webviewController.onProgressChanged(progress);
                    },
                    onLoadStart: (controller, url) {
                      _webviewController.onUrlChanged(url);
                    },
                    onLoadStop: (controller, url) {
                      _webviewController.onLoadStop(url);
                    },
                    onTitleChanged: (controller, title) {
                      _webviewController.onTitleChanged(title);
                    },
                    onReceivedError: (controller, request, error) {
                      _webviewController.onLoadError(request, error);
                    },
                    shouldOverrideUrlLoading:
                        _webviewController.shouldOverrideUrlLoading,
                  ),
                  // 错误状态覆盖层（使用 AnimatedSwitcher 实现快速渐入渐出）
                  Obx(() => AnimatedSwitcher(
                        duration: const Duration(milliseconds: 150), // 快速渐入
                        reverseDuration:
                            const Duration(milliseconds: 300), // 标准渐出
                        switchInCurve: Curves.easeIn,
                        switchOutCurve: Curves.easeOut,
                        child: _webviewController.hasError.value
                            ? _buildErrorState()
                            : const SizedBox.shrink(),
                      )),
                ],
              ),
            ),
          ],
        ));
  }
}
