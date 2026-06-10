/// 应用配置文件 - 集中管理项目信息
///
/// 本文件定义了项目的核心配置信息，包括：
/// - 项目名称和描述
/// - GitHub 仓库相关 URL
/// - 作者信息
///
/// 使用方式：
/// ```dart
/// // 获取项目名称
/// String name = AppConfig.appName;
///
/// // 获取 GitHub 仓库 URL
/// String repoUrl = AppConfig.githubRepoUrl;
///
/// // 获取作者信息
/// String author = AppConfig.authorName;
/// ```
///
/// 所有配置项均为编译时常量，可安全用于 const 构造函数中。
library;

/// 应用配置常量类
///
/// 包含项目的所有静态配置信息，使用 `const` 定义确保编译时优化。
/// 所有属性均为静态常量，无需实例化即可访问。
class AppConfig {
  AppConfig._();

  // ==================== 项目信息 ====================

  /// 项目名称
  ///
  /// 用于应用标题、关于页面等场景。
  /// 示例：`Text(AppConfig.appName)`
  static const String appName = 'PiliOtto';

  /// 项目描述
  ///
  /// 用于应用介绍、关于页面、商店描述等场景。
  /// 描述项目的核心功能和定位。
  static const String appDescription = '使用 Flutter 开发的 Ottohub 第三方客户端';

  /// 应用版本号
  ///
  /// 遵循语义化版本规范 (SemVer)。
  /// 格式：主版本号.次版本号.修订号
  static const String appVersion = '1.0.0';

  // ==================== GitHub 相关 ====================

  /// GitHub 仓库 URL
  ///
  /// 项目的主仓库地址，用于：
  /// - 关于页面的源码链接
  /// - 问题反馈跳转
  /// - README 中的项目链接
  static const String githubRepoUrl =
      'https://github.com/CyaniAgent/piliotto';

  /// GitHub API URL
  ///
  /// 用于调用 GitHub REST API，例如：
  /// - 获取最新 Release 信息
  /// - 查询 Issues 列表
  /// - 获取仓库统计信息
  static const String githubApiUrl =
      'https://api.github.com/repos/CyaniAgent/piliotto';

  /// GitHub Issues URL
  ///
  /// 用于问题反馈和功能建议。
  static const String githubIssuesUrl =
      'https://github.com/CyaniAgent/piliotto/issues';

  /// GitHub Releases URL
  ///
  /// 用于版本更新检查和下载。
  static const String githubReleasesUrl =
      'https://github.com/CyaniAgent/piliotto/releases';

  // ==================== 作者信息 ====================

  /// 作者名称
  ///
  /// 用于关于页面、版权声明等场景。
  static const String authorName = 'SakuraCake';

  /// 作者 GitHub 主页
  ///
  /// 用于关于页面的作者链接跳转。
  static const String authorGithubUrl = 'https://github.com/SakuraCake';

  // ==================== 其他配置 ====================

  /// 默认用户代理
  ///
  /// 用于 HTTP 请求头，标识客户端身份。
  static const String defaultUserAgent =
      'Mozilla/5.0 PiliOtto Flutter App';

  /// 应用构建时间
  ///
  /// 由构建脚本自动注入，用于版本追踪。
  /// 如果未注入，默认为空字符串。
  static const String buildTime = String.fromEnvironment(
    'BUILD_TIME',
    defaultValue: '',
  );

  /// 是否为调试模式
  ///
  /// 用于控制日志输出、调试功能开关等。
  /// 由编译时常量决定，生产环境自动为 false。
  static const bool isDebug = bool.fromEnvironment(
    'DEBUG_MODE',
    defaultValue: false,
  );
}
