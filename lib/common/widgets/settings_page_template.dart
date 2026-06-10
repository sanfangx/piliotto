import 'package:flutter/material.dart';
import 'package:piliotto/common/constants/app_styles.dart';

/// 设置项类型枚举
///
/// 定义设置页面支持的不同类型设置项
enum SettingsItemType {
  /// 开关类型 - 使用 Switch 组件
  ///
  /// 适用于布尔值设置，如"开启通知"、"深色模式"等
  /// 需要提供 [SettingsItem.switchValue] 和 [SettingsItem.onSwitchChanged]
  switchType,

  /// 输入类型 - 使用 TextField 组件
  ///
  /// 适用于文本输入设置，如"用户名"、"服务器地址"等
  /// 需要提供 [SettingsItem.inputController] 或 [SettingsItem.inputValue]
  input,

  /// 选择类型 - 使用点击弹出选择对话框
  ///
  /// 适用于多选一设置，如"语言选择"、"主题选择"等
  /// 需要提供 [SettingsItem.selectOptions] 和 [SettingsItem.selectedValue]
  select,

  /// 导航类型 - 点击跳转到其他页面
  ///
  /// 适用于跳转设置，如"关于页面"、"高级设置"等
  /// 需要提供 [SettingsItem.onTap] 回调
  navigation,

  /// 普通文本类型 - 仅显示文本
  ///
  /// 适用于信息展示，如"版本号"、"版权信息"等
  text,
}

/// 设置项数据模型
///
/// 表示单个设置项的所有配置信息，支持多种类型的设置项。
///
/// 根据不同的 [type]，需要提供不同的参数：
/// - [SettingsItemType.switchType]: 必须提供 [switchValue] 和 [onSwitchChanged]
/// - [SettingsItemType.input]: 可选提供 [inputController] 或 [inputValue]
/// - [SettingsItemType.select]: 必须提供 [selectOptions] 和 [selectedValue]
/// - [SettingsItemType.navigation]: 可选提供 [onTap] 回调
/// - [SettingsItemType.text]: 无特殊参数要求
///
/// 示例：
/// ```dart
/// // 开关类型
/// SettingsItem(
///   type: SettingsItemType.switchType,
///   title: '开启通知',
///   switchValue: true,
///   onSwitchChanged: (value) => print('Switch: $value'),
/// )
///
/// // 输入类型
/// SettingsItem(
///   type: SettingsItemType.input,
///   title: '服务器地址',
///   inputValue: 'https://api.example.com',
///   inputHint: '请输入服务器地址',
/// )
///
/// // 选择类型
/// SettingsItem(
///   type: SettingsItemType.select,
///   title: '语言',
///   selectOptions: ['简体中文', 'English', '日本語'],
///   selectedValue: '简体中文',
/// )
///
/// // 导航类型
/// SettingsItem(
///   type: SettingsItemType.navigation,
///   title: '关于',
///   onTap: () => Navigator.pushNamed(context, '/about'),
/// )
/// ```
class SettingsItem {
  /// 设置项类型
  final SettingsItemType type;

  /// 设置项标题
  final String title;

  /// 设置项描述（可选）
  final String? description;

  /// 设置项图标（可选）
  final IconData? icon;

  /// ===== 开关类型参数 =====

  /// 开关当前值（仅 switchType 使用）
  final bool? switchValue;

  /// 开关值变化回调（仅 switchType 使用）
  final ValueChanged<bool>? onSwitchChanged;

  /// ===== 输入类型参数 =====

  /// 输入控制器（仅 input 使用，优先使用）
  final TextEditingController? inputController;

  /// 输入框初始值（仅 input 使用，当 inputController 为空时使用）
  final String? inputValue;

  /// 输入框提示文本（仅 input 使用）
  final String? inputHint;

  /// 输入框键盘类型（仅 input 使用）
  final TextInputType? inputKeyboardType;

  /// 输入完成回调（仅 input 使用）
  final ValueChanged<String>? onInputSubmitted;

  /// ===== 选择类型参数 =====

  /// 选择选项列表（仅 select 使用）
  final List<String>? selectOptions;

  /// 当前选中值（仅 select 使用）
  final String? selectedValue;

  /// 选择变化回调（仅 select 使用）
  final ValueChanged<String>? onSelectedChanged;

