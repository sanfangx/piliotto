import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/ottohub/api/models/message.dart';
import 'package:piliotto/ottohub/api/services/message_service.dart';
import 'package:piliotto/repositories/i_message_repository.dart';
import 'package:piliotto/utils/storage.dart';

/// 聊天详情控制器
/// 管理聊天消息的状态和业务逻辑
class ChatDetailController extends GetxController {
  // 参数
  final int friendUid;
  final String friendName;
  final String? friendAvatar;

  ChatDetailController({
    required this.friendUid,
    required this.friendName,
    this.friendAvatar,
  });

  // 状态变量
  RxList<Message> messages = <Message>[].obs;
  RxBool isLoading = false.obs;
  RxBool isSending = false.obs;
  RxString errorMessage = ''.obs;

  // 新消息追踪（用于入场动画）
  final Set<int> _newMessageIds = {};
  // 正在删除的消息（用于删除动画）
  final Set<int> _deletingMessageIds = {};

  // 分页参数
  int _offset = 0;
  final int _pageSize = 20;
  bool _hasMore = true;

  // 轮询定时器
  Timer? _pollTimer;

  // 滚动控制器
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    loadMessages();
    _startPolling();
  }

  @override
  void onClose() {
    _stopPolling();
    scrollController.dispose();
    super.onClose();
  }

  /// 启动轮询
  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _pollNewMessages();
    });
  }

  /// 停止轮询
  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// 轮询新消息
  Future<void> _pollNewMessages() async {
    if (isLoading.value || isSending.value) return;

    try {
      final repo = Get.find<IMessageRepository>();
      // 轮询时清除缓存以获取最新消息
      repo.invalidateFriendMessageCache(friendUid);

      final newMessages = await repo.getFriendMessage(
        friendUid: friendUid,
        offset: 0,
        num: _pageSize,
      );

      if (newMessages.isNotEmpty && messages.isNotEmpty) {
        final latestMsgId = messages.first.msgId;
        // 只添加新消息，不刷新整个列表
        final newMsgs =
            newMessages.where((msg) => msg.msgId > latestMsgId).toList();

        if (newMsgs.isNotEmpty) {
          // 将新消息插入到列表开头
          messages.insertAll(0, newMsgs);
          _offset += newMsgs.length;

          // 手动触发消息列表更新
          update(['messages']);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (scrollController.hasClients) {
              scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      }
    } catch (e) {
      // 静默处理轮询错误
    }
  }

  /// 加载消息
  Future<void> loadMessages({bool refresh = false}) async {
    if (isLoading.value) return;

    if (refresh) {
      _offset = 0;
      _hasMore = true;
      messages.clear();
    }

    if (!_hasMore) return;

    isLoading.value = true;
    errorMessage.value = '';

    // 手动触发加载状态更新
    update(['loading']);

    try {
      final List<Message> newMessages =
          await Get.find<IMessageRepository>().getFriendMessage(
        friendUid: friendUid,
        offset: _offset,
        num: _pageSize,
      );

      if (newMessages.length < _pageSize) {
        _hasMore = false;
      }

      if (refresh) {
        messages.assignAll(newMessages);
      } else {
        messages.addAll(newMessages);
      }

      _offset += newMessages.length;

      // 手动触发消息列表更新
      update(['messages']);

      if (messages.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      errorMessage.value = '加载失败: $e';
      // 手动触发错误状态更新
      update(['error']);
    } finally {
      isLoading.value = false;
      // 手动触发加载状态更新
      update(['loading']);
    }
  }

  /// 发送消息
  Future<void> sendMessage(String text) async {
    if (text.isEmpty || isSending.value) return;

    isSending.value = true;
    update(['sending']);

    try {
      final repo = Get.find<IMessageRepository>();
      final success = await repo.sendMessage(
        receiver: friendUid,
        message: text,
      );

      if (success) {
        // 清除缓存并刷新消息列表
        repo.invalidateFriendMessageCache(friendUid);
        await loadMessages(refresh: true);
      }
    } catch (e) {
      // Handle error silently
    } finally {
      isSending.value = false;
      update(['sending']);
    }
  }

  /// 撤回消息
  Future<void> recallMessage(Message message) async {
    try {
      final success = await MessageService.recallMessage(msgId: message.msgId);
      if (success) {
        // 清除缓存并刷新消息列表
        Get.find<IMessageRepository>().invalidateFriendMessageCache(friendUid);
        await loadMessages(refresh: true);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  /// 获取用户信息
  Map<String, dynamic> getUserInfo() {
    final userInfo = GStorage.userInfo.get('userInfoCache');
    return {
      'uid': userInfo?.mid ?? 0,
      'avatar': userInfo?.face,
    };
  }

  /// 判断消息是否是新消息（用于入场动画）
  bool isNewMessage(int msgId) {
    return _newMessageIds.contains(msgId);
  }

  /// 判断消息是否正在删除（用于删除动画）
  bool isDeletingMessage(int msgId) {
    return _deletingMessageIds.contains(msgId);
  }

  /// 完成删除动画
  void finishDeleting(int msgId) {
    _deletingMessageIds.remove(msgId);
    messages.removeWhere((msg) => msg.msgId == msgId);
    update(['messages']);
  }
}
