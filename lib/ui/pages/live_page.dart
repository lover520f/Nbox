import 'dart:convert';
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
  int _selectedLiveIndex = 0;

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
      final idx = _selectedLiveIndex.clamp(0, configService.liveGroups.length - 1);
      final liveGroup = configService.liveGroups[idx];
      final liveUrl = liveGroup.url;
      if (liveUrl == null || liveUrl.isEmpty) {
        setState(() { _isLoading = false; _channels = {}; });
        return;
      }
      final dio = Dio();
      final response = await dio.get(liveUrl,
        options: Options(responseType: ResponseType.plain, receiveTimeout: const Duration(seconds: 30)));
      final content = response.data.toString();
      _channels = _parseLiveContent(content, liveGroup.type);
      _selectedGroup = _channels.keys.isNotEmpty ? _channels.keys.first : null;
      setState(() { _isLoading = false; });
    } catch (e) {
      setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  Map<String, List<LiveChannelItem>> _parseLiveContent(String content, int type) {
    final trimmed = content.trim();
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      return _parseJsonContent(trimmed);
    } else if (trimmed.contains('#EXTINF')) {
      return _parseM3uContent(trimmed);
    } else {
      return _parseTxtContent(trimmed);
    }
  }

  Map<String, List<LiveChannelItem>> _parseTxtContent(String content) {
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

  Map<String, List<LiveChannelItem>> _parseM3uContent(String content) {
    final result = <String, List<LiveChannelItem>>{};
    String currentGroup = '其他';
    String? pendingName;
    for (final line in content.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed.startsWith('#EXTINF')) {
        final groupMatch = RegExp(r'group-title="([^"]*)"').firstMatch(trimmed);
        if (groupMatch != null && groupMatch.group(1)!.isNotEmpty) {
          currentGroup = groupMatch.group(1)!;
          result.putIfAbsent(currentGroup, () => []);
        }
        final commaIdx = trimmed.lastIndexOf(',');
        if (commaIdx != -1) {
          pendingName = trimmed.substring(commaIdx + 1).trim();
        } else {
          pendingName = '未命名';
        }
      } else if (!trimmed.startsWith('#') && pendingName != null) {
        result.putIfAbsent(currentGroup, () => []);
        result[currentGroup]!.add(LiveChannelItem(name: pendingName, urls: [trimmed]));
        pendingName = null;
      }
    }
    return result;
  }

  Map<String, List<LiveChannelItem>> _parseJsonContent(String content) {
    final result = <String, List<LiveChannelItem>>{};
    try {
      final json = jsonDecode(content);
      if (json is List) {
        for (var item in json) {
          if (item is! Map<String, dynamic>) continue;
          final name = item['name']?.toString() ?? '未命名';
          final group = item['group']?.toString() ?? '其他';
          List<String> urls = [];
          if (item['urls'] is List) {
            urls = (item['urls'] as List).map((u) => u.toString()).toList();
          } else if (item['url'] is String) {
            urls = [item['url'] as String];
          }
          if (urls.isNotEmpty) {
            result.putIfAbsent(group, () => []);
            result[group]!.add(LiveChannelItem(name: name, urls: urls));
          }
        }
      } else if (json is Map<String, dynamic>) {
        for (var entry in json.entries) {
          final group = entry.key;
          if (entry.value is List) {
            result.putIfAbsent(group, () => []);
            for (var item in entry.value as List) {
              if (item is! Map<String, dynamic>) continue;
              final name = item['name']?.toString() ?? '未命名';
              List<String> urls = [];
              if (item['urls'] is List) {
                urls = (item['urls'] as List).map((u) => u.toString()).toList();
              } else if (item['url'] is String) {
                urls = [item['url'] as String];
              }
              if (urls.isNotEmpty) {
                result[group]!.add(LiveChannelItem(name: name, urls: urls));
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('LivePage: JSON parse error: $e');
    }
    return result;
  }

  void _showLiveSourceSwitcher() {
    final configService = context.read<ConfigService>();
    final groups = configService.liveGroups;
    if (groups.length <= 1) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4, margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('切换直播源', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          ...groups.asMap().entries.map((entry) {
            final index = entry.key;
            final group = entry.value;
            final isActive = index == _selectedLiveIndex;
            return ListTile(
              leading: Icon(
                isActive ? Icons.check_circle : Icons.radio_button_off,
                color: isActive ? Theme.of(context).primaryColor : Colors.grey,
              ),
              title: Text(group.name),
              subtitle: group.url != null ? Text(group.url!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)) : null,
              selected: isActive,
              onTap: () {
                setState(() { _selectedLiveIndex = index; });
                Navigator.pop(context);
                _loadChannels();
              },
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final configService = context.watch<ConfigService>();
    final liveGroups = configService.liveGroups;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('直播'),
            if (liveGroups.length > 1) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _showLiveSourceSwitcher,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.5), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.swap_horiz, size: 14, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        liveGroups[_selectedLiveIndex.clamp(0, liveGroups.length - 1)].name,
                        style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadChannels, tooltip: '刷新'),
        ],
      ),
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
                Text('请在设置中添加直播源地址', style: TextStyle(color: Colors.white54)),
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
