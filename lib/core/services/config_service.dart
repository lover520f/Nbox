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
  Map<String, dynamic> _globalConfig = {};
  Map<String, String> _liveConfig = {};
  List<Map<String, dynamic>> _proxyRules = [];
  List<Map<String, dynamic>> _hostRules = [];
  
  bool _isLoading = false;
  String? _error;

  List<VideoSource> get sources => _sources;
  VideoSource? get activeSource => _activeSource;
  Map<String, dynamic> get globalConfig => _globalConfig;
  Map<String, String> get liveConfig => _liveConfig;
  List<Map<String, dynamic>> get proxyRules => _proxyRules;
  List<Map<String, dynamic>> get hostRules => _hostRules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadConfig(String configUrl) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _dio.get(
        configUrl,
        options: Options(
          responseType: ResponseType.plain,
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      final config = jsonDecode(response.data);
      
      if (config['spider'] is List) {
        _sources = (config['spider'] as List)
            .map((e) => VideoSource.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (config['lives'] is Map) {
        _liveConfig = Map<String, String>.from(
          (config['lives'] as Map).map((k, v) => MapEntry(k.toString(), v.toString())),
        );
      }

      _globalConfig = config['config'] as Map<String, dynamic>? ?? {};
      
      _proxyRules = (config['proxy'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ?? [];
      
      _hostRules = (config['hosts'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ?? [];

      if (_sources.isNotEmpty) {
        _activeSource = _sources.firstWhere(
          (s) => s.isEnabled,
          orElse: () => _sources.first,
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load config: $e';
      debugPrint(_error);
      notifyListeners();
    }
  }

  Future<void> loadConfigFromFile(String path) async {
    try {
      _isLoading = true;
      notifyListeners();

      final file = File(path);
      if (await file.exists()) {
        final content = await file.readAsString();
        final config = jsonDecode(content);
        _parseConfig(config);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load config from file: $e';
      debugPrint(_error);
      notifyListeners();
    }
  }

  void _parseConfig(Map<String, dynamic> config) {
    if (config['spider'] is List) {
      _sources = (config['spider'] as List)
          .map((e) => VideoSource.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (config['lives'] is Map) {
      _liveConfig = Map<String, String>.from(
        (config['lives'] as Map).map((k, v) => MapEntry(k.toString(), v.toString())),
      );
    }

    _globalConfig = config['config'] as Map<String, dynamic>? ?? {};
    _proxyRules = (config['proxy'] as List<dynamic>?)
        ?.map((e) => e as Map<String, dynamic>)
        .toList() ?? [];
    _hostRules = (config['hosts'] as List<dynamic>?)
        ?.map((e) => e as Map<String, dynamic>)
        .toList() ?? [];

    if (_sources.isNotEmpty) {
      _activeSource ??= _sources.first;
    }
  }

  void setActiveSource(VideoSource source) {
    _activeSource = source;
    notifyListeners();
  }

  Future<void> saveConfig() async {
    try {
      final config = {
        'spider': _sources.map((s) => s.toJson()).toList(),
        'lives': _liveConfig,
        'config': _globalConfig,
        'proxy': _proxyRules,
        'hosts': _hostRules,
      };

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/config.json');
      await file.writeAsString(jsonEncode(config));
    } catch (e) {
      debugPrint('Failed to save config: $e');
    }
  }

  String? getProxyForHost(String host) {
    for (final rule in _proxyRules) {
      final hosts = rule['hosts'] as List<dynamic>?;
      if (hosts == null) continue;
      
      for (final pattern in hosts) {
        final regex = RegExp(pattern.toString().replaceAll('.', r'\.').replaceAll('*', '.*'));
        if (regex.hasMatch(host)) {
          final urls = rule['urls'] as List<dynamic>?;
          if (urls != null && urls.isNotEmpty) {
            return urls.first.toString();
          }
        }
      }
    }
    return null;
  }

  String? getHostRewrite(String host) {
    for (final rule in _hostRules) {
      if (rule['host']?.toString() == host) {
        return rule['rewrite']?.toString();
      }
    }
    return null;
  }

  bool isVipHost(String host) {
    final vipFlags = _globalConfig['vipFlag'] as List<dynamic>?;
    if (vipFlags == null) return false;
    
    for (final flag in vipFlags) {
      if (host.contains(flag.toString())) {
        return true;
      }
    }
    return false;
  }
}
