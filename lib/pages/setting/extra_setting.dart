import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/models/common/reply_sort_type.dart';
import 'package:piliotto/pages/setting/widgets/select_dialog.dart';
import 'package:piliotto/utils/storage.dart';

import 'controller.dart';
import 'widgets/switch_item.dart';

class ExtraSetting extends StatefulWidget {
  const ExtraSetting({super.key});

  @override
  State<ExtraSetting> createState() => _ExtraSettingState();
}

class _ExtraSettingState extends State<ExtraSetting> {
  final SettingController settingController = Get.find<SettingController>();
  Box<dynamic> setting = GStorage.setting;
  late int defaultReplySort;

  @override
  void initState() {
    super.initState();
    defaultReplySort =
        setting.get(SettingBoxKey.replySortType, defaultValue: 0);
    if (defaultReplySort == 2) {
      setting.put(SettingBoxKey.replySortType, 0);
      defaultReplySort = 0;
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
          '其他设置',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: ListView(
        children: [
          Obx(
            () => ListTile(
              enableFeedback: true,
              onTap: () => settingController.onOpenFeedBack(),
              title: const Text('震动反馈'),
              subtitle: Text('请确定手机设置中已开启震动反馈', style: subTitleStyle),
              trailing: Transform.scale(
                alignment: Alignment.centerRight,
                scale: 0.8,
                child: Switch(
                  thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
                    (Set<WidgetState> states) {
                      if (states.isNotEmpty && states.first == WidgetState.selected) {
                        return const Icon(Icons.done);
                      }
                      return null;
                    },
                  ),
                  value: settingController.feedBackEnable.value,
                  onChanged: (value) => settingController.onOpenFeedBack(),
                ),
              ),
            ),
          ),
          const SetSwitchItem(
            title: '相关视频推荐',
            subTitle: '视频详情页推荐相关视频',
            setKey: SettingBoxKey.enableRelatedVideo,
            defaultVal: true,
          ),
          ListTile(
            dense: false,
            title: Text('推荐过滤设置', style: titleStyle),
            subtitle: Text(
              '过滤推荐视频的最小时长和点赞率',
              style: subTitleStyle,
            ),
            onTap: () {
              Get.toNamed('/recommendFilterSetting');
            },
          ),
          ListTile(
            dense: false,
            title: Text('评论展示', style: titleStyle),
            subtitle: Text(
              '当前优先展示「${ReplySortType.values[defaultReplySort].titles}」',
              style: subTitleStyle,
            ),
            onTap: () async {
              int? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<int>(
                      title: '评论展示',
                      value: defaultReplySort,
                      values: ReplySortType.values.map((e) {
                        return {'title': e.titles, 'value': e.index};
                      }).toList());
                },
              );
              if (result != null) {
                defaultReplySort = result;
                setting.put(SettingBoxKey.replySortType, result);
                setState(() {});
              }
            },
          ),
          const SetSwitchItem(
            title: '检查更新',
            subTitle: '每次启动时检查是否需要更新',
            setKey: SettingBoxKey.autoUpdate,
            defaultVal: false,
          ),
        ],
      ),
    );
  }
}
