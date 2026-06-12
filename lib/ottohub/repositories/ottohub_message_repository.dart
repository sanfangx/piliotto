import '../api/services/message_service.dart';
import '../api/models/message.dart';
import 'package:piliotto/repositories/base_repository.dart';
import 'package:piliotto/repositories/i_message_repository.dart';

class OttohubMessageRepository extends BaseRepository
    implements IMessageRepository {
  @override
  Future<List<Friend>> getFriendList(
      {int offset = 0, int num = 20, CacheConfig? cacheConfig}) {
    return withCache(
      'getFriendList_$offset',
      () => MessageService.getFriendList(offset: offset, num: num),
      cacheConfig:
          cacheConfig ?? const CacheConfig(duration: Duration(minutes: 5)),
    );
  }

  @override
  Future<List<Message>> getFriendMessage(
      {required int friendUid, int offset = 0, int num = 20}) {
    return withCache(
      'getFriendMessage_${friendUid}_$offset',
      () => MessageService.getFriendMessage(
          friendUid: friendUid, offset: offset, num: num),
      cacheConfig: const CacheConfig(duration: Duration(minutes: 10)),
    );
  }

  @override
  Future<bool> sendMessage({required int receiver, required String message}) {
    // 清除好友列表和消息列表缓存
    invalidateCacheByPrefix('getFriendList');
    invalidateCacheByPrefix('getFriendMessage_$receiver');
    return MessageService.sendMessage(receiver: receiver, message: message);
  }

  /// 清除特定好友的消息缓存
  @override
  void invalidateFriendMessageCache(int friendUid) {
    invalidateCacheByPrefix('getFriendMessage_$friendUid');
  }

  @override
  Future<int> getUnreadMessageNum() {
    return MessageService.getUnreadMessageNum();
  }
}
