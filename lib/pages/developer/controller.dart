import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/utils/storage.dart';

/// 开发者选项页面控制器
///
/// 提供开发者模式相关的功能控制，包括：
/// - 路由跳转测试
/// - 组件展示测试
/// - 对话框测试
/// - 状态页面测试
/// - 内置浏览器
/// - 路由信息查看
/// - 网络调试
/// - 开发者模式开关
class DeveloperController extends GetxController {
  /// 设置存储
  Box setting = GStrorage.setting;

  /// 路由路径输入控制器
  final TextEditingController routePathController = TextEditingController();

  /// 路由参数输入控制器（JSON格式）
  final TextEditingController routeParamsController = TextEditingController();

  /// WebView URL 输入控制器
  final TextEditingController webviewUrlController = TextEditingController();

  /// 开发者模式是否启用
  RxBool developerModeEnabled = true.obs;

  /// 网络请求日志列表（占位符，后续完善）
  RxList<Map<String, dynamic>> networkLogs = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // 初始化开发者模式状态
    developerModeEnabled.value =
        setting.get(SettingBoxKey.developerMode, defaultValue: false);
  }

  @override
  void onClose() {
    routePathController.dispose();
    routeParamsController.dispose();
    webviewUrlController.dispose();
    super.onClose();
  }

  /// 执行路由跳转
  ///
  /// 根据输入的路由路径和参数进行跳转
  void navigateToRoute() {
    final String path = routePathController.text.trim();
    if (path.isEmpty) {
      SmartDialog.showToast('请输入路由路径');
      return;
    }

    try {
      // 尝试解析参数
      Map<String, dynamic>? arguments;
      if (routeParamsController.text.trim().isNotEmpty) {
        // 简单的参数解析，格式为 key1=value1,key2=value2
        final params = <String, dynamic>{};
        for (final pair in routeParamsController.text.split(',')) {
          final kv = pair.split('=');
          if (kv.length == 2) {
            params[kv[0].trim()] = kv[1].trim();
          }
        }
        if (params.isNotEmpty) {
          arguments = params;
        }
      }

      // 执行跳转
      if (arguments != null) {
        // 将 Map<String, dynamic> 转换为 Map<String, String>
        final stringParams = arguments.map((key, value) => MapEntry(key, value.toString()));
        Get.toNamed(path, parameters: stringParams);
      } else {
        Get.toNamed(path);
      }
    } catch (e) {
      SmartDialog.showToast('路由跳转失败: $e');
    }
  }

  /// 打开 WebView 页面
  ///
  /// 跳转到 WebView 页面并加载指定 URL
  void openWebview() {
    String url = webviewUrlController.text.trim();
    if (url.isEmpty) {
      SmartDialog.showToast('请输入 URL');
      return;
    }

    // 如果没有协议前缀，添加 https://
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    Get.toNamed('/webview', parameters: {'url': url, 'pageTitle': '开发者浏览器'});
  }

  /// 获取当前路由栈信息
  ///
  /// 返回当前路由栈的详细信息
  List<Map<String, dynamic>> getRouteStackInfo() {
    final List<Map<String, dynamic>> stackInfo = [];
    try {
      final currentRoute = Get.currentRoute;
      final routing = Get.routing;

      stackInfo.add({
        'currentRoute': currentRoute,
        'previousRoute': routing.previous,
        'isDialog': routing.isDialog,
        'isBottomSheet': routing.isBottomSheet,
      });
    } catch (e) {
      stackInfo.add({'error': e.toString()});
    }
    return stackInfo;
  }

  /// 获取当前路由参数
  ///
  /// 返回当前页面的路由参数
  Map<String, dynamic>? getCurrentRouteParameters() {
    try {
      return Get.parameters;
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// 关闭开发者模式
  ///
  /// 将开发者模式设置为关闭状态，并返回上一页
  void closeDeveloperMode() {
    SmartDialog.show(
      useSystem: true,
      animationType: SmartAnimationType.centerFade_otherSlide,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('关闭开发者模式'),
          content: const Text('确认要关闭开发者模式吗？关闭后将无法访问开发者选项页面。'),
          actions: [
            TextButton(
              onPressed: () => SmartDialog.dismiss(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                developerModeEnabled.value = false;
                setting.put(SettingBoxKey.developerMode, false);
                SmartDialog.dismiss();
                Get.back();
                SmartDialog.showToast('开发者模式已关闭');
              },
              child: const Text('确认'),
            ),
          ],
        );
      },
    );
  }

  /// 添加网络请求日志（占位符方法）
  ///
  /// 用于记录网络请求信息，后续可接入实际的网络拦截器
  void addNetworkLog(Map<String, dynamic> log) {
    networkLogs.insert(0, log);
    // 限制日志数量
    if (networkLogs.length > 100) {
      networkLogs.removeLast();
    }
  }

  /// 清空网络请求日志
  void clearNetworkLogs() {
    networkLogs.clear();
    SmartDialog.showToast('网络日志已清空');
  }
}
