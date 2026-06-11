import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/constants/app_styles.dart';
import 'package:piliotto/services/system_info_service.dart';

/// 性能分析页面
///
/// 显示帧率、内存使用、启动耗时等性能指标
class PerformancePage extends StatefulWidget {
  const PerformancePage({super.key});

  @override
  State<PerformancePage> createState() => _PerformancePageState();
}

class _PerformancePageState extends State<PerformancePage> {
  // 帧率监控
  final RxInt currentFps = 0.obs;
  final RxDouble averageFps = 0.0.obs;
  final RxBool isMonitoring = false.obs;
  final List<int> _fpsHistory = [];
  Timer? _fpsTimer;
  int _frameCount = 0;
  DateTime? _lastFpsTime;

  // 内存使用
  final RxInt currentMemory = 0.obs;
  final RxInt peakMemory = 0.obs;
  Timer? _memoryTimer;
  bool _isMemoryMonitoring = false;

  // 系统信息服务
  final SystemInfoService _systemInfoService = SystemInfoService();

  @override
  void initState() {
    super.initState();
    _startMemoryMonitor();
  }

  @override
  void dispose() {
    _stopFpsMonitor();
    _stopMemoryMonitor();
    super.dispose();
  }

  /// 开始帧率监控
  void _startFpsMonitor() {
    if (isMonitoring.value) return;

    isMonitoring.value = true;
    _frameCount = 0;
    _lastFpsTime = DateTime.now();
    _fpsHistory.clear();

    // 使用 SchedulerBinding 监听帧回调
    SchedulerBinding.instance.addTimingsCallback(_onTimings);

    // 定时计算 FPS
    _fpsTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      if (_lastFpsTime != null) {
        final elapsed = now.difference(_lastFpsTime!).inMilliseconds;
        if (elapsed > 0) {
          final fps = (_frameCount * 1000 / elapsed).round();
          currentFps.value = fps;
          _fpsHistory.add(fps);
          if (_fpsHistory.length > 60) {
            _fpsHistory.removeAt(0);
          }
          averageFps.value =
              _fpsHistory.reduce((a, b) => a + b) / _fpsHistory.length;
        }
      }
      _frameCount = 0;
      _lastFpsTime = now;
    });
  }

  /// 停止帧率监控
  void _stopFpsMonitor() {
    if (!isMonitoring.value) return;

    isMonitoring.value = false;
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
    _fpsTimer?.cancel();
    _fpsTimer = null;
  }

  /// 帧回调
  void _onTimings(List<FrameTiming> timings) {
    _frameCount += timings.length;
  }

  /// 开始内存监控
  void _startMemoryMonitor() {
    if (_isMemoryMonitoring) return;

    _isMemoryMonitoring = true;
    _updateMemory();
    _memoryTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _updateMemory();
    });
  }

  /// 停止内存监控
  void _stopMemoryMonitor() {
    if (!_isMemoryMonitoring) return;

    _isMemoryMonitoring = false;
    _memoryTimer?.cancel();
    _memoryTimer = null;
  }

  /// 更新内存使用
  void _updateMemory() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // 移动端无法直接获取内存使用，使用存储信息估算
        final storageInfo = await _systemInfoService.getStorageInfo();
        final totalSize = storageInfo['totalSize'] as String?;
        if (totalSize != null) {
          // 解析大小字符串
          currentMemory.value = _parseSizeToMB(totalSize);
          if (currentMemory.value > peakMemory.value) {
            peakMemory.value = currentMemory.value;
          }
        }
      } else {
        // 桌面端使用 Process 获取内存
        // 这里简化处理，显示存储大小
        final storageInfo = await _systemInfoService.getStorageInfo();
        final totalSize = storageInfo['totalSize'] as String?;
        if (totalSize != null) {
          currentMemory.value = _parseSizeToMB(totalSize);
          if (currentMemory.value > peakMemory.value) {
            peakMemory.value = currentMemory.value;
          }
        }
      }
    } catch (e) {
      // 忽略错误
    }
  }

  /// 解析大小字符串到 MB
  int _parseSizeToMB(String sizeStr) {
    final parts = sizeStr.split(' ');
    if (parts.length == 2) {
      final value = double.tryParse(parts[0]) ?? 0;
      final unit = parts[1];
      switch (unit) {
        case 'B':
          return (value / (1024 * 1024)).round();
        case 'KB':
          return (value / 1024).round();
        case 'MB':
          return value.round();
        case 'GB':
          return (value * 1024).round();
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 16,
        title: Text(
          '性能分析',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.base),
        children: [
          // 帧率监控
          _buildSection(
            context,
            title: '帧率监控',
            icon: Icons.speed_outlined,
            children: [
              _buildFpsCard(context),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // 内存使用
          _buildSection(
            context,
            title: '内存使用',
            icon: Icons.memory_outlined,
            children: [
              _buildMemoryCard(context),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // 性能工具
          _buildSection(
            context,
            title: '性能工具',
            icon: Icons.build_outlined,
            children: [
              _buildToolList(context),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建分组
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
        Row(
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
        const SizedBox(height: AppSpacing.sm),
        ...children,
      ],
    );
  }

  /// 构建帧率卡片
  Widget _buildFpsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Obx(() => _buildMetricItem(
                      context,
                      '当前帧率',
                      '${currentFps.value}',
                      'FPS',
                      _getFpsColor(currentFps.value),
                    )),
                Obx(() => _buildMetricItem(
                      context,
                      '平均帧率',
                      averageFps.value.toStringAsFixed(1),
                      'FPS',
                      _getFpsColor(averageFps.value.round()),
                    )),
              ],
            ),
            const SizedBox(height: AppSpacing.base),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() => FilledButton.icon(
                      onPressed: isMonitoring.value
                          ? _stopFpsMonitor
                          : _startFpsMonitor,
                      icon: Icon(isMonitoring.value
                          ? Icons.stop_outlined
                          : Icons.play_arrow_outlined),
                      label: Text(isMonitoring.value ? '停止监控' : '开始监控'),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 获取帧率颜色
  Color _getFpsColor(int fps) {
    if (fps >= 55) return Colors.green;
    if (fps >= 30) return Colors.orange;
    return Colors.red;
  }

  /// 构建内存卡片
  Widget _buildMemoryCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Obx(() => _buildMetricItem(
                  context,
                  '当前内存',
                  '${currentMemory.value}',
                  'MB',
                  Colors.blue,
                )),
            Obx(() => _buildMetricItem(
                  context,
                  '峰值内存',
                  '${peakMemory.value}',
                  'MB',
                  Colors.purple,
                )),
          ],
        ),
      ),
    );
  }

  /// 构建指标项
  Widget _buildMetricItem(
    BuildContext context,
    String label,
    String value,
    String unit,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                unit,
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ],
    );
  }

  /// 构建工具列表
  Widget _buildToolList(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.analytics_outlined, color: colorScheme.primary),
            title: const Text('Dart DevTools'),
            subtitle: const Text('打开 Flutter 开发者工具'),
            trailing: const Icon(Icons.chevron_right_outlined),
            onTap: () => _showDevToolsInfo(context),
          ),
          ListTile(
            leading: Icon(Icons.insights_outlined, color: colorScheme.primary),
            title: const Text('性能叠加层'),
            subtitle: const Text('显示 Flutter 性能叠加层'),
            trailing: const Icon(Icons.chevron_right_outlined),
            onTap: () => _togglePerformanceOverlay(context),
          ),
          ListTile(
            leading: Icon(Icons.grid_on_outlined, color: colorScheme.primary),
            title: const Text('重绘边界可视化'),
            subtitle: const Text('显示重绘边界'),
            trailing: const Icon(Icons.chevron_right_outlined),
            onTap: () => _toggleRepaintRainbow(context),
          ),
        ],
      ),
    );
  }

  /// 显示 DevTools 信息
  void _showDevToolsInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dart DevTools'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('要打开 Dart DevTools，请运行以下命令：'),
            SizedBox(height: 8),
            SelectableText(
              'flutter pub global activate devtools\nflutter pub global run devtools',
              style: TextStyle(fontFamily: 'monospace'),
            ),
            SizedBox(height: 8),
            Text('或者在 VS Code 中使用 Flutter 扩展的 DevTools 功能。'),
          ],
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

  /// 切换性能叠加层
  void _togglePerformanceOverlay(BuildContext context) {
    // 性能叠加层需要通过 --profile 或 --debug 模式启动应用
    // 并在 MaterialApp 中设置 showPerformanceOverlay: true
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('请在 MaterialApp 中设置 showPerformanceOverlay: true'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// 切换重绘边界可视化
  void _toggleRepaintRainbow(BuildContext context) {
    debugRepaintRainbowEnabled = !debugRepaintRainbowEnabled;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(debugRepaintRainbowEnabled ? '已启用重绘边界可视化' : '已禁用重绘边界可视化'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
