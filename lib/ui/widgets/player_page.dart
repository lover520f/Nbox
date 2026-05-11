import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:chewie/chewie.dart';
import '../../core/services/player_service.dart';
import '../../core/services/spider_service.dart';

class PlayerPage extends StatefulWidget {
  final String title;
  final String sourceName;
  final String url;

  const PlayerPage({
    super.key,
    required this.title,
    required this.sourceName,
    required this.url,
  });

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  bool _isLoading = true;
  String? _error;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initPlayer();
    _enterFullScreen();
  }

  @override
  void dispose() {
    _exitFullScreen();
    super.dispose();
  }

  void _enterFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _exitFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  Future<void> _initPlayer() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final spiderService = context.read<SpiderService>();
      final playerService = context.read<PlayerService>();

      final result = await spiderService.playerContent(
        flag: widget.sourceName,
        id: widget.url,
      );

      String playUrl = widget.url;
      int parse = result['parse'] as int? ?? 0;
      
      if (result['url'] != null && result['url'].toString().isNotEmpty) {
        playUrl = result['url'].toString();
      }

      Map<String, String>? headers;
      if (result['header'] != null) {
        try {
          final headerStr = result['header'].toString();
          if (headerStr.startsWith('{')) {
            final headerMap = Map<String, dynamic>.from(
              result['header'] as Map
            );
            headers = headerMap.map((k, v) => MapEntry(k, v.toString()));
          }
        } catch (e) {
          debugPrint('Header parse error: $e');
        }
      }

      await playerService.initialize(
        url: playUrl,
        title: widget.title,
        headers: headers,
        autoPlay: true,
        showControls: true,
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          setState(() {
            _showControls = !_showControls;
          });
        },
        child: Stack(
          children: [
            _buildPlayer(),
            if (_showControls) _buildTopBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              '正在解析播放地址...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              '播放失败',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initPlayer,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    return Consumer<PlayerService>(
      builder: (context, playerService, child) {
        if (playerService.chewieController != null) {
          return Center(
            child: AspectRatio(
              aspectRatio: playerService.aspectRatio,
              child: Chewie(controller: playerService.chewieController!),
            ),
          );
        }
        return const Center(
          child: Text(
            '播放器未初始化',
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.sourceName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildPlaybackSpeed(),
              const SizedBox(width: 8),
              _buildQualityMenu(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaybackSpeed() {
    return Consumer<PlayerService>(
      builder: (context, playerService, child) {
        return PopupMenuButton<double>(
          icon: const Icon(Icons.speed, color: Colors.white),
          tooltip: '播放速度',
          onSelected: (speed) {
            playerService.setPlaybackSpeed(speed);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 0.5, child: Text('0.5x')),
            const PopupMenuItem(value: 0.75, child: Text('0.75x')),
            const PopupMenuItem(value: 1.0, child: Text('1.0x')),
            const PopupMenuItem(value: 1.25, child: Text('1.25x')),
            const PopupMenuItem(value: 1.5, child: Text('1.5x')),
            const PopupMenuItem(value: 2.0, child: Text('2.0x')),
          ],
        );
      },
    );
  }

  Widget _buildQualityMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.settings, color: Colors.white),
      tooltip: '画质设置',
      onSelected: (quality) {
        // Quality switching would be implemented here
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'auto', child: Text('自动')),
        const PopupMenuItem(value: '1080p', child: Text('1080P')),
        const PopupMenuItem(value: '720p', child: Text('720P')),
        const PopupMenuItem(value: '480p', child: Text('480P')),
        const PopupMenuItem(value: '360p', child: Text('360P')),
      ],
    );
  }
}
