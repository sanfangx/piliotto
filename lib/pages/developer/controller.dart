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
  Box setting = GStorage.setting;

  /// 系统信息服务
  final SystemInfoService _systemInfoService = SystemInfoService();

  /// 系统信息
  final RxMap<String, Map<String, dynamic>> systemInfo =
      <String, Map<String, dynamic>>{}.obs;

  /// 是否正在加载系统信息
  final RxBool isLoadingSystemInfo = false.obs;

  /// 路由路径输入控制器
  final TextEditingController routePathController = TextEditingController();

  /// 路由参数输入控制器
  final TextEditingController routeParamsController = TextEditingController();

  /// 浏览器 URL 输入控制器
  final TextEditingController browserUrlController = TextEditingController();

  /// 浏览器页面标题输入控制器
  final TextEditingController browserTitleController = TextEditingController();

  /// 浏览器主标题模式控制器
  final TextEditingController browserTitleModeController =
      TextEditingController();

  /// 浏览器副标题模式控制器
  final TextEditingController browserSubtitleModeController =
      TextEditingController();

  /// 浏览器 JS 注入模式控制器
  final TextEditingController browserJsInjectionModeController =
      TextEditingController();

  /// 浏览器调用时 JS 代码控制器
  final TextEditingController browserJsInjectionController =
      TextEditingController();

  /// 全局 JS 注入代码控制器
  final TextEditingController globalJsInjectionController =
      TextEditingController();

  /// 开发者模式是否启用
  RxBool developerModeEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    // 初始化开发者模式状态
    developerModeEnabled.value =
        setting.get(SettingBoxKey.developerMode, defaultValue: false);

    // 加载系统信息
    loadSystemInfo();

    // 加载全局 JS 注入代码
    globalJsInjectionController.text = setting.get(
      SettingBoxKey.globalJsInjection,
      defaultValue: '',
    );
  }

  @override
  void onClose() {
    routePathController.dispose();
    routeParamsController.dispose();
    browserUrlController.dispose();
    browserTitleController.dispose();
    browserTitleModeController.dispose();
    browserSubtitleModeController.dispose();
    browserJsInjectionModeController.dispose();
    browserJsInjectionController.dispose();
    globalJsInjectionController.dispose();
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
      await GStorage.setting.clear();
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
      await GStorage.setting.clear();
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
        final stringParams =
            arguments.map((key, value) => MapEntry(key, value.toString()));
        Get.toNamed(path, parameters: stringParams);
      } else {
        Get.toNamed(path);
      }
    } catch (e) {
      SmartDialog.showToast('路由跳转失败: $e');
    }
  }

  /// 打开网络调试页面
  void openNetworkDebug() {
    Get.toNamed('/networkDebug');
  }

  /// 打开性能分析页面
  void openPerformance() {
    Get.toNamed('/performance');
  }

  /// 打开浏览器测试
  void openBrowserTest() {
    final String url = browserUrlController.text.trim();
    if (url.isEmpty) {
      SmartDialog.showToast('请输入 URL');
      return;
    }

    // 格式化 URL（如果没有协议则添加 https://）
    String formattedUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      formattedUrl = 'https://$url';
    }

    final String title = browserTitleController.text.trim();
    final String titleMode = browserTitleModeController.text.trim();
    final String subtitleMode = browserSubtitleModeController.text.trim();
    final String jsInjectionMode = browserJsInjectionModeController.text.trim();
    final String jsInjection = browserJsInjectionController.text.trim();

    // 构建参数
    final Map<String, dynamic> arguments = {};
    if (titleMode.isNotEmpty) {
      arguments['titleMode'] = titleMode;
    }
    if (subtitleMode.isNotEmpty) {
      arguments['subtitleMode'] = subtitleMode;
    }
    if (jsInjectionMode.isNotEmpty) {
      arguments['jsInjectionMode'] = jsInjectionMode;
    }
    if (jsInjection.isNotEmpty) {
      arguments['jsInjection'] = jsInjection;
    }

    Get.toNamed(
      '/webview?url=${Uri.encodeComponent(formattedUrl)}&pageTitle=${Uri.encodeComponent(title)}',
      arguments: arguments.isNotEmpty ? arguments : null,
    );
  }

  /// 保存全局 JS 注入代码
  Future<void> saveGlobalJsInjection() async {
    final String jsCode = globalJsInjectionController.text;
    await setting.put(SettingBoxKey.globalJsInjection, jsCode);
    SmartDialog.showToast('已保存');
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
