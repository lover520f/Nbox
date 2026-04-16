import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/source.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text('设置', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        children: [
          _buildSectionTitle('影视源管理'),
          _buildSourceList(context, 'vod'),
          _buildAddSourceButton(context, 'vod'),
          const Divider(color: Colors.grey),
          _buildSectionTitle('直播源管理'),
          _buildSourceList(context, 'live'),
          _buildAddSourceButton(context, 'live'),
          const Divider(color: Colors.grey),
          _buildSectionTitle('关于'),
          _buildAboutItem(context),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSourceList(BuildContext context, String type) {
    final provider = Provider.of<AppProvider>(context);
    List<Source> sources = type == 'vod' ? provider.vodSources : provider.liveSources;

    if (sources.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text('暂无${type == "vod" ? "影视" : "直播"}源', style: const TextStyle(color: Colors.white54)),
      );
    }

    return Column(
      children: sources.map((source) => _buildSourceItem(context, source, type)).toList(),
    );
  }

  Widget _buildSourceItem(BuildContext context, Source source, String type) {
    return ListTile(
      leading: const Icon(Icons.source, color: Colors.blue),
      title: Text(source.name, style: const TextStyle(color: Colors.white)),
      subtitle: Text(source.url, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () {
          Provider.of<AppProvider>(context, listen: false).removeSource(source.id, type);
        },
      ),
    );
  }

  Widget _buildAddSourceButton(BuildContext context, String type) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _showAddSourceDialog(context, type),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text('添加${type == "vod" ? "影视" : "直播"}源'),
        ),
      ),
    );
  }

  void _showAddSourceDialog(BuildContext context, String type) {
    TextEditingController nameController = TextEditingController();
    TextEditingController urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2D2D2D),
          title: Text('添加${type == "vod" ? "影视" : "直播"}源', style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '源名称',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: '源地址',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && urlController.text.isNotEmpty) {
                  Source source = Source(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    url: urlController.text,
                    type: type,
                  );
                  Provider.of<AppProvider>(context, listen: false).addSource(source);
                  Navigator.pop(context);
                }
              },
              child: const Text('确认', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAboutItem(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.info, color: Colors.blue),
      title: const Text('关于蜂蜜', style: TextStyle(color: Colors.white)),
      subtitle: const Text('版本 1.0.0', style: TextStyle(color: Colors.white54)),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2D2D2D),
              title: const Text('蜂蜜', style: TextStyle(color: Colors.white)),
              content: const Text(
                '一款基于Flutter开发的全平台影音软件，支持影视、直播、小说、漫画、音乐等多种内容。',
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('确定', style: TextStyle(color: Colors.blue)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
