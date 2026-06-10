import 'package:hive/hive.dart';
import 'package:piliotto/utils/storage.dart';

class DeveloperModeService {
  static const String _developerModeKey = 'developerMode';

  final Box _localCache = GStrorage.localCache;

  bool isDeveloperMode() {
    return _localCache.get(_developerModeKey, defaultValue: false);
  }

  void enableDeveloperMode() {
    _localCache.put(_developerModeKey, true);
  }

  void disableDeveloperMode() {
    _localCache.put(_developerModeKey, false);
  }

  void toggleDeveloperMode() {
    final currentMode = isDeveloperMode();
    _localCache.put(_developerModeKey, !currentMode);
  }
}
