import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/video_source.dart';

class StorageService extends ChangeNotifier {
  static late Box<String> _configBox;
  static late Box<VideoSource> _sourcesBox;
  static late Box _cacheBox;
  static late Box _historyBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    
    _configBox = await Hive.openBox<String>('config');
    _sourcesBox = await Hive.openBox<VideoSource>('sources');
    _cacheBox = await Hive.openBox('cache');
    _historyBox = await Hive.openBox('history');
  }

  static Future<void> saveString(String key, String value) async {
    await _configBox.put(key, value);
  }

  static String? getString(String key) {
    return _configBox.get(key);
  }

  static Future<void> saveJson(String key, Map<String, dynamic> value) async {
    await _configBox.put(key, jsonEncode(value));
  }

  static Map<String, dynamic>? getJson(String key) {
    final str = _configBox.get(key);
    if (str == null) return null;
    return jsonDecode(str) as Map<String, dynamic>;
  }

  static Future<void> saveVideoSource(VideoSource source) async {
    if (source.key != null) {
      await _sourcesBox.put(source.key, source);
    }
  }

  static List<VideoSource> getAllSources() {
    return _sourcesBox.values.toList();
  }

  static Future<void> deleteVideoSource(String key) async {
    await _sourcesBox.delete(key);
  }

  static Future<void> saveCache(String key, String value, {Duration? expiresIn}) async {
    final data = {
      'value': value,
      'expiresAt': expiresIn != null 
          ? DateTime.now().add(expiresIn).millisecondsSinceEpoch 
          : null,
    };
    await _cacheBox.put(key, jsonEncode(data));
  }

  static String? getCache(String key) {
    final data = _cacheBox.get(key);
    if (data == null) return null;
    
    try {
      final map = jsonDecode(data as String) as Map<String, dynamic>;
      final expiresAt = map['expiresAt'] as int?;
      
      if (expiresAt != null && DateTime.now().millisecondsSinceEpoch > expiresAt) {
        _cacheBox.delete(key);
        return null;
      }
      
      return map['value'] as String?;
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveHistory(String videoId, Map<String, dynamic> data) async {
    final history = _historyBox.get('watch_history', defaultValue: <String, dynamic>{}) as Map;
    history[videoId] = {
      ...data,
      'watchedAt': DateTime.now().millisecondsSinceEpoch,
    };
    await _historyBox.put('watch_history', history);
  }

  static Map<String, dynamic>? getHistory(String videoId) {
    final history = _historyBox.get('watch_history', defaultValue: <String, dynamic>{}) as Map;
    return history[videoId] as Map<String, dynamic>?;
  }

  static List<Map<String, dynamic>> getAllHistory() {
    final history = _historyBox.get('watch_history', defaultValue: <String, dynamic>{}) as Map;
    final list = history.values.toList();
    list.sort((a, b) => (b['watchedAt'] as int).compareTo(a['watchedAt'] as int));
    return list.cast<Map<String, dynamic>>();
  }

  static Future<void> clearHistory() async {
    await _historyBox.clear();
  }

  static Future<void> clearCache() async {
    await _cacheBox.clear();
  }

  static Future<void> savePreference(String key, dynamic value) async {
    await _configBox.put('pref_$key', jsonEncode(value));
  }

  static T? getPreference<T>(String key) {
    final str = _configBox.get('pref_$key');
    if (str == null) return null;
    try {
      return jsonDecode(str) as T;
    } catch (e) {
      return null;
    }
  }

  static Future<File> getLogFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/nbox.log');
  }

  static Future<void> appendLog(String message) async {
    try {
      final file = await getLogFile();
      final timestamp = DateTime.now().toIso8601String();
      await file.writeAsString('[$timestamp] $message\n', mode: FileMode.append);
    } catch (e) {
      debugPrint('Failed to write log: $e');
    }
  }
}
