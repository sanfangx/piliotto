import 'package:hive/hive.dart';
import 'package:piliotto/utils/storage.dart';

/// 开发者模式服务
///
/// 管理开发者模式的启用/禁用状态
/// 默认禁用，用户可通过特定方式激活（如连续点击版本号）
class DeveloperModeService {
  static const String _developerModeKey = 'developerMode';

  final Box _localCache = GStorage.localCache;

  /// 检查开发者模式是否启用
  ///
  /// 默认返回 false，需要用户主动激活
  bool isDeveloperMode() {
    return _localCache.get(_developerModeKey, defaultValue: false);
  }

  /// 启用开发者模式
  void enableDeveloperMode() {
    _localCache.put(_developerModeKey, true);
  }

  /// 禁用开发者模式
  void disableDeveloperMode() {
    _localCache.put(_developerModeKey, false);
  }

  /// 切换开发者模式
  void toggleDeveloperMode() {
    final currentMode = isDeveloperMode();
    _localCache.put(_developerModeKey, !currentMode);
  }
}
