import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/ottohub/api/models/message.dart';
import 'package:piliotto/pages/message/chat_detail_panel.dart';
import 'package:piliotto/pages/message/add_friend_dialog.dart';
import 'controller.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  late MessageController controller;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(MessageController());

    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final screenWidth = view.physicalSize.width / view.devicePixelRatio;
    final isWideScreen = screenWidth >= 800;

    if (!isWideScreen) {
      final parameters = Get.parameters;
      final mid = parameters['mid'];
      final name = parameters['name'];
      final face = parameters['face'];

      if (mid != null && name != null && !_hasNavigated) {
        _hasNavigated = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.toNamed('/whisperDetail', parameters: {
            'mid': mid,
            'name': name,
            'face': face ?? '',
            'heroTag': mid,
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('消息'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Get.dialog(const AddFriendDialog()),
            icon: const Icon(Icons.person_add),
            tooltip: '添加好友',
          ),
        ],
      ),
      body: isWideScreen ? _buildWideLayout(theme) : _buildNarrowLayout(theme),
    );
  }

  Widget _buildWideLayout(ThemeData theme) {
    return Row(
      children: [
        SizedBox(
          width: 320,
          child: _buildFriendListPanel(theme),
        ),
        Container(
          width: 1,
          color: theme.colorScheme.outlineVariant.withAlpha(50),
        ),
        Expanded(
          child: Obx(() {
            final friend = controller.selectedFriend.value;
            if (friend == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 64,
                      color: theme.colorScheme.outlineVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '选择一个对话开始聊天',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ChatDetailPanel(
              key: ValueKey(friend.uid),
              friendUid: friend.uid,
              friendName: friend.username,
              friendAvatar: friend.avatarUrl,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(ThemeData theme) {
    return _buildFriendListPanel(theme);
  }

  Widget _buildFriendListPanel(ThemeData theme) {
    return Obx(() {
      if (controller.isLoading.value && controller.friendList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value.isNotEmpty &&
          controller.friendList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(controller.errorMessage.value),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.loadFriendList(refresh: true),
                child: const Text('重试'),
              ),
            ],
          ),
        );
      }

      if (controller.friendList.isEmpty) {
        return const Center(child: Text('暂无消息'));
      }

      return RefreshIndicator(
        onRefresh: () => controller.loadFriendList(refresh: true),
        child: ListView.builder(
          itemCount: controller.friendList.length,
          itemBuilder: (context, index) {
            final friend = controller.friendList[index];
            return _buildFriendItem(friend, theme);
          },
        ),
      );
    });
  }

  Widget _buildFriendItem(Friend friend, ThemeData theme) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= 800;

    return Obx(() {
      final isSelected = controller.selectedFriend.value?.uid == friend.uid;
      return Container(
        color: isSelected
            ? theme.colorScheme.primaryContainer.withAlpha(100)
            : null,
        child: ListTile(
          onTap: () {
            if (isWideScreen) {
              controller.selectFriend(friend);
            } else {
              Get.toNamed('/whisperDetail', parameters: {
                'mid': friend.uid.toString(),
                'name': friend.username,
                'face': friend.avatarUrl ?? '',
                'heroTag': friend.uid.toString(),
              });
            }
          },
          leading: Badge(
            label: friend.newMessageNum != null && friend.newMessageNum! > 0
                ? Text('${friend.newMessageNum}')
                : null,
            isLabelVisible:
                friend.newMessageNum != null && friend.newMessageNum! > 0,
            child: CircleAvatar(
              radius: 24,
              backgroundImage:
                  friend.avatarUrl != null && friend.avatarUrl!.isNotEmpty
                      ? NetworkImage(friend.avatarUrl!)
                      : null,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: friend.avatarUrl == null || friend.avatarUrl!.isEmpty
                  ? Icon(Icons.person,
                      size: 24, color: theme.colorScheme.onPrimaryContainer)
                  : null,
            ),
          ),
          title: Text(
            friend.username,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: friend.lastMessage != null
              ? Text(
                  friend.lastMessage!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              : null,
          trailing: friend.lastTime != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatTime(friend.lastTime!),
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (friend.newMessageNum != null &&
                        friend.newMessageNum! > 0)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          friend.newMessageNum! > 99
                              ? '99+'
                              : friend.newMessageNum.toString(),
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onError,
                          ),
                        ),
                      ),
                  ],
                )
              : null,
        ),
      );
    });
  }

  String _formatTime(String time) {
    try {
      final dateTime = DateTime.parse(time);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return '昨天';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}天前';
      } else {
        return '${dateTime.month}/${dateTime.day}';
      }
    } catch (e) {
      return time;
    }
  }
}
