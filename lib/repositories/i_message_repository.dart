import 'package:piliotto/ottohub/api/models/message.dart';
import 'base_repository.dart';

abstract class IMessageRepository {
  Future<List<Friend>> getFriendList(
      {int offset = 0, int num = 20, CacheConfig? cacheConfig});
  Future<List<Message>> getFriendMessage(
      {required int friendUid, int offset = 0, int num = 20});
  Future<bool> sendMessage({required int receiver, required String message});
  Future<int> getUnreadMessageNum();

  /// 清除特定好友的消息缓存
  void invalidateFriendMessageCache(int friendUid);
}
