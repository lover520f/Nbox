import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/config_service.dart';
import '../../core/services/spider_service.dart';
import '../../core/models/video_source.dart';
import '../widgets/video_card.dart';
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
        if (spiderService.currentSource != configService.activeSource) {
          await spiderService.loadSource(configService.activeSource!);
        }
      }
      final homeData = await spiderService.homeContent();
      if (!mounted) return;
      setState(() {
        _categories = (homeData['class'] as List?)
            ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
            .toList() ?? [];
        _videos = (homeData['list'] as List?)
            ?.map((e) => Video.fromJson(e as Map<String, dynamic>))
            .toList() ?? [];
        _isLoading = false;
      });
    } catch (e) {
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

  void _showSourceSwitcher() {
    final configService = context.read<ConfigService>();
    final sources = configService.sources;
    if (sources.isEmpty) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Consumer<ConfigService>(
        builder: (context, configService, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4, margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('切换站点', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ),
              const Divider(height: 1),
              ...sources.map((source) {
                final isActive = source.key == configService.activeSource?.key;
                return ListTile(
                  leading: Icon(
                    isActive ? Icons.check_circle : Icons.radio_button_off,
                    color: isActive ? Theme.of(context).primaryColor : Colors.grey,
                  ),
                  title: Text(source.name ?? '未命名'),
                  subtitle: Text(source.api ?? source.spider ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                  selected: isActive,
                  onTap: () {
                    configService.setActiveSource(source);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  void _quickSwitchSource() {
    final configService = context.read<ConfigService>();
    final sources = configService.sources;
    if (sources.length <= 1) return;

    final currentIndex = sources.indexWhere((s) => s.key == configService.activeSource?.key);
    final nextIndex = (currentIndex + 1) % sources.length;
    configService.setActiveSource(sources[nextIndex]);
  }

  @override
  Widget build(BuildContext context) {
    final configService = context.watch<ConfigService>();
    final activeSource = configService.activeSource;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _quickSwitchSource,
              child: const Text('牛盒', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _showSourceSwitcher,
              onLongPress: _loadData,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.5), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.swap_horiz, size: 14, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      activeSource?.name ?? '选择站点',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_outline),
            onPressed: () {
              Navigator.pushNamed(context, '/favorites');
            },
            tooltip: '收藏',
          ),
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
      const Text('请在设置中添加猫源接口', style: TextStyle(color: Colors.white54)),
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
