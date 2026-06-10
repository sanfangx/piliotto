import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:piliotto/common/constants.dart';
import 'package:piliotto/common/skeleton/video_card_h.dart';
import 'package:piliotto/common/widgets/video_card_h.dart';
import 'package:piliotto/ottohub/api/models/video.dart';
import 'package:piliotto/pages/search/base_search_controller.dart';
import 'package:piliotto/pages/search/controller.dart';
import 'package:piliotto/services/search_history_service.dart';
import 'package:piliotto/utils/responsive_util.dart';

/// 通用搜索页面模板
/// 
/// 支持自定义搜索结果渲染，可用于任意类型的搜索场景。
/// 
/// ## 基本用法（视频搜索）
/// ```dart
/// SearchPage<Video>(
///   controller: VideoSearchController(),
///   itemBuilder: (context, video, index) => VideoCardH(
///     videoItem: video,
///     source: 'search',
///   ),
///   skeletonBuilder: (context) => const VideoCardHSkeleton(),
///   emptyIcon: Icons.video_library_outlined,
///   emptyText: '未找到相关视频',
/// )
/// ```
/// 
/// ## 自定义搜索类型
/// ```dart
/// // 1. 创建自定义控制器
/// class UserSearchController extends BaseSearchController<User> {
///   @override
///   Future<List<User>> performSearch(String keyword, int offset, int count) async {
///     return await userRepo.search(keyword, offset, count);
///   }
/// }
/// 
/// // 2. 使用自定义搜索页面
/// SearchPage<User>(
///   controller: UserSearchController(),
///   itemBuilder: (context, user, index) => UserCard(user: user),
///   skeletonBuilder: (context) => UserCardSkeleton(),
///   emptyIcon: Icons.person_outline,
///   emptyText: '未找到相关用户',
///   hintText: '搜索用户',
/// )
/// ```
/// 
/// ## 参数说明
/// - [controller]: 搜索控制器，必须继承自 [BaseSearchController]
/// - [itemBuilder]: 搜索结果项构建器，用于自定义渲染每个搜索结果
/// - [skeletonBuilder]: 加载骨架屏构建器，用于自定义加载状态显示
/// - [emptyBuilder]: 空状态构建器，完全自定义空状态显示
/// - [emptyIcon]: 空状态图标（当不使用 emptyBuilder 时）
/// - [emptyText]: 空状态文本（当不使用 emptyBuilder 时）
/// - [hintText]: 搜索框提示文本
/// - [gridChildAspectRatio]: 网格项宽高比，默认 3/1
/// - [gridMainAxisSpacing]: 网格主轴间距，默认 16
/// - [gridCrossAxisSpacing]: 网格交叉轴间距，默认 16
class SearchPage<T> extends StatefulWidget {
  /// 搜索控制器
  final BaseSearchController<T> controller;
  
  /// 搜索结果项构建器
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  
  /// 加载骨架屏构建器
  final Widget Function(BuildContext context)? skeletonBuilder;
  
  /// 空状态构建器（完全自定义）
  final Widget Function(BuildContext context, String keyword)? emptyBuilder;
  
  /// 空状态图标
  final IconData? emptyIcon;
  
  /// 空状态文本
  final String? emptyText;
  
  /// 搜索框提示文本
  final String? hintText;
  
  /// 初始搜索关键词
  final String? initialKeyword;
  
  /// 网格项宽高比
  final double gridChildAspectRatio;
  
  /// 网格主轴间距
  final double gridMainAxisSpacing;
  
  /// 网格交叉轴间距
  final double gridCrossAxisSpacing;
  
  /// 是否显示搜索历史
  final bool showSearchHistory;

  const SearchPage({
    super.key,
    required this.controller,
    required this.itemBuilder,
    this.skeletonBuilder,
    this.emptyBuilder,
    this.emptyIcon,
    this.emptyText,
    this.hintText,
    this.initialKeyword,
    this.gridChildAspectRatio = 3 / 1,
    this.gridMainAxisSpacing = 16,
    this.gridCrossAxisSpacing = 16,
    this.showSearchHistory = true,
  });

  @override
  State<SearchPage<T>> createState() => _SearchPageState<T>();
}

