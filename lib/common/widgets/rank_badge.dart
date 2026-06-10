import 'package:flutter/material.dart';
import 'package:piliotto/common/constants/app_styles.dart';

/// 排名徽章组件
///
/// 用于显示排行榜名次，前三名使用金银铜颜色
class RankBadge extends StatelessWidget {
  /// 排名（1, 2, 3, ...）
  final int rank;

  /// 徽章尺寸
  final double size;

  /// 字体大小
  final double fontSize;

  /// 圆角半径
  final double borderRadius;

  const RankBadge({
    super.key,
    required this.rank,
    this.size = 28,
    this.fontSize = 14,
    this.borderRadius = 8,
  });

  /// 根据排名获取徽章颜色
  Color get _badgeColor {
    if (rank == 1) return AppColors.rankGold; // 金牌
    if (rank == 2) return AppColors.rankSilver; // 银牌
    if (rank == 3) return AppColors.rankBronze; // 铜牌
    return AppColors.overlayDark; // 普通排名
  }

  /// 是否使用粗体
  bool get _isBold => rank <= 3;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _badgeColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
