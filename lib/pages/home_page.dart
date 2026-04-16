import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/video.dart';
import '../models/category.dart';
import '../utils/spider_engine.dart';
import 'detail_page.dart';
import 'live_page.dart';
import 'novel_page.dart';
import 'comic_page.dart';
import 'music_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Category> _categories = [];
  List<Video> _videos = [];
  int _currentCategoryIndex = 0;
  int _currentPage = 1;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<AppProvider>(context, listen: false);
    await provider.loadSources();

    if (provider.vodSources.isNotEmpty) {
      _categories = await SpiderEngine.getCategories(provider.vodSources.first.url);
      if (_categories.isNotEmpty) {
        await _loadVideos();
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadVideos({bool refresh = false}) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final provider = Provider.of<AppProvider>(context, listen: false);
    if (provider.vodSources.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    int page = refresh ? 1 : _currentPage;
    String categoryId = _categories.isNotEmpty ? _categories[_currentCategoryIndex].id : '';

    List<Video> videos = await SpiderEngine.getVideos(
      provider.vodSources.first.url,
      page: page,
      categoryId: categoryId,
    );

    setState(() {
      if (refresh) {
        _videos = videos;
        _currentPage = 1;
      } else {
        _videos.addAll(videos);
        _currentPage++;
      }
      _isLoading = false;
    });
  }

  Future<void> _loadMore() async {
    await _loadVideos();
  }

  void _onCategoryTap(int index) {
    setState(() {
      _currentCategoryIndex = index;
      _currentPage = 1;
    });
    _loadVideos(refresh: true);
  }

  void _onVideoTap(Video video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(video: video),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    bool isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: _buildAppBar(),
      body: _buildBody(),
      drawer: isDesktop ? _buildDesktopDrawer(provider) : null,
      bottomNavigationBar: isDesktop ? null : _buildBottomNavigationBar(provider),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1A1A1A),
      elevation: 0,
      title: const Text(
        '影视',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.cast, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () => _loadVideos(refresh: true),
        ),
        IconButton(
          icon: const Icon(Icons.favorite, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading && _videos.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Colors.blue));
    }

    return Column(
      children: [
        _buildCategoryTabs(),
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.65,
              crossAxisSpacing: 8,
              mainAxisSpacing: 12,
            ),
            itemCount: _videos.length + (_isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _videos.length) {
                return const Center(child: CircularProgressIndicator(color: Colors.blue));
              }
              return _buildVideoCard(_videos[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          for (int i = 0; i < _categories.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ElevatedButton(
                onPressed: () => _onCategoryTap(i),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentCategoryIndex == i 
                    ? Colors.blue 
                    : const Color(0xFF2D2D2D),
                  foregroundColor: _currentCategoryIndex == i 
                    ? Colors.white 
                    : Colors.white70,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(_categories[i].name),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(Video video) {
    return GestureDetector(
      onTap: () => _onVideoTap(video),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: video.cover.isNotEmpty
                  ? Image.network(
                      video.cover,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator(color: Colors.blue));
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image, color: Colors.grey);
                      },
                    )
                  : const Icon(Icons.image, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            video.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          if (video.type != null || video.year != null)
            Text(
              '${video.type ?? ''} ${video.year ?? ''}'.trim(),
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(AppProvider provider) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF2D2D2D),
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.white54,
      currentIndex: provider.currentIndex,
      onTap: (index) {
        provider.setCurrentIndex(index);
        _navigateToPage(index);
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '影视',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: '小说',
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: '漫画',
          ),
        BottomNavigationBarItem(
          icon: Icon(Icons.music_note),
          label: '音乐',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.play_circle),
          label: '直播',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: '设置',
        ),
      ],
    );
  }

  Widget _buildDesktopDrawer(AppProvider provider) {
    return Drawer(
      width: 100,
      backgroundColor: const Color(0xFF2D2D2D),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 40),
          _buildDrawerItem(Icons.home, '影视', 0, provider),
          _buildDrawerItem(Icons.book, '小说', 1, provider),
          _buildDrawerItem(Icons.menu_book, '漫画', 2, provider),
          _buildDrawerItem(Icons.music_note, '音乐', 3, provider),
          _buildDrawerItem(Icons.play_circle, '直播', 4, provider),
          _buildDrawerItem(Icons.settings, '设置', 5, provider),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String label, int index, AppProvider provider) {
    return GestureDetector(
      onTap: () {
        provider.setCurrentIndex(index);
        _navigateToPage(index);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        color: provider.currentIndex == index ? Colors.blue : Colors.transparent,
        child: Column(
          children: [
            Icon(
              icon,
              color: provider.currentIndex == index ? Colors.white : Colors.white54,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: provider.currentIndex == index ? Colors.white : Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPage(int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const NovelPage()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ComicPage()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const MusicPage()));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const LivePage()));
        break;
      case 5:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
        break;
    }
  }
}
