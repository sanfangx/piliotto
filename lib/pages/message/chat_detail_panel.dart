import 'dart:math' show cos, sin;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/ottohub/api/models/message.dart';
import 'package:piliotto/pages/message/chat_detail_controller.dart';

/// 聊天详情面板
/// 使用 GetBuilder 替代 Obx，手动控制更新范围
class ChatDetailPanel extends StatelessWidget {
  final int friendUid;
  final String friendName;
  final String? friendAvatar;

  const ChatDetailPanel({
    super.key,
    required this.friendUid,
    required this.friendName,
    this.friendAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GetBuilder<ChatDetailController>(
      init: ChatDetailController(
        friendUid: friendUid,
        friendName: friendName,
        friendAvatar: friendAvatar,
      ),
      tag: friendUid.toString(),
      builder: (controller) {
        final userInfo = controller.getUserInfo();
        final myUid = userInfo['uid'] as int;
        final myAvatar = userInfo['avatar'] as String?;

        return Column(
          children: [
            // 头部：好友信息
            _buildHeader(theme),

            // 消息区域
            Expanded(
              child: GetBuilder<ChatDetailController>(
                id: 'messages',
                tag: friendUid.toString(),
                builder: (controller) {
                  // 加载状态
                  if (controller.isLoading.value &&
                      controller.messages.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // 错误状态
                  if (controller.errorMessage.value.isNotEmpty &&
                      controller.messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(controller.errorMessage.value),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () =>
                                controller.loadMessages(refresh: true),
                            child: const Text('重试'),
                          ),
                        ],
                      ),
                    );
                  }

                  // 空状态
                  if (controller.messages.isEmpty &&
                      !controller.isLoading.value &&
                      controller.errorMessage.value.isEmpty) {
                    return const Center(child: Text('暂无消息'));
                  }

                  // 消息列表
                  return RefreshIndicator(
                    onRefresh: () => controller.loadMessages(refresh: true),
                    child: ListView.builder(
                      controller: controller.scrollController,
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.messages.length,
                      itemBuilder: (context, index) {
                        final message = controller.messages[index];
                        final isMe = message.sender == myUid;
                        final isNew = controller.isNewMessage(message.msgId);
                        final isDeleting =
                            controller.isDeletingMessage(message.msgId);

                        return _AnimatedMessageItem(
                          key: ObjectKey(message),
                          message: message,
                          isMe: isMe,
                          isNew: isNew,
                          isDeleting: isDeleting,
                          friendAvatar: friendAvatar,
                          myAvatar: myAvatar,
                          theme: theme,
                          controller: controller,
                          onDeleteComplete: () {
                            controller.finishDeleting(message.msgId);
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            // 输入区域
            _buildInputArea(controller, theme),
          ],
        );
      },
    );
  }

  /// 构建头部
  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withAlpha(50),
          ),
        ),
      ),
      child: Row(
        children: [
          if (friendAvatar != null && friendAvatar!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(friendAvatar!),
              ),
            ),
          Text(
            friendName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建输入区域
  Widget _buildInputArea(ChatDetailController controller, ThemeData theme) {
    final messageController = TextEditingController();
    final focusNode = FocusNode();

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(Get.context!).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withAlpha(80),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: '输入消息...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) {
                controller.sendMessage(messageController.text.trim());
                messageController.clear();
              },
            ),
          ),
          const SizedBox(width: 8),
          GetBuilder<ChatDetailController>(
            id: 'sending',
            tag: friendUid.toString(),
            builder: (controller) {
              return IconButton.filled(
                onPressed: controller.isSending.value
                    ? null
                    : () {
                        controller.sendMessage(messageController.text.trim());
                        messageController.clear();
                      },
                icon: controller.isSending.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// 带动画的消息项
class _AnimatedMessageItem extends StatefulWidget {
  final Message message;
  final bool isMe;
  final bool isNew;
  final bool isDeleting;
  final String? friendAvatar;
  final String? myAvatar;
  final ThemeData theme;
  final ChatDetailController controller;
  final VoidCallback onDeleteComplete;

  const _AnimatedMessageItem({
    super.key,
    required this.message,
    required this.isMe,
    required this.isNew,
    required this.isDeleting,
    required this.friendAvatar,
    required this.myAvatar,
    required this.theme,
    required this.controller,
    required this.onDeleteComplete,
  });

  @override
  State<_AnimatedMessageItem> createState() => _AnimatedMessageItemState();
}

class _AnimatedMessageItemState extends State<_AnimatedMessageItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // 入场动画：从右侧滑入（自己发送的消息）或淡入（对方的消息）
    _slideAnimation = Tween<double>(
      begin: widget.isMe ? 100.0 : 0.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // 如果是新消息，执行入场动画
    if (widget.isNew) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0; // 直接显示
    }
  }

  @override
  void didUpdateWidget(_AnimatedMessageItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 如果消息正在删除，执行删除动画
    if (widget.isDeleting && !oldWidget.isDeleting) {
      _animationController.reverse().then((_) {
        widget.onDeleteComplete();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(
              widget.isMe ? _slideAnimation.value : 0.0,
              widget.isMe ? 0.0 : 20 * (1 - _fadeAnimation.value),
            ),
            child: child,
          ),
        );
      },
      child: widget.isDeleting
          ? _buildDeletingEffect(theme)
          : _buildMessageContent(theme),
    );
  }

  /// 构建删除效果（粉碎动画）
  Widget _buildDeletingEffect(ThemeData theme) {
    return Stack(
      children: [
        // 原消息内容（逐渐消失）
        Opacity(
          opacity: _fadeAnimation.value,
          child: _buildMessageContent(theme),
        ),
        // 粉碎效果：多个小块分散
        ...List.generate(8, (index) {
          final angle = (index * 45.0) * 3.14159 / 180.0;
          final distance = 50.0 * (1 - _fadeAnimation.value);
          final offsetX = distance * cos(angle);
          final offsetY = distance * sin(angle);

          return Positioned(
            left: offsetX,
            top: offsetY,
            child: Opacity(
              opacity: (1 - _fadeAnimation.value) * 0.5,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(100),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  /// 构建消息内容
  Widget _buildMessageContent(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage:
                  widget.friendAvatar != null && widget.friendAvatar!.isNotEmpty
                      ? NetworkImage(widget.friendAvatar!)
                      : null,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: widget.friendAvatar == null || widget.friendAvatar!.isEmpty
                  ? Icon(Icons.person,
                      size: 16, color: theme.colorScheme.onPrimaryContainer)
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: widget.isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: widget.isMe
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width * 0.5,
                  ),
                  child: SelectableText(
                    widget.message.content,
                    style: TextStyle(
                      fontSize: 15,
                      color: widget.isMe
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                    contextMenuBuilder: (context, editableTextState) {
                      final List<ContextMenuButtonItem> items = [];

                      // 添加撤回按钮（仅对自己发送的消息）
                      if (widget.isMe) {
                        items.add(
                          ContextMenuButtonItem(
                            onPressed: () {
                              // 关闭菜单
                              editableTextState.hideToolbar();
                              // 撤回消息
                              widget.controller.recallMessage(widget.message);
                            },
                            label: '撤回',
                          ),
                        );
                      }

                      // 添加默认的复制和全选按钮
                      final defaultItems =
                          editableTextState.contextMenuButtonItems;
                      for (var item in defaultItems) {
                        if (item.type == ContextMenuButtonType.copy ||
                            item.type == ContextMenuButtonType.selectAll) {
                          items.add(item);
                        }
                      }

                      return AdaptiveTextSelectionToolbar.buttonItems(
                        anchors: editableTextState.contextMenuAnchors,
                        buttonItems: items,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: widget.isMe
                      ? const EdgeInsets.only(right: 8)
                      : const EdgeInsets.only(left: 40),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: widget.isMe
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      Tooltip(
                        message: _getFullTimeInfo(widget.message),
                        waitDuration: const Duration(seconds: 1),
                        child: Text(
                          _formatTime(widget.message.time),
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      // 已读未读状态显示（仅对自己发送的消息）
                      if (widget.isMe) ...[
                        const SizedBox(width: 4),
                        Tooltip(
                          message: widget.message.isRead == true ? '已读' : '未读',
                          waitDuration: const Duration(seconds: 1),
                          child: Icon(
                            // 双钩表示对方已读，单钩表示已发送未读
                            widget.message.isRead == true
                                ? Icons.done_all
                                : Icons.done,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (widget.isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundImage:
                  widget.myAvatar != null && widget.myAvatar!.isNotEmpty
                      ? NetworkImage(widget.myAvatar!)
                      : null,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: widget.myAvatar == null || widget.myAvatar!.isEmpty
                  ? Icon(Icons.person,
                      size: 16, color: theme.colorScheme.onPrimaryContainer)
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  /// 获取完整时间信息
  String _getFullTimeInfo(Message message) {
    try {
      final dateTime = DateTime.parse(message.time);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      String relativeTime;
      if (difference.inDays == 0) {
        relativeTime = '今天';
      } else if (difference.inDays == 1) {
        relativeTime = '昨天';
      } else if (difference.inDays < 7) {
        relativeTime = '${difference.inDays}天前';
      } else {
        relativeTime = '${dateTime.year}年${dateTime.month}月${dateTime.day}日';
      }

      return '$relativeTime ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return message.time;
    }
  }

  /// 格式化时间
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
