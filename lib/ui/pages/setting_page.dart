import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/config_service.dart';
import '../../core/services/proxy_service.dart';
import '../../core/services/storage_service.dart';
import 'interface_page.dart';
import 'live_config_page.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(context, title: '接口管理', children: [_buildInterfaceEntry(context)]),
          const SizedBox(height: 16),
          _buildSection(context, title: '直播接口', children: [_buildLiveEntry(context)]),
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

  Widget _buildInterfaceEntry(BuildContext context) {
    return Consumer<ConfigService>(
      builder: (context, configService, child) {
        final count = configService.interfaces.length;
        return ListTile(
          leading: const Icon(Icons.source, color: Colors.blue),
          title: const Text('接口列表'),
          subtitle: Text(count > 0 ? '已添加 $count 个接口' : '暂无接口'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InterfacePage())),
        );
      },
    );
  }

  Widget _buildLiveEntry(BuildContext context) {
    return Consumer<ConfigService>(
      builder: (context, configService, child) {
        final count = configService.liveGroups.length;
        return ListTile(
          leading: const Icon(Icons.live_tv, color: Colors.blueAccent),
          title: const Text('直播源列表'),
          subtitle: Text(count > 0 ? '已添加 $count 个直播源' : '暂无直播源'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveConfigPage())),
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
        ListTile(leading: Icon(Icons.info_outline), title: Text('版本'), subtitle: Text('3.2.0')),
        ListTile(leading: Icon(Icons.code), title: Text('牛盒'), subtitle: Text('基于 CatVod 架构的全平台影视播放器')),
      ],
    );
  }

  void _showProxyPortDialog(BuildContext context) {
    final controller = TextEditingController(text: context.read<ProxyService>().port.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('设置代理端口'),
        content: TextField(controller: controller, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '端口', hintText: '7890')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              final port = int.tryParse(controller.text);
              if (port != null && port > 0 && port < 65536) {
                context.read<ProxyService>().stop();
                context.read<ProxyService>().start(port: port);
                Navigator.pop(ctx);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
