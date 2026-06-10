import 'package:flutter/material.dart';
import 'package:piliotto/common/constants/app_styles.dart';

/// 新动态横幅组件
///
/// 显示新动态数量的提示横幅，点击可加载新动态
class NewDynamicsBanner extends StatelessWidget {
  /// 新动态数量
  final int count;

  /// 点击回调
  final VoidCallback onTap;

  /// 外边距
  final EdgeInsetsGeometry? margin;

  /// 内边距
  final EdgeInsetsGeometry padding;

  const NewDynamicsBanner({
    super.key,
    required this.count,
    required this.onTap,
    this.margin,
    this.padding = AppPaddings.buttonHorizontal,
  });

  @override
  Widget build(BuildContext context) {
    // 数量为0时不显示
    if (count == 0) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.lg),
          child: Padding(
            padding: padding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_upward_rounded,
                  size: AppFontSize.xl,
                  color: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '$count 条新动态',
                  style: TextStyle(
                    fontSize: AppFontSize.base,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
