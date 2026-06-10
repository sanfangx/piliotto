import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';

/// 用户资料头部组件
///
/// 用于在 MemberPage 和 MinePage 中显示用户资料头部信息，包括：
/// - 封面图片
/// - 头像
/// - 用户名和 UID
/// - 关注数和粉丝数
/// - 操作按钮（关注、发消息等）
class UserProfileHeader extends StatelessWidget {
  /// 封面图片 URL
  final String? coverUrl;

  /// 头像图片 URL
  final String? avatarUrl;

  /// 用户名
  final String? userName;

  /// 用户 ID
  final String? userId;

  /// 关注数
  final String? followingCount;

  /// 粉丝数
  final String? followerCount;

  /// 是否显示操作按钮
  final bool showActionButtons;

  /// 是否是当前用户
  final bool isOwner;

  /// 点击关注数的回调
  final VoidCallback? onFollowingTap;

  /// 点击粉丝数的回调
  final VoidCallback? onFollowerTap;

  /// 点击头像的回调
  final VoidCallback? onAvatarTap;

  /// 点击关注按钮的回调
  final VoidCallback? onRelationAction;

  /// 关注按钮文字
  final String? relationButtonText;

  /// 点击发消息按钮的回调
  final VoidCallback? onMessageAction;

  /// 头部高度
  final double height;

  /// 头像大小
  final double avatarSize;

  /// 额外内容（如登录按钮）
  final Widget? extraContent;

  const UserProfileHeader({
    super.key,
    this.coverUrl,
    this.avatarUrl,
    this.userName,
    this.userId,
    this.followingCount,
    this.followerCount,
    this.showActionButtons = false,
    this.isOwner = false,
    this.onFollowingTap,
    this.onFollowerTap,
    this.onAvatarTap,
    this.onRelationAction,
    this.relationButtonText,
    this.onMessageAction,
    this.height = 280,
    this.avatarSize = 70,
    this.extraContent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasCover = coverUrl != null && coverUrl!.isNotEmpty;

    return Container(
      height: height,
      color: theme.colorScheme.secondaryContainer,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasCover)
            CachedNetworkImage(
              imageUrl:
                  coverUrl!.startsWith('//') ? 'https:$coverUrl' : coverUrl!,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 300),
              fadeOutDuration: const Duration(milliseconds: 120),
              placeholder: (context, url) => const SizedBox.shrink(),
              errorWidget: (context, url, error) => const SizedBox.shrink(),
            ),
          Container(
            color: hasCover
                ? Colors.black.withValues(alpha: 100 / 255)
                : Colors.transparent,
          ),
          SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAvatar(theme, hasCover),
                          const SizedBox(width: 16),
                          Expanded(child: _buildUserDetails(theme, hasCover)),
                        ],
                      ),
                    ],
                  ),
                ),
                if (showActionButtons && !isOwner)
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: _buildActionButtons(context, theme, hasCover),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme, bool hasCover) {
    final avatarWidget = avatarUrl != null && avatarUrl!.isNotEmpty
        ? ClipOval(
            child: NetworkImgLayer(
              src: avatarUrl!,
              width: avatarSize,
              height: avatarSize,
              type: 'avatar',
            ),
          )
        : CircleAvatar(
            radius: avatarSize / 2,
            backgroundColor: theme.colorScheme.surface,
            child: Icon(Icons.person,
                size: avatarSize * 0.57, color: theme.colorScheme.primary),
          );

    return GestureDetector(
      onTap: onAvatarTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: hasCover ? Colors.white : theme.colorScheme.primary,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: hasCover
                  ? Colors.black.withValues(alpha: 80 / 255)
                  : theme.colorScheme.shadow.withValues(alpha: 50 / 255),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: avatarWidget,
      ),
    );
  }

  Widget _buildUserDetails(ThemeData theme, bool hasCover) {
    final textColor = hasCover ? Colors.white : theme.colorScheme.onSurface;
    final subTextColor =
        hasCover ? Colors.white70 : theme.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          userName ?? '',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        if (userId != null) ...[
          const SizedBox(height: 4),
          Text('UID: $userId',
              style: TextStyle(fontSize: 13, color: subTextColor)),
        ],
        if (followingCount != null || followerCount != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              if (followingCount != null)
                _buildStatItem('关注', followingCount!, textColor, subTextColor,
                    onFollowingTap),
              if (followingCount != null && followerCount != null)
                const SizedBox(width: 16),
              if (followerCount != null)
                _buildStatItem('粉丝', followerCount!, textColor, subTextColor,
                    onFollowerTap),
            ],
          ),
        ],
        if (extraContent != null) ...[
          const SizedBox(height: 12),
          extraContent!,
        ],
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor,
      Color labelColor, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: valueColor)),
          Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, ThemeData theme, bool hasCover) {
    final textColor = hasCover ? Colors.white : theme.colorScheme.onSurface;
    final subTextColor =
        hasCover ? Colors.white70 : theme.colorScheme.onSurfaceVariant;
    final isNarrowScreen = MediaQuery.of(context).size.width < 600;

    if (isNarrowScreen) {
      return FilledButton(
        onPressed: onRelationAction,
        child: Text(relationButtonText ?? '关注'),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilledButton(
          onPressed: onRelationAction,
          child: Text(relationButtonText ?? '关注'),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor,
            side: BorderSide(color: subTextColor),
          ),
          onPressed: onMessageAction,
          child: const Text('发消息'),
        ),
      ],
    );
  }
}
