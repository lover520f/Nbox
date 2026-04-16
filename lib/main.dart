import 'package:flutter/material.dart';
import 'package:nbox/pages/home_page.dart';
import 'package:nbox/pages/novel_page.dart';
import 'package:nbox/pages/comic_page.dart';
import 'package:nbox/pages/music_page.dart';
import 'package:nbox/pages/live_page.dart';
import 'package:nbox/pages/settings_page.dart';
import 'package:nbox/components/category_tab.dart';

void main() {
  runApp(const NboxApp());
}

class NboxApp extends StatelessWidget {
  const NboxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nbox',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.grey),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const NovelPage(),
    const ComicPage(),
    const MusicPage(),
    const LivePage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
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
            icon: Icon(Icons.live_tv),
            label: '直播',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }
}
