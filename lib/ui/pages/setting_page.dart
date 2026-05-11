import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/config_service.dart';
import '../../core/services/proxy_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/models/video_source.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(context, title: '接口管理', children: [_buildInterfaceList(context)]),
          const SizedBox(height: 16),
          _buildSection(context, title: '直播接口', children: [_buildLiveConfig(context)]),
          const SizedBox(height: 16),
          _buildSection(context, title: '代理设置', children: [_buildProxySettings(context)]),
          const SizedBox(height: 16),
          _buildSection(context, title: '播放器设置', children: [_buildPlayerSettings(context)]),
          const SizedBox(height: 16),
          _buildSection(context, title: '缓存管理', children: [_buildCacheSettings(context)]),
          const SizedBox(height: 16),
          _buildSection(context, title: '关于', children: [_buildAbout(context)]),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required List<Widget> children}) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInterfaceList(BuildContext context) {
    return Consumer<ConfigService>(
      builder: (context, configService, child) {
        final interfaces = configService.interfaces;
        return Column(
          children: [
            if (interfaces.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('暂无接口', style: TextStyle(color: Colors.white54)),
                    SizedBox(height: 4),
                    Text('点击下方按钮添加接口配置', style: TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
              )
            else
              ...interfaces.asMap().entries.map((entry) {
                final index = entry.key;
                final iface = entry.value;
                return ListTile(
                  leading: Icon(
                    iface.type == 'local' ? Icons.folder_open : Icons.link,
                    size: 22,
                    color: iface.type == 'local' ? Colors.orange : Colors.blue,
                  ),
                  title: Text(iface.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                    onPressed: () => configService.removeInterface(index),
                  ),
                  onTap: () => _showReloadDialog(context, iface),
                );
              }),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.add_circle_outline, color: Colors.green),
              title: const Text('添加接口'),
              onTap: () => _showAddInterfaceDialog(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLiveConfig(BuildContext context) {
    return Consumer<ConfigService>(
      builder: (context, configService, child) {
        return Column(
          children: [
            if (configService.liveGroups.isNotEmpty)
              ...configService.liveGroups.map((group) => ListTile(
                leading: const Icon(Icons.live_tv, size: 20),
                title: Text(group.name),
                subtitle: Text(group.url ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.check_circle, size: 16, color: Colors.green),
              ))
            else
              const ListTile(
                leading: Icon(Icons.live_tv),
                title: Text('未设置直播接口'),
                subtitle: Text('请在下方添加直播源地址', style: TextStyle(fontSize: 12, color: Colors.white54)),
              ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.add_link),
              title: const Text('设置直播地址'),
              subtitle: const Text('M3U/TXT直播源地址'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLiveUrlDialog(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProxySettings(BuildContext context) {
    return Consumer<ProxyService>(
      builder: (context, proxyService, child) {
        return Column(
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.vpn_key),
              title: const Text('启用代理'),
              subtitle: Text(proxyService.isRunning ? '运行中' : '未启动'),
              value: proxyService.isRunning,
              onChanged: (value) {
                if (value) { proxyService.start(); } else { proxyService.stop(); }
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('代理端口'),
              subtitle: Text('${proxyService.port}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showProxyPortDialog(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlayerSettings(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.fullscreen),
          title: const Text('自动全屏播放'),
          value: StorageService.getPreference<bool>('auto_fullscreen') ?? false,
          onChanged: (value) async { await StorageService.savePreference('auto_fullscreen', value); },
        ),
        SwitchListTile(
          secondary: const Icon(Icons.speed),
          title: const Text('记住播放速度'),
          value: StorageService.getPreference<bool>('remember_speed') ?? true,
          onChanged: (value) async { await StorageService.savePreference('remember_speed', value); },
        ),
      ],
    );
  }

  Widget _buildCacheSettings(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.cached),
          title: const Text('清除缓存'),
          onTap: () async {
            await StorageService.clearCache();
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('缓存已清除')));
          },
        ),
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('清除历史记录'),
          onTap: () async {
            await StorageService.clearHistory();
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('历史记录已清除')));
          },
        ),
      ],
    );
  }

  Widget _buildAbout(BuildContext context) {
    return const Column(
      children: [
        ListTile(leading: Icon(Icons.info_outline), title: Text('版本'), subtitle: Text('3.0.0')),
        ListTile(leading: Icon(Icons.code), title: Text('牛盒'), subtitle: Text('基于 CatVod 架构的全平台影视播放器')),
      ],
    );
  }

  void _showAddInterfaceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('添加接口', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.link, color: Colors.blue),
              title: const Text('配置网址'),
              subtitle: const Text('输入TVBox标准配置JSON地址'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () { Navigator.pop(context); _showConfigUrlDialog(context); },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.folder_open, color: Colors.orange),
              title: const Text('本地包'),
              subtitle: const Text('从本地文件选择配置'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () { Navigator.pop(context); _showLocalFileDialog(context); },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.code, color: Colors.green),
              title: const Text('单个猫源'),
              subtitle: const Text('添加.js.md5猫源地址'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () { Navigator.pop(context); _showAddSingleSourceDialog(context); },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showConfigUrlDialog(BuildContext context) {
    final urlController = TextEditingController();
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('配置网址'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: '接口名称', labelText: '名称', prefixIcon: Icon(Icons.label)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(hintText: 'https://example.com/config.json', labelText: '配置网址', prefixIcon: Icon(Icons.link)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () async {
              if (urlController.text.isNotEmpty) {
                final name = nameController.text.isEmpty ? '接口${DateTime.now().millisecondsSinceEpoch % 10000}' : nameController.text;
                final iface = ConfigInterface(name: name, url: urlController.text, type: 'url');
                final configService = context.read<ConfigService>();
                await configService.addInterface(iface);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已添加接口: $name')));
                }
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showLocalFileDialog(BuildContext context) {
    final pathController = TextEditingController();
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('本地包'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: '接口名称', labelText: '名称', prefixIcon: Icon(Icons.label)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pathController,
              decoration: const InputDecoration(hintText: '/sdcard/config.json', labelText: '本地文件路径', prefixIcon: Icon(Icons.folder_open)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () async {
              if (pathController.text.isNotEmpty) {
                final name = nameController.text.isEmpty ? '本地接口' : nameController.text;
                final iface = ConfigInterface(name: name, url: pathController.text, type: 'local');
                final configService = context.read<ConfigService>();
                await configService.addInterface(iface);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已添加接口: $name')));
                }
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showAddSingleSourceDialog(BuildContext context) {
    final nameController = TextEditingController();
    final apiController = TextEditingController();
    final extController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加猫源'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(hintText: '接口名称', labelText: '名称', prefixIcon: Icon(Icons.label))),
              const SizedBox(height: 12),
              TextField(controller: apiController, decoration: const InputDecoration(hintText: 'https://example.com/spider.js.md5', labelText: '猫源地址', prefixIcon: Icon(Icons.code))),
              const SizedBox(height: 12),
              TextField(controller: extController, decoration: const InputDecoration(hintText: '扩展参数(可选)', labelText: 'ext', prefixIcon: Icon(Icons.extension))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              if (apiController.text.isNotEmpty) {
                final name = nameController.text.isEmpty ? '自定义猫源' : nameController.text;
                final source = VideoSource(
                  key: 'csp_${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  api: apiController.text,
                  type: 3,
                  spider: apiController.text,
                  ext: extController.text.isEmpty ? null : extController.text,
                );
                final configService = context.read<ConfigService>();
                configService.addSource(source);
                configService.setActiveSource(source);
                Navigator.pop(context);
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showReloadDialog(BuildContext ctx, ConfigInterface iface) {
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: Text(iface.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('地址: ${iface.url}', style: const TextStyle(fontSize: 12, color: Colors.white54)),
            const SizedBox(height: 12),
            const Text('是否重新加载此接口?'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('取消')),
          ElevatedButton(
            onPressed: () async {
              final configService = ctx.read<ConfigService>();
              if (iface.type == 'url') {
                await configService.loadConfig(iface.url);
              } else {
                await configService.loadConfigFromFile(iface.url);
              }
              if (ctx.mounted) {
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('已重新加载: ${iface.name}')));
              }
            },
            child: const Text('重新加载'),
          ),
        ],
      ),
    );
  }

  void _showLiveUrlDialog(BuildContext context) {
    final controller = TextEditingController(text: StorageService.getString('live_url') ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('直播接口'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: controller, decoration: const InputDecoration(hintText: 'https://example.com/iptv.m3u', labelText: '直播源地址', prefixIcon: Icon(Icons.live_tv))),
            const SizedBox(height: 8),
            const Text('支持M3U/TXT格式直播源', style: TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () async {
              await StorageService.saveString('live_url', controller.text);
              if (context.mounted) {
                context.read<ConfigService>().updateLiveUrl(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showProxyPortDialog(BuildContext context) {
    final controller = TextEditingController(text: context.read<ProxyService>().port.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置代理端口'),
        content: TextField(controller: controller, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '端口', hintText: '7890')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              final port = int.tryParse(controller.text);
              if (port != null && port > 0 && port < 65536) {
                context.read<ProxyService>().stop();
                context.read<ProxyService>().start(port: port);
                Navigator.pop(context);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
