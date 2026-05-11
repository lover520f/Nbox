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
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: '数据源',
            children: [
              _buildSourceConfig(context),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '代理设置',
            children: [
              _buildProxySettings(context),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '播放器设置',
            children: [
              _buildPlayerSettings(context),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '缓存管理',
            children: [
              _buildCacheSettings(context),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '关于',
            children: [
              _buildAbout(context),
            ],
          ),
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
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSourceConfig(BuildContext context) {
    return Consumer<ConfigService>(
      builder: (context, configService, child) {
        return Column(
          children: [
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('配置地址'),
              subtitle: Text(StorageService.getString('config_url') ?? '未设置'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showConfigUrlDialog(context),
            ),
            ListTile(
              leading: const Icon(Icons.add_link),
              title: const Text('添加单源'),
              subtitle: const Text('添加JSON API源或JS猫源'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showAddSourceDialog(context),
            ),
            ListTile(
              leading: const Icon(Icons.source),
              title: const Text('数据源列表'),
              subtitle: Text('${configService.sources.length} 个源'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showSourceListDialog(context),
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
              subtitle: Text(proxyService.isRunning
                  ? '运行中: ${proxyService.currentProxyUrl}'
                  : '未启动'),
              value: proxyService.isRunning,
              onChanged: (value) {
                if (value) {
                  proxyService.start();
                } else {
                  proxyService.stop();
                }
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
          subtitle: const Text('进入播放页时自动全屏'),
          value: StorageService.getPreference<bool>('auto_fullscreen') ?? false,
          onChanged: (value) async {
            await StorageService.savePreference('auto_fullscreen', value);
          },
        ),
        SwitchListTile(
          secondary: const Icon(Icons.speed),
          title: const Text('记住播放速度'),
          subtitle: const Text('下次播放使用相同速度'),
          value: StorageService.getPreference<bool>('remember_speed') ?? true,
          onChanged: (value) async {
            await StorageService.savePreference('remember_speed', value);
          },
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
          subtitle: const Text('清除图片和视频缓存'),
          onTap: () => _clearCache(context),
        ),
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('清除历史记录'),
          subtitle: const Text('清除观看历史'),
          onTap: () => _clearHistory(context),
        ),
      ],
    );
  }

  Widget _buildAbout(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('版本'),
          subtitle: const Text('2.2.0'),
        ),
        ListTile(
          leading: const Icon(Icons.code),
          title: const Text('牛盒'),
          subtitle: const Text('基于 CatVod 架构的全平台影视播放器'),
        ),
      ],
    );
  }

  void _showConfigUrlDialog(BuildContext context) {
    final controller = TextEditingController(text: StorageService.getString('config_url') ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('输入配置地址'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'https://example.com/config.json',
                labelText: '配置URL',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '支持TVBox标准JSON配置格式，自动解析源列表',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await StorageService.saveString('config_url', controller.text);
                final configService = context.read<ConfigService>();
                await configService.loadConfig(controller.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('已加载 ${configService.sources.length} 个源')),
                  );
                }
              }
            },
            child: const Text('加载'),
          ),
        ],
      ),
    );
  }

  void _showAddSourceDialog(BuildContext context) {
    final nameController = TextEditingController();
    final apiController = TextEditingController();
    int selectedType = 1;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('添加数据源'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: '数据源名称',
                      labelText: '名称',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: '源类型',
                    ),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('XML源 (type 0)')),
                      DropdownMenuItem(value: 1, child: Text('JSON源 (type 1)')),
                      DropdownMenuItem(value: 3, child: Text('JS猫源 (type 3)')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedType = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: apiController,
                    decoration: InputDecoration(
                      hintText: selectedType == 3
                          ? 'https://example.com/spider.js.md5'
                          : 'https://example.com/api.php/provide/vod/',
                      labelText: selectedType == 3 ? 'JS源地址' : 'API地址',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedType == 3
                        ? 'JS猫源地址支持 .js 和 .js.md5 格式，将自动下载并执行JS代码'
                        : 'JSON/XML源地址为CatVod标准API接口地址',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (apiController.text.isNotEmpty) {
                      final source = VideoSource(
                        key: apiController.text,
                        name: nameController.text.isEmpty ? '自定义源' : nameController.text,
                        api: apiController.text,
                        type: selectedType,
                        spider: selectedType == 3 ? apiController.text : null,
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
            );
          },
        );
      },
    );
  }

  void _showSourceListDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer<ConfigService>(
        builder: (context, configService, child) {
          return AlertDialog(
            title: const Text('选择数据源'),
            content: SizedBox(
              width: 300,
              height: 400,
              child: configService.sources.isEmpty
                ? const Center(child: Text('暂无数据源'))
                : ListView.builder(
                    itemCount: configService.sources.length,
                    itemBuilder: (context, index) {
                      final source = configService.sources[index];
                      final isActive = source.key == configService.activeSource?.key;
                      final typeLabel = source.type == 3 ? 'JS' : (source.type == 0 ? 'XML' : 'JSON');
                      return ListTile(
                        leading: Icon(
                          isActive ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: isActive ? Theme.of(context).primaryColor : null,
                        ),
                        title: Text(source.name ?? '未知'),
                        subtitle: Text('[$typeLabel] ${source.api ?? source.spider ?? ''}', maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () {
                            configService.removeSource(source);
                          },
                        ),
                        onTap: () {
                          configService.setActiveSource(source);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
            ),
          );
        },
      ),
    );
  }

  void _showProxyPortDialog(BuildContext context) {
    final controller = TextEditingController(
      text: context.read<ProxyService>().port.toString(),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置代理端口'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '端口',
            hintText: '7890',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
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

  void _clearCache(BuildContext context) async {
    await StorageService.clearCache();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('缓存已清除')),
      );
    }
  }

  void _clearHistory(BuildContext context) async {
    await StorageService.clearHistory();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('历史记录已清除')),
      );
    }
  }
}
