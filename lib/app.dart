import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/config_service.dart';
import 'core/services/storage_service.dart';
import 'ui/pages/home_page.dart';
import 'ui/pages/live_page.dart';
import 'ui/pages/favorite_page.dart';
import 'ui/pages/setting_page.dart';
import 'ui/theme/app_theme.dart';
import 'ui/widgets/source_selector.dart';

class NboxApp extends StatelessWidget {
  const NboxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '牛盒',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    LivePage(),
    FavoritePage(),
    SettingPage(),
  ];

  static const List<NavigationDestination> _navDestinations = [
    NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: '首页'),
    NavigationDestination(icon: Icon(Icons.live_tv_outlined), selectedIcon: Icon(Icons.live_tv), label: '直播'),
    NavigationDestination(icon: Icon(Icons.favorite_outline), selectedIcon: Icon(Icons.favorite), label: '收藏'),
    NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: '设置'),
  ];

  static const List<NavigationRailDestination> _railDestinations = [
    NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: Text('首页')),
    NavigationRailDestination(icon: Icon(Icons.live_tv_outlined), selectedIcon: Icon(Icons.live_tv), label: Text('直播')),
    NavigationRailDestination(icon: Icon(Icons.favorite_outline), selectedIcon: Icon(Icons.favorite), label: Text('收藏')),
    NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('设置')),
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final configService = context.read<ConfigService>();
    final savedUrl = StorageService.getString('config_url');
    if (savedUrl != null && savedUrl.isNotEmpty) {
      await configService.loadConfig(savedUrl);
    } else {
      await configService.loadConfigFromFile('assets/config/default.json');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    final isTv = Platform.isAndroid &&
        MediaQuery.of(context).size.shortestSide >= 600 &&
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (isDesktop) {
      return _buildDesktopLayout();
    } else if (isTv) {
      return _buildTvLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: _navDestinations,
      ),
    );
  }

  Widget _buildTvLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('牛盒'),
        actions: const [SourceSelector()],
      ),
      body: Column(
        children: [
          _buildTvTabBar(),
          Expanded(child: _pages[_currentIndex]),
        ],
      ),
    );
  }

  Widget _buildTvTabBar() {
    return Container(
      height: 48,
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: _navDestinations.map((dest) {
          final index = _navDestinations.indexOf(dest);
          final isSelected = index == _currentIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TextButton(
              onPressed: () => setState(() => _currentIndex = index),
              style: TextButton.styleFrom(
                foregroundColor: isSelected ? Theme.of(context).primaryColor : Colors.white54,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(isSelected ? dest.selectedIcon : dest.icon, size: 20),
                  const SizedBox(width: 4),
                  Text(dest.label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) => setState(() => _currentIndex = index),
            labelType: NavigationRailLabelType.all,
            destinations: _railDestinations,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _pages[_currentIndex]),
        ],
      ),
    );
  }
}