  /// ===== 导航类型参数 =====

  /// 点击回调（navigation 和其他类型通用）
  final VoidCallback? onTap;

  /// 导航右侧显示的副标题（仅 navigation 使用）
  final String? navigationSubtitle;

  /// ===== 通用参数 =====

  /// 是否启用（默认 true）
  final bool enabled;

  /// 自定义构建器（可选，用于完全自定义设置项）
  final Widget Function(BuildContext context)? customBuilder;

  const SettingsItem({
    required this.type,
    required this.title,
    this.description,
    this.icon,
    this.switchValue,
    this.onSwitchChanged,
    this.inputController,
    this.inputValue,
    this.inputHint,
    this.inputKeyboardType,
    this.onInputSubmitted,
    this.selectOptions,
    this.selectedValue,
    this.onSelectedChanged,
    this.onTap,
    this.navigationSubtitle,
    this.enabled = true,
    this.customBuilder,
  });
}

/// 设置分组数据模型
///
/// 表示一组相关的设置项，包含分组标题、描述和设置项列表。
///
/// 示例：
/// ```dart
/// SettingsSection(
///   title: '通用设置',
///   description: '配置应用的基本行为',
///   items: [
///     SettingsItem(
///       type: SettingsItemType.switchType,
///       title: '深色模式',
///       switchValue: false,
///       onSwitchChanged: (value) => print('Dark mode: $value'),
///     ),
///     SettingsItem(
///       type: SettingsItemType.select,
///       title: '语言',
///       selectOptions: ['简体中文', 'English'],
///       selectedValue: '简体中文',
///     ),
///   ],
/// )
/// ```
class SettingsSection {
  /// 分组标题
  final String title;

  /// 分组描述（可选）
  final String? description;

  /// 分组内的设置项列表
  final List<SettingsItem> items;

  /// 分组标题图标（可选）
  final IconData? icon;

  const SettingsSection({
    required this.title,
    required this.items,
    this.description,
    this.icon,
  });
}

/// 通用设置页面模板
///
/// 提供统一的设置页面布局和样式，自动渲染所有分组和设置项。
/// 支持多种类型的设置项，包括开关、输入、选择、导航和普通文本。
///
/// 特性：
/// - 自动分组渲染，每组之间有分隔
/// - 支持分组标题和描述
/// - 支持多种设置项类型
/// - 响应式布局，适配不同屏幕尺寸
/// - 支持自定义样式配置
///
/// 示例：
/// ```dart
/// class MySettingsPage extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       appBar: AppBar(title: Text('设置')),
///       body: SettingsPageTemplate(
///         sections: [
///           SettingsSection(
///             title: '外观',
///             items: [
///               SettingsItem(
///                 type: SettingsItemType.switchType,
///                 title: '深色模式',
///                 description: '启用深色主题',
///                 switchValue: isDarkMode,
///                 onSwitchChanged: (value) {
///                   // 更新主题
///                 },
///               ),
///             ],
///           ),
///           SettingsSection(
///             title: '网络',
///             items: [
///               SettingsItem(
///                 type: SettingsItemType.input,
///                 title: '服务器地址',
///                 inputValue: 'https://api.example.com',
///                 inputHint: '请输入服务器地址',
///               ),
///             ],
///           ),
///         ],
///       ),
///     );
///   }
/// }
/// ```
class SettingsPageTemplate extends StatelessWidget {
  /// 设置分组列表
  final List<SettingsSection> sections;

  /// 页面内边距（默认使用 AppPaddings.pageHorizontal）
  final EdgeInsets? padding;

  /// 分组之间的间距（默认 AppSpacing.xl）
  final double? sectionSpacing;

  /// 分组标题样式
  final TextStyle? sectionTitleStyle;

  /// 分组描述样式
  final TextStyle? sectionDescriptionStyle;

  /// 设置项标题样式
  final TextStyle? itemTitleStyle;

  /// 设置项描述样式
  final TextStyle? itemDescriptionStyle;

  /// 卡片圆角半径（默认 12.0）
  final double? cardBorderRadius;

  /// 卡片内边距（默认 AppPaddings.cardAll）
  final EdgeInsets? cardPadding;

