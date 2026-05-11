import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/video_source.dart';

class SpiderService extends ChangeNotifier {
  final Dio _dio = Dio();
  final Map<String, dynamic> _cache = {};

  VideoSource? _currentSource;
  bool _isLoading = false;
  String? _error;
  String? _jsCode;

  VideoSource? get currentSource => _currentSource;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSource(VideoSource source) async {
    _currentSource = source;
    _isLoading = true;
    _error = null;
    _jsCode = null;
    notifyListeners();

    try {
      if (source.type == 3 &&
          source.spider != null &&
          source.spider!.isNotEmpty) {
        await _loadJsSpider(source.spider!);
      }
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = '加载源失败: $e';
      debugPrint(_error);
    }
    notifyListeners();
  }

  Future<void> _loadJsSpider(String url) async {
    if (_cache.containsKey('js_$url')) {
      _jsCode = _cache['js_$url'];
      return;
    }
    final response = await _dio.get(url,
        options: Options(
            responseType: ResponseType.plain,
            receiveTimeout: const Duration(seconds: 30)));
    _jsCode = response.data.toString();
    _cache['js_$url'] = _jsCode;
  }

  Future<Map<String, dynamic>> homeContent() async {
    if (_currentSource == null) return {'class': [], 'list': []};
    try {
      final source = _currentSource!;
      if (source.type == 3 && _jsCode != null) {
        return await _jsSpiderHome();
      }
      return await _apiHome(source);
    } catch (e) {
      debugPrint('homeContent error: $e');
      return {'class': [], 'list': []};
    }
  }

  Future<Map<String, dynamic>> categoryContent(
      {required String tid,
      int page = 1,
      Map<String, String>? extend}) async {
    if (_currentSource == null) {
      return {'page': 1, 'pagecount': 1, 'list': [], 'count': 0};
    }
    try {
      final source = _currentSource!;
      if (source.type == 3 && _jsCode != null) {
        return await _jsSpiderCategory(tid, page);
      }
      return await _apiCategory(source, tid, page, extend);
    } catch (e) {
      debugPrint('categoryContent error: $e');
      return {'page': page, 'pagecount': 1, 'list': [], 'count': 0};
    }
  }

  Future<Map<String, dynamic>> detailContent(List<String> ids) async {
    if (_currentSource == null || ids.isEmpty) return {'list': []};
    try {
      final source = _currentSource!;
      if (source.type == 3 && _jsCode != null) {
        return await _jsSpiderDetail(ids);
      }
      return await _apiDetail(source, ids);
    } catch (e) {
      debugPrint('detailContent error: $e');
      return {'list': []};
    }
  }

  Future<Map<String, dynamic>> searchContent(
      {required String key, int page = 1}) async {
    if (_currentSource == null) return {'list': [], 'page': page};
    try {
      final source = _currentSource!;
      if (source.type == 3 && _jsCode != null) {
        return await _jsSpiderSearch(key, page);
      }
      return await _apiSearch(source, key, page);
    } catch (e) {
      debugPrint('searchContent error: $e');
      return {'list': [], 'page': page};
    }
  }

  Future<Map<String, dynamic>> playerContent(
      {required String flag, required String id}) async {
    if (_currentSource == null) return {'parse': 0, 'url': '', 'header': {}};
    try {
      final source = _currentSource!;
      if (source.type == 3 && _jsCode != null) {
        return await _jsSpiderPlay(flag, id);
      }
      return await _apiPlay(source, flag, id);
    } catch (e) {
      debugPrint('playerContent error: $e');
      return {'parse': 0, 'url': '', 'header': {}};
    }
  }

  Future<Map<String, dynamic>> _apiHome(VideoSource source) async {
    final url = _buildApiUrl(source.api, {'ac': 'home'});
    return await _fetchJson(url);
  }

  Future<Map<String, dynamic>> _apiCategory(VideoSource source, String tid,
      int page, Map<String, String>? extend) async {
    final params = {'ac': 'list', 't': tid, 'pg': page.toString()};
    if (extend != null) params.addAll(extend);
    final url = _buildApiUrl(source.api, params);
    return await _fetchJson(url);
  }

