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
  bool _isLoading = true;
  String? _error;
  String? _selectedCategoryId;
  VideoSource? _lastActiveSource;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final configService = context.read<ConfigService>();
      _lastActiveSource = configService.activeSource;
      configService.addListener(_onConfigChanged);
      _loadData();
    });
  }

  void _onConfigChanged() {
    if (!mounted) return;
    final configService = context.read<ConfigService>();
    if (configService.activeSource != _lastActiveSource) {
      _lastActiveSource = configService.activeSource;
      _selectedCategoryId = null;
      _loadData();
    }
  }

  @override
  void dispose() {
    try {
      final configService = context.read<ConfigService>();
      configService.removeListener(_onConfigChanged);
    } catch (_) {}
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final spiderService = context.read<SpiderService>();
      final configService = context.read<ConfigService>();
      if (configService.activeSource != null) {
        await spiderService.loadSource(configService.activeSource!);
      }
      final homeData = await spiderService.homeContent();
      if (!mounted) return;
      debugPrint('HomePage: homeData keys = ${homeData.keys.toList()}');
      debugPrint('HomePage: class count = ${(homeData['class'] as List?)?.length ?? 0}');
      debugPrint('HomePage: list count = ${(homeData['list'] as List?)?.length ?? 0}');
      setState(() {
        _categories = (homeData['class'] as List?)
            ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
            .toList() ?? [];
        _videos = (homeData['list'] as List?)
            ?.map((e) => Video.fromJson(e as Map<String, dynamic>))
            .toList() ?? [];
        _isLoading = false;
      });
      debugPrint('HomePage: loaded ${_videos.length} videos, ${_categories.length} categories');
    } catch (e) {
      debugPrint('HomePage: _loadData error: $e');
      if (!mounted) return;
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _loadCategory(String categoryId) async {
    setState(() { _isLoading = true; _selectedCategoryId = categoryId; });
    try {
      final spiderService = context.read<SpiderService>();
      final data = await spiderService.categoryContent(tid: categoryId);
      if (!mounted) return;
      setState(() {
        _videos = (data['list'] as List?)
            ?.map((e) => Video.fromJson(e as Map<String, dynamic>))
            .toList() ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _search(String keyword) async {
    setState(() { _isLoading = true; });
    try {
      final spiderService = context.read<SpiderService>();
      final data = await spiderService.searchContent(key: keyword);
      if (!mounted) return;
      setState(() {
        _videos = (data['list'] as List?)
            ?.map((e) => Video.fromJson(e as Map<String, dynamic>))
            .toList() ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('牛盒'),
        actions: [
          const SourceSelector(),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData, tooltip: '刷新'),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SearchBarWidget(onSearch: _search),
          ),
        ),
      ),
      body: Column(children: [
        if (_categories.isNotEmpty)
          CategoryTabs(categories: _categories, selectedId: _selectedCategoryId,
            onCategorySelected: (id) => _loadCategory(id ?? '')),
        Expanded(child: _buildContent()),
      ]),
    );
  }

  Widget _buildContent() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
      const SizedBox(height: 16),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 32), child: Text('加载失败: $_error', textAlign: TextAlign.center)),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: _loadData, child: const Text('重试')),
    ]));
    if (_videos.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.movie_filter, size: 64, color: Colors.grey),
      const SizedBox(height: 16),
      const Text('暂无内容'),
      const SizedBox(height: 8),
      const Text('请在设置中添加数据源', style: TextStyle(color: Colors.white54)),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: _loadData, child: const Text('刷新')),
    ]));
    return RefreshIndicator(
      onRefresh: _loadData,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 250, childAspectRatio: 0.65, crossAxisSpacing: 16, mainAxisSpacing: 16),
        itemCount: _videos.length,
        itemBuilder: (context, index) => VideoCard(video: _videos[index]),
      ),
    );
  }
}