class _SearchPageState<T> extends State<SearchPage<T>> {
  late BaseSearchController<T> _controller;
  final SearchController _searchController = SearchController();
  final SearchHistoryService _historyService = SearchHistoryService();
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    
    // 从路由参数获取初始关键词
    final routeKeyword = Get.parameters['keyword'];
    
    final effectiveKeyword = widget.initialKeyword ?? routeKeyword;
    
    if (widget.showSearchHistory) {
      _historyService.loadSearchHistory();
    }

    if (effectiveKeyword != null && effectiveKeyword.isNotEmpty) {
      _searchController.text = effectiveKeyword;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeKeyword = Get.parameters['keyword'];
    final effectiveKeyword = widget.initialKeyword ?? routeKeyword;
    
    if (!_hasSearched && effectiveKeyword != null && effectiveKeyword.isNotEmpty) {
      _hasSearched = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller.search(effectiveKeyword);
        }
      });
    }
  }

  void _onSearch(String keyword, {bool closeView = true}) {
    if (keyword.trim().isEmpty) return;
    if (widget.showSearchHistory) {
      _historyService.saveSearchHistory(keyword.trim());
    }
    if (closeView) {
      _searchController.closeView(null);
    }
    _controller.search(keyword.trim());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWideScreen = ResponsiveUtil.isMd;
    double maxContentWidth = 800;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isWideScreen ? 500 : double.infinity,
                      ),
                      child: _buildSearchInput(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: Obx(
          () => _buildSearchResult(screenWidth, isWideScreen, maxContentWidth)),
    );
  }

  Widget _buildSearchInput() {
    final effectiveHintText = widget.hintText ?? Get.parameters['hintText'] ?? '搜索';
    
    return SearchAnchor(
      searchController: _searchController,
      viewHintText: effectiveHintText,
      viewOnSubmitted: (value) {
        _onSearch(value);
      },
      viewTrailing: [
        IconButton(
          onPressed: () {
            _onSearch(_searchController.text);
          },
          icon: const Icon(Icons.search),
        ),
      ],
      builder: (context, controller) {
        return SearchBar(
          controller: controller,
          hintText: effectiveHintText,
          leading: const Icon(Icons.search_outlined),
          onTap: () {
            controller.openView();
          },
          onChanged: (_) {
            controller.openView();
          },
          onSubmitted: (value) {
            _onSearch(value);
          },
          trailing: [
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                if (value.text.isNotEmpty) {
                  return IconButton(
                    onPressed: () {
                      controller.clear();
                    },
                    icon: const Icon(Icons.clear),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
          elevation: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.focused)) {
              return 3.0;
            }
            return 0.0;
          }),
        );
      },
      suggestionsBuilder: widget.showSearchHistory 
          ? _buildSuggestions 
          : (context, controller) => [],
    );
  }

  List<Widget> _buildSuggestions(BuildContext context, SearchController controller) {
    final query = controller.text;
    final filteredHistory = _historyService.filterSearchHistory(query);

    if (filteredHistory.isEmpty && query.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '暂无搜索历史',
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
        ),
      ];
    }

    final List<Widget> suggestions = [
      if (_historyService.currentHistory.isNotEmpty) ...[
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '搜索历史',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {});
                  _historyService.clearSearchHistory();
                },
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('清空'),
              ),
            ],
          ),
        ),
      ],
    ];

    suggestions.addAll(
      filteredHistory.map((item) {
        return ListTile(
          leading: const Icon(Icons.history, size: 20),
          title: Text(item),
          trailing: IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {
              setState(() {});
              _historyService.removeSearchHistory(item);
            },
          ),
          onTap: () {
            controller.closeView(item);
            _onSearch(item, closeView: false);
          },
          dense: true,
          visualDensity: VisualDensity.compact,
        );
      }),
    );

    return suggestions;
  }

  Widget _buildSearchResult(
      double screenWidth, bool isWideScreen, double maxContentWidth) {
    if (_controller.isLoading.value) {
      return _buildLoadingSkeleton(screenWidth, isWideScreen, maxContentWidth);
    }

    if (_controller.hasError.value) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _controller.retrySearch,
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    if (_controller.resultList.isEmpty) {
      // 使用自定义空状态构建器
      if (widget.emptyBuilder != null) {
        return widget.emptyBuilder!(context, _controller.currentKeyword.value);
      }
      
      // 默认空状态显示
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.emptyIcon ?? Icons.search_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              _controller.currentKeyword.value.isEmpty
                  ? '输入关键词开始搜索'
                  : (widget.emptyText ?? '未找到相关结果'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 100) {
          _controller.onLoad();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: _controller.onRefresh,
        child: CustomScrollView(
          controller: _controller.scrollController,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                StyleString.safeSpace,
                StyleString.safeSpace - 5,
                StyleString.safeSpace,
                0,
              ),
              sliver: SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal:
                      isWideScreen ? (screenWidth - maxContentWidth) / 2 : 0,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _controller.crossAxisCount.value,
                    mainAxisSpacing: widget.gridMainAxisSpacing,
                    crossAxisSpacing: widget.gridCrossAxisSpacing,
                    childAspectRatio: widget.gridChildAspectRatio,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return widget.itemBuilder(
                        context,
                        _controller.resultList[index],
                        index,
                      );
                    },
                    childCount: _controller.resultList.length,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Obx(() {
                if (_controller.isLoadingMore.value) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  );
                }
                if (!_controller.hasMore.value) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: Text(
                      '没有更多了',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(
      double screenWidth, bool isWideScreen, double maxContentWidth) {
    // 使用自定义骨架屏构建器
    if (widget.skeletonBuilder != null) {
      return CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              StyleString.safeSpace,
              StyleString.safeSpace - 5,
              StyleString.safeSpace,
              0,
            ),
            sliver: SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal:
                    isWideScreen ? (screenWidth - maxContentWidth) / 2 : 0,
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _controller.crossAxisCount.value,
                  mainAxisSpacing: widget.gridMainAxisSpacing,
                  crossAxisSpacing: widget.gridCrossAxisSpacing,
                  childAspectRatio: widget.gridChildAspectRatio,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return widget.skeletonBuilder!(context);
                  },
                  childCount: 10,
                ),
              ),
            ),
          ),
        ],
      );
    }
    
    // 默认骨架屏（使用 VideoCardHSkeleton 作为后备）
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            StyleString.safeSpace,
            StyleString.safeSpace - 5,
            StyleString.safeSpace,
            0,
          ),
          sliver: SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal:
                  isWideScreen ? (screenWidth - maxContentWidth) / 2 : 0,
            ),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _controller.crossAxisCount.value,
                mainAxisSpacing: widget.gridMainAxisSpacing,
                crossAxisSpacing: widget.gridCrossAxisSpacing,
                childAspectRatio: widget.gridChildAspectRatio,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return const VideoCardHSkeleton();
                },
                childCount: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 视频搜索页面（向后兼容）
