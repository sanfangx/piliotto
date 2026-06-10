import 'package:flutter/material.dart';
import 'package:piliotto/common/constants/app_styles.dart';

/// 加载指示器组件
///
/// 统一的加载状态显示组件，支持不同大小和样式
class LoadingIndicator extends StatelessWidget {
  /// 是否正在加载
  final bool isLoading;

  /// 加载完成后的文本（如"没有更多了"）
  final String? endText;

  /// 加载中的文本
  final String loadingText;

  /// 指示器大小
  final double size;

  /// 线宽
  final double strokeWidth;

  /// 垂直内边距
  final double verticalPadding;

  const LoadingIndicator({
    super.key,
    this.isLoading = true,
    this.endText,
    this.loadingText = '加载中...',
    this.size = 16,
    this.strokeWidth = 2,
    this.verticalPadding = 20,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Center(
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: size,
                    height: size,
                    child: CircularProgressIndicator(
                      strokeWidth: strokeWidth,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.base),
                  Text(
                    loadingText,
                    style: TextStyle(
                      fontSize: AppFontSize.base,
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              )
            : Text(
                endText ?? '',
                style: TextStyle(
                  fontSize: AppFontSize.base,
                  color: colorScheme.outline,
                ),
              ),
      ),
    );
  }
}
