import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/utils/responsive_util.dart';

/// 通用搜索控制器基类
///
/// 提供搜索页面的通用逻辑，包括：
/// - 分页加载
/// - 加载状态管理
/// - 错误处理
/// - 下拉刷新
/// - 滚动控制
///
/// 使用示例：
/// ```dart
/// class VideoSearchController extends BaseSearchController<Video> {
///   @override
///   Future<List<Video>> performSearch(String keyword, int offset, int count) async {
///     final response = await videoRepo.searchVideos(
///       searchTerm: keyword,
///       offset: offset,
///       num: count,
///     );
///     return response.videoList;
///   }
/// }
/// ```
abstract class BaseSearchController<T> extends GetxController {
  /// 滚动控制器
  final ScrollController scrollController = ScrollController();

  /// 搜索输入控制器
  final TextEditingController searchInputController = TextEditingController();

  /// 搜索框焦点
  final FocusNode searchFocusNode = FocusNode();

  /// 每页数据数量
  final int pageSize;

  /// 当前页码
  int _currentPage = 1;

  /// 搜索结果列表
  RxList<T> resultList = <T>[].obs;

  /// 是否正在加载（首次加载）
  RxBool isLoading = false.obs;

  /// 是否正在加载更多
  RxBool isLoadingMore = false.obs;

  /// 是否还有更多数据
  RxBool hasMore = true.obs;

  /// 当前搜索关键词
  RxString currentKeyword = ''.obs;

  /// 网格列数
  RxInt crossAxisCount = 1.obs;

  /// 错误信息
  RxString errorMessage = ''.obs;

  /// 是否有错误
  RxBool hasError = false.obs;

  BaseSearchController({this.pageSize = 20});

  @override
  void onInit() {
    super.onInit();
    updateCrossAxisCount();
  }

  /// 更新网格列数（响应式布局）
  void updateCrossAxisCount() {
    try {
      crossAxisCount.value = ResponsiveUtil.calculateCrossAxisCount(
        baseCount: 1,
        minCount: 1,
        maxCount: 3,
      );
    } catch (e) {
      crossAxisCount.value = 1;
    }
  }

  /// 清除错误状态
  void _clearError() {
    errorMessage.value = '';
    hasError.value = false;
  }

  /// 设置错误状态
  void _setError(String message) {
    errorMessage.value = message;
    hasError.value = true;
  }

  /// 执行搜索的具体实现
  ///
  /// 子类必须实现此方法，返回搜索结果列表
  ///
  /// 参数：
  /// - [keyword]: 搜索关键词
  /// - [offset]: 偏移量（用于分页）
  /// - [count]: 请求数量
  ///
  /// 返回：搜索结果列表
  Future<List<T>> performSearch(String keyword, int offset, int count);

  /// 搜索前的预处理
  ///
  /// 子类可重写此方法实现搜索前的特殊逻辑
  /// 例如：处理特殊搜索格式（如 OV123）
  ///
  /// 返回 true 表示已处理，不需要继续搜索
  /// 返回 false 表示需要继续执行搜索
  Future<bool> onBeforeSearch(String keyword) async {
    return false;
  }

  /// 执行搜索
  ///
  /// [keyword]: 搜索关键词
  /// [isLoadMore]: 是否为加载更多
  Future<void> search(String keyword, {bool isLoadMore = false}) async {
    if (keyword.isEmpty) return;

    final String trimmedKeyword = keyword.trim();

    // 搜索前预处理
    final handled = await onBeforeSearch(trimmedKeyword);
    if (handled) return;

    if (!isLoadMore) {
      isLoading.value = true;
      _currentPage = 1;
      currentKeyword.value = keyword;
      _clearError();
    } else {
      isLoadingMore.value = true;
    }

    try {
      int offset = (_currentPage - 1) * pageSize;
      final List<T> results =
          await performSearch(trimmedKeyword, offset, pageSize);

      if (isLoadMore) {
        resultList.addAll(results);
      } else {
        resultList.value = results;
      }

      hasMore.value = results.length >= pageSize;
      _currentPage++;
    } catch (e) {
      onSearchError(e, isLoadMore);
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// 搜索错误处理
  ///
  /// 子类可重写此方法自定义错误处理逻辑
  void onSearchError(dynamic error, bool isLoadMore) {
    final String message = error.toString();
    if (!isLoadMore) {
      _setError(message.contains('Exception:')
          ? message.replaceFirst('Exception: ', '')
          : '搜索失败，请稍后重试');
      resultList.clear();
    }
  }

  /// 加载更多
  Future<void> onLoad() async {
    if (isLoadingMore.value || !hasMore.value) return;
    await search(currentKeyword.value, isLoadMore: true);
  }

  /// 下拉刷新
  Future<void> onRefresh() async {
    if (currentKeyword.value.isNotEmpty) {
      await search(currentKeyword.value);
    }
  }

  /// 清除搜索结果
  void clearSearchResult() {
    resultList.clear();
    currentKeyword.value = '';
    searchInputController.clear();
    _clearError();
  }

  /// 重试搜索
  void retrySearch() {
    if (currentKeyword.value.isNotEmpty) {
      search(currentKeyword.value);
    }
  }

  /// 滚动到顶部
  void animateToTop() async {
    // 检查 scrollController 是否已经被 dispose
    if (!scrollController.hasClients) return;

    // 保存当前 offset，避免在异步过程中 scrollController 被 dispose
    final currentOffset = scrollController.offset;
    final context = Get.context;

    if (context == null) return;

    if (currentOffset >= MediaQuery.of(context).size.height * 5) {
      // 再次检查，因为前面的判断可能耗时
      if (!scrollController.hasClients) return;
      scrollController.jumpTo(0);
    } else {
      // 使用 try-catch 捕获可能的异常
      try {
        if (!scrollController.hasClients) return;
        await scrollController.animateTo(0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut);
      } catch (e) {
        // 忽略 dispose 后的异常
      }
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchInputController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }
}
