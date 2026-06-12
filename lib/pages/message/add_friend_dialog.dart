import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/ottohub/models/member/info.dart';
import 'package:piliotto/ottohub/api/services/legacy_api_service.dart';
import 'package:piliotto/services/loggeer.dart';

class AddFriendDialog extends StatefulWidget {
  const AddFriendDialog({super.key});

  @override
  State<AddFriendDialog> createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<AddFriendDialog> {
  final TextEditingController _uidController = TextEditingController();
  final Rxn<MemberInfoModel> foundUser = Rxn<MemberInfoModel>();
  final RxBool isSearching = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void dispose() {
    _uidController.dispose();
    super.dispose();
  }

  Future<void> _findUser() async {
    final uidText = _uidController.text.trim();
    if (uidText.isEmpty) {
      errorMessage.value = '请输入用户 UID';
      return;
    }

    final uid = int.tryParse(uidText);
    if (uid == null) {
      errorMessage.value = 'UID 格式不正确，请输入数字';
      return;
    }

    isSearching.value = true;
    errorMessage.value = '';
    foundUser.value = null;

    try {
      final response = await LegacyApiService.getUserDetail(uid: uid);
      if (response['status'] == 'success') {
        final userData = response['data'] ?? response;
        foundUser.value = MemberInfoModel.fromJson(userData);
      } else {
        errorMessage.value = '用户不存在';
      }
    } catch (e) {
      getLogger().e('查找用户失败: $e');
      errorMessage.value = '查找失败: $e';
    } finally {
      isSearching.value = false;
    }
  }

  void _sendMessage() {
    final user = foundUser.value;
    if (user == null) return;

    Get.back();
    Get.toNamed('/whisperDetail', parameters: {
      'mid': user.mid.toString(),
      'name': user.name ?? '',
      'face': user.face ?? '',
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('添加好友'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // UID 输入框
            TextField(
              controller: _uidController,
              decoration: InputDecoration(
                hintText: '输入用户 UID',
                prefixIcon: const Icon(Icons.person),
                suffixIcon: Obx(
                  () => isSearching.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          onPressed: _findUser,
                          icon: const Icon(Icons.search),
                        ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
              onSubmitted: (_) => _findUser(),
            ),
            const SizedBox(height: 16),

            // 错误信息
            Obx(
              () {
                if (errorMessage.value.isNotEmpty) {
                  return Text(
                    errorMessage.value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // 找到的用户信息
            Obx(
              () {
                final user = foundUser.value;
                if (user == null) return const SizedBox.shrink();

                return Card(
                  margin: const EdgeInsets.only(top: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: user.face != null && user.face!.isNotEmpty
                              ? NetworkImage(user.face!)
                              : null,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: user.face == null || user.face!.isEmpty
                              ? Icon(Icons.person,
                                  size: 24,
                                  color: theme.colorScheme.onPrimaryContainer)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name ?? '未知用户',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'UID: ${user.mid ?? 0}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('取消'),
        ),
        Obx(
          () => foundUser.value != null
              ? FilledButton(
                  onPressed: _sendMessage,
                  child: const Text('发送消息'),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}