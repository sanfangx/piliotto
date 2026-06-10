/// 瀑布流布局计算服务
///
/// 负责计算瀑布流布局的各项参数，包括列数、卡片宽度等。
/// 从 DynamicsController 中提取，实现职责分离。
class WaterfallLayoutCalculator {
  WaterfallLayoutCalculator({
    required this.minItemWidth,
    required this.crossAxisSpacing,
    this.maxCrossAxisCount = 6,
    this.minCrossAxisCount = 2,
  });

  /// 最小卡片宽度
  final double minItemWidth;

  /// 列间距
  final double crossAxisSpacing;

  /// 最大列数
  final int maxCrossAxisCount;

  /// 最小列数
  final int minCrossAxisCount;

  /// 计算瀑布流布局配置
  ///
  /// [screenWidth] 屏幕宽度
  /// [limitWidth] 是否限制宽度（启用自定义列数）
  /// [fixedCrossAxisCount] 固定列数（当 limitWidth 为 true 时使用）
  /// [customItemWidth] 自定义卡片宽度（可选）
  WaterfallLayoutConfig calculate(
    double screenWidth, {
    bool limitWidth = false,
    int? fixedCrossAxisCount,
    double? customItemWidth,
  }) {
    final autoCrossAxisCount = _calculateAutoCrossAxisCount(screenWidth);

    int effectiveCrossAxisCount;
    double effectiveItemWidth;

    if (customItemWidth != null) {
      // 使用自定义宽度
      effectiveItemWidth = customItemWidth;
      if (limitWidth && fixedCrossAxisCount != null) {
        // 限制宽度时，直接使用固定列数
        effectiveCrossAxisCount =
            fixedCrossAxisCount.clamp(minCrossAxisCount, maxCrossAxisCount);
      } else {
        // 根据自定义宽度计算列数
        final customCrossAxisCount = (screenWidth / customItemWidth).floor();
        effectiveCrossAxisCount =
            customCrossAxisCount.clamp(minCrossAxisCount, maxCrossAxisCount);
      }
    } else {
      // 自动计算宽度
      effectiveCrossAxisCount = limitWidth && fixedCrossAxisCount != null
          ? fixedCrossAxisCount.clamp(minCrossAxisCount, autoCrossAxisCount)
          : autoCrossAxisCount;
      effectiveItemWidth = _calculateItemWidth(
        screenWidth,
        effectiveCrossAxisCount,
      );
    }

    return WaterfallLayoutConfig(
      crossAxisCount: effectiveCrossAxisCount,
      itemWidth: effectiveItemWidth,
      autoCrossAxisCount: autoCrossAxisCount,
    );
  }

  /// 计算自动列数
  int _calculateAutoCrossAxisCount(double screenWidth) {
    final count = (screenWidth / minItemWidth).floor();
    return count.clamp(minCrossAxisCount, maxCrossAxisCount);
  }

  /// 计算卡片宽度
  double _calculateItemWidth(double screenWidth, int crossAxisCount) {
    return (screenWidth - (crossAxisCount - 1) * crossAxisSpacing) /
        crossAxisCount;
  }

  /// 计算自动列数（公开方法，供外部调用）
  int calculateAutoCrossAxisCount(double screenWidth) {
    return _calculateAutoCrossAxisCount(screenWidth);
  }

  /// 计算卡片宽度（公开方法，供外部调用）
  double calculateItemWidth(double screenWidth, int crossAxisCount) {
    return _calculateItemWidth(screenWidth, crossAxisCount);
  }

  /// 获取有效列数
  int getEffectiveCrossAxisCount(
    double screenWidth, {
    bool limitWidth = false,
    int? fixedCrossAxisCount,
  }) {
    final autoCount = calculateAutoCrossAxisCount(screenWidth);
    if (!limitWidth) {
      return autoCount;
    }
    return (fixedCrossAxisCount ?? autoCount)
        .clamp(minCrossAxisCount, autoCount);
  }
}

/// 瀑布流布局配置
class WaterfallLayoutConfig {
  const WaterfallLayoutConfig({
    required this.crossAxisCount,
    required this.itemWidth,
    required this.autoCrossAxisCount,
  });

  /// 有效列数
  final int crossAxisCount;

  /// 卡片宽度
  final double itemWidth;

  /// 自动计算的列数
  final int autoCrossAxisCount;

  /// 计算网格宽度
  double calculateGridWidth(double crossAxisSpacing) {
    return crossAxisCount * itemWidth + (crossAxisCount - 1) * crossAxisSpacing;
  }

  /// 计算水平内边距
  double calculateHorizontalPadding(
    double screenWidth,
    double crossAxisSpacing, {
    double maxContentWidth = 1600.0,
  }) {
    final effectiveScreenWidth =
        screenWidth > maxContentWidth ? maxContentWidth : screenWidth;
    final gridWidth = calculateGridWidth(crossAxisSpacing);
    return ((effectiveScreenWidth - gridWidth) / 2)
        .clamp(12.0, double.infinity);
  }
}
