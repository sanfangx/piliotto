import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/constants/app_styles.dart';
import 'package:piliotto/services/network_debug_service.dart';

/// 网络调试页面
///
/// 显示网络请求日志列表，支持过滤和搜索
class NetworkDebugPage extends StatelessWidget {
  const NetworkDebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    final NetworkDebugService service = Get.find<NetworkDebugService>();
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 16,
        title: Text(
          '网络调试',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        actions: [
          IconButton(
            onPressed: () => _showClearConfirmDialog(context, service),
            icon: Icon(Icons.delete_outline, color: colorScheme.primary),
            tooltip: '清空日志',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 过滤器和搜索
          _buildFilterBar(context, service),

          // 统计信息
          _buildStatisticsBar(context, service),

          // 日志列表
          Expanded(
            child: Obx(() {
              final logs = service.getFilteredLogs();
              if (logs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.network_check_outlined,
                        size: 64,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(height: AppSpacing.base),
                      Text(
                        '暂无网络请求日志',
                        style: TextStyle(color: colorScheme.outline),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  return _buildLogItem(context, logs[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 构建过滤栏
  Widget _buildFilterBar(BuildContext context, NetworkDebugService service) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        children: [
          // 过滤按钮
          Obx(() => Row(
                children: [
                  _buildFilterChip(context, service, '全部', 'all'),
                  const SizedBox(width: AppSpacing.sm),
                  _buildFilterChip(context, service, '成功', 'success'),
                  const SizedBox(width: AppSpacing.sm),
                  _buildFilterChip(context, service, '失败', 'error'),
                  const SizedBox(width: AppSpacing.sm),
                  _buildFilterChip(context, service, '进行中', 'pending'),
                ],
              )),
          const SizedBox(height: AppSpacing.sm),
          // 搜索框
          TextField(
            decoration: InputDecoration(
              hintText: '搜索 URL、方法、请求体...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Obx(() => service.searchKeyword.value.isNotEmpty
                  ? IconButton(
                      onPressed: () => service.searchKeyword.value = '',
                      icon: const Icon(Icons.clear),
                    )
                  : const SizedBox.shrink()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              isDense: true,
            ),
            onChanged: (value) => service.searchKeyword.value = value,
          ),
        ],
      ),
    );
  }

  /// 构建过滤按钮
  Widget _buildFilterChip(
    BuildContext context,
    NetworkDebugService service,
    String label,
    String type,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final isSelected = service.filterType.value == type;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => service.filterType.value = type,
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.onPrimaryContainer,
    );
  }

  /// 构建统计栏
  Widget _buildStatisticsBar(BuildContext context, NetworkDebugService service) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final stats = service.getStatistics();
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            bottom: BorderSide(color: colorScheme.outlineVariant),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(context, '总计', stats['total']!, colorScheme.onSurface),
            _buildStatItem(context, '成功', stats['success']!, Colors.green),
            _buildStatItem(context, '失败', stats['error']!, colorScheme.error),
            _buildStatItem(context, '进行中', stats['pending']!, Colors.orange),
          ],
        ),
      );
    });
  }

  /// 构建统计项
  Widget _buildStatItem(
    BuildContext context,
    String label,
    int value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: AppFontSize.lg,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: AppFontSize.xs,
            color: color,
          ),
        ),
      ],
    );
  }

  /// 构建日志项
  Widget _buildLogItem(BuildContext context, NetworkLog log) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // 根据状态选择颜色
    Color statusColor;
    if (log.isError) {
      statusColor = colorScheme.error;
    } else if (log.statusCode != null && log.statusCode! >= 400) {
      statusColor = Colors.orange;
    } else if (log.statusCode != null) {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.grey;
    }

    return ListTile(
      dense: true,
      leading: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          log.method,
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.bold,
            fontSize: AppFontSize.xs,
          ),
        ),
      ),
      title: Text(
        _shortenUrl(log.url),
        style: const TextStyle(fontSize: AppFontSize.sm),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${log.statusText} · ${log.durationText}',
        style: TextStyle(
          fontSize: AppFontSize.xs,
          color: statusColor,
        ),
      ),
      trailing: Text(
        _formatTime(log.timestamp),
        style: TextStyle(
          fontSize: AppFontSize.xs,
          color: colorScheme.outline,
        ),
      ),
      onTap: () => _showLogDetail(context, log),
    );
  }

  /// 缩短 URL 显示
  String _shortenUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    return uri.path + (uri.query.isNotEmpty ? '?${uri.query}' : '');
  }

  /// 格式化时间
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  /// 显示日志详情
  void _showLogDetail(BuildContext context, NetworkLog log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _LogDetailSheet(
          log: log,
          scrollController: scrollController,
        ),
      ),
    );
  }

  /// 显示清空确认对话框
  void _showClearConfirmDialog(
    BuildContext context,
    NetworkDebugService service,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空日志'),
        content: const Text('确认要清空所有网络请求日志吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              service.clearLogs();
              Navigator.pop(context);
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }
}

/// 日志详情底部弹窗
class _LogDetailSheet extends StatelessWidget {
  final NetworkLog log;
  final ScrollController scrollController;

  const _LogDetailSheet({
    required this.log,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // 拖动指示器
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    log.method,
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    log.url,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // 内容
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                // 基本信息
                _buildSection('基本信息', [
                  _buildKeyValue('状态码', log.statusCode?.toString() ?? 'N/A'),
                  _buildKeyValue('耗时', log.durationText),
                  _buildKeyValue('时间', log.timestamp.toString()),
                  if (log.errorMessage != null)
                    _buildKeyValue('错误', log.errorMessage!),
                ]),

                // 请求头
                _buildSection('请求头', _buildMapEntries(log.headers)),

                // 请求体
                if (log.requestBody != null)
                  _buildSection('请求体', [_buildCodeBlock(log.requestBody)]),

                // 响应头
                if (log.responseHeaders != null)
                  _buildSection('响应头', _buildMapEntries(log.responseHeaders!)),

                // 响应体
                if (log.responseBody != null)
                  _buildSection('响应体', [_buildCodeBlock(log.responseBody)]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildKeyValue(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              key,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMapEntries(Map<String, dynamic> map) {
    return map.entries.map((entry) {
      return _buildKeyValue(entry.key, entry.value.toString());
    }).toList();
  }

  Widget _buildCodeBlock(dynamic data) {
    final content = data is String ? data : data.toString();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SelectableText(
        content,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
        ),
      ),
    );
  }
}
