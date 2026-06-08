/// 搜索结果模型
class SearchResult {
  /// 搜索关键词
  final String query;

  /// 视频列表
  final List<dynamic> videos;

  /// 总结果数
  final int totalCount;

  /// 当前页码
  final int page;

  /// 每页数量
  final int pageSize;

  /// 是否有下一页
  final bool hasMore;

  const SearchResult({
    required this.query,
    required this.videos,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });
}
