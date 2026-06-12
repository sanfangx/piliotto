import '../services/legacy_api_service.dart';
import '../models/message.dart';
import 'package:piliotto/services/loggeer.dart';

class MessageService {
  // 获取未读消息数
  static Future<int> getUnreadMessageNum() async {
    final token = LegacyApiService.getToken();
    if (token == null) {
      getLogger().w('getUnreadMessageNum: token 为 null，请先登录 Ottohub 账号');
      return 0;
    }

    final response = await LegacyApiService.request(
      'im',
      'new_message_num',
      {'token': token},
    );
    if (response['status'] == 'success') {
      return int.tryParse(response['new_message_num']?.toString() ?? '0') ?? 0;
    }
    return 0;
  }

  // 获取已读消息列表
  static Future<List<Message>> getReadMessageList({
    int offset = 0,
    int num = 20,
  }) async {
    final token = LegacyApiService.getToken();
    if (token == null) {
      getLogger().w('getReadMessageList: token 为 null，请先登录账号');
      return [];
    }

    // API 限制 num 不能超过 12
    if (num > 12) {
      getLogger().w('getReadMessageList: num 参数超过12，自动调整为12');
      num = 12;
    }

    try {
      final response = await LegacyApiService.request(
        'im',
        'read_message_list',
        {'token': token, 'offset': offset.toString(), 'num': num.toString()},
      );
      if (response['status'] == 'success') {
        final list = response['read_message_list'] as List?;
        return list?.map((e) => Message.fromJson(e)).toList() ?? [];
      } else {
        getLogger().e('getReadMessageList 失败: ${response['message'] ?? '未知错误'}');
        return [];
      }
    } catch (e) {
      getLogger().e('getReadMessageList 异常: $e');
      return [];
    }
  }

  // 获取未读消息列表
  static Future<List<Message>> getUnreadMessageList({
    int offset = 0,
    int num = 20,
  }) async {
    final token = LegacyApiService.getToken();
    if (token == null) {
      getLogger().w('getUnreadMessageList: token 为 null，请先登录账号');
      return [];
    }

    // API 限制 num 不能超过 12
    if (num > 12) {
      getLogger().w('getUnreadMessageList: num 参数超过12，自动调整为12');
      num = 12;
    }

    try {
      final response = await LegacyApiService.request(
        'im',
        'unread_message_list',
        {'token': token, 'offset': offset.toString(), 'num': num.toString()},
      );
      if (response['status'] == 'success') {
        final list = response['unread_message_list'] as List?;
        return list?.map((e) => Message.fromJson(e)).toList() ?? [];
      } else {
        getLogger().e('getUnreadMessageList 失败: ${response['message'] ?? '未知错误'}');
        return [];
      }
    } catch (e) {
      getLogger().e('getUnreadMessageList 异常: $e');
      return [];
    }
  }

  // 获取已发消息列表
  static Future<List<Message>> getSentMessageList({
    int offset = 0,
    int num = 20,
  }) async {
    final token = LegacyApiService.getToken();
    if (token == null) {
      getLogger().w('getSentMessageList: token 为 null，请先登录账号');
      return [];
    }

    // API 限制 num 不能超过 12
    if (num > 12) {
      getLogger().w('getSentMessageList: num 参数超过12，自动调整为12');
      num = 12;
    }

    try {
      final response = await LegacyApiService.request(
        'im',
        'sent_message_list',
        {'token': token, 'offset': offset.toString(), 'num': num.toString()},
      );
      if (response['status'] == 'success') {
        final list = response['sent_message_list'] as List?;
        return list?.map((e) => Message.fromJson(e)).toList() ?? [];
      } else {
        getLogger().e('getSentMessageList 失败: ${response['message'] ?? '未知错误'}');
        return [];
      }
    } catch (e) {
      getLogger().e('getSentMessageList 异常: $e');
      return [];
    }
  }

