import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_js/flutter_js.dart';
import '../models/video_source.dart';

class SpiderService extends ChangeNotifier {
  final Dio _dio = Dio();
  JavascriptRuntime? _jsRuntime;
  final Map<String, dynamic> _spiderCache = {};
  final Map<String, String> _cookieCache = {};
  
  VideoSource? _currentSource;
  String? _currentSpiderCode;
  bool _isLoading = false;
  String? _error;

  VideoSource? get currentSource => _currentSource;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasSpider => _currentSpiderCode != null && _currentSpiderCode!.isNotEmpty;

  SpiderService() {
    _initJsRuntime();
  }

  void _initJsRuntime() {
    try {
      _jsRuntime = getJavascriptRuntime();
    } catch (e) {
      debugPrint('JS Runtime init failed: $e');
    }
  }

  Future<void> loadSource(VideoSource source) async {
    _currentSource = source;
    if (source.spider != null && source.spider!.isNotEmpty) {
      await _loadSpiderCode(source.spider!);
    }
    notifyListeners();
  }

  Future<void> _loadSpiderCode(String spiderUrl) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_spiderCache.containsKey(spiderUrl)) {
        _currentSpiderCode = _spiderCache[spiderUrl];
      } else {
        final response = await _dio.get(spiderUrl, 
          options: Options(
            responseType: ResponseType.plain,
            receiveTimeout: const Duration(seconds: 30),
          ),
        );
        _currentSpiderCode = response.data.toString();
        _spiderCache[spiderUrl] = _currentSpiderCode;
      }
      
      _isLoading = false;
      _error = null;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load spider: $e';
      debugPrint(_error);
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> homeContent({bool filter = true}) async {
    if (_currentSource == null) {
      return {'class': [], 'list': [], 'filters': {}};
    }

    try {
      final api = '${_currentSource!.api}/home';
      final response = await _fetchApi(api, {'filter': filter ? 1 : 0});
      return response;
    } catch (e) {
      debugPrint('homeContent error: $e');
      return {'class': [], 'list': [], 'filters': {}};
    }
  }

  Future<Map<String, dynamic>> categoryContent({
    required String tid,
    int page = 1,
    String? filter,
    Map<String, String>? extend,
  }) async {
    if (_currentSource == null) {
      return {'page': 1, 'pagecount': 1, 'list': [], 'count': 0};
    }

    try {
      final params = <String, dynamic>{
        'type_id': tid,
        'page': page,
      };
      
      if (filter != null) params['filter'] = filter;
      if (extend != null) params.addAll(extend);

      final api = '${_currentSource!.api}/category';
      return await _fetchApi(api, params);
    } catch (e) {
      debugPrint('categoryContent error: $e');
      return {'page': page, 'pagecount': 1, 'list': [], 'count': 0};
    }
  }

  Future<Map<String, dynamic>> detailContent(List<String> ids) async {
    if (_currentSource == null || ids.isEmpty) {
      return {'list': []};
    }

    try {
      final api = '${_currentSource!.api}/detail';
      final response = await _fetchApi(api, {'ids': ids.join(',')});
      return response;
    } catch (e) {
      debugPrint('detailContent error: $e');
      return {'list': []};
    }
  }

  Future<Map<String, dynamic>> searchContent({
    required String key,
    bool quick = false,
    int page = 1,
  }) async {
    if (_currentSource == null) {
      return {'list': []};
    }

    try {
      final api = '${_currentSource!.api}/search';
      return await _fetchApi(api, {
        'keyword': key,
        'quick': quick ? 1 : 0,
        'page': page,
      });
    } catch (e) {
      debugPrint('searchContent error: $e');
      return {'list': [], 'page': page};
    }
  }

  Future<Map<String, dynamic>> playerContent({
    required String flag,
    required String id,
    List<String>? vipFlags,
  }) async {
    if (_currentSource == null) {
      return {'parse': 0, 'url': '', 'header': {}};
    }

    try {
      final api = '${_currentSource!.api}/player';
      return await _fetchApi(api, {
        'flag': flag,
        'id': id,
        'vipFlags': vipFlags?.join(',') ?? '',
      });
    } catch (e) {
      debugPrint('playerContent error: $e');
      return {'parse': 0, 'url': '', 'header': {}};
    }
  }

  Future<Map<String, dynamic>> _fetchApi(String api, Map<String, dynamic> params) async {
    final url = Uri.parse(api).replace(queryParameters: {
      ...Uri.parse(api).queryParameters,
      ...params.map((k, v) => MapEntry(k, v?.toString() ?? '')),
    }).toString();

    final response = await _dio.get(
      url,
      options: Options(
        responseType: ResponseType.json,
        receiveTimeout: const Duration(seconds: 30),
        headers: _getHeaders(api),
      ),
    );

    return response.data as Map<String, dynamic>;
  }

  Map<String, String> _getHeaders(String url) {
    final host = Uri.parse(url).host;
    return {
      'User-Agent': 'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36',
      'Referer': 'https://$host/',
      'Origin': 'https://$host',
    };
  }

  Future<String?> executeJsSpider(String function, List<dynamic> args) async {
    if (_jsRuntime == null || _currentSpiderCode == null) {
      return null;
    }

    try {
      final jsCode = '''
        $_currentSpiderCode
        $function(${args.map((a) => jsonEncode(a)).join(',')});
      ''';
      
      final result = _jsRuntime!.evaluate(jsCode);
      return result.stringResult;
    } catch (e) {
      debugPrint('JS execution error: $e');
      return null;
    }
  }

  Future<void> clearCache() async {
    _spiderCache.clear();
    _cookieCache.clear();
    notifyListeners();
  }

  void dispose() {
    _jsRuntime?.dispose();
    super.dispose();
  }
}
