// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/pages/setting/pages/logs.dart';

import '../pages/about/index.dart';
// 开发者选项页面导入
import '../pages/developer/index.dart';
import '../pages/developer/network_debug/index.dart';
import '../pages/developer/performance/index.dart';
import '../pages/dynamics/detail/index.dart';
import '../pages/dynamics/index.dart';
import '../pages/fan/index.dart';
import '../pages/fav/index.dart';
import '../pages/fav_detail/index.dart';
import '../pages/follow/index.dart';
import '../pages/history/index.dart';
import '../pages/home/index.dart';
import '../pages/hot/index.dart';

import '../pages/login/index.dart';
import '../pages/media/index.dart';
import '../pages/member/index.dart';
import '../pages/member_archive/index.dart';
import '../pages/member_dynamics/index.dart';
import '../pages/message/index.dart';
import '../pages/mine/index.dart';

import '../pages/setting/binding.dart';
import '../pages/setting/extra_setting.dart';
import '../pages/setting/index.dart';
import '../pages/setting/pages/action_menu_set.dart';
import '../pages/setting/pages/browser_setting.dart';
import '../pages/setting/pages/color_select.dart';
import '../pages/setting/pages/display_mode.dart';
import '../pages/setting/pages/font_size_select.dart';
import '../pages/setting/pages/home_tabbar_set.dart';
import '../pages/setting/pages/navigation_bar_set.dart';
import '../pages/setting/pages/play_gesture_set.dart';
import '../pages/setting/pages/play_speed_set.dart';
import '../pages/setting/pages/bottom_control_set.dart';
import '../pages/setting/pages/recommend_filter_setting.dart';
import '../pages/setting/play_setting.dart';
import '../pages/setting/style_setting.dart';
import '../pages/setting/privacy_setting.dart';

import '../pages/video/detail/index.dart';
import '../pages/video/detail/reply_reply/index.dart';
import '../pages/webview/index.dart';
import '../pages/search/index.dart';
import '../pages/whisper_detail/index.dart';
import '../utils/storage.dart';

Box<dynamic> setting = GStorage.setting;

class Routes {
  static final List<GetPage<dynamic>> getPages = [
    CustomGetPage(name: '/', page: () => const HomePage()),
    CustomGetPage(name: '/hot', page: () => const HotPage()),
    CustomGetPage(name: '/search', page: () => const VideoSearchPage()),
    CustomGetPage(name: '/video', page: () => const VideoDetailPage()),
    CustomGetPage(
        name: '/webview',
        page: () {
          final args = Get.arguments as Map<String, dynamic>?;
          return WebviewPage(
            showAppBar: args?['showAppBar'] ?? true,
            appBarTitle: args?['appBarTitle'],
          );
        }),
    CustomGetPage(
        name: '/setting',
        page: () => const SettingPage(),
        binding: SettingBinding()),
    CustomGetPage(name: '/media', page: () => const MediaPage()),
    CustomGetPage(name: '/fav', page: () => const FavPage()),
    CustomGetPage(name: '/favDetail', page: () => const FavDetailPage()),
    CustomGetPage(name: '/history', page: () => const HistoryPage()),
    CustomGetPage(name: '/dynamics', page: () => const DynamicsPage()),
    CustomGetPage(
        name: '/dynamicDetail', page: () => const DynamicDetailPage()),
    CustomGetPage(name: '/follow', page: () => const FollowPage()),
    CustomGetPage(name: '/fan', page: () => const FansPage()),
    CustomGetPage(name: '/member', page: () => const MemberPage()),
    CustomGetPage(
        name: '/mine', page: () => const MinePage(showBackButton: true)),
    CustomGetPage(
        name: '/replyReply', page: () => const VideoReplyReplyPanel()),
    CustomGetPage(name: '/playSetting', page: () => const PlaySetting()),
    CustomGetPage(name: '/styleSetting', page: () => const StyleSetting()),
    CustomGetPage(name: '/extraSetting', page: () => const ExtraSetting()),
    CustomGetPage(name: '/privacySetting', page: () => const PrivacySetting()),
    CustomGetPage(
        name: '/recommendFilterSetting',
        page: () => const RecommendFilterSetting()),
    CustomGetPage(name: '/colorSetting', page: () => const ColorSelectPage()),
    CustomGetPage(name: '/tabbarSetting', page: () => const TabbarSetPage()),
    CustomGetPage(
        name: '/fontSizeSetting', page: () => const FontSizeSelectPage()),
    CustomGetPage(
        name: '/displayModeSetting', page: () => const SetDiaplayMode()),
    CustomGetPage(name: '/about', page: () => const AboutPage()),
    CustomGetPage(name: '/playSpeedSet', page: () => const PlaySpeedPage()),
    CustomGetPage(
        name: '/bottomControlSet', page: () => const BottomControlSetPage()),
    CustomGetPage(name: '/loginPage', page: () => const LoginPage()),
    CustomGetPage(
        name: '/memberDynamics', page: () => const MemberDynamicsPage()),
    CustomGetPage(
        name: '/memberArchive', page: () => const MemberArchivePage()),
    CustomGetPage(name: '/logs', page: () => const LogsPage()),
    CustomGetPage(
        name: '/playerGestureSet', page: () => const PlayGesturePage()),
    CustomGetPage(
        name: '/navbarSetting', page: () => const NavigationBarSetPage()),
    CustomGetPage(
        name: '/actionMenuSet', page: () => const ActionMenuSetPage()),
    CustomGetPage(
        name: '/browserSetting', page: () => const BrowserSettingPage()),
    CustomGetPage(
        name: '/whisperDetail', page: () => const WhisperDetailPage()),
    CustomGetPage(name: '/message', page: () => const MessagePage()),
    // 开发者选项路由（需要通过特定方式激活才能访问）
    CustomGetPage(name: '/developer', page: () => const DeveloperPage()),
    CustomGetPage(name: '/networkDebug', page: () => const NetworkDebugPage()),
    CustomGetPage(name: '/performance', page: () => const PerformancePage()),
  ];
}

class CustomGetPage extends GetPage<dynamic> {
  CustomGetPage({
    required super.name,
    required super.page,
    this.fullscreen,
    super.transitionDuration,
    super.binding,
  }) : super(
          curve: Curves.linear,
          transition: Transition.native,
          showCupertinoParallax: false,
          popGesture: false,
          fullscreenDialog: fullscreen != null && fullscreen,
        );
  bool? fullscreen = false;
}
