import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  static const List<_NavItem> _navItems = [
    _NavItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: '首页'),
    _NavItem(icon: Icons.live_tv_outlined, selectedIcon: Icons.live_tv, label: '直播'),
    _NavItem(icon: Icons.favorite_outline, selectedIcon: Icons.favorite, label: '收藏'),
    _NavItem(icon: Icons.settings_outlined, selectedIcon: Icons.settings, label: '设置'),
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final configService = context.read<ConfigService>();
    final savedUrl = StorageService.getString('config_url');
    bool loaded = false;
    if (savedUrl != null && savedUrl.isNotEmpty) {
      try {
        await configService.loadConfig(savedUrl);
        loaded = configService.activeSource != null;
      } catch (e) {
        debugPrint('MainPage: loadConfig from URL failed: $e');
      }
    }
    if (!loaded) {
      try {
        await configService.loadConfigFromFile('assets/config/default.json');
      } catch (e) {
        debugPrint('MainPage: loadConfigFromFile failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    final size = MediaQuery.of(context).size;
    final isTv = Platform.isAndroid &&
        size.shortestSide >= 600 &&
        size.width > size.height;

    if (isTv) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

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
        destinations: _navItems.map((item) => NavigationDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.selectedIcon),
          label: item.label,
        )).toList(),
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
        children: _navItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
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
                  Icon(isSelected ? item.selectedIcon : item.icon, size: 20),
                  const SizedBox(width: 4),
                  Text(item.label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
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
            destinations: _navItems.map((item) => NavigationRailDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon),
              label: Text(item.label),
            )).toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _pages[_currentIndex]),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _NavItem({required this.icon, required this.selectedIcon, required this.label});
}
