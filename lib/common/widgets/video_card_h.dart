import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

import 'package:piliotto/common/constants/app_styles.dart';
import 'package:piliotto/common/models/video_data.dart';
import 'package:piliotto/common/models/video_data_adapter.dart';
import 'package:piliotto/utils/feed_back.dart';
import 'package:piliotto/utils/image_save.dart';

import 'package:piliotto/repositories/i_user_repository.dart';
import '../../utils/utils.dart';
import '../constants.dart';
import 'badge.dart';
import 'network_img_layer.dart';
import 'rank_badge.dart';
import 'stat/danmu.dart';
import 'stat/view.dart';

class VideoCardH extends StatelessWidget {
  const VideoCardH({
    super.key,
    required this.videoItem,
    this.onPressedFn,
    this.source = 'normal',
    this.showOwner = true,
    this.showView = true,
    this.showDanmaku = true,
    this.showPubdate = false,
    this.showCharge = false,
    this.rankIndex,
  });
  final dynamic videoItem;
  final Function()? onPressedFn;
  final String source;
  final bool showOwner;
  final bool showView;
  final bool showDanmaku;
  final bool showPubdate;
  final bool showCharge;
  final int? rankIndex;

  /// 获取类型安全的视频数据
  VideoData get _videoData {
    final data = toVideoData(videoItem);
    if (data != null) return data;
    // 如果无法转换，返回一个默认实现（这种情况不应该发生）
    throw ArgumentError(
        'Unsupported video item type: ${videoItem.runtimeType}');
  }

  @override
  Widget build(BuildContext context) {
    final videoData = _videoData;
    final String heroTag = Utils.makeHeroTag(videoData.videoId);
    return InkWell(
      onTap: () async {
        Get.toNamed('/video?vid=${videoData.videoId}', arguments: {
          'pic': videoData.coverUrl,
          'heroTag': heroTag,
        });
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            StyleString.safeSpace, 5, StyleString.safeSpace, 5),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints boxConstraints) {
            final double width = (boxConstraints.maxWidth -
                    StyleString.cardSpace *
                        6 /
                        MediaQuery.textScalerOf(context).scale(1.0)) /
                2;
            return Container(
              constraints: const BoxConstraints(minHeight: 88),
              height: width / StyleString.aspectRatio,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: StyleString.aspectRatio,
                    child: LayoutBuilder(
                      builder: (BuildContext context,
                          BoxConstraints boxConstraints) {
                        final double maxWidth = boxConstraints.maxWidth;
                        final double maxHeight = boxConstraints.maxHeight;
                        return Stack(
                          children: [
                            Hero(
                              tag: heroTag,
                              child: NetworkImgLayer(
                                src: videoData.coverUrl,
                                width: maxWidth,
                                height: maxHeight,
                              ),
                            ),
                            if (rankIndex != null && rankIndex! <= 3)
                              Positioned(
                                left: 0,
                                top: 0,
                                child: RankBadge(rank: rankIndex!),
                              ),
                            if (rankIndex != null && rankIndex! > 3)
                              Positioned(
                                left: 0,
                                top: 0,
                                child: RankBadge(
                                    rank: rankIndex!, fontSize: AppFontSize.sm),
                              ),
                            if (videoData.duration > 0)
                              PBadge(
                                text: Utils.timeFormat(videoData.duration),
                                right: 6.0,
                                bottom: 6.0,
                                type: 'gray',
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 6, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            videoData.title,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          if (showPubdate && videoData.pubdate != null)
                            Text(
                              Utils.dateFormat(videoData.pubdate!),
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).colorScheme.outline),
                            ),
                          if (showOwner)
                            Row(
                              children: [
                                Text(
                                  videoData.ownerName,
                                  style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .fontSize,
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          Row(
                            children: [
                              if (showView) ...[
                                StatView(view: videoData.viewCount),
                                const SizedBox(width: AppSpacing.sm),
                              ],
                              if (showDanmaku && videoData.danmakuCount != null)
                                StatDanMu(danmu: videoData.danmakuCount),
                              const Spacer(),
                              if (source == 'normal')
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      feedBack();
                                      showModalBottomSheet(
                                        context: context,
                                        useRootNavigator: true,
                                        isScrollControlled: true,
                                        builder: (context) {
                                          return MorePanel(
                                              videoItem: videoItem);
                                        },
                                      );
                                    },
                                    icon: Icon(
                                      Icons.more_vert_outlined,
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              if (source == 'later') ...[
                                IconButton(
                                  style: ButtonStyle(
                                    padding: WidgetStateProperty.all(
                                        EdgeInsets.zero),
                                  ),
                                  onPressed: () => onPressedFn?.call(),
                                  icon: Icon(
                                    Icons.clear_outlined,
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                    size: 18,
                                  ),
                                )
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class MorePanel extends StatelessWidget {
  final dynamic videoItem;
  const MorePanel({super.key, required this.videoItem});

  /// 获取类型安全的视频数据
  VideoData get _videoData {
    final data = toVideoData(videoItem);
    if (data != null) return data;
    throw ArgumentError(
        'Unsupported video item type: ${videoItem.runtimeType}');
  }

  String get _ownerName => _videoData.ownerName;

  int get _ownerId => _videoData.ownerId;

  void blockUser() async {
    SmartDialog.show(
      useSystem: true,
      animationType: SmartAnimationType.centerFade_otherSlide,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('提示'),
          content:
              Text('确定拉黑:$_ownerName($_ownerId)?\n\n注：被拉黑的Up可以在隐私设置-黑名单管理中解除'),
          actions: [
            TextButton(
              onPressed: () => SmartDialog.dismiss(),
              child: Text(
                '点错了',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await Get.find<IUserRepository>()
                      .blockUser(blockedId: _ownerId);
                  SmartDialog.dismiss();
                  SmartDialog.showToast('拉黑成功');
                } catch (error) {
                  SmartDialog.dismiss();
                  SmartDialog.showToast('拉黑失败: $error');
                }
              },
              child: const Text('确认'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => Get.back(),
            child: Container(
              height: 35,
              padding: const EdgeInsets.only(bottom: 2),
              child: Center(
                child: Container(
                  width: 32,
                  height: 3,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outline,
                      borderRadius: const BorderRadius.all(Radius.circular(3))),
                ),
              ),
            ),
          ),
          ListTile(
            onTap: () async => blockUser(),
            minLeadingWidth: 0,
            leading: const Icon(Icons.block, size: 19),
            title: Text(
              '拉黑up主 「$_ownerName」',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ListTile(
            onTap: () =>
                imageSaveDialog(context, videoItem, SmartDialog.dismiss),
            minLeadingWidth: 0,
            leading: const Icon(Icons.photo_outlined, size: 19),
            title:
                Text('查看视频封面', style: Theme.of(context).textTheme.titleSmall),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
