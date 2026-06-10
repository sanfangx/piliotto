import 'package:get/get.dart';
import 'package:piliotto/pages/search/base_search_controller.dart';
import 'package:piliotto/repositories/i_video_repository.dart';
import 'package:piliotto/ottohub/api/models/video.dart';
import 'package:piliotto/ottohub/api/services/api_service.dart';
import 'package:piliotto/services/loggeer.dart';

final _logger = getLogger();

/// 视频搜索控制器
/// 
/// 继承自 [BaseSearchController]，实现视频搜索的具体逻辑。
/// 
/// 特殊功能：
/// - 支持 OV号码快速跳转（如 OV123 直接跳转到视频详情）
/// 
/// 使用示例：
/// ```dart
/// // 在页面中注册控制器
/// final controller = Get.put(VideoSearchController());
/// 
/// // 执行搜索
/// controller.search('关键词');
/// ```
class VideoSearchController extends BaseSearchController<Video> {
  final IVideoRepository _videoRepo = Get.find<IVideoRepository>();

  VideoSearchController({super.pageSize});

  /// 检查是否为 OV号码格式
  bool _isOVNumber(String input) {
    final RegExp ovPattern = RegExp(r'^OV(\d+)$', caseSensitive: false);
    return ovPattern.hasMatch(input.trim());
  }

  /// 从 OV号码中提取视频ID
  int? _extractVidFromOV(String input) {
    final RegExp ovPattern = RegExp(r'^OV(\d+)$', caseSensitive: false);
    final match = ovPattern.firstMatch(input.trim());
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  @override
  Future<bool> onBeforeSearch(String keyword) async {
    // 处理 OV号码快速跳转
    if (_isOVNumber(keyword)) {
      final int? vid = _extractVidFromOV(keyword);
      if (vid != null) {
        Get.toNamed('/video?vid=$vid', arguments: {
          'heroTag': 'ov_$vid',
        });
        return true;
      }
    }
    return false;
  }

  @override
  Future<List<Video>> performSearch(String keyword, int offset, int count) async {
    final response = await _videoRepo.searchVideos(
      searchTerm: keyword,
      offset: offset,
      num: count,
    );
    return response.videoList;
  }

  @override
  void onSearchError(dynamic error, bool isLoadMore) {
    if (error is ApiException) {
      _logger.w('搜索失败: ${error.message}');
      if (!isLoadMore) {
        errorMessage.value = error.message;
        hasError.value = true;
        resultList.clear();
      }
    } else {
      _logger.w('搜索失败: $error');
      super.onSearchError(error, isLoadMore);
    }
  }

  /// 向后兼容：使用 searchVideos 方法
  Future<void> searchVideos(String keyword, {bool isLoadMore = false}) async {
    await search(keyword, isLoadMore: isLoadMore);
  }

  /// 向后兼容：获取视频列表
  RxList<Video> get videoList => resultList;
}
