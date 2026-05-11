import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../models/video_source.dart';

class SpiderService extends ChangeNotifier {
  final Dio _dio = Dio();
  HeadlessInAppWebView? _headlessWebView;
  final Map<String, dynamic> _cache = {};
  bool _webViewReady = false;
  Completer<void>? _initCompleter;

  VideoSource? _currentSource;
  bool _isLoading = false;
  String? _error;

  VideoSource? get currentSource => _currentSource;
  bool get isLoading => _isLoading;
  String? get error => _error;

  static const String _htmlPage =
      '<!DOCTYPE html><html><head><meta charset="utf-8"></head><body></body></html>';

  static const String _reqPolyfill = '''
function req(url, options) {
  options = options || {};
  var method = options.method || 'GET';
  var headers = options.headers || {};
  var body = options.body || options.data || null;
  var responseType = options.responseType || 'text';
  var xhr = new XMLHttpRequest();
  if (responseType === 'buffer' || responseType === 'arraybuffer') {
    xhr.responseType = 'arraybuffer';
  }
  xhr.open(method, url, false);
  for (var key in headers) {
    if (headers.hasOwnProperty(key)) {
      xhr.setRequestHeader(key, headers[key]);
    }
  }
  xhr.send(body);
  if (responseType === 'buffer' || responseType === 'arraybuffer') {
    return new Uint8Array(xhr.response);
  }
  if (responseType === 'json') {
    try { return JSON.parse(xhr.responseText); } catch(e) { return null; }
  }
  return xhr.responseText;
}
''';

  static const String _localPolyfill = '''
var __local_store = {};
function local(key, value) {
  if (value === undefined) {
    return __local_store[key] || null;
  }
  __local_store[key] = value;
}
''';

  Future<void> loadSource(VideoSource source) async {
    _currentSource = source;
    _isLoading = true;
    _error = null;
    _webViewReady = false;
    notifyListeners();

    try {
      await _disposeWebView();

      if (source.type == 3) {
        String? spiderUrl = source.spider;
        if (spiderUrl != null && spiderUrl.isNotEmpty) {
          if (spiderUrl.endsWith('.md5')) {
            spiderUrl = spiderUrl.substring(0, spiderUrl.length - 4);
          }
          await _loadJsSpider(spiderUrl, source);
        } else if (source.api != null && source.api!.isNotEmpty) {
          String apiUrl = source.api!;
          if (apiUrl.endsWith('.md5')) {
            apiUrl = apiUrl.substring(0, apiUrl.length - 4);
          }
          await _loadJsSpider(apiUrl, source);
        }
      }
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = '加载源失败: $e';
      debugPrint(_error);
    }
    notifyListeners();
  }

  Future<void> _loadJsSpider(String url, VideoSource source) async {
    String? jsCode;
    if (_cache.containsKey('js_$url')) {
      jsCode = _cache['js_$url'];
    } else {
      final response = await _dio.get(url,
          options: Options(
              responseType: ResponseType.plain,
              receiveTimeout: const Duration(seconds: 30)));
      jsCode = response.data.toString();
      _cache['js_$url'] = jsCode;
    }

    if (jsCode != null && jsCode.isNotEmpty) {
      _initCompleter = Completer<void>();
      _headlessWebView = HeadlessInAppWebView(
        initialSettings: InAppWebViewSettings(
          allowUniversalAccessFromFileURLs: true,
          allowFileAccessFromFileURLs: true,
          javaScriptEnabled: true,
          domStorageEnabled: true,
        ),
        initialData: InAppWebViewInitialData(
          data: _htmlPage,
          baseUrl: WebUri('https://localhost/'),
        ),
        onWebViewCreated: (controller) async {
          debugPrint('SpiderService: WebView created');
        },
        onLoadStop: (controller, url) async {
          debugPrint('SpiderService: onLoadStop $url');
          try {
            await controller.evaluateJavascript(source: _reqPolyfill);
            await controller.evaluateJavascript(source: _localPolyfill);
            await controller.evaluateJavascript(source: jsCode!);

            final initCfg = jsonEncode({
              'skey': source.key ?? '',
              'ext': source.ext ?? '',
            });
            await controller.evaluateJavascript(
                source: 'typeof init === "function" ? init($initCfg) : undefined');

            _webViewReady = true;
            if (_initCompleter != null && !_initCompleter!.isCompleted) {
              _initCompleter!.complete();
            }
          } catch (e) {
            debugPrint('SpiderService: init error $e');
            _webViewReady = true;
            if (_initCompleter != null && !_initCompleter!.isCompleted) {
              _initCompleter!.complete();
            }
          }
        },
      );
      await _headlessWebView!.run();

      try {
        await _initCompleter!.future.timeout(const Duration(seconds: 30));
      } catch (e) {
        debugPrint('SpiderService: WebView init timeout or error: $e');
        _webViewReady = false;
      }
    }
  }

