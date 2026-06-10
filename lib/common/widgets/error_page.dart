import 'package:flutter/material.dart';
import 'package:piliotto/common/constants/app_styles.dart';

/// 错误类型枚举
///
/// 定义应用中常见的错误类型，用于自动选择合适的图标和文本。
/// 每种错误类型都有对应的默认图标、标题和描述。
///
/// 示例：
/// ```dart
/// ErrorPage(errorType: ErrorType.networkError)
/// ErrorPage(errorType: ErrorType.serverError)
/// ```
enum ErrorType {
  /// 网络错误
  ///
  /// 表示网络连接失败、超时等网络相关问题。
  /// 默认图标：wifi_off
  /// 默认标题：网络连接失败
  /// 默认描述：请检查网络设置后重试
  networkError,

  /// 服务器错误
  ///
  /// 表示服务器内部错误、维护等服务器端问题。
  /// 默认图标：cloud_off
  /// 默认标题：服务器开小差了
  /// 默认描述：服务器正在维护或遇到了问题，请稍后再试
  serverError,

  /// 资源未找到
  ///
  /// 表示请求的资源不存在，如 404 错误。
  /// 默认图标：search_off
  /// 默认标题：未找到内容
  /// 默认描述：您访问的内容不存在或已被删除
  notFound,

  /// 未授权
  ///
  /// 表示用户未登录或无权限访问，如 401/403 错误。
  /// 默认图标：lock
  /// 默认标题：无访问权限
  /// 默认描述：请登录后重试或联系管理员
  unauthorized,

  /// 未知错误
  ///
  /// 表示无法识别的错误类型。
  /// 默认图标：error_outline
  /// 默认标题：出错了
  /// 默认描述：发生了未知错误，请重试
  unknown,
}

/// 通用错误页面组件
///
/// 一个可复用的错误展示组件，支持多种错误类型和自定义配置。
/// 根据 [errorType] 自动选择合适的图标和文本，也支持完全自定义。
///
/// ## 基础用法
///
/// ### 使用预设错误类型
/// ```dart
/// // 网络错误
/// ErrorPage(
///   errorType: ErrorType.networkError,
///   onRetry: () => _reloadData(),
/// )
///
/// // 服务器错误
/// ErrorPage(
///   errorType: ErrorType.serverError,
///   onRetry: () => _retryRequest(),
/// )
///
/// // 404 错误
/// ErrorPage(
///   errorType: ErrorType.notFound,
/// )
///
/// // 未授权错误
/// ErrorPage(
///   errorType: ErrorType.unauthorized,
///   onRetry: () => _navigateToLogin(),
/// )
/// ```
///
/// ### 自定义错误信息
/// ```dart
/// ErrorPage(
///   errorType: ErrorType.networkError,
///   title: '网络不给力',
///   message: '当前网络状况不佳，请切换网络后重试',
///   onRetry: () => _retry(),
/// )
/// ```
///
/// ### 完全自定义
/// ```dart
/// ErrorPage(
///   icon: Icon(Icons.sentiment_dissatisfied, size: 100),
///   title: '加载失败',
///   message: '数据加载出现问题',
///   onRetry: () => _reload(),
///   retryText: '重新加载',
/// )
/// ```
///
/// ### 自定义高度
/// ```dart
/// ErrorPage(
///   errorType: ErrorType.serverError,
///   height: 300,
///   onRetry: () => _retry(),
/// )
/// ```
///
/// ## 参数说明
///
/// - [errorType]: 错误类型，用于自动选择默认图标和文本
/// - [icon]: 自定义错误图标，优先级高于 [errorType] 的默认图标
/// - [title]: 自定义错误标题，优先级高于 [errorType] 的默认标题
/// - [message]: 自定义错误描述，优先级高于 [errorType] 的默认描述
/// - [onRetry]: 重试回调，不为 null 时自动显示重试按钮
/// - [retryText]: 自定义重试按钮文本
/// - [height]: 组件高度，默认 400
/// - [iconSize]: 图标大小，默认 80
class ErrorPage extends StatelessWidget {
  const ErrorPage({
    super.key,
    this.errorType = ErrorType.unknown,
    this.icon,
    this.title,
    this.message,
    this.onRetry,
    this.retryText,
    this.height = 400,
    this.iconSize = 80,
  });

  /// 错误类型，用于自动选择默认图标和文本
  final ErrorType errorType;

