import 'package:get/get.dart';
import 'package:piliotto/ottohub/api/models/message.dart';
import 'package:piliotto/repositories/i_message_repository.dart';
import 'package:piliotto/pages/home/controller.dart';
import 'package:piliotto/utils/storage.dart';

class MessageController extends GetxController {
  final IMessageRepository _messageRepo = Get.find<IMessageRepository>();
  RxList<Friend> friendList = <Friend>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  Rxn<Friend> selectedFriend = Rxn<Friend>();
  Rxn<Friend> currentUser = Rxn<Friend>();
  RxList<Friend> userList = <Friend>[].obs;

  int _offset = 0;
  final int _pageSize = 12; // API 限制 num 不能超过 12
  bool _hasMore = true;

  @override
  void onInit() {
    super.onInit();
    _initCurrentUser();
    _checkInitialFriend();
    loadFriendList();
    // 打开消息页面时刷新未读消息数
    _refreshUnreadCount();
  }

  void _refreshUnreadCount() {
    try {
      Get.find<HomeController>().refreshUnreadMessageNum();
    } catch (_) {
      // HomeController 可能尚未注册
    }
  }

  void _initCurrentUser() {
    final userInfo = GStorage.userInfo.get('userInfoCache');
    if (userInfo != null) {
      currentUser.value = Friend(
        uid: userInfo.mid ?? 0,
        username: userInfo.uname ?? '',
        avatarUrl: userInfo.face,
      );
    }
  }

  void _checkInitialFriend() {
    final parameters = Get.parameters;
    final mid = parameters['mid'];
    final name = parameters['name'];
    final face = parameters['face'];

    if (mid != null && name != null) {
      selectedFriend.value = Friend(
        uid: int.tryParse(mid) ?? 0,
        username: name,
        avatarUrl: face,
      );
    }
  }

  Future loadFriendList({bool refresh = false}) async {
    if (isLoading.value) return;

    if (refresh) {
      _offset = 0;
      _hasMore = true;
      friendList.clear();
    }

    if (!_hasMore) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final allFriends = await _messageRepo.getFriendList(
        offset: _offset,
        num: _pageSize,
      );

      if (allFriends.length < _pageSize) {
        _hasMore = false;
      }

      friendList.addAll(allFriends);
      _updateUserList(allFriends);
      _offset += allFriends.length;
    } catch (e) {
      errorMessage.value = '加载失败: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void _updateUserList(List<Friend> friends) {
    for (final friend in friends) {
      if (!userList.any((u) => u.uid == friend.uid)) {
        userList.add(friend);
      }
    }
  }

  void selectFriend(Friend friend) {
    selectedFriend.value = friend;
  }

  void clearSelection() {
    selectedFriend.value = null;
  }

  void switchUser(Friend user) {
    currentUser.value = user;
    selectedFriend.value = null;
    friendList.clear();
    userList.clear();
    _offset = 0;
    _hasMore = true;
    loadFriendList(refresh: true);
  }
}
