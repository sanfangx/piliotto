import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/services/network_debug_service.dart';
import 'package:piliotto/services/system_info_service.dart';
import 'package:piliotto/utils/storage.dart';

/// 开发者选项页面控制器
///
/// 提供开发者模式相关的功能控制，包括：
/// - 系统信息展示
/// - 快捷操作
/// - 路由跳转测试
/// - 内置浏览器
/// - 路由信息查看
/// - 开发者模式开关
class DeveloperController extends GetxController {
  /// 设置存储
  Box setting = GStrorage.setting;

  /// 系统信息服务
  final SystemInfoService _systemInfoService = SystemInfoService();

  /// 系统信息
  final RxMap<String, Map<String, dynamic>> systemInfo = <String, Map<String, dynamic>>{}.obs;

  /// 是否正在加载系统信息
  final RxBool isLoadingSystemInfo = false.obs;

  /// 路由路径输入控制器
  final TextEditingController routePathController = TextEditingController();

  /// 路由参数输入控制器
  final TextEditingController routeParamsController = TextEditingController();

  /// WebView URL 输入控制器
  final TextEditingController webviewUrlController = TextEditingController();

  /// WebView 页面标题输入控制器
  final TextEditingController webviewTitleController = TextEditingController();

  /// WebView 页面类型输入控制器
  final TextEditingController webviewTypeController = TextEditingController();

  /// 开发者模式是否启用
  RxBool developerModeEnabled = true.obs;

  /// 是否显示 AppBar
  RxBool webviewShowAppBar = true.obs;

  @override
  void onInit() {
    super.onInit();
    // 初始化开发者模式状态
    developerModeEnabled.value =
        setting.get(SettingBoxKey.developerMode, defaultValue: false);

    // 加载系统信息
    loadSystemInfo();
  }

  @override
  void onClose() {
    routePathController.dispose();
    routeParamsController.dispose();
    webviewUrlController.dispose();
    webviewTitleController.dispose();
    webviewTypeController.dispose();
    super.onClose();
  }

  /// 加载系统信息
  Future<void> loadSystemInfo() async {
    isLoadingSystemInfo.value = true;
    try {
      final info = await _systemInfoService.getAllSystemInfo();
      systemInfo.value = info;
    } catch (e) {
      SmartDialog.showToast('加载系统信息失败: $e');
    } finally {
      isLoadingSystemInfo.value = false;
    }
  }

  /// 清除缓存
  Future<void> clearCache() async {
    try {
      final success = await _systemInfoService.clearCache();
      if (success) {
        SmartDialog.showToast('缓存已清除');
        // 重新加载系统信息
        await loadSystemInfo();
      } else {
        SmartDialog.showToast('清除缓存失败');
      }
    } catch (e) {
      SmartDialog.showToast('清除缓存失败: $e');
    }
  }

  /// 清除所有存储
  Future<void> clearAllStorage() async {
    try {
      // 清除 Hive 所有 box
      await GStrorage.setting.clear();
      SmartDialog.showToast('存储已清除');
      // 重新加载系统信息
      await loadSystemInfo();
    } catch (e) {
      SmartDialog.showToast('清除存储失败: $e');
    }
  }

  /// 重置设置
  Future<void> resetSettings() async {
    try {
      // 清除设置
      await GStrorage.setting.clear();
      SmartDialog.showToast('设置已重置');
    } catch (e) {
      SmartDialog.showToast('重置设置失败: $e');
    }
  }

  /// 执行路由跳转
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

    // 构建参数
    final String pageTitle = webviewTitleController.text.trim().isEmpty
        ? '开发者浏览器'
        : webviewTitleController.text.trim();
    final String type = webviewTypeController.text.trim();

    // 构建路由参数
    final Map<String, String> parameters = {
      'url': url,
      'pageTitle': pageTitle,
    };
    if (type.isNotEmpty) {
      parameters['type'] = type;
    }

    // 构建路由参数（showAppBar 通过 arguments 传递）
    final Map<String, dynamic> arguments = {
      'showAppBar': webviewShowAppBar.value,
    };

    Get.toNamed('/webview', parameters: parameters, arguments: arguments);
  }

  /// 打开网络调试页面
  void openNetworkDebug() {
    Get.toNamed('/networkDebug');
  }

  /// 打开性能分析页面
  void openPerformance() {
    Get.toNamed('/performance');
  }

  /// 获取当前路由栈信息
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
  Map<String, dynamic>? getCurrentRouteParameters() {
    try {
      return Get.parameters;
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// 关闭开发者模式
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

  /// 获取网络日志统计
  Map<String, int> getNetworkStatistics() {
    try {
      final service = Get.find<NetworkDebugService>();
      return service.getStatistics();
    } catch (e) {
      return {'total': 0, 'success': 0, 'error': 0, 'pending': 0};
    }
  }
}
