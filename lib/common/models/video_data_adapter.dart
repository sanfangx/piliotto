import 'package:piliotto/common/models/video_data.dart';
import 'package:piliotto/ottohub/api/models/video.dart';
import 'package:piliotto/ottohub/models/member/archive.dart';

/// Video 类的 VideoData 适配器
class VideoAdapter implements VideoData {
  final Video _video;

  VideoAdapter(this._video);

  @override
  int get videoId => _video.vid;

  @override
  String get coverUrl => _video.coverUrl;

  @override
  String get title => _video.title;

  @override
  String get ownerName => _video.username;

  @override
  int get ownerId => _video.uid;

  @override
  int get viewCount => _video.viewCount;

  @override
  int? get danmakuCount => null;

  @override
  int get duration => _video.duration ?? 0;

  @override
  int? get pubdate {
    final time = _video.time;
    final dt = DateTime.tryParse(time);
    return dt != null ? dt.millisecondsSinceEpoch ~/ 1000 : null;
  }
}

/// VListItemModel 类的 VideoData 适配器
class VListItemModelAdapter implements VideoData {
  final VListItemModel _item;

  VListItemModelAdapter(this._item);

  @override
  int get videoId => _item.vid ?? _item.aid ?? 0;

  @override
  String get coverUrl => _item.pic ?? '';

  @override
  String get title => _item.title ?? '';

  @override
  String get ownerName => _item.owner?.name ?? _item.author ?? '';

  @override
  int get ownerId => _item.owner?.mid ?? _item.mid ?? 0;

  @override
  int get viewCount => _item.stat?.view ?? _item.play ?? 0;

  @override
  int? get danmakuCount => _item.stat?.danmaku ?? _item.videoReview;

  @override
  int get duration {
    final dur = _item.duration ?? _item.length;
    if (dur != null) return int.tryParse(dur) ?? 0;
    return 0;
  }

  @override
  int? get pubdate => _item.pubdate ?? _item.created;
}

/// 动态类型转 VideoData 的工具方法
VideoData? toVideoData(dynamic item) {
  if (item is Video) {
    return VideoAdapter(item);
  }
  if (item is VListItemModel) {
    return VListItemModelAdapter(item);
  }
  return null;
}
