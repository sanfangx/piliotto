import 'package:hive/hive.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:piliotto/ottohub/api/services/auth_service.dart';
import 'package:piliotto/services/loggeer.dart';

/// 签到服务
///
/// 管理用户签到状态和签到历史记录
/// 应用启动时自动检查并签到
class SignInService {
  static const String _lastSignInDateKey = 'lastSignInDate';
  static const String _signInHistoryKey = 'signInHistory';

  final Box _localCache = GStorage.localCache;

  /// 检查今天是否已签到
  ///
  /// 通过比较存储的最后签到日期与当前日期
  bool hasSignedInToday() {
    final lastSignInDate = _localCache.get(_lastSignInDateKey, defaultValue: '');
    final today = _getTodayDateString();
    return lastSignInDate == today;
  }

  /// 自动签到
  ///
  /// 应用启动时调用，检查今天是否已签到
  /// 如果未签到，尝试调用签到 API
  /// 记录签到结果到历史
  Future<SignInResult> autoSignIn() async {
    // 检查今天是否已签到
    if (hasSignedInToday()) {
      getLogger().i('今天已签到，跳过自动签到');
      return SignInResult.alreadySignedIn;
    }

    getLogger().i('开始自动签到');

    try {
      // 调用签到 API
      final response = await AuthService.signIn();

      // 记录签到日期
      final today = _getTodayDateString();
      _localCache.put(_lastSignInDateKey, today);

      // 记录签到历史
      _recordSignInHistory(today, true, response.ifTodayFirstLogin);

      getLogger().i('自动签到成功: ifTodayFirstLogin=${response.ifTodayFirstLogin}');
      return SignInResult.success;
    } catch (e, stackTrace) {
      getLogger().e('自动签到失败', error: e, stackTrace: stackTrace);

      // 记录签到失败历史
      final today = _getTodayDateString();
      _recordSignInHistory(today, false, null, error: e.toString());

      return SignInResult.failed;
    }
  }

  /// 获取签到历史记录
  ///
  /// 返回最近的签到记录列表
  List<SignInHistory> getSignInHistory() {
    final history = _localCache.get(_signInHistoryKey, defaultValue: []);
    if (history is List) {
      return history.map((item) {
        if (item is Map) {
          return SignInHistory.fromJson(Map<String, dynamic>.from(item));
        }
        return null;
      }).whereType<SignInHistory>().toList();
    }
    return [];
  }

  /// 记录签到历史
  ///
  /// 保存签到结果到历史记录列表
  void _recordSignInHistory(
    String date,
    bool success,
    String? ifTodayFirstLogin,
    {String? error}
  ) {
    final history = getSignInHistory();
    final newRecord = SignInHistory(
      date: date,
      success: success,
      ifTodayFirstLogin: ifTodayFirstLogin,
      error: error,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    // 添加新记录到列表开头
    history.insert(0, newRecord);

    // 限制历史记录数量（最多保留 30 天）
    if (history.length > 30) {
      history.removeRange(30, history.length);
    }

    // 保存到本地存储
    _localCache.put(
      _signInHistoryKey,
      history.map((h) => h.toJson()).toList(),
    );
  }

  /// 获取今天的日期字符串
  ///
  /// 格式: YYYY-MM-DD
  String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

/// 签到结果枚举
enum SignInResult {
  /// 签到成功
  success,
  /// 今天已签到
  alreadySignedIn,
  /// 签到失败
  failed,
}

/// 签到历史记录
class SignInHistory {
  final String date;
  final bool success;
  final String? ifTodayFirstLogin;
  final String? error;
  final int timestamp;

  SignInHistory({
    required this.date,
    required this.success,
    this.ifTodayFirstLogin,
    this.error,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'success': success,
      'ifTodayFirstLogin': ifTodayFirstLogin,
      'error': error,
      'timestamp': timestamp,
    };
  }

  factory SignInHistory.fromJson(Map<String, dynamic> json) {
    return SignInHistory(
      date: json['date'] ?? '',
      success: json['success'] ?? false,
      ifTodayFirstLogin: json['ifTodayFirstLogin'],
      error: json['error'],
      timestamp: json['timestamp'] ?? 0,
    );
  }
}