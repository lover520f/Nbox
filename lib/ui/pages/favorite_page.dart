import 'package:flutter/material.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('收藏')),
      body: const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.favorite_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('暂无收藏'),
          SizedBox(height: 8),
          Text('浏览影视时点击收藏即可添加', style: TextStyle(color: Colors.white54)),
        ]),
      ),
    );
  }
}
