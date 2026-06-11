import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/constants/app_styles.dart';
import 'package:piliotto/services/network_debug_service.dart';
import 'controller.dart';

/// 开发者选项页面
///
/// 提供开发者调试和测试功能，包括：
/// - 系统信息展示
/// - 快捷操作
/// - 调试工具
/// - 路由信息
/// - 关闭开发者模式
class DeveloperPage extends StatelessWidget {
  const DeveloperPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DeveloperController controller = Get.put(DeveloperController());
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 16,
        title: Text(
          '开发者选项',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        actions: [
          IconButton(
            onPressed: controller.loadSystemInfo,
            icon: Icon(Icons.refresh_outlined, color: colorScheme.primary),
            tooltip: '刷新',
          ),
          IconButton(
            onPressed: controller.closeDeveloperMode,
            icon: Icon(
              Icons.power_settings_new_outlined,
              color: colorScheme.primary,
            ),
            tooltip: '关闭开发者模式',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        children: [
          // 系统信息
          _buildSystemInfoSection(context, controller),

          const Divider(height: 1),

          // 快捷操作
          _buildQuickActionsSection(context, controller),

          const Divider(height: 1),

          // 调试工具
          _buildDebugToolsSection(context, controller),

          const Divider(height: 1),

          // 路由信息
          _buildRouteInfoSection(context, controller),

          // 关闭开发者模式
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton.icon(
              onPressed: controller.closeDeveloperMode,
              icon: const Icon(Icons.power_settings_new_outlined),
              label: const Text('关闭开发者模式'),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  /// 构建系统信息区域
  Widget _buildSystemInfoSection(
      BuildContext context, DeveloperController controller) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ExpansionTile(
      leading: Icon(Icons.info_outline, color: colorScheme.primary),
      title: const Text('系统信息'),
      subtitle: Obx(() => Text(
            controller.isLoadingSystemInfo.value ? '加载中...' : '设备、应用、存储信息',
          )),
      initiallyExpanded: false,
      children: [
        Obx(() {
          if (controller.isLoadingSystemInfo.value) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final info = controller.systemInfo;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 设备信息
                if (info['device'] != null) ...[
                  _buildInfoCard(context, '设备信息', info['device']!),
                  const SizedBox(height: AppSpacing.base),
                ],
                // 应用信息
                if (info['app'] != null) ...[
                  _buildInfoCard(context, '应用信息', info['app']!),
                  const SizedBox(height: AppSpacing.base),
                ],
                // 存储信息
                if (info['storage'] != null)
                  _buildInfoCard(context, '存储信息', info['storage']!),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// 构建信息卡片
  Widget _buildInfoCard(
      BuildContext context, String title, Map<String, dynamic> info) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: AppFontSize.base,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            ...info.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: AppFontSize.sm,
                            color: colorScheme.outline,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value.toString(),
                          style: const TextStyle(fontSize: AppFontSize.sm),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  /// 构建快捷操作区域
  Widget _buildQuickActionsSection(
      BuildContext context, DeveloperController controller) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(Icons.flash_on_outlined,
                  size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '快捷操作',
                style: TextStyle(
                  fontSize: AppFontSize.lg,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonal(
                onPressed: () => _showConfirmDialog(
                  context,
                  '清除缓存',
                  '确认要清除缓存吗？',
                  controller.clearCache,
                ),
                child: const Text('清除缓存'),
              ),
              FilledButton.tonal(
                onPressed: () => _showConfirmDialog(
                  context,
                  '清除存储',
                  '确认要清除所有存储吗？这将删除所有本地数据。',
                  controller.clearAllStorage,
                ),
                child: const Text('清除存储'),
              ),
              FilledButton.tonal(
                onPressed: () => _showConfirmDialog(
                  context,
                  '重置设置',
                  '确认要重置所有设置吗？',
                  controller.resetSettings,
                ),
                child: const Text('重置设置'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  /// 构建调试工具区域
  Widget _buildDebugToolsSection(
      BuildContext context, DeveloperController controller) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(Icons.build_outlined, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '调试工具',
                style: TextStyle(
                  fontSize: AppFontSize.lg,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        // 网络调试
        ListTile(
          leading:
              Icon(Icons.network_check_outlined, color: colorScheme.primary),
          title: const Text('网络调试'),
          subtitle: Obx(() {
            try {
              final service = Get.find<NetworkDebugService>();
              final stats = service.getStatistics();
              return Text('共 ${stats['total']} 条请求');
            } catch (e) {
              return const Text('查看网络请求日志');
            }
          }),
          trailing: const Icon(Icons.chevron_right_outlined),
          onTap: controller.openNetworkDebug,
        ),
        // 性能分析
        ListTile(
          leading: Icon(Icons.speed_outlined, color: colorScheme.primary),
          title: const Text('性能分析'),
          subtitle: const Text('帧率、内存、启动耗时'),
          trailing: const Icon(Icons.chevron_right_outlined),
          onTap: controller.openPerformance,
        ),
        // 浏览器测试
        _buildBrowserTestTile(context, controller),
        // 路由跳转测试
        _buildRouteTestTile(context, controller),
        // 对话框测试
        _buildDialogTestTile(context),
        // 状态页面测试
        _buildStatePageTestTile(context),
      ],
    );
  }

  /// 构建浏览器测试项
  Widget _buildBrowserTestTile(
      BuildContext context, DeveloperController controller) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ExpansionTile(
      leading: Icon(Icons.language_outlined, color: colorScheme.primary),
      title: const Text('浏览器测试'),
      subtitle: const Text('输入 URL 测试 WebView 页面'),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: controller.browserUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL',
                  hintText: '例如: https://example.com',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.browserTitleController,
                decoration: const InputDecoration(
                  labelText: '页面标题（可选）',
                  hintText: '显示在 AppBar 的标题',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              // 主标题模式选择
              DropdownButtonFormField<String>(
                initialValue: controller.browserTitleModeController.text.isEmpty
                    ? null
                    : controller.browserTitleModeController.text,
                decoration: const InputDecoration(
                  labelText: '主标题模式（可选）',
                  hintText: '留空则使用默认配置',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: 'fixed', child: Text('固定文本')),
                  DropdownMenuItem(value: 'webTitle', child: Text('网页名称')),
                ],
                onChanged: (value) {
                  controller.browserTitleModeController.text = value ?? '';
                },
              ),
              const SizedBox(height: 12),
              // 副标题模式选择
              DropdownButtonFormField<String>(
                initialValue:
                    controller.browserSubtitleModeController.text.isEmpty
                        ? null
                        : controller.browserSubtitleModeController.text,
                decoration: const InputDecoration(
                  labelText: '副标题模式（可选）',
                  hintText: '留空则使用默认配置',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: 'fixed', child: Text('固定文本')),
                  DropdownMenuItem(value: 'webTitle', child: Text('网页名称')),
                  DropdownMenuItem(value: 'webUrl', child: Text('网页链接')),
                  DropdownMenuItem(value: 'none', child: Text('无副标题')),
                ],
                onChanged: (value) {
                  controller.browserSubtitleModeController.text = value ?? '';
                },
              ),
              const SizedBox(height: 12),
              // JS 注入模式选择
              DropdownButtonFormField<String>(
                initialValue:
                    controller.browserJsInjectionModeController.text.isEmpty
                        ? null
                        : controller.browserJsInjectionModeController.text,
                decoration: const InputDecoration(
                  labelText: 'JS 注入模式（可选）',
                  hintText: '留空则使用默认配置',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'override', child: Text('override - 只执行调用时 JS')),
                  DropdownMenuItem(
                      value: 'merge', child: Text('merge - 先全局再调用时')),
                  DropdownMenuItem(
                      value: 'globalOnly',
                      child: Text('globalOnly - 只执行全局 JS')),
                  DropdownMenuItem(
                      value: 'callOnly', child: Text('callOnly - 只执行调用时 JS')),
                ],
                onChanged: (value) {
                  controller.browserJsInjectionModeController.text =
                      value ?? '';
                },
              ),
              const SizedBox(height: 12),
              // 调用时 JS 代码输入
              TextField(
                controller: controller.browserJsInjectionController,
                maxLines: 4,
                minLines: 2,
                decoration: const InputDecoration(
                  labelText: '调用时 JS 代码（可选）',
                  hintText: '例如: console.log("Hello");',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: controller.openBrowserTest,
                icon: const Icon(Icons.open_in_browser_outlined),
                label: const Text('打开'),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              // 全局 JS 注入配置
              Row(
                children: [
                  Icon(Icons.code_outlined,
                      size: 18, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '全局 JS 注入',
                    style: TextStyle(
                      fontSize: AppFontSize.base,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '输入的 JavaScript 代码将在所有网页加载时自动执行',
                style: TextStyle(
                  fontSize: AppFontSize.sm,
                  color: colorScheme.outline,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller.globalJsInjectionController,
                maxLines: 6,
                minLines: 4,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '// 在此输入 JS 代码\n// 例如:\n// console.log("Hello");',
                  alignLabelWithHint: true,
                ),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonal(
                  onPressed: controller.saveGlobalJsInjection,
                  child: const Text('保存 JS 代码'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建路由跳转测试项
  Widget _buildRouteTestTile(
      BuildContext context, DeveloperController controller) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ExpansionTile(
      leading: Icon(Icons.route_outlined, color: colorScheme.primary),
      title: const Text('路由跳转测试'),
      subtitle: const Text('输入路由路径和参数进行跳转'),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: controller.routePathController,
                decoration: const InputDecoration(
                  labelText: '路由路径',
                  hintText: '例如: /setting',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.routeParamsController,
                decoration: const InputDecoration(
                  labelText: '路由参数',
                  hintText: '格式: key1=value1,key2=value2',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: controller.navigateToRoute,
                icon: const Icon(Icons.arrow_forward_outlined),
                label: const Text('跳转'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建对话框测试项
  Widget _buildDialogTestTile(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ExpansionTile(
      leading: Icon(Icons.chat_bubble_outline, color: colorScheme.primary),
      title: const Text('对话框测试'),
      subtitle: const Text('测试各种对话框、弹窗'),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: () => _showTestAlertDialog(context),
                child: const Text('AlertDialog'),
              ),
              FilledButton(
                onPressed: () => _showTestBottomSheet(context),
                child: const Text('BottomSheet'),
              ),
              FilledButton(
                onPressed: () => SmartDialog.showToast('Toast 测试'),
                child: const Text('Toast'),
              ),
              FilledButton(
                onPressed: () => SmartDialog.showLoading(msg: '加载中...'),
                child: const Text('Loading'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建状态页面测试项
  Widget _buildStatePageTestTile(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ExpansionTile(
      leading: Icon(Icons.error_outline, color: colorScheme.primary),
      title: const Text('状态页面测试'),
      subtitle: const Text('展示错误页面、空状态等'),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: () => _showErrorPage(context),
                child: const Text('错误页面'),
              ),
              FilledButton(
                onPressed: () => _showEmptyPage(context),
                child: const Text('空状态'),
              ),
              FilledButton(
                onPressed: () => _showNoNetworkPage(context),
                child: const Text('无网络'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建路由信息区域
  Widget _buildRouteInfoSection(
      BuildContext context, DeveloperController controller) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(Icons.route_outlined, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '路由信息',
                style: TextStyle(
                  fontSize: AppFontSize.lg,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        ListTile(
          leading: Icon(Icons.layers_outlined, color: colorScheme.primary),
          title: const Text('查看路由栈信息'),
          subtitle: const Text('显示当前路由栈的详细信息'),
          trailing: const Icon(Icons.chevron_right_outlined),
          onTap: () {
            final stackInfo = controller.getRouteStackInfo();
            _showRouteInfoDialog(context, '路由栈信息', stackInfo);
          },
        ),
        ListTile(
          leading: Icon(Icons.data_object_outlined, color: colorScheme.primary),
          title: const Text('查看当前路由参数'),
          subtitle: const Text('显示当前页面的路由参数'),
          trailing: const Icon(Icons.chevron_right_outlined),
          onTap: () {
            final params = controller.getCurrentRouteParameters();
            _showRouteInfoDialog(
              context,
              '路由参数',
              params != null ? [params] : [],
            );
          },
        ),
      ],
    );
  }

  /// 显示确认对话框
  void _showConfirmDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  /// 显示测试 AlertDialog
  void _showTestAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('测试对话框'),
        content: const Text('这是一个测试 AlertDialog'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  /// 显示测试 BottomSheet
  void _showTestBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('测试 BottomSheet', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            const Text('这是一个测试 BottomSheet 内容'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示错误页面
  void _showErrorPage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              const Text('出错了', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              const Text('这是一个错误状态页面示例'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('关闭'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 显示空状态页面
  void _showEmptyPage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              const Text('暂无数据', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              const Text('这是一个空状态页面示例'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('关闭'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 显示无网络页面
  void _showNoNetworkPage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              const Text('网络连接失败', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              const Text('请检查网络设置后重试'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 显示路由信息对话框
  void _showRouteInfoDialog(
    BuildContext context,
    String title,
    List<Map<String, dynamic>> info,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: info.isEmpty
                ? [const Text('暂无信息')]
                : info.map((item) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: item.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            '${entry.key}: ${entry.value}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                    );
                  }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
