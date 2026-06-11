import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:piliotto/utils/recommend_filter.dart';

import '../widgets/switch_item.dart';

class RecommendFilterSetting extends StatefulWidget {
  const RecommendFilterSetting({super.key});

  @override
  State<RecommendFilterSetting> createState() => _RecommendFilterSettingState();
}

class _RecommendFilterSettingState extends State<RecommendFilterSetting> {
  Box<dynamic> setting = GStorage.setting;
  late int minDurationForRcmd;
  late int minLikeRatioForRecommend;
  late bool exemptFilterForFollowed;
  late bool applyFilterToRelatedVideos;

  @override
  void initState() {
    super.initState();
    minDurationForRcmd = setting.get(SettingBoxKey.minDurationForRcmd, defaultValue: 0);
    minLikeRatioForRecommend = setting.get(SettingBoxKey.minLikeRatioForRecommend, defaultValue: 0);
    exemptFilterForFollowed = setting.get(SettingBoxKey.exemptFilterForFollowed, defaultValue: true);
    applyFilterToRelatedVideos = setting.get(SettingBoxKey.applyFilterToRelatedVideos, defaultValue: true);
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
          '推荐过滤设置',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            dense: false,
            title: Text('最小时长（秒）', style: titleStyle),
            subtitle: Text(
              '过滤时长小于此值的视频，当前：$minDurationForRcmd 秒',
              style: subTitleStyle,
            ),
            onTap: () async {
              int? result = await showDialog(
                context: context,
                builder: (context) {
                  int tempValue = minDurationForRcmd;
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        title: const Text('最小时长'),
                        content: TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: '请输入秒数',
                            suffixText: '秒',
                          ),
                          controller: TextEditingController(text: tempValue.toString()),
                          onChanged: (value) {
                            tempValue = int.tryParse(value) ?? 0;
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.back(result: tempValue);
                            },
                            child: const Text('确定'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
              if (result != null) {
                minDurationForRcmd = result;
                setting.put(SettingBoxKey.minDurationForRcmd, result);
                RecommendFilter.update();
                setState(() {});
                SmartDialog.showToast('设置成功');
              }
            },
          ),
          ListTile(
            dense: false,
            title: Text('最小点赞率（%）', style: titleStyle),
            subtitle: Text(
              '过滤点赞率小于此值的视频，当前：$minLikeRatioForRecommend %',
              style: subTitleStyle,
            ),
            onTap: () async {
              int? result = await showDialog(
                context: context,
                builder: (context) {
                  int tempValue = minLikeRatioForRecommend;
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        title: const Text('最小点赞率'),
                        content: TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: '请输入百分比',
                            suffixText: '%',
                          ),
                          controller: TextEditingController(text: tempValue.toString()),
                          onChanged: (value) {
                            tempValue = int.tryParse(value) ?? 0;
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.back(result: tempValue);
                            },
                            child: const Text('确定'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
              if (result != null) {
                minLikeRatioForRecommend = result;
                setting.put(SettingBoxKey.minLikeRatioForRecommend, result);
                RecommendFilter.update();
                setState(() {});
                SmartDialog.showToast('设置成功');
              }
            },
          ),
          SetSwitchItem(
            title: '关注豁免',
            subTitle: '已关注用户的视频不受过滤影响',
            setKey: SettingBoxKey.exemptFilterForFollowed,
            defaultVal: true,
            callFn: (val) {
              RecommendFilter.update();
            },
          ),
          SetSwitchItem(
            title: '相关视频过滤',
            subTitle: '对相关推荐视频也应用过滤规则',
            setKey: SettingBoxKey.applyFilterToRelatedVideos,
            defaultVal: true,
            callFn: (val) {
              RecommendFilter.update();
            },
          ),
        ],
      ),
    );
  }
}