/// 
/// 这是一个便捷类，等同于使用 [SearchPage] 配置视频搜索参数。
/// 
/// 使用示例：
/// ```dart
/// // 直接使用
/// VideoSearchPage()
/// 
/// // 或使用 SearchPage
/// SearchPage<Video>(
///   controller: VideoSearchController(),
///   itemBuilder: (context, video, index) => VideoCardH(
///     videoItem: video,
///     source: 'search',
///   ),
///   skeletonBuilder: (context) => const VideoCardHSkeleton(),
///   emptyIcon: Icons.video_library_outlined,
///   emptyText: '未找到相关视频',
/// )
/// ```
class VideoSearchPage extends StatelessWidget {
  final String? hintText;
  final String? initialKeyword;

  const VideoSearchPage({
    super.key,
    this.hintText,
    this.initialKeyword,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VideoSearchController>(
      init: VideoSearchController(),
      builder: (controller) {
        return SearchPage<Video>(
          controller: controller,
          itemBuilder: (context, video, index) => VideoCardH(
            videoItem: video,
            source: 'search',
          ),
          skeletonBuilder: (context) => const VideoCardHSkeleton(),
          emptyIcon: Icons.video_library_outlined,
          emptyText: '未找到相关视频',
          hintText: hintText,
          initialKeyword: initialKeyword,
        );
      },
    );
  }
}
