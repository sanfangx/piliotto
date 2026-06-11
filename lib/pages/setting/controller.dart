import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/models/common/theme_type.dart';
import 'package:piliotto/services/developer_mode_service.dart';
import 'package:piliotto/utils/feed_back.dart';
import 'package:piliotto/utils/login.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:piliotto/models/common/dynamic_badge_mode.dart';
import 'package:piliotto/models/common/nav_bar_config.dart';
import '../main/index.dart';
import 'widgets/select_dialog.dart';

class SettingController extends GetxController {
  Box<dynamic> userInfoCache = GStorage.userInfo;
  Box<dynamic> setting = GStorage.setting;
  Box<dynamic> localCache = GStorage.localCache;

  final DeveloperModeService _developerModeService = DeveloperModeService();

  RxBool userLogin = false.obs;
  RxBool feedBackEnable = false.obs;
  RxDouble toastOpacity = (1.0).obs;
  RxInt picQuality = 10.obs;
  Rx<ThemeType> themeType = ThemeType.system.obs;
  Object? userInfo;
  Rx<DynamicBadgeMode> dynamicBadgeType = DynamicBadgeMode.number.obs;
  RxInt defaultHomePage = 0.obs;
  RxBool isDeveloperMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    try {
      userInfo = userInfoCache.get('userInfoCache');
      userLogin.value = userInfo != null;
    } catch (e) {
      userInfo = null;
      userLogin.value = false;
    }

    try {
      feedBackEnable.value =
          setting.get(SettingBoxKey.feedBackEnable, defaultValue: false);
    } catch (e) {
      feedBackEnable.value = false;
    }

    try {
      toastOpacity.value =
          setting.get(SettingBoxKey.defaultToastOp, defaultValue: 1.0);
    } catch (e) {
      toastOpacity.value = 1.0;
    }

    try {
      picQuality.value =
          setting.get(SettingBoxKey.defaultPicQa, defaultValue: 10);
    } catch (e) {
      picQuality.value = 10;
    }

    try {
      themeType.value = ThemeType.values[setting.get(SettingBoxKey.themeMode,
          defaultValue: ThemeType.system.code)];
    } catch (e) {
      themeType.value = ThemeType.system;
    }

    try {
      dynamicBadgeType.value = DynamicBadgeMode.values[setting.get(
          SettingBoxKey.dynamicBadgeMode,
          defaultValue: DynamicBadgeMode.number.code)];
    } catch (e) {
      dynamicBadgeType.value = DynamicBadgeMode.number;
    }

    try {
      defaultHomePage.value =
          setting.get(SettingBoxKey.defaultHomePage, defaultValue: 0);
    } catch (e) {
      defaultHomePage.value = 0;
    }

    try {
      isDeveloperMode.value = _developerModeService.isDeveloperMode();
    } catch (e) {
      isDeveloperMode.value = false;
    }
  }

  Future<void> loginOut() async {
    SmartDialog.show(
      useSystem: true,
      animationType: SmartAnimationType.centerFade_otherSlide,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('提示'),
          content: const Text('确认要退出登录吗'),
          actions: [
            TextButton(
              onPressed: () => SmartDialog.dismiss(),
              child: const Text('点错了'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // 清空本地存储的用户标识
                  userInfoCache.put('userInfoCache', null);
                  localCache
                      .put(LocalCacheKey.accessKey, {'mid': -1, 'value': ''});

                  await LoginUtils.refreshLoginStatus(false);
                  userLogin.value = false; // 更新登录状态
                  SmartDialog.dismiss().then((value) => Get.back());
                } catch (e) {
                  SmartDialog.dismiss();
                  SmartDialog.showToast('退出登录失败：$e');
                }
              },
              child: const Text('确认'),
            )
          ],
        );
      },
    );
  }

  // 开启关闭震动反馈
  void onOpenFeedBack() {
    feedBack();
    feedBackEnable.value = !feedBackEnable.value;
    setting.put(SettingBoxKey.feedBackEnable, feedBackEnable.value);
  }

  // 设置动态未读标记
  Future<void> setDynamicBadgeMode(BuildContext context) async {
    DynamicBadgeMode? result = await showDialog(
      context: context,
      builder: (context) {
        return SelectDialog<DynamicBadgeMode>(
          title: '动态未读标记',
          value: dynamicBadgeType.value,
          values: DynamicBadgeMode.values.map((e) {
            return {'title': e.description, 'value': e};
          }).toList(),
        );
      },
    );
    if (result != null) {
      dynamicBadgeType.value = result;
      setting.put(SettingBoxKey.dynamicBadgeMode, result.code);
      MainController mainController = Get.put(MainController());
      mainController.dynamicBadgeType.value =
          DynamicBadgeMode.values[result.code];
      SmartDialog.showToast('设置成功');
    }
  }

  // 设置默认启动页
  Future<void> seteDefaultHomePage(BuildContext context) async {
    int? result = await showDialog(
      context: context,
      builder: (context) {
        return SelectDialog<int>(
            title: '首页启动页',
            value: defaultHomePage.value,
            values: defaultNavigationBars.map((e) {
              return {'title': e['label'], 'value': e['id']};
            }).toList());
      },
    );
    if (result != null) {
      defaultHomePage.value = result;
      setting.put(SettingBoxKey.defaultHomePage, result);
      SmartDialog.showToast('设置成功，重启生效');
    }
  }
}
