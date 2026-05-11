import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../models/video_source.dart';

class ConfigService extends ChangeNotifier {
  final Dio _dio = Dio();
  List<VideoSource> _sources = [];
  VideoSource? _activeSource;
  List<LiveGroup> _liveGroups = [];
  String? _configUrl;
  String? _wallpaper;
  bool _isLoading = false;
  String? _error;

  List<VideoSource> get sources => _sources;
  VideoSource? get activeSource => _activeSource;
  List<LiveGroup> get liveGroups => _liveGroups;
  String? get configUrl => _configUrl;
  String? get wallpaper => _wallpaper;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadConfig(String url) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _configUrl = url;
      final response = await _dio.get(url,
          options: Options(
              responseType: ResponseType.plain,
              receiveTimeout: const Duration(seconds: 30)));

      final content = response.data.toString().trim();
      Map<String, dynamic> config;

      if (content.startsWith('{') || content.startsWith('[')) {
        config = jsonDecode(content) as Map<String, dynamic>;
      } else {
        _isLoading = false;
        _error = '不支持的配置格式';
        notifyListeners();
        return;
      }

      _parseConfig(config);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = '加载配置失败: $e';
      debugPrint(_error);
      notifyListeners();
    }
  }

  Future<void> loadConfigFromFile(String path) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String content;
      if (path.startsWith('assets/')) {
        content = await rootBundle.loadString(path);
      } else {
        final file = File(path);
        if (await file.exists()) {
          content = await file.readAsString();
        } else {
          _isLoading = false;
          _error = '配置文件不存在: $path';
          notifyListeners();
          return;
        }
      }

      content = content.trim();
      if (!content.startsWith('{') && !content.startsWith('[')) {
        _isLoading = false;
        _error = '不支持的配置格式';
        notifyListeners();
        return;
      }

      final config = jsonDecode(content) as Map<String, dynamic>;
      _parseConfig(config);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = '加载配置文件失败: $e';
      debugPrint(_error);
      notifyListeners();
    }
  }

  void _parseConfig(Map<String, dynamic> config) {
    String? globalSpider;
    if (config['spider'] is String && (config['spider'] as String).isNotEmpty) {
      globalSpider = config['spider'] as String;
      if (globalSpider.contains(';')) {
        globalSpider = globalSpider.split(';').first;
      }
    }

    if (config['sites'] is List) {
      _sources = (config['sites'] as List).map((e) {
        final map = e as Map<String, dynamic>;
        String? spiderUrl = map['spider']?.toString() ?? map['jar']?.toString();
        if (spiderUrl == null || spiderUrl.isEmpty) {
          spiderUrl = globalSpider;
        }
        String? ext = map['ext']?.toString();
        if (ext == null && map['extra'] != null) {
          ext = map['extra'].toString();
        }
        return VideoSource(
          key: map['key']?.toString(),
          name: map['name']?.toString(),
          api: map['api']?.toString(),
          type: map['type'] as int?,
          spider: spiderUrl,
          searchable: (map['searchable'] as int?) ?? 1,
          changeable: (map['changeable'] as int?) ?? 1,
          quicksearch: (map['quicksearch'] as int?) ?? 1,
          filter: (map['filter'] as int?) ?? 1,
          filterable: map['filterable'] as int?,
          enabled: 1,
          ext: ext,
        );
      }).toList();
    } else if (config['spider'] is List) {
      _sources = (config['spider'] as List)
          .map((e) => VideoSource.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    _liveGroups = [];
    if (config['lives'] is List) {
      for (var live in (config['lives'] as List)) {
        if (live is Map<String, dynamic>) {
          _liveGroups.add(LiveGroup(
            name: live['name']?.toString() ?? '直播',
            type: live['type'] as int? ?? 0,
            url: live['url']?.toString(),
            epg: live['epg']?.toString(),
          ));
        }
      }
    }

    _wallpaper = config['wallpaper']?.toString();

    if (_sources.isNotEmpty) {
      _activeSource ??= _sources.first;
    }

    debugPrint('ConfigService: parsed ${_sources.length} sources, ${_liveGroups.length} live groups');
    for (final s in _sources) {
      debugPrint('ConfigService: source ${s.name} type=${s.type} api=${s.api} spider=${s.spider}');
    }
  }

  void setActiveSource(VideoSource source) {
    _activeSource = source;
    debugPrint('ConfigService: active source changed to ${source.name}');
    notifyListeners();
  }

  void addSource(VideoSource source) {
    _sources.add(source);
    _activeSource ??= source;
    notifyListeners();
  }

  void removeSource(VideoSource source) {
    _sources.remove(source);
    if (_activeSource == source) {
      _activeSource = _sources.isNotEmpty ? _sources.first : null;
    }
    notifyListeners();
  }

  void updateLiveUrl(String url) {
    if (url.isNotEmpty) {
      _liveGroups = [
        LiveGroup(name: '直播', type: 0, url: url),
      ];
    }
    notifyListeners();
  }

  Future<void> saveConfig() async {
    try {
      final config = {
        'sites': _sources.map((s) => s.toJson()).toList(),
        'lives': _liveGroups.map((g) => g.toJson()).toList(),
        'wallpaper': _wallpaper,
      };
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/config.json');
      await file.writeAsString(jsonEncode(config));
    } catch (e) {
      debugPrint('Failed to save config: $e');
    }
  }
}

class LiveGroup {
  final String name;
  final int type;
  final String? url;
  final String? epg;

  LiveGroup({required this.name, this.type = 0, this.url, this.epg});

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'url': url,
        'epg': epg,
      };
}
