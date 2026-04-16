import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/live_channel.dart';
import '../utils/spider_engine.dart';

class LivePage extends StatefulWidget {
  const LivePage({super.key});

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  List<LiveChannel> _channels = [];
  List<String> _groups = [];
  String _selectedGroup = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  Future<void> _loadChannels() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<AppProvider>(context, listen: false);
    
    if (provider.liveSources.isNotEmpty) {
      _channels = await SpiderEngine.getLiveChannels(provider.liveSources.first.url);
    } else {
      _channels = await SpiderEngine.getLiveChannels('http://ok213.top/ok');
    }

    _groups = _channels
        .map((c) => c.group ?? '其他')
        .toSet()
        .toList();
    
    if (_groups.isNotEmpty) {
      _selectedGroup = _groups.first;
    }

    setState(() => _isLoading = false);
  }

  List<LiveChannel> _getChannelsByGroup(String group) {
    return _channels.where((c) => c.group == group || (group == '其他' && c.group == null)).toList();
  }

  void _playChannel(LiveChannel channel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LivePlayerPage(channel: channel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text('直播', style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : Row(
              children: [
                _buildGroupList(),
                Expanded(child: _buildChannelList()),
              ],
            ),
    );
  }

  Widget _buildGroupList() {
    return Container(
      width: 120,
      color: const Color(0xFF2D2D2D),
      child: ListView.builder(
        itemCount: _groups.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => setState(() => _selectedGroup = _groups[index]),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              color: _selectedGroup == _groups[index] ? Colors.blue : Colors.transparent,
              child: Text(
                _groups[index],
                style: TextStyle(
                  color: _selectedGroup == _groups[index] ? Colors.white : Colors.white70,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChannelList() {
    var channels = _getChannelsByGroup(_selectedGroup);
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: channels.length,
      itemBuilder: (context, index) {
        var channel = channels[index];
        return GestureDetector(
          onTap: () => _playChannel(channel),
          child: Card(
            color: const Color(0xFF2D2D2D),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_circle, color: Colors.blue, size: 40),
                const SizedBox(height: 8),
                Text(
                  channel.name,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class LivePlayerPage extends StatefulWidget {
  final LiveChannel channel;

  const LivePlayerPage({super.key, required this.channel});

  @override
  State<LivePlayerPage> createState() => _LivePlayerPageState();
}

class _LivePlayerPageState extends State<LivePlayerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.channel.name,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: const Center(
        child: Icon(Icons.play_circle, color: Colors.blue, size: 100),
      ),
    );
  }
}
