import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/config_service.dart';

class LiveConfigPage extends StatelessWidget {
  const LiveConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('直播接口')),
      body: Consumer<ConfigService>(
        builder: (context, configService, child) {
          final groups = configService.liveGroups;
          if (groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.live_tv, size: 64, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  const Text('暂无直播源', style: TextStyle(color: Colors.white54, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('点击右下角按钮添加直播源', style: TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.live_tv, color: Colors.blueAccent),
                  title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(
                    group.url ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                    onPressed: () => _confirmDelete(context, configService, index, group.name),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ConfigService configService, int index, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除直播源 "$name" 吗?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              configService.removeLiveGroup(index);
              Navigator.pop(ctx);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('添加直播源'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: '请输入直播源名称',
                labelText: '名称 *',
                prefixIcon: Icon(Icons.label),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                hintText: 'https://example.com/iptv.m3u',
                labelText: '直播源地址 *',
                prefixIcon: Icon(Icons.live_tv),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '支持M3U/TXT/JSON格式直播源',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final url = urlController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入直播源名称')));
                return;
              }
              if (url.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入直播源地址')));
                return;
              }
              Navigator.pop(ctx);
              context.read<ConfigService>().updateLiveUrl(url, name: name);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已添加: $name')));
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }
}
