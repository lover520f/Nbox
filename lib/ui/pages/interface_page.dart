import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/config_service.dart';
import '../../core/services/spider_service.dart';
import '../../core/models/video_source.dart';

class InterfacePage extends StatelessWidget {
  const InterfacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('接口管理')),
      body: Consumer<ConfigService>(
        builder: (context, configService, child) {
          final interfaces = configService.interfaces;
          if (interfaces.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, size: 64, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  const Text('暂无接口', style: TextStyle(color: Colors.white54, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('点击右下角按钮添加接口', style: TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: interfaces.length,
            itemBuilder: (context, index) {
              final iface = interfaces[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    iface.type == 'local' ? Icons.folder_open : (iface.type == 'js' ? Icons.code : Icons.link),
                    color: iface.type == 'local' ? Colors.orange : (iface.type == 'js' ? Colors.green : Colors.blue),
                  ),
                  title: Text(iface.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(
                    iface.url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (configService.isLoading)
                        const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      else
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 20, color: Colors.white54),
                          onPressed: () => _reloadInterface(context, iface),
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                        onPressed: () => _confirmDelete(context, configService, index, iface.name),
                      ),
                    ],
                  ),
                  onTap: () => _reloadInterface(context, iface),
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

  void _reloadInterface(BuildContext context, ConfigInterface iface) async {
    final configService = context.read<ConfigService>();
    if (iface.type == 'js') {
      final source = configService.sources.where((s) => s.spider == iface.url).firstOrNull;
      if (source != null) {
        configService.setActiveSource(source);
        final spiderService = context.read<SpiderService>();
        await spiderService.loadSource(source);
      }
    } else if (iface.type == 'url') {
      await configService.loadConfig(iface.url);
    } else {
      await configService.loadConfigFromFile(iface.url);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已加载: ${iface.name}')));
    }
  }

  void _confirmDelete(BuildContext context, ConfigService configService, int index, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除接口 "$name" 吗?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              configService.removeInterface(index);
              Navigator.pop(ctx);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('添加接口', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.link, color: Colors.blue),
              title: const Text('在线接口'),
              subtitle: const Text('输入配置地址，支持TVBox配置和猫源地址'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () { Navigator.pop(ctx); _showOnlineDialog(context); },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.folder_open, color: Colors.orange),
              title: const Text('本地接口'),
              subtitle: const Text('从本地文件选择配置'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () { Navigator.pop(ctx); _showLocalDialog(context); },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showOnlineDialog(BuildContext context) {
    final urlController = TextEditingController();
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('在线接口'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: '请输入接口名称',
                labelText: '接口名称 *',
                prefixIcon: Icon(Icons.label),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                hintText: '配置地址或猫源地址',
                labelText: '接口地址 *',
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '支持TVBox配置JSON、猫源.js.md5等地址',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final url = urlController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入接口名称')));
                return;
              }
              if (url.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入接口地址')));
                return;
              }
              Navigator.pop(ctx);
              final configService = context.read<ConfigService>();
              final isJsSource = url.endsWith('.js') || url.endsWith('.js.md5');
              if (isJsSource) {
                await configService.addJsInterface(name: name, url: url);
              } else {
                final iface = ConfigInterface(name: name, url: url, type: 'url');
                await configService.addInterface(iface);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已添加: $name')));
              }
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void _showLocalDialog(BuildContext context) {
    final pathController = TextEditingController();
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('本地接口'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: '请输入接口名称',
                labelText: '接口名称 *',
                prefixIcon: Icon(Icons.label),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pathController,
              decoration: const InputDecoration(
                hintText: '/sdcard/config.json',
                labelText: '本地文件路径 *',
                prefixIcon: Icon(Icons.folder_open),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final path = pathController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入接口名称')));
                return;
              }
              if (path.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入文件路径')));
                return;
              }
              Navigator.pop(ctx);
              final iface = ConfigInterface(name: name, url: path, type: 'local');
              final configService = context.read<ConfigService>();
              await configService.addInterface(iface);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已添加: $name')));
              }
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }
}
