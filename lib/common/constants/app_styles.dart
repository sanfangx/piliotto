import 'package:flutter/material.dart';

/// 应用字体大小常量
///
/// 提供统一的字体大小规范，确保整个应用的排版一致性。
/// 命名遵循 Tailwind CSS 的尺寸命名约定。
class AppFontSize {
  AppFontSize._();

  /// 超小字体 - 10.0
  ///
  /// 适用于辅助信息、标签、时间戳等次要文本
  static const double xs = 10.0;

  /// 小字体 - 12.0
  ///
  /// 适用于次要标题、说明文字、小标签等
  static const double sm = 12.0;

  /// 基础字体 - 14.0
  ///
  /// 适用于正文内容、列表项标题等常规文本
  static const double base = 14.0;

  /// 大字体 - 16.0
  ///
  /// 适用于重要正文、卡片标题等
  static const double lg = 16.0;

  /// 超大字体 - 18.0
  ///
  /// 适用于小标题、强调文本等
  static const double xl = 18.0;

  /// 双倍超大字体 - 20.0
  ///
  /// 适用于副标题、重要标题等
  static const double xxl = 20.0;

  /// 三倍超大字体 - 24.0
  ///
  /// 适用于页面标题、大标题等
  static const double xxxl = 24.0;
}

/// 应用间距常量
///
/// 提供统一的间距规范，用于组件之间的间隔。
/// 命名遵循 Tailwind CSS 的尺寸命名约定。
class AppSpacing {
  AppSpacing._();

  /// 超小间距 - 4.0
  ///
  /// 适用于紧凑布局、图标与文字间距等
  static const double xs = 4.0;

  /// 小间距 - 8.0
  ///
  /// 适用于列表项内间距、卡片内元素间距等
  static const double sm = 8.0;

  /// 基础间距 - 12.0
  ///
  /// 适用于常规组件间距、卡片内边距等
  static const double base = 12.0;

  /// 大间距 - 16.0
  ///
  /// 适用于页面内边距、组件间间距等
  static const double lg = 16.0;

  /// 超大间距 - 20.0
  ///
  /// 适用于区块间距、重要分隔等
  static const double xl = 20.0;

  /// 双倍超大间距 - 24.0
  ///
  /// 适用于页面区块间距、大分隔等
  static const double xxl = 24.0;
}

/// 应用 Padding/Margin 常量
///
/// 提供常用的 EdgeInsets 预设值，简化布局代码。
/// 包含页面、卡片、列表项、按钮等常用边距配置。
class AppPaddings {
  AppPaddings._();

  /// 页面水平边距 - EdgeInsets.symmetric(horizontal: 16)
  ///
  /// 适用于页面内容的左右边距
  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(horizontal: 16);

  /// 卡片水平边距 - EdgeInsets.symmetric(horizontal: 12)
  ///
  /// 适用于卡片内容的左右边距
  static const EdgeInsets cardHorizontal = EdgeInsets.symmetric(horizontal: 12);

  /// 列表项垂直边距 - EdgeInsets.symmetric(vertical: 8)
  ///
  /// 适用于列表项的上下边距
  static const EdgeInsets listItemVertical = EdgeInsets.symmetric(vertical: 8);

  /// 卡片全方向边距 - EdgeInsets.all(12)
  ///
  /// 适用于卡片内容的统一内边距
  static const EdgeInsets cardAll = EdgeInsets.all(12);

  /// 按钮边距 - EdgeInsets.symmetric(horizontal: 16, vertical: 10)
  ///
  /// 适用于按钮的内边距
  static const EdgeInsets buttonHorizontal =
      EdgeInsets.symmetric(horizontal: 16, vertical: 10);

  /// 小尺寸全方向边距 - EdgeInsets.all(8)
  ///
  /// 适用于小组件、图标的内边距
  static const EdgeInsets smallAll = EdgeInsets.all(8);

  /// 中等尺寸全方向边距 - EdgeInsets.all(12)
  ///
  /// 适用于中等尺寸组件的内边距
  static const EdgeInsets mediumAll = EdgeInsets.all(12);
}

/// 应用颜色常量
///
/// 提供应用特定的颜色常量，如排名颜色、遮罩颜色等。
/// 主题相关颜色应使用 Theme.of(context) 获取。
class AppColors {
  AppColors._();

  /// 金牌颜色 - #FFD700
  ///
  /// 用于第一名、金牌成就等场景
  static const Color rankGold = Color(0xFFFFD700);

  /// 银牌颜色 - #C0C0C0
  ///
  /// 用于第二名、银牌成就等场景
  static const Color rankSilver = Color(0xFFC0C0C0);

  /// 铜牌颜色 - #CD7F32
  ///
  /// 用于第三名、铜牌成就等场景
  static const Color rankBronze = Color(0xFFCD7F32);

  /// 深色遮罩 - Colors.black54
  ///
  /// 用于弹窗背景、图片遮罩等场景
  static const Color overlayDark = Colors.black54;
}

/// 应用动画时长常量
///
/// 提供统一的动画时长规范，确保动画体验的一致性。
/// 遵循 Material Design 动画指南。
class AppDurations {
  AppDurations._();

  /// 快速动画 - 120ms
  ///
  /// 适用于微交互、状态切换、hover 效果等
  static const Duration fast = Duration(milliseconds: 120);

  /// 普通动画 - 200ms
  ///
  /// 适用于常规过渡、展开收起、淡入淡出等
  static const Duration normal = Duration(milliseconds: 200);

  /// 慢速动画 - 300ms
  ///
  /// 适用于页面切换、复杂动画、重要交互等
  static const Duration slow = Duration(milliseconds: 300);

  /// 节流时长 - 1s
  ///
  /// 用于防止重复点击、请求节流等场景
  static const Duration throttle = Duration(seconds: 1);
}

/// 应用响应式断点常量
///
/// 提供统一的响应式布局断点，用于适配不同屏幕尺寸。
/// 遵循 Material Design 响应式布局指南。
class AppBreakpoints {
  AppBreakpoints._();

  /// 移动端最大宽度 - 600.0
  ///
  /// 小于此宽度为移动端布局
  static const double mobile = 600.0;

  /// 平板最大宽度 - 900.0
  ///
  /// 小于此宽度为平板布局，大于等于移动端断点
  static const double tablet = 900.0;

  /// 桌面最大宽度 - 1200.0
  ///
  /// 小于此宽度为桌面布局，大于等于平板断点
  static const double desktop = 1200.0;

  /// 宽屏最大宽度 - 1600.0
  ///
  /// 小于此宽度为宽屏布局，大于等于桌面断点
  static const double wide = 1600.0;
}

/// 应用透明度常量
///
/// 提供统一的透明度规范，用于遮罩、禁用状态等场景。
/// 值基于 255 色阶计算，便于设计师理解。
class AppOpacity {
  AppOpacity._();

  /// 轻透明度 - 50/255 ≈ 0.196
  ///
  /// 适用于轻微遮罩、hover 效果等
  static const double light = 50 / 255;

  /// 中等透明度 - 80/255 ≈ 0.314
  ///
  /// 适用于中等遮罩、禁用状态等
  static const double medium = 80 / 255;

  /// 重透明度 - 100/255 ≈ 0.392
  ///
  /// 适用于强遮罩、模态背景等
  static const double heavy = 100 / 255;
}
