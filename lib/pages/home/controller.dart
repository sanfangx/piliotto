import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/models/common/tab_type.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:piliotto/repositories/i_video_repository.dart';
import 'package:piliotto/repositories/i_message_repository.dart';

class HomeController extends GetxController with GetTickerProviderStateMixin {
  final IVideoRepository _videoRepo = Get.find<IVideoRepository>();
  final IMessageRepository _messageRepo = Get.find<IMessageRepository>();
  bool flag = false;
  late RxList tabs = [].obs;
  RxInt initialIndex = 1.obs;
  late TabController tabController;
  late List tabsCtrList;
  late List<Widget> tabsPageList;
  Box userInfoCache = GStorage.userInfo;
  Box settingStorage = GStorage.setting;
  RxBool userLogin = false.obs;
  RxString userFace = ''.obs;
  dynamic userInfo;
  Box setting = GStorage.setting;
  late final StreamController<bool> searchBarStream =
      StreamController<bool>.broadcast();
  late bool hideSearchBar;
  late List defaultTabs;
  late List<String> tabbarSort;
  RxString defaultSearch = ''.obs;
  late bool enableGradientBg;
  RxInt unreadMessageNum = 0.obs;
  Timer? _unreadMessageTimer;

  @override
  void onInit() {
    super.onInit();
    userInfo = userInfoCache.get('userInfoCache');
    userLogin.value = userInfo != null;
    userFace.value = userInfo != null ? userInfo.face : '';
    hideSearchBar =
        setting.get(SettingBoxKey.hideSearchBar, defaultValue: false);
    searchDefault();
    enableGradientBg =
        setting.get(SettingBoxKey.enableGradientBg, defaultValue: true);
    // 进行tabs配置
    setTabConfig();
    // 获取未读消息数
    _loadUnreadMessageNum();
    _startUnreadMessagePolling();
  }

  void onRefresh() {
    int index = tabController.index;
    var ctr = tabsCtrList[index];
    ctr().onRefresh();
  }

  void animateToTop() {
    int index = tabController.index;
    var ctr = tabsCtrList[index];
    ctr().animateToTop();
  }

  // 更新登录状态
  void updateLoginStatus(bool? val) async {
    userInfo = await userInfoCache.get('userInfoCache');
    userLogin.value = val ?? false;
    if (val ?? false) return;
    userFace.value = userInfo != null ? userInfo.face : '';
    // 登录状态变化时，重新获取未读消息数
    if (val ?? false) {
      _loadUnreadMessageNum();
      _startUnreadMessagePolling();
    } else {
      _stopUnreadMessagePolling();
      unreadMessageNum.value = 0;
    }
  }

  void setTabConfig() async {
    defaultTabs = [...tabsConfig];
    tabbarSort = settingStorage
        .get(SettingBoxKey.tabbarSort, defaultValue: ['rcmd', 'hot']);
    defaultTabs.retainWhere(
        (item) => tabbarSort.contains((item['type'] as TabType).id));
    defaultTabs.sort((a, b) => tabbarSort
        .indexOf((a['type'] as TabType).id)
        .compareTo(tabbarSort.indexOf((b['type'] as TabType).id)));

    tabs.value = defaultTabs;

    if (tabbarSort.contains(TabType.rcmd.id)) {
      initialIndex.value = tabbarSort.indexOf(TabType.rcmd.id);
    } else {
      initialIndex.value = 0;
    }
    tabsCtrList = tabs.map((e) => e['ctr']).toList();
    tabsPageList = tabs.map<Widget>((e) => e['page']).toList();

    tabController = TabController(
      initialIndex: initialIndex.value,
      length: tabs.length,
      vsync: this,
    );
    // 监听 tabController 切换
    if (enableGradientBg) {
      tabController.animation!.addListener(() {
        if (tabController.indexIsChanging) {
          if (initialIndex.value != tabController.index) {
            initialIndex.value = tabController.index;
          }
        } else {
          final int temp = tabController.animation!.value.round();
          if (initialIndex.value != temp) {
            initialIndex.value = temp;
            tabController.index = initialIndex.value;
          }
        }
      });
    }
  }

  void searchDefault() async {
    try {
      final response = await _videoRepo.getPopularVideos(
        timeLimit: 7,
        offset: 0,
        num: 10,
      );
      if (response.videoList.isNotEmpty) {
        final random =
            DateTime.now().millisecondsSinceEpoch % response.videoList.length;
        defaultSearch.value = response.videoList[random].title;
      }
    } catch (e) {
      defaultSearch.value = '搜索视频';
    }
  }

  // 加载未读消息数
  Future<void> _loadUnreadMessageNum() async {
    if (!userLogin.value) return;

    try {
      final num = await _messageRepo.getUnreadMessageNum();
      unreadMessageNum.value = num;
    } catch (e) {
      // 静默处理错误
    }
  }

  // 开始轮询未读消息数
  void _startUnreadMessagePolling() {
    if (!userLogin.value) return;

    _unreadMessageTimer?.cancel();
    _unreadMessageTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _loadUnreadMessageNum(),
    );
  }

  // 停止轮询未读消息数
  void _stopUnreadMessagePolling() {
    _unreadMessageTimer?.cancel();
    _unreadMessageTimer = null;
  }

  @override
  void onClose() {
    searchBarStream.close();
    _stopUnreadMessagePolling();
    super.onClose();
  }
}
