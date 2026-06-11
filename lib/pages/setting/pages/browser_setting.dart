import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/pages/setting/widgets/select_dialog.dart';
import 'package:piliotto/pages/setting/widgets/switch_item.dart';
import 'package:piliotto/utils/storage.dart';

/// 主标题模式枚举
enum TitleMode {
  fixed('固定文本', 'fixed'),
  webTitle('网页名称', 'webTitle');

  final String label;
  final String value;
  const TitleMode(this.label, this.value);
}

/// 副标题模式枚举
enum SubtitleMode {
  fixed('固定文本', 'fixed'),
  webTitle('网页名称', 'webTitle'),
  webUrl('网页链接', 'webUrl'),
  none('无副标题', 'none');

  final String label;
  final String value;
  const SubtitleMode(this.label, this.value);
}

class BrowserSettingPage extends StatefulWidget {
  const BrowserSettingPage({super.key});

  @override
  State<BrowserSettingPage> createState() => _BrowserSettingPageState();
}

class _BrowserSettingPageState extends State<BrowserSettingPage> {
  Box<dynamic> setting = GStorage.setting;
  late String titleMode;
  late String subtitleMode;

  @override
  void initState() {
    super.initState();
    titleMode = setting.get(
      SettingBoxKey.titleMode,
      defaultValue: TitleMode.fixed.value,
    );
    subtitleMode = setting.get(
      SettingBoxKey.subtitleMode,
      defaultValue: SubtitleMode.none.value,
    );
  }

  /// 获取主标题模式的显示文本
  String getTitleModeLabel() {
    switch (titleMode) {
      case 'fixed':
        return TitleMode.fixed.label;
      case 'webTitle':
        return TitleMode.webTitle.label;
      default:
        return TitleMode.fixed.label;
    }
  }

  /// 获取副标题模式的显示文本
  String getSubtitleModeLabel() {
    switch (subtitleMode) {
      case 'fixed':
        return SubtitleMode.fixed.label;
      case 'webTitle':
        return SubtitleMode.webTitle.label;
      case 'webUrl':
        return SubtitleMode.webUrl.label;
      case 'none':
        return SubtitleMode.none.label;
      default:
        return SubtitleMode.none.label;
    }
  }

  /// 保存设置
  Future<void> _saveSettings() async {
    await setting.put(SettingBoxKey.titleMode, titleMode);
    await setting.put(SettingBoxKey.subtitleMode, subtitleMode);
    SmartDialog.showToast('保存成功');
  }

  /// 显示主标题模式选择对话框
  Future<void> _showTitleModeDialog() async {
    String? result = await showDialog(
      context: context,
      builder: (context) {
        return SelectDialog<String>(
          title: '主标题模式',
          value: titleMode,
          values: TitleMode.values.map((e) {
            return {'title': e.label, 'value': e.value};
          }).toList(),
        );
      },
    );
    if (result != null) {
      titleMode = result;
      await setting.put(SettingBoxKey.titleMode, result);
      setState(() {});
    }
  }

  /// 显示副标题模式选择对话框
  Future<void> _showSubtitleModeDialog() async {
    String? result = await showDialog(
      context: context,
      builder: (context) {
        return SelectDialog<String>(
          title: '副标题模式',
          value: subtitleMode,
          values: SubtitleMode.values.map((e) {
            return {'title': e.label, 'value': e.value};
          }).toList(),
        );
      },
    );
    if (result != null) {
      subtitleMode = result;
      await setting.put(SettingBoxKey.subtitleMode, result);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = Theme.of(context).textTheme.titleMedium!;
    TextStyle subTitleStyle = Theme.of(context)
        .textTheme
        .labelMedium!
        .copyWith(color: Theme.of(context).colorScheme.outline);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          '浏览器设置',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text('保存'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: ListView(
        children: [
          // 说明提示
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '以下配置为默认值，调用时可通过参数覆盖',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 主标题模式（默认）
          ListTile(
            dense: false,
            title: Text('主标题模式（默认）', style: titleStyle),
            subtitle: Text(
              '当前: ${getTitleModeLabel()}',
              style: subTitleStyle,
            ),
            onTap: _showTitleModeDialog,
            trailing: const Icon(Icons.arrow_forward_rounded, size: 22),
          ),

          // 副标题模式（默认）
          ListTile(
            dense: false,
            title: Text('副标题模式（默认）', style: titleStyle),
            subtitle: Text(
              '当前: ${getSubtitleModeLabel()}',
              style: subTitleStyle,
            ),
            onTap: _showSubtitleModeDialog,
            trailing: const Icon(Icons.arrow_forward_rounded, size: 22),
          ),

          const Divider(),

          // 其他浏览器设置项（默认）
          const SetSwitchItem(
            title: '启用 JavaScript（默认）',
            subTitle: '允许网页执行 JavaScript 代码',
            setKey: 'browserEnableJs',
            defaultVal: true,
          ),

          const SetSwitchItem(
            title: '启用缓存（默认）',
            subTitle: '缓存网页资源以加快加载速度',
            setKey: 'browserEnableCache',
            defaultVal: true,
          ),

          const SetSwitchItem(
            title: '允许缩放（默认）',
            subTitle: '允许用户缩放网页内容',
            setKey: 'browserAllowZoom',
            defaultVal: true,
          ),

          const SetSwitchItem(
            title: '自动播放媒体（默认）',
            subTitle: '允许网页自动播放音视频',
            setKey: 'browserAutoPlayMedia',
            defaultVal: false,
          ),

          const Divider(),

          // User-Agent 设置（默认）
          ListTile(
            dense: false,
            title: Text('User-Agent（默认）', style: titleStyle),
            subtitle: Text(
              '自定义浏览器 User-Agent 标识',
              style: subTitleStyle,
            ),
            onTap: _showUserAgentDialog,
            trailing: const Icon(Icons.arrow_forward_rounded, size: 22),
          ),
        ],
      ),
    );
  }

  /// 显示 User-Agent 编辑对话框
  Future<void> _showUserAgentDialog() async {
    String userAgent = setting.get('browserUserAgent', defaultValue: '');
    final TextEditingController controller = TextEditingController(text: userAgent);

    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('User-Agent'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '留空则使用默认 User-Agent',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  maxLines: 3,
                  minLines: 1,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Mozilla/5.0 ...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, controller.text);
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      await setting.put('browserUserAgent', result);
      setState(() {});
      SmartDialog.showToast('已保存');
    }
  }
}
