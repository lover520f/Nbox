import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import '../models/video.dart';
import '../models/category.dart';
import '../models/live_channel.dart';

class SpiderEngine {
  static Dio? _dio;
  static Map<String, dynamic> _cache = {};

  static Future<void> init() async {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      },
    ));
    _dio!.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (error, handler) {
        return handler.next(error);
      },
    ));
  }

  static Future<List<Category>> getCategories(String url) async {
    try {
      if (_cache.containsKey('categories_$url')) {
        return (_cache['categories_$url'] as List).map((e) => Category.fromJson(e)).toList();
      }

      var response = await _dio!.get(url);
      var data = response.data;

      if (data is Map && data.containsKey('class')) {
        var categories = (data['class'] as List).map((e) => Category.fromJson(e)).toList();
        _cache['categories_$url'] = categories.map((e) => e.toJson()).toList();
        return categories;
      } else if (data is Map && data.containsKey('categories')) {
        var categories = (data['categories'] as List).map((e) => Category.fromJson(e)).toList();
        _cache['categories_$url'] = categories.map((e) => e.toJson()).toList();
        return categories;
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Video>> getVideos(String url, {int page = 1, String? categoryId}) async {
    try {
      String requestUrl = url;
      if (categoryId != null) {
        requestUrl = '$url?ac=list&pg=$page&t=$categoryId';
      } else if (url.contains('?')) {
        requestUrl = '$url&pg=$page';
      } else {
        requestUrl = '$url?pg=$page';
      }

      var response = await _dio!.get(requestUrl);
      var data = response.data;

      if (data is Map) {
        if (data.containsKey('list')) {
          return (data['list'] as List).map((e) => Video.fromJson(e)).toList();
        } else if (data.containsKey('data')) {
          return (data['data'] as List).map((e) => Video.fromJson(e)).toList();
        }
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Video?> getVideoDetail(String url, String videoId) async {
    try {
      String requestUrl = '$url?ac=detail&ids=$videoId';
      var response = await _dio!.get(requestUrl);
      var data = response.data;

      if (data is Map && data.containsKey('list')) {
        var list = data['list'] as List;
        if (list.isNotEmpty) {
          return Video.fromJson(list.first);
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<LiveChannel>> getLiveChannels(String url) async {
    try {
      if (url.endsWith('.m3u') || url.endsWith('.m3u8')) {
        return await _parseM3U(url);
      } else if (url.endsWith('.txt')) {
        return await _parseTXT(url);
      } else if (url.endsWith('.json')) {
        return await _parseJSON(url);
      }

      var response = await _dio!.get(url);
      var data = response.data;

      if (data is Map && data.containsKey('channels')) {
        return (data['channels'] as List).map((e) => LiveChannel.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<LiveChannel>> _parseM3U(String url) async {
    var response = await _dio!.get(url);
    var content = response.data as String;
    var lines = content.split('\n');
    List<LiveChannel> channels = [];
    String? currentName;

    for (var line in lines) {
      line = line.trim();
      if (line.startsWith('#EXTINF:')) {
        var match = RegExp(r'tvg-name="([^"]+)"').firstMatch(line);
        currentName = match?.group(1) ?? line.split(',')[1];
      } else if (line.isNotEmpty && !line.startsWith('#')) {
        if (currentName != null) {
          channels.add(LiveChannel(
            id: line,
            name: currentName,
            url: line,
          ));
          currentName = null;
        }
      }
    }

    return channels;
  }

  static Future<List<LiveChannel>> _parseTXT(String url) async {
    var response = await _dio!.get(url);
    var content = response.data as String;
    var lines = content.split('\n');
    List<LiveChannel> channels = [];

    for (var line in lines) {
      line = line.trim();
      if (line.isNotEmpty && !line.startsWith('#')) {
        var parts = line.split(',');
        if (parts.length >= 2) {
          channels.add(LiveChannel(
            id: parts[1],
            name: parts[0],
            url: parts[1],
          ));
        }
      }
    }

    return channels;
  }

  static Future<List<LiveChannel>> _parseJSON(String url) async {
    var response = await _dio!.get(url);
    var data = response.data;

    if (data is List) {
      return data.map((e) => LiveChannel.fromJson(e)).toList();
    } else if (data is Map && data.containsKey('channels')) {
      return (data['channels'] as List).map((e) => LiveChannel.fromJson(e)).toList();
    }

    return [];
  }

  static Future<String> resolveUrl(String url) async {
    try {
      var response = await _dio!.get(url, options: Options(
        followRedirects: true,
        maxRedirects: 5,
      ));
      return response.realUri.toString();
    } catch (e) {
      return url;
    }
  }

  static Future<String> fetchCatSource(String url) async {
    try {
      if (url.endsWith('.md5')) {
        url = url.substring(0, url.length - 4);
      }

      var response = await _dio!.get(url);
      return response.data;
    } catch (e) {
      return '';
    }
  }

  static String generateId(String input) {
    var bytes = utf8.encode(input);
    var digest = md5.convert(bytes);
    return digest.toString();
  }
}
