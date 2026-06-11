import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

/// 系统信息服务
///
/// 提供设备信息、应用信息、存储信息等系统相关数据的获取
class SystemInfoService {
  static final SystemInfoService _instance = SystemInfoService._internal();
  factory SystemInfoService() => _instance;
  SystemInfoService._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// 获取设备信息
  Future<Map<String, dynamic>> getDeviceInfo() async {
    final Map<String, dynamic> info = {};

    try {
      if (kIsWeb) {
        final webInfo = await _deviceInfo.webBrowserInfo;
        info['platform'] = 'Web';
        info['browser'] = webInfo.browserName.name;
        info['userAgent'] = webInfo.userAgent ?? 'Unknown';
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        info['platform'] = 'Android';
        info['brand'] = androidInfo.brand;
        info['manufacturer'] = androidInfo.manufacturer;
        info['model'] = androidInfo.model;
        info['product'] = androidInfo.product;
        info['androidVersion'] = 'Android ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt})';
        info['isPhysicalDevice'] = androidInfo.isPhysicalDevice ? '是' : '否';
        info['display'] = androidInfo.display;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        info['platform'] = 'iOS';
        info['name'] = iosInfo.name;
        info['model'] = iosInfo.model;
        info['systemName'] = iosInfo.systemName;
        info['systemVersion'] = iosInfo.systemVersion;
        info['isPhysicalDevice'] = iosInfo.isPhysicalDevice ? '是' : '否';
        info['identifierForVendor'] = iosInfo.identifierForVendor ?? 'Unknown';
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        info['platform'] = 'Windows';
        info['computerName'] = windowsInfo.computerName;
        info['productName'] = windowsInfo.productName;
        info['releaseId'] = windowsInfo.releaseId;
      } else if (Platform.isMacOS) {
        final macInfo = await _deviceInfo.macOsInfo;
        info['platform'] = 'macOS';
        info['computerName'] = macInfo.computerName;
        info['arch'] = macInfo.arch;
        info['model'] = macInfo.model;
        info['kernelVersion'] = macInfo.kernelVersion;
      } else if (Platform.isLinux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        info['platform'] = 'Linux';
        info['name'] = linuxInfo.name;
        info['prettyName'] = linuxInfo.prettyName;
        info['version'] = linuxInfo.version;
      }
    } catch (e) {
      info['error'] = '获取设备信息失败: $e';
    }

    return info;
  }

  /// 获取应用信息
  Future<Map<String, dynamic>> getAppInfo() async {
    final Map<String, dynamic> info = {};

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      info['appName'] = packageInfo.appName;
      info['packageName'] = packageInfo.packageName;
      info['version'] = packageInfo.version;
      info['buildNumber'] = packageInfo.buildNumber;
      info['buildSignature'] = packageInfo.buildSignature;
    } catch (e) {
      info['appName'] = 'PiliOtto';
      info['version'] = '1.1.2';
      info['buildNumber'] = '2111';
      info['error'] = '获取应用信息失败: $e';
    }

    return info;
  }

  /// 获取存储信息
  Future<Map<String, dynamic>> getStorageInfo() async {
    final Map<String, dynamic> info = {};

    try {
      // 获取应用文档目录
      final appDocDir = await getApplicationDocumentsDirectory();
      final appDocSize = await _calculateDirectorySize(appDocDir.path);
      info['documentsPath'] = appDocDir.path;
      info['documentsSize'] = _formatBytes(appDocSize);

      // 获取应用支持目录
      final appSupportDir = await getApplicationSupportDirectory();
      final appSupportSize = await _calculateDirectorySize(appSupportDir.path);
      info['supportPath'] = appSupportDir.path;
      info['supportSize'] = _formatBytes(appSupportSize);

      // 获取临时目录
      final tempDir = await getTemporaryDirectory();
      final tempSize = await _calculateDirectorySize(tempDir.path);
      info['tempPath'] = tempDir.path;
      info['tempSize'] = _formatBytes(tempSize);

      // 计算总大小
      info['totalSize'] = _formatBytes(appDocSize + appSupportSize + tempSize);

      // 获取缓存目录（如果可用）
      try {
        final cacheDir = await getApplicationCacheDirectory();
        final cacheSize = await _calculateDirectorySize(cacheDir.path);
        info['cachePath'] = cacheDir.path;
        info['cacheSize'] = _formatBytes(cacheSize);
      } catch (e) {
        // 缓存目录不可用
        info['cacheSize'] = '不可用';
      }
    } catch (e) {
      info['error'] = '获取存储信息失败: $e';
    }

    return info;
  }

  /// 计算目录大小
  Future<int> _calculateDirectorySize(String path) async {
    try {
      final dir = Directory(path);
      if (!await dir.exists()) return 0;

      int size = 0;
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          size += await entity.length();
        }
      }
      return size;
    } catch (e) {
      return 0;
    }
  }

  /// 格式化字节数
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// 清除缓存
  Future<bool> clearCache() async {
    try {
      // 清除临时目录
      final tempDir = await getTemporaryDirectory();
      await _clearDirectory(tempDir.path);

      // 清除缓存目录（如果可用）
      try {
        final cacheDir = await getApplicationCacheDirectory();
        await _clearDirectory(cacheDir.path);
      } catch (e) {
        // 忽略
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// 清除目录内容
  Future<void> _clearDirectory(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) return;

    await for (final entity in dir.list()) {
      try {
        await entity.delete(recursive: true);
      } catch (e) {
        // 忽略删除失败
      }
    }
  }

  /// 获取所有系统信息
  Future<Map<String, Map<String, dynamic>>> getAllSystemInfo() async {
    return {
      'device': await getDeviceInfo(),
      'app': await getAppInfo(),
      'storage': await getStorageInfo(),
    };
  }
}