  Future<void> _ensureWebViewReady() async {
    if (!_webViewReady || _headlessWebView == null) {
      throw Exception('WebView not initialized');
    }
  }

  Future<Map<String, dynamic>> _evaluateSpider(String jsExpression) async {
    await _ensureWebViewReady();
    final controller = _headlessWebView!.webViewController;
    if (controller == null) {
      throw Exception('WebView controller is null');
    }
    final result = await controller.evaluateJavascript(
        source: 'try { var __r = $jsExpression; __r === undefined || __r === null ? "null" : JSON.stringify(__r) } catch(e) { JSON.stringify({__error: e.message}) }');
    final jsonStr = result?.toString() ?? '';
    if (jsonStr.isEmpty || jsonStr == 'undefined' || jsonStr == 'null') {
      return {};
    }
    try {
      final parsed = jsonDecode(jsonStr);
      if (parsed is Map<String, dynamic>) {
        if (parsed.containsKey('__error')) {
          debugPrint('SpiderService: JS error: ${parsed['__error']}');
          return {};
        }
        return parsed;
      }
      return {};
    } catch (e) {
      debugPrint('SpiderService: JSON decode error: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> homeContent() async {
    if (_currentSource == null) return {'class': [], 'list': []};
    try {
      if (_currentSource!.type == 3 && _webViewReady) {
        return await _jsSpiderHome();
      }
      return await _apiHome(_currentSource!);
    } catch (e) {
      debugPrint('homeContent error: $e');
      return {'class': [], 'list': []};
    }
  }

  Future<Map<String, dynamic>> categoryContent(
      {required String tid, int page = 1, Map<String, String>? extend}) async {
    if (_currentSource == null) {
      return {'page': 1, 'pagecount': 1, 'list': [], 'count': 0};
    }
    try {
      if (_currentSource!.type == 3 && _webViewReady) {
        return await _jsSpiderCategory(tid, page, extend);
      }
      return await _apiCategory(_currentSource!, tid, page, extend);
    } catch (e) {
      debugPrint('categoryContent error: $e');
      return {'page': page, 'pagecount': 1, 'list': [], 'count': 0};
    }
  }

  Future<Map<String, dynamic>> detailContent(List<String> ids) async {
    if (_currentSource == null || ids.isEmpty) return {'list': []};
    try {
      if (_currentSource!.type == 3 && _webViewReady) {
        return await _jsSpiderDetail(ids);
      }
      return await _apiDetail(_currentSource!, ids);
    } catch (e) {
      debugPrint('detailContent error: $e');
      return {'list': []};
    }
  }

  Future<Map<String, dynamic>> searchContent(
      {required String key, int page = 1}) async {
    if (_currentSource == null) return {'list': [], 'page': page};
    try {
      if (_currentSource!.type == 3 && _webViewReady) {
        return await _jsSpiderSearch(key, page);
      }
      return await _apiSearch(_currentSource!, key, page);
    } catch (e) {
      debugPrint('searchContent error: $e');
      return {'list': [], 'page': page};
    }
  }

  Future<Map<String, dynamic>> playerContent(
      {required String flag, required String id}) async {
    if (_currentSource == null) return {'parse': 0, 'url': '', 'header': {}};
    try {
      if (_currentSource!.type == 3 && _webViewReady) {
        return await _jsSpiderPlay(flag, id);
      }
      return await _apiPlay(_currentSource!, flag, id);
    } catch (e) {
      debugPrint('playerContent error: $e');
      return {'parse': 0, 'url': '', 'header': {}};
    }
  }

  Future<Map<String, dynamic>> _jsSpiderHome() async {
    try {
      final homeResult = await _evaluateSpider('home(true)');
      final homeVodResult = await _evaluateSpider('typeof homeVod === "function" ? homeVod() : null');
      final merged = <String, dynamic>{};
      if (homeResult.containsKey('class')) {
        merged['class'] = homeResult['class'];
      } else {
        merged['class'] = [];
      }
      if (homeResult.containsKey('filters')) {
        merged['filters'] = homeResult['filters'];
      }
      if (homeVodResult.containsKey('list') && (homeVodResult['list'] as List).isNotEmpty) {
        merged['list'] = homeVodResult['list'];
      } else if (homeResult.containsKey('list')) {
        merged['list'] = homeResult['list'];
      } else {
        merged['list'] = [];
      }
      debugPrint('SpiderService: home class=${(merged['class'] as List).length} list=${(merged['list'] as List).length}');
      return merged;
    } catch (e) {
      debugPrint('_jsSpiderHome error: $e');
      return {'class': [], 'list': []};
    }
  }

  Future<Map<String, dynamic>> _jsSpiderCategory(
      String tid, int page, Map<String, String>? extend) async {
    try {
      final extendJson = extend != null ? jsonEncode(extend) : '{}';
      final escapedTid = tid.replaceAll("'", "\\'");
      final result = await _evaluateSpider(
          "category('$escapedTid', $page, true, $extendJson)");
      if (result.isEmpty) {
        return {'page': page, 'pagecount': 1, 'list': [], 'count': 0};
      }
      return result;
    } catch (e) {
      debugPrint('_jsSpiderCategory error: $e');
      return {'page': page, 'pagecount': 1, 'list': [], 'count': 0};
    }
  }

  Future<Map<String, dynamic>> _jsSpiderDetail(List<String> ids) async {
    try {
      final idsStr = ids.join(',').replaceAll("'", "\\'");
      final result = await _evaluateSpider("detail('$idsStr')");
      if (result.isEmpty) return {'list': []};
      return result;
    } catch (e) {
      debugPrint('_jsSpiderDetail error: $e');
      return {'list': []};
    }
  }

  Future<Map<String, dynamic>> _jsSpiderSearch(String key, int page) async {
    try {
      final escapedKey = key.replaceAll("'", "\\'").replaceAll('"', '\\"');
      final result = await _evaluateSpider("search('$escapedKey', false)");
      if (result.isEmpty) return {'list': [], 'page': page};
      return result;
    } catch (e) {
      debugPrint('_jsSpiderSearch error: $e');
      return {'list': [], 'page': page};
    }
  }

  Future<Map<String, dynamic>> _jsSpiderPlay(String flag, String id) async {
    try {
      final escapedFlag = flag.replaceAll("'", "\\'");
      final escapedId = id.replaceAll("'", "\\'").replaceAll('"', '\\"');
      final result = await _evaluateSpider("play('$escapedFlag', '$escapedId', [])");
      if (result.isEmpty) return {'parse': 0, 'url': '', 'header': {}};
      return result;
    } catch (e) {
      debugPrint('_jsSpiderPlay error: $e');
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
    final url = _buildApiUrl(source.api, {'ac': 'detail', 'ids': ids.join(',')});
    return await _fetchJson(url);
  }

  Future<Map<String, dynamic>> _apiSearch(
      VideoSource source, String key, int page) async {
    final url = _buildApiUrl(source.api, {'wd': key, 'pg': page.toString()});
    return await _fetchJson(url);
  }

  Future<Map<String, dynamic>> _apiPlay(
      VideoSource source, String flag, String id) async {
    final url = _buildApiUrl(source.api, {'ac': 'play', 'flag': flag, 'id': id});
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
    try {
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
    } catch (e) {
      debugPrint('_fetchJson error: $e');
      return {};
    }
  }

  Map<String, String> _getHeaders(String url) {
    final host = Uri.parse(url).host;
    return {
      'User-Agent':
          'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36',
      'Referer': 'https://$host/',
    };
  }

  Future<void> _disposeWebView() async {
    if (_headlessWebView != null) {
      try {
        await _headlessWebView!.dispose();
      } catch (e) {
        debugPrint('SpiderService: dispose WebView error: $e');
      }
      _headlessWebView = null;
    }
    _webViewReady = false;
    _initCompleter = null;
  }

  Future<void> clearCache() async {
    _cache.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposeWebView();
    _dio.close();
    super.dispose();
  }
}
