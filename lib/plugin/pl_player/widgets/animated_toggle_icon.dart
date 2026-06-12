import 'package:flutter/material.dart';

/// 通用动画切换图标组件
/// 使用 AnimatedSwitcher 实现图标切换时的平滑过渡动画
class AnimatedToggleIcon extends StatelessWidget {
  final bool condition;
  final Widget trueIcon;
  final Widget falseIcon;
  final Duration duration;

  const AnimatedToggleIcon({
    super.key,
    required this.condition,
    required this.trueIcon,
    required this.falseIcon,
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: condition ? trueIcon : falseIcon,
    );
  }
}