  Future<Map<String, dynamic>> _apiDetail(
      VideoSource source, List<String> ids) async {
    final url =
        _buildApiUrl(source.api, {'ac': 'detail', 'ids': ids.join(',')});
    return await _fetchJson(url);
  }

  Future<Map<String, dynamic>> _apiSearch(
      VideoSource source, String key, int page) async {
    final url = _buildApiUrl(source.api, {'wd': key, 'pg': page.toString()});
    return await _fetchJson(url);
  }

  Future<Map<String, dynamic>> _apiPlay(
      VideoSource source, String flag, String id) async {
    final url =
        _buildApiUrl(source.api, {'ac': 'play', 'flag': flag, 'id': id});
    return await _fetchJson(url);
  }

  String _buildApiUrl(String? baseApi, Map<String, String> params) {
    if (baseApi == null || baseApi.isEmpty) return '';
    final uri = Uri.parse(baseApi);
    final newParams = Map<String, String>.from(uri.queryParameters)
      ..addAll(params);
    return uri.replace(queryParameters: newParams).toString();
  }

  Future<Map<String, dynamic>> _fetchJson(String url) async {
    if (url.isEmpty) return {};
    final response = await _dio.get(url,
        options: Options(
          responseType: ResponseType.json,
          receiveTimeout: const Duration(seconds: 30),
          headers: _getHeaders(url),
        ));
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is String) {
      try {
        return Map<String, dynamic>.from(
            const JsonDecoder().convert(data) as Map);
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  Map<String, String> _getHeaders(String url) {
    final host = Uri.parse(url).host;
    return {
      'User-Agent': 'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36',
      'Referer': 'https://$host/',
    };
  }

  Future<Map<String, dynamic>> _jsSpiderHome() async {
    final source = _currentSource!;
    if (source.api != null && source.api!.isNotEmpty) {
      return await _apiHome(source);
    }
    final spiderUrl = source.spider ?? '';
    if (spiderUrl.isEmpty) return {'class': [], 'list': []};
    final baseUrl = spiderUrl.substring(0, spiderUrl.lastIndexOf('/'));
    return await _fetchJson('$baseUrl?ac=home');
  }

  Future<Map<String, dynamic>> _jsSpiderCategory(String tid, int page) async {
    final source = _currentSource!;
    if (source.api != null && source.api!.isNotEmpty) {
      return await _apiCategory(source, tid, page, null);
    }
    final spiderUrl = source.spider ?? '';
    final baseUrl = spiderUrl.substring(0, spiderUrl.lastIndexOf('/'));
    return await _fetchJson('$baseUrl?ac=list&t=$tid&pg=$page');
  }

  Future<Map<String, dynamic>> _jsSpiderDetail(List<String> ids) async {
    final source = _currentSource!;
    if (source.api != null && source.api!.isNotEmpty) {
      return await _apiDetail(source, ids);
    }
    final spiderUrl = source.spider ?? '';
    final baseUrl = spiderUrl.substring(0, spiderUrl.lastIndexOf('/'));
    return await _fetchJson('$baseUrl?ac=detail&ids=${ids.join(',')}');
  }

  Future<Map<String, dynamic>> _jsSpiderSearch(String key, int page) async {
    final source = _currentSource!;
    if (source.api != null && source.api!.isNotEmpty) {
      return await _apiSearch(source, key, page);
    }
    final spiderUrl = source.spider ?? '';
    final baseUrl = spiderUrl.substring(0, spiderUrl.lastIndexOf('/'));
    return await _fetchJson('$baseUrl?wd=$key&pg=$page');
  }

  Future<Map<String, dynamic>> _jsSpiderPlay(String flag, String id) async {
    final source = _currentSource!;
    if (source.api != null && source.api!.isNotEmpty) {
      return await _apiPlay(source, flag, id);
    }
    final spiderUrl = source.spider ?? '';
    final baseUrl = spiderUrl.substring(0, spiderUrl.lastIndexOf('/'));
    return await _fetchJson('$baseUrl?ac=play&flag=$flag&id=$id');
  }

  Future<void> clearCache() async {
    _cache.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _dio.close();
    super.dispose();
  }
}
