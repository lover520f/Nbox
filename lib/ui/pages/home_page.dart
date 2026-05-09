import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/config_service.dart';
import '../../core/services/spider_service.dart';
import '../../core/models/video_source.dart';
import '../widgets/video_card.dart';
import '../widgets/source_selector.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/category_tabs.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Video> _videos = [];
  List<Category> _categories = [];
  Map<String, dynamic> _filters = {};
  bool _isLoading = true;
  String? _error;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final spiderService = context.read<SpiderService>();
      final configService = context.read<ConfigService>();
      
      if (configService.activeSource != null) {
        await spiderService.loadSource(configService.activeSource!);
      }
      
      final homeData = await spiderService.homeContent();
      
      setState(() {
        _categories = (homeData['class'] as List?)
            ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
            .toList() ?? [];
        
        _videos = (homeData['list'] as List?)
            ?.map((e) => Video.fromJson(e as Map<String, dynamic>))
            .toList() ?? [];
        
        _filters = homeData['filters'] as Map<String, dynamic>? ?? {};
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCategory(String categoryId) async {
    setState(() {
      _isLoading = true;
      _selectedCategoryId = categoryId;
    });

    try {
      final spiderService = context.read<SpiderService>();
      final data = await spiderService.categoryContent(tid: categoryId);
      
      setState(() {
        _videos = (data['list'] as List?)
            ?.map((e) => Video.fromJson(e as Map<String, dynamic>))
            .toList() ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _search(String keyword) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final spiderService = context.read<SpiderService>();
      final data = await spiderService.searchContent(key: keyword);
      
      setState(() {
        _videos = (data['list'] as List?)
            ?.map((e) => Video.fromJson(e as Map<String, dynamic>))
            .toList() ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter TV'),
        actions: [
          const SourceSelector(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: '刷新',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SearchBarWidget(onSearch: _search),
          ),
        ),
      ),
      body: Column(
        children: [
          if (_categories.isNotEmpty)
            CategoryTabs(
              categories: _categories,
              selectedId: _selectedCategoryId,
              onCategorySelected: (id) => _loadCategory(id ?? ''),
            ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('加载失败: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_videos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie_filter, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无内容'),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        return VideoCard(video: _videos[index]);
      },
    );
  }
}