  // 发送消息
  static Future<bool> sendMessage({
    required int receiver,
    required String message,
  }) async {
    final token = LegacyApiService.getToken();
    if (token == null) return false;

    final response = await LegacyApiService.request(
      'im',
      'send_message',
      {'token': token, 'receiver': receiver.toString(), 'message': message},
    );
    return response['status'] == 'success';
  }

  // 读取消息
  static Future<Message?> readMessage({required int msgId}) async {
    final token = LegacyApiService.getToken();
    if (token == null) return null;

    final response = await LegacyApiService.request(
      'im',
      'read_message',
      {'token': token, 'msg_id': msgId.toString()},
    );
    if (response['status'] == 'success') {
      return Message.fromJson(response);
    }
    return null;
  }

  // 系统消息一键已读
  static Future<bool> readAllSystemMessage() async {
    final token = LegacyApiService.getToken();
    if (token == null) return false;

    final response = await LegacyApiService.request(
      'im',
      'read_all_system_message',
      {'token': token},
    );
    return response['status'] == 'success';
  }

  // 删除消息
  static Future<bool> deleteMessage({required int msgId}) async {
    final token = LegacyApiService.getToken();
    if (token == null) return false;

    final response = await LegacyApiService.request(
      'im',
      'delete_message',
      {'token': token, 'msg_id': msgId.toString()},
    );
    return response['status'] == 'success';
  }

  // 撤回消息（使用 delete_message API）
  static Future<bool> recallMessage({required int msgId}) async {
    return await deleteMessage(msgId: msgId);
  }

  // 获取好友列表
  static Future<List<Friend>> getFriendList({
    int offset = 0,
    int num = 20,
    int ifTimeDesc = 1,
  }) async {
    final token = LegacyApiService.getToken();
    if (token == null) {
      getLogger().w('getFriendList: token 为 null，请先登录账号');
      return [];
    }

    // API 限制 num 不能超过 12
    if (num > 12) {
      getLogger().w('getFriendList: num 参数超过12，自动调整为12');
      num = 12;
    }

    try {
      final response = await LegacyApiService.request(
        'im',
        'friend_list',
        {
          'token': token,
          'offset': offset.toString(),
          'num': num.toString(),
          'if_time_desc': ifTimeDesc.toString(),
        },
      );
      if (response['status'] == 'success') {
        final list = response['user_list'] as List?;
        return list?.map((e) => Friend.fromJson(e)).toList() ?? [];
      } else {
        getLogger().e('getFriendList 失败: ${response['message'] ?? '未知错误'}');
        return [];
      }
    } catch (e) {
      getLogger().e('getFriendList 异常: $e');
      return [];
    }
  }

  // 获取好友消息
  static Future<List<Message>> getFriendMessage({
    required int friendUid,
    int offset = 0,
    int num = 20,
    int ifTimeDesc = 1,
  }) async {
    final token = LegacyApiService.getToken();
    if (token == null) {
      getLogger().w('getFriendMessage: token 为 null，请先登录账号');
      return [];
    }

    // API 限制 num 不能超过 12
    if (num > 12) {
      getLogger().w('getFriendMessage: num 参数超过12，自动调整为12');
      num = 12;
    }

    try {
      final response = await LegacyApiService.request(
        'im',
        'friend_message',
        {
          'token': token,
          'friend_uid': friendUid.toString(),
          'offset': offset.toString(),
          'num': num.toString(),
          'if_time_desc': ifTimeDesc.toString(),
        },
      );
      if (response['status'] == 'success') {
        final list = response['message_list'] as List?;
        return list?.map((e) => Message.fromJson(e)).toList() ?? [];
      } else {
        getLogger().e('getFriendMessage 失败: ${response['message'] ?? '未知错误'}');
        return [];
      }
    } catch (e) {
      getLogger().e('getFriendMessage 异常: $e');
      return [];
    }
  }
}
