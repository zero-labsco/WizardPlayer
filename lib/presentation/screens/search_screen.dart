import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amis_flutter_utils/utils.dart';
import 'package:wizardplayer/core/services/bangumi_service.dart';
import 'package:wizardplayer/core/widgets/video_grid.dart';
import 'package:wizardplayer/presentation/screens/subject_detail_screen.dart';

/// 搜索页面
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  bool _isLoading = false;
  List<VideoGridItem> _searchResults = [];
  String _lastKeyword = '';

  @override
  void initState() {
    super.initState();
    // 自动聚焦搜索框
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _search(String keyword) async {
    if (keyword.trim().isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
      _lastKeyword = keyword;
    });

    try {
      final bangumiService = Get.find<BangumiService>();
      final result = await bangumiService.searchSubject(keyword);

      setState(() {
        // 将 BangumiSubject 转换为 VideoGridItem
        _searchResults = result.list.map((subject) {
          return VideoGridItem(
            title: subject.displayName,
            subtitle: subject.name,
            coverUrl: subject.image,
            rating: subject.rating,
            viewCount: subject.collectionCount?.toString(),
            tags: subject.tags.take(3).toList(),
            onTap: () =>
                Get.to(() => SubjectDetailScreen(subjectId: subject.id)),
          );
        }).toList();
        _isLoading = false;
      });

      AppLogger().d('搜索完成: $keyword, 结果: ${_searchResults.length} 条');
    } catch (e, stackTrace) {
      AppLogger().e('搜索失败', error: e, stackTrace: stackTrace);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: '搜索番剧...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey.shade400),
          ),
          onSubmitted: _search,
          textInputAction: TextInputAction.search,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _search(_searchController.text),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _lastKeyword.isEmpty ? '输入关键词搜索番剧' : '未找到相关结果',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '找到 ${_searchResults.length} 个结果',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          Expanded(child: VideoGrid(items: _searchResults)),
        ],
      ),
    );
  }
}