  /// 自定义错误图标
  ///
  /// 如果提供，将覆盖 [errorType] 对应的默认图标。
  final Widget? icon;

  /// 自定义错误标题
  ///
  /// 如果提供，将覆盖 [errorType] 对应的默认标题。
  final String? title;

  /// 自定义错误描述
  ///
  /// 如果提供，将覆盖 [errorType] 对应的默认描述。
  final String? message;

  /// 重试回调
  ///
  /// 如果不为 null，将显示重试按钮。
  final VoidCallback? onRetry;

  /// 自定义重试按钮文本
  ///
  /// 默认为 '点击重试'。
  final String? retryText;

  /// 组件高度
  ///
  /// 默认为 400。
  final double height;

  /// 图标大小
  ///
  /// 默认为 80。
  final double iconSize;

  /// 获取默认图标
  Widget _getDefaultIcon() {
    switch (errorType) {
      case ErrorType.networkError:
        return Icon(
          Icons.wifi_off_rounded,
          size: iconSize,
          color: _getIconColor(),
        );
      case ErrorType.serverError:
        return Icon(
          Icons.cloud_off_rounded,
          size: iconSize,
          color: _getIconColor(),
        );
      case ErrorType.notFound:
        return Icon(
          Icons.search_off_rounded,
          size: iconSize,
          color: _getIconColor(),
        );
      case ErrorType.unauthorized:
        return Icon(
          Icons.lock_rounded,
          size: iconSize,
          color: _getIconColor(),
        );
      case ErrorType.unknown:
        return Icon(
          Icons.error_outline_rounded,
          size: iconSize,
          color: _getIconColor(),
        );
    }
  }

  /// 获取图标颜色
  Color? _getIconColor() {
    // 返回 null 让 Icon 使用主题默认颜色
    return null;
  }

  /// 获取默认标题
  String _getDefaultTitle() {
    switch (errorType) {
      case ErrorType.networkError:
        return '网络连接失败';
      case ErrorType.serverError:
        return '服务器开小差了';
      case ErrorType.notFound:
        return '未找到内容';
      case ErrorType.unauthorized:
        return '无访问权限';
      case ErrorType.unknown:
        return '出错了';
    }
  }

  /// 获取默认描述
  String _getDefaultMessage() {
    switch (errorType) {
      case ErrorType.networkError:
        return '请检查网络设置后重试';
      case ErrorType.serverError:
        return '服务器正在维护或遇到了问题，请稍后再试';
      case ErrorType.notFound:
        return '您访问的内容不存在或已被删除';
      case ErrorType.unauthorized:
        return '请登录后重试或联系管理员';
      case ErrorType.unknown:
        return '发生了未知错误，请重试';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 错误图标
          icon ?? _getDefaultIcon(),
          const SizedBox(height: AppSpacing.xl),
          // 错误标题
          Text(
            title ?? _getDefaultTitle(),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall,
          ),
          // 错误描述
          const SizedBox(height: AppSpacing.sm),
          Text(
            message ?? _getDefaultMessage(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          // 重试按钮
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.xl),
            FilledButton.tonal(
              onPressed: onRetry,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  return colorScheme.primary.withAlpha(20);
                }),
              ),
              child: Text(
                retryText ?? '点击重试',
                style: TextStyle(color: colorScheme.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Sliver 版本的错误页面组件
///
/// 用于 Sliver 布局中的错误展示，包装为 [SliverToBoxAdapter]。
///
/// ## 用法示例
///
/// ```dart
/// CustomScrollView(
///   slivers: [
///     SliverAppBar(...),
///     if (hasError)
///       SliverErrorPage(
///         errorType: ErrorType.networkError,
///         onRetry: () => _reload(),
///       )
///     else
///       SliverList(...),
///   ],
/// )
/// ```
///
/// 参数说明同 [ErrorPage]。
class SliverErrorPage extends StatelessWidget {
  const SliverErrorPage({
    super.key,
    this.errorType = ErrorType.unknown,
    this.icon,
    this.title,
    this.message,
    this.onRetry,
    this.retryText,
    this.height = 400,
    this.iconSize = 80,
  });

  final ErrorType errorType;
  final Widget? icon;
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final String? retryText;
  final double height;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: ErrorPage(
        errorType: errorType,
        icon: icon,
        title: title,
        message: message,
        onRetry: onRetry,
        retryText: retryText,
        height: height,
        iconSize: iconSize,
      ),
    );
  }
}
