import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/utils/storage.dart';

/// 瀑布流布局设置管理
///
/// 负责管理瀑布流布局相关的设置持久化。
/// 从 DynamicsController 中提取，实现职责分离。
/// 使用 Rx 变量支持响应式更新。
class WaterfallLayoutSettings {
  WaterfallLayoutSettings(this._storage) {
    _layoutMode = RxString(_storage.get(
      SettingBoxKey.dynamicWideScreenLayout,
      defaultValue: 'center',
    ));
    _crossAxisCount = RxInt(_storage.get(
      SettingBoxKey.waterfallCrossAxisCount,
      defaultValue: 3,
    ));
    _limitWidth = RxBool(_storage.get(
      SettingBoxKey.waterfallLimitWidth,
      defaultValue: false,
    ));
    _customItemWidth = RxDouble(_storage.get(
      SettingBoxKey.waterfallCustomItemWidth,
      defaultValue: 300.0,
    ));
    _useCustomItemWidth = RxBool(_storage.get(
      SettingBoxKey.waterfallUseCustomItemWidth,
      defaultValue: false,
    ));
  }

  final Box<dynamic> _storage;

  late final RxString _layoutMode;
  late final RxInt _crossAxisCount;
  late final RxBool _limitWidth;
  late final RxDouble _customItemWidth;
  late final RxBool _useCustomItemWidth;

  /// 宽屏布局模式 Rx 变量: 'center' 居中, 'waterfall' 瀑布流
  RxString get layoutModeRx => _layoutMode;

  /// 瀑布流列数 Rx 变量
  RxInt get crossAxisCountRx => _crossAxisCount;

  /// 是否限制宽度 Rx 变量（启用自定义列数）
  RxBool get limitWidthRx => _limitWidth;

  /// 自定义卡片宽度 Rx 变量
  RxDouble get customItemWidthRx => _customItemWidth;

  /// 是否使用自定义卡片宽度 Rx 变量
  RxBool get useCustomItemWidthRx => _useCustomItemWidth;

  /// 宽屏布局模式
  String get layoutMode => _layoutMode.value;
  set layoutMode(String value) {
    _layoutMode.value = value;
    _storage.put(SettingBoxKey.dynamicWideScreenLayout, value);
  }

  /// 瀑布流列数
  int get crossAxisCount => _crossAxisCount.value;
  set crossAxisCount(int value) {
    _crossAxisCount.value = value.clamp(2, 6);
    _storage.put(SettingBoxKey.waterfallCrossAxisCount, value.clamp(2, 6));
  }

  /// 是否限制宽度（启用自定义列数）
  bool get limitWidth => _limitWidth.value;
  set limitWidth(bool value) {
    _limitWidth.value = value;
    _storage.put(SettingBoxKey.waterfallLimitWidth, value);
  }

  /// 自定义卡片宽度
  double get customItemWidth => _customItemWidth.value;
  set customItemWidth(double value) {
    _customItemWidth.value = value.clamp(200.0, 600.0);
    _storage.put(
        SettingBoxKey.waterfallCustomItemWidth, value.clamp(200.0, 600.0));
  }

  /// 是否使用自定义卡片宽度
  bool get useCustomItemWidth => _useCustomItemWidth.value;
  set useCustomItemWidth(bool value) {
    _useCustomItemWidth.value = value;
    _storage.put(SettingBoxKey.waterfallUseCustomItemWidth, value);
  }

  /// 切换布局模式
  void toggleLayoutMode() {
    layoutMode = layoutMode == 'center' ? 'waterfall' : 'center';
  }

  /// 切换限制宽度
  void toggleLimitWidth([bool? value]) {
    limitWidth = value ?? !limitWidth;
  }

  /// 切换使用自定义宽度
  void toggleUseCustomItemWidth([bool? value]) {
    useCustomItemWidth = value ?? !useCustomItemWidth;
  }
}
