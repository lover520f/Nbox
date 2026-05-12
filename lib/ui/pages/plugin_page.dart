import 'package:flutter/material.dart';

class PluginPage extends StatelessWidget {
  const PluginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('插件')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.extension, size: 80, color: Colors.grey[600]),
            const SizedBox(height: 24),
            Text('插件中心', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white54)),
            const SizedBox(height: 12),
            const Text('即将上线，敬请期待', style: TextStyle(color: Colors.white38, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
