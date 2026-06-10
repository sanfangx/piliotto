import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/constants/app_styles.dart';
import 'package:piliotto/common/widgets/user_profile_header.dart';
import 'package:piliotto/models/common/theme_type.dart';
import 'package:piliotto/pages/fav/index.dart';
import 'package:piliotto/pages/history/index.dart';
import 'controller.dart';

class MinePage extends StatefulWidget {
  final bool showBackButton;
  const MinePage({super.key, this.showBackButton = false});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  final MineController mineController = Get.put(MineController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    mineController.userLogin.listen((status) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(context, theme),
          SliverToBoxAdapter(
            child: _buildContent(context, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ThemeData theme) {
    return SliverAppBar(
      leading: widget.showBackButton
          ? IconButton(
              icon: Obx(() => Icon(
                    Icons.arrow_back,
                    color: _getIconColor(theme),
                  )),
              onPressed: () => Get.back(),
            )
          : null,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          onPressed: () => mineController.onChangeTheme(),
          icon: Obx(() => Icon(
                mineController.themeType.value == ThemeType.light
                    ? Icons.light_mode
                    : mineController.themeType.value == ThemeType.dark
                        ? Icons.dark_mode
                        : Icons.brightness_auto,
                size: 22,
                color: _getIconColor(theme),
              )),
        ),
        IconButton(
          onPressed: () => Get.toNamed('/setting', preventDuplicates: false),
          icon: Obx(() => Icon(
                Icons.settings_outlined,
                size: 22,
                color: _getIconColor(theme),
              )),
        ),
        const SizedBox(width: AppSpacing.xs),
      ],
      floating: true,
      pinned: true,
      snap: true,
      expandedHeight: 280,
      flexibleSpace:
          FlexibleSpaceBar(background: _buildHeaderWithUserInfo(theme)),
    );
  }

  Color _getIconColor(ThemeData theme) {
    final cover = mineController.userInfo.value.cover;
    final hasCover = cover != null && cover.isNotEmpty;
    return hasCover ? Colors.white : theme.colorScheme.onSurface;
  }

  Widget _buildHeaderWithUserInfo(ThemeData theme) {
    return Obx(() {
      final userInfo = mineController.userInfo.value;
      final userStat = mineController.userStat.value;
      final isLogin = mineController.userLogin.value;

      return UserProfileHeader(
        coverUrl: userInfo.cover,
        avatarUrl: userInfo.face,
        userName: isLogin ? userInfo.uname : '点击头像登录',
        userId: isLogin ? userInfo.mid?.toString() : null,
        followingCount: isLogin ? userStat.following?.toString() : null,
        followerCount: isLogin ? userStat.follower?.toString() : null,
        onAvatarTap: () => mineController.onLogin(),
        onFollowingTap: isLogin ? () => mineController.pushFollow() : null,
        onFollowerTap: isLogin ? () => mineController.pushFans() : null,
        height: 280,
        avatarSize: 80,
        extraContent: !isLogin
            ? FilledButton(
                onPressed: () => Get.toNamed('/loginPage'),
                child: const Text('立即登录'),
              )
            : null,
      );
    });
  }

  Widget _buildContent(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.sm),
          _buildMenuItems(context, theme),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        _buildMenuItem(
          context,
          theme,
          Icons.favorite_border_outlined,
          '我的收藏',
          () => Get.to(const FavPage()),
        ),
        _buildMenuItem(
          context,
          theme,
          Icons.history_outlined,
          '历史记录',
          () => Get.to(const HistoryPage()),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    ThemeData theme,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        size: 24,
        color: theme.colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: AppFontSize.lg,
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_outlined, size: 19),
    );
  }
}
