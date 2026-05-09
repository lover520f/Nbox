import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';

class PlayerService extends ChangeNotifier {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isBuffering = false;
  bool _isFullScreen = false;
  
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Duration _buffered = Duration.zero;
  
  String? _currentUrl;
  String? _currentTitle;
  String? _error;

  bool get isInitialized => _isInitialized;
  bool get isPlaying => _isPlaying;
  bool get isBuffering => _isBuffering;
  bool get isFullScreen => _isFullScreen;
  Duration get position => _position;
  Duration get duration => _duration;
  Duration get buffered => _buffered;
  String? get currentUrl => _currentUrl;
  String? get currentTitle => _currentTitle;
  String? get error => _error;
  
  VideoPlayerController? get videoController => _videoController;
  ChewieController? get chewieController => _chewieController;

  Future<void> initialize({
    required String url,
    String? title,
    Map<String, String>? headers,
    bool autoPlay = true,
    bool showControls = true,
  }) async {
    try {
      _error = null;
      _currentUrl = url;
      _currentTitle = title;
      notifyListeners();

      await dispose();

      if (url.startsWith('http')) {
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(url),
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: true,
            allowBackgroundPlayback: true,
          ),
        );
      } else {
        _videoController = VideoPlayerController.file(File(url));
      }

      if (headers != null && headers.isNotEmpty) {
        await _videoController!.setNetworkHeaders(headers);
      }

      await _videoController!.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: autoPlay,
        looping: false,
        showControls: showControls,
        aspectRatio: _videoController!.value.aspectRatio,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.red,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.lightBlue,
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.red),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
          );
        },
      );

      _videoController!.addListener(_onVideoUpdate);
      
      _isInitialized = true;
      _isPlaying = autoPlay;
      _duration = _videoController!.value.duration;
      notifyListeners();
    } catch (e) {
      _error = '播放初始化失败: $e';
      debugPrint(_error);
      notifyListeners();
    }
  }

  void _onVideoUpdate() {
    if (_videoController == null) return;
    
    final value = _videoController!.value;
    _position = value.position;
    _duration = value.duration;
    _isPlaying = value.isPlaying;
    _isBuffering = value.isBuffering;
    
    if (value.hasError) {
      _error = value.errorDescription;
    }
    
    notifyListeners();
  }

  Future<void> play() async {
    await _videoController?.play();
    _isPlaying = true;
    notifyListeners();
  }

  Future<void> pause() async {
    await _videoController?.pause();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seekTo(Duration position) async {
    await _videoController?.seekTo(position);
  }

  Future<void> seekRelative(Duration offset) async {
    final newPosition = _position + offset;
    if (newPosition.isNegative) {
      await seekTo(Duration.zero);
    } else if (newPosition > _duration) {
      await seekTo(_duration);
    } else {
      await seekTo(newPosition);
    }
  }

  void setFullScreen(bool fullScreen) {
    _isFullScreen = fullScreen;
    notifyListeners();
  }

  Future<void> setPlaybackSpeed(double speed) async {
    await _videoController?.setPlaybackSpeed(speed);
  }

  Future<void> setVolume(double volume) async {
    await _videoController?.setVolume(volume.clamp(0.0, 1.0));
  }

  double get aspectRatio {
    if (_videoController == null) return 16 / 9;
    return _videoController!.value.aspectRatio;
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Future<void> dispose() async {
    _videoController?.removeListener(_onVideoUpdate);
    await _chewieController?.dispose();
    await _videoController?.dispose();
    _chewieController = null;
    _videoController = null;
    _isInitialized = false;
    _isPlaying = false;
    _currentUrl = null;
    super.dispose();
  }
}
