import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/constants/app_styles.dart';
import 'controller.dart';

/// 开发者选项页面
///
/// 提供开发者调试和测试功能，包括：
/// - 页面测试：路由跳转、组件展示、对话框、状态页面
/// - 内置浏览器：打开 WebView 页面
/// - 路由信息：查看当前路由栈和参数
/// - 网络调试：查看网络请求日志
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
          // 页面测试分组
          _buildSection(
            context,
            title: '页面测试',
            icon: Icons.pages_outlined,
            children: [
              _buildRouteTestTile(context, controller),
              _buildComponentTestTile(context),
              _buildDialogTestTile(context),
              _buildStatePageTestTile(context),
            ],
          ),

          // 内置浏览器分组
          _buildSection(
            context,
            title: '内置浏览器',
            icon: Icons.language_outlined,
            children: [
              _buildWebviewTile(context, controller),
            ],
          ),

          // 路由信息分组
          _buildSection(
            context,
            title: '路由信息',
            icon: Icons.route_outlined,
            children: [
              _buildRouteStackTile(context, controller),
              _buildRouteParamsTile(context, controller),
            ],
          ),

          // 网络调试分组
          _buildSection(
            context,
            title: '网络调试',
            icon: Icons.network_check_outlined,
            children: [
              _buildNetworkLogTile(context, controller),
            ],
          ),

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

  /// 构建分组标题
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: AppFontSize.lg,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        ...children,
        const Divider(height: 1),
      ],
    );
  }

  /// 构建路由跳转测试项
  Widget _buildRouteTestTile(BuildContext context, DeveloperController controller) {
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

  /// 构建组件展示测试项
  Widget _buildComponentTestTile(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(Icons.widgets_outlined, color: colorScheme.primary),
      title: const Text('组件展示测试'),
      subtitle: const Text('展示各种通用组件的效果'),
      trailing: const Icon(Icons.chevron_right_outlined),
      onTap: () {
        SmartDialog.showToast('组件展示测试页面开发中...');
      },
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

  /// 构建 WebView 测试项
  Widget _buildWebviewTile(BuildContext context, DeveloperController controller) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ExpansionTile(
      leading: Icon(Icons.public_outlined, color: colorScheme.primary),
      title: const Text('打开内置浏览器'),
      subtitle: const Text('输入 URL 打开 WebView 页面'),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: controller.webviewUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL',
                  hintText: '例如: www.example.com',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: controller.openWebview,
                icon: const Icon(Icons.open_in_browser_outlined),
                label: const Text('打开'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建路由栈信息项
  Widget _buildRouteStackTile(BuildContext context, DeveloperController controller) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(Icons.layers_outlined, color: colorScheme.primary),
      title: const Text('查看路由栈信息'),
      subtitle: const Text('显示当前路由栈的详细信息'),
      trailing: const Icon(Icons.chevron_right_outlined),
      onTap: () {
        final stackInfo = controller.getRouteStackInfo();
        _showRouteInfoDialog(context, '路由栈信息', stackInfo);
      },
    );
  }

  /// 构建路由参数项
  Widget _buildRouteParamsTile(BuildContext context, DeveloperController controller) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ListTile(
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
    );
  }

  /// 构建网络日志项
  Widget _buildNetworkLogTile(BuildContext context, DeveloperController controller) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Obx(
      () => ExpansionTile(
        leading: Icon(Icons.history_outlined, color: colorScheme.primary),
        title: const Text('网络请求日志'),
        subtitle: Text('共 ${controller.networkLogs.length} 条记录'),
        children: [
          if (controller.networkLogs.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('暂无网络请求日志'),
            )
          else
            Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.networkLogs.length > 20
                      ? 20
                      : controller.networkLogs.length,
                  itemBuilder: (context, index) {
                    final log = controller.networkLogs[index];
                    return ListTile(
                      dense: true,
                      title: Text(log['url'] ?? 'Unknown'),
                      subtitle: Text(log['method'] ?? ''),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: OutlinedButton(
                    onPressed: controller.clearNetworkLogs,
                    child: const Text('清空日志'),
                  ),
                ),
              ],
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
