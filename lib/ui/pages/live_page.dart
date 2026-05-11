import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../core/services/config_service.dart';
import '../widgets/player_page.dart';

class LivePage extends StatefulWidget {
  const LivePage({super.key});

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  Map<String, List<LiveChannelItem>> _channels = {};
  bool _isLoading = true;
  String? _error;
  String? _selectedGroup;

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  Future<void> _loadChannels() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final configService = context.read<ConfigService>();
      if (configService.liveGroups.isEmpty) {
        setState(() { _isLoading = false; _channels = {}; });
        return;
      }
      final liveUrl = configService.liveGroups.first.url;
      if (liveUrl == null || liveUrl.isEmpty) {
        setState(() { _isLoading = false; _channels = {}; });
        return;
      }
      final dio = Dio();
      final response = await dio.get(liveUrl,
        options: Options(responseType: ResponseType.plain, receiveTimeout: const Duration(seconds: 30)));
      final content = response.data.toString();
      _channels = _parseLiveContent(content);
      _selectedGroup = _channels.keys.isNotEmpty ? _channels.keys.first : null;
      setState(() { _isLoading = false; });
    } catch (e) {
      setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  Map<String, List<LiveChannelItem>> _parseLiveContent(String content) {
    final result = <String, List<LiveChannelItem>>{};
    String currentGroup = '其他';
    for (final line in content.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed.startsWith('#')) continue;
      if (trimmed.contains(',')) {
        if (trimmed.endsWith(',#genre#')) {
          currentGroup = trimmed.replaceAll(',#genre#', '').trim();
          result.putIfAbsent(currentGroup, () => []);
          continue;
        }
        final parts = trimmed.split(',');
        if (parts.length >= 2) {
          final name = parts[0].trim();
          final urls = parts.sublist(1).map((u) => u.trim()).where((u) => u.isNotEmpty).toList();
          result.putIfAbsent(currentGroup, () => []);
          result[currentGroup]!.add(LiveChannelItem(name: name, urls: urls));
        }
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('直播')),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text('加载失败: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadChannels, child: const Text('重试')),
            ]))
          : _channels.isEmpty
            ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.live_tv, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('暂无直播源'),
                SizedBox(height: 8),
                Text('请在设置中添加配置地址', style: TextStyle(color: Colors.white54)),
              ]))
            : Row(children: [
                _buildGroupList(),
                const VerticalDivider(width: 1),
                Expanded(child: _buildChannelList()),
              ]),
    );
  }

  Widget _buildGroupList() {
    return SizedBox(
      width: 120,
      child: ListView.builder(
        itemCount: _channels.keys.length,
        itemBuilder: (context, index) {
          final group = _channels.keys.elementAt(index);
          final isSelected = group == _selectedGroup;
          return ListTile(
            title: Text(group, style: TextStyle(
              color: isSelected ? Theme.of(context).primaryColor : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            )),
            selected: isSelected,
            dense: true,
            onTap: () => setState(() => _selectedGroup = group),
          );
        },
      ),
    );
  }

  Widget _buildChannelList() {
    final channels = _selectedGroup != null ? _channels[_selectedGroup] ?? [] : [];
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: channels.length,
      itemBuilder: (context, index) {
        final channel = channels[index];
        return InkWell(
          onTap: () => _playChannel(channel),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.play_circle_outline, size: 20, color: Colors.white54),
                const SizedBox(width: 8),
                Flexible(child: Text(channel.name, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis)),
              ]),
            ),
          ),
        );
      },
    );
  }

  void _playChannel(LiveChannelItem channel) {
    if (channel.urls.isEmpty) return;
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => PlayerPage(
        title: channel.name,
        sourceName: '直播',
        url: channel.urls.first,
      ),
    ));
  }
}

class LiveChannelItem {
  final String name;
  final List<String> urls;
  LiveChannelItem({required this.name, required this.urls});
}
