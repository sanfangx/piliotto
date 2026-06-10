/// 视频数据抽象接口
///
/// 统一不同来源的视频数据格式，提供类型安全的访问方式
abstract class VideoData {
  /// 视频ID
  int get videoId;

  /// 封面URL
  String get coverUrl;

  /// 视频标题
  String get title;

  /// 作者名称
  String get ownerName;

  /// 作者ID
  int get ownerId;

  /// 播放量
  int get viewCount;

  /// 弹幕数（可能为空）
  int? get danmakuCount;

  /// 视频时长（秒）
  int get duration;

  /// 发布时间戳（秒，可能为空）
  int? get pubdate;
}