  /// 是否显示分割线（默认 true）
  final bool showDividers;

  const SettingsPageTemplate({
    super.key,
    required this.sections,
    this.padding,
    this.sectionSpacing,
    this.sectionTitleStyle,
    this.sectionDescriptionStyle,
    this.itemTitleStyle,
    this.itemDescriptionStyle,
    this.cardBorderRadius,
    this.cardPadding,
    this.showDividers = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListView.builder(
      padding: padding ?? AppPaddings.pageHorizontal.copyWith(top: AppSpacing.lg, bottom: AppSpacing.lg),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < sections.length - 1 ? (sectionSpacing ?? AppSpacing.xl) : 0,
          ),
          child: _buildSection(context, section, colorScheme, textTheme),
        );
      },
    );
  }

  /// 构建单个分组
  Widget _buildSection(
    BuildContext context,
    SettingsSection section,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 分组标题
        Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.sm,
            bottom: section.description != null ? AppSpacing.xs : AppSpacing.sm,
          ),
          child: Row(
            children: [
              if (section.icon != null) ...[
                Icon(
                  section.icon,
                  size: AppFontSize.lg,
                  color: colorScheme.primary,
                ),
                SizedBox(width: AppSpacing.sm),
              ],
              Text(
                section.title,
                style: sectionTitleStyle ??
                    textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
              ),
            ],
          ),
        ),

        // 分组描述
        if (section.description != null)
          Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.sm,
              bottom: AppSpacing.sm,
            ),
            child: Text(
              section.description!,
              style: sectionDescriptionStyle ??
                  textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ),

        // 设置项卡片
        Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardBorderRadius ?? 12.0),
          ),
          child: Padding(
            padding: cardPadding ?? AppPaddings.cardAll,
            child: Column(
              children: _buildItems(context, section.items, colorScheme, textTheme),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建分组内的设置项列表
  List<Widget> _buildItems(
    BuildContext context,
    List<SettingsItem> items,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final widgets = <Widget>[];

    for (var i = 0; i < items.length; i++) {
      final item = items[i];

      // 添加设置项
      widgets.add(_buildItem(context, item, colorScheme, textTheme));

      // 添加分割线（最后一项不添加）
      if (showDividers && i < items.length - 1) {
        widgets.add(
          Divider(
            height: AppSpacing.lg,
            thickness: 0.5,
            color: colorScheme.outlineVariant,
          ),
        );
      }
    }

    return widgets;
  }

  /// 构建单个设置项
  Widget _buildItem(
    BuildContext context,
    SettingsItem item,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    // 如果有自定义构建器，使用自定义构建
    if (item.customBuilder != null) {
      return item.customBuilder!(context);
    }

    // 根据类型构建不同的设置项
    switch (item.type) {
      case SettingsItemType.switchType:
        return _buildSwitchItem(context, item, colorScheme, textTheme);
      case SettingsItemType.input:
        return _buildInputItem(context, item, colorScheme, textTheme);
      case SettingsItemType.select:
        return _buildSelectItem(context, item, colorScheme, textTheme);
      case SettingsItemType.navigation:
        return _buildNavigationItem(context, item, colorScheme, textTheme);
      case SettingsItemType.text:
        return _buildTextItem(context, item, colorScheme, textTheme);
    }
  }

  /// 构建开关类型设置项
  Widget _buildSwitchItem(
    BuildContext context,
    SettingsItem item,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return InkWell(
      onTap: item.enabled && item.onSwitchChanged != null
          ? () => item.onSwitchChanged!(!(item.switchValue ?? false))
          : null,
      borderRadius: BorderRadius.circular(cardBorderRadius ?? 12.0),
      child: Row(
        children: [
          if (item.icon != null) ...[
            Icon(
              item.icon,
              size: AppFontSize.xl,
              color: item.enabled ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: AppSpacing.base),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: itemTitleStyle ??
                      textTheme.bodyLarge?.copyWith(
                        color: item.enabled ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                      ),
                ),
                if (item.description != null) ...[
                  SizedBox(height: AppSpacing.xs / 2),
                  Text(
                    item.description!,
                    style: itemDescriptionStyle ??
                        textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: item.switchValue ?? false,
            onChanged: item.enabled ? item.onSwitchChanged : null,
          ),
        ],
      ),
    );
  }

  /// 构建输入类型设置项
  Widget _buildInputItem(
    BuildContext context,
    SettingsItem item,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (item.icon != null) ...[
              Icon(
                item.icon,
                size: AppFontSize.xl,
                color: item.enabled ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: AppSpacing.base),
            ],
            Text(
              item.title,
              style: itemTitleStyle ??
                  textTheme.bodyLarge?.copyWith(
                    color: item.enabled ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        if (item.description != null) ...[
          SizedBox(height: AppSpacing.xs),
          Text(
            item.description!,
            style: itemDescriptionStyle ??
                textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
        SizedBox(height: AppSpacing.sm),
        TextField(
          controller: item.inputController,
          decoration: InputDecoration(
            hintText: item.inputHint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: AppSpacing.sm,
            ),
          ),
          keyboardType: item.inputKeyboardType,
          enabled: item.enabled,
          onSubmitted: item.onInputSubmitted,
        ),
      ],
    );
  }

  /// 构建选择类型设置项
  Widget _buildSelectItem(
    BuildContext context,
    SettingsItem item,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return InkWell(
      onTap: item.enabled ? () => _showSelectDialog(context, item) : null,
      borderRadius: BorderRadius.circular(cardBorderRadius ?? 12.0),
      child: Row(
        children: [
          if (item.icon != null) ...[
            Icon(
              item.icon,
              size: AppFontSize.xl,
              color: item.enabled ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: AppSpacing.base),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: itemTitleStyle ??
                      textTheme.bodyLarge?.copyWith(
                        color: item.enabled ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                      ),
                ),
                if (item.description != null) ...[
                  SizedBox(height: AppSpacing.xs / 2),
                  Text(
                    item.description!,
                    style: itemDescriptionStyle ??
                        textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.selectedValue ?? '',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right,
                size: AppFontSize.xl,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建导航类型设置项
  Widget _buildNavigationItem(
    BuildContext context,
    SettingsItem item,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return InkWell(
      onTap: item.enabled ? item.onTap : null,
      borderRadius: BorderRadius.circular(cardBorderRadius ?? 12.0),
      child: Row(
        children: [
          if (item.icon != null) ...[
            Icon(
              item.icon,
              size: AppFontSize.xl,
              color: item.enabled ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: AppSpacing.base),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: itemTitleStyle ??
                      textTheme.bodyLarge?.copyWith(
                        color: item.enabled ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                      ),
                ),
                if (item.description != null) ...[
                  SizedBox(height: AppSpacing.xs / 2),
                  Text(
                    item.description!,
                    style: itemDescriptionStyle ??
                        textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (item.navigationSubtitle != null) ...[
            Text(
              item.navigationSubtitle!,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
          ],
          Icon(
            Icons.chevron_right,
            size: AppFontSize.xl,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  /// 构建普通文本类型设置项
  Widget _buildTextItem(
    BuildContext context,
    SettingsItem item,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return InkWell(
      onTap: item.enabled ? item.onTap : null,
      borderRadius: BorderRadius.circular(cardBorderRadius ?? 12.0),
      child: Row(
        children: [
          if (item.icon != null) ...[
            Icon(
              item.icon,
              size: AppFontSize.xl,
              color: item.enabled ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: AppSpacing.base),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: itemTitleStyle ??
                      textTheme.bodyLarge?.copyWith(
                        color: item.enabled ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                      ),
                ),
                if (item.description != null) ...[
                  SizedBox(height: AppSpacing.xs / 2),
                  Text(
                    item.description!,
                    style: itemDescriptionStyle ??
                        textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 显示选择对话框
  void _showSelectDialog(BuildContext context, SettingsItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(item.title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: (item.selectOptions ?? []).map((option) {
                return ListTile(
                  title: Text(option),
                  trailing: Radio<String>(
                    value: option,
                    // ignore: deprecated_member_use
                    groupValue: item.selectedValue,
                    // ignore: deprecated_member_use
                    onChanged: (value) {
                      Navigator.pop(context);
                      if (value != null && item.onSelectedChanged != null) {
                        item.onSelectedChanged!(value);
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    if (item.onSelectedChanged != null) {
                      item.onSelectedChanged!(option);
                    }
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
