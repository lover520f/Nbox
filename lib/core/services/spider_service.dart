import 'dart:async';
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
  var resHeaders = {};
  try {
    var allHeaders = xhr.getAllResponseHeaders();
    if (allHeaders) {
      allHeaders.split('\\r\\n').forEach(function(line) {
        var parts = line.split(': ');
        if (parts.length >= 2) resHeaders[parts[0].toLowerCase()] = parts.slice(1).join(': ');
      });
    }
  } catch(e) {}
  if (responseType === 'buffer' || responseType === 'arraybuffer') {
    return { ok: xhr.status >= 200 && xhr.status < 300, status: xhr.status, url: url, content: new Uint8Array(xhr.response), headers: resHeaders };
  }
  if (responseType === 'json') {
    try {
      return { ok: xhr.status >= 200 && xhr.status < 300, status: xhr.status, url: url, content: JSON.parse(xhr.responseText), headers: resHeaders };
    } catch(e) {
      return { ok: false, status: xhr.status, url: url, content: null, headers: resHeaders };
    }
  }
  return { ok: xhr.status >= 200 && xhr.status < 300, status: xhr.status, url: url, content: xhr.responseText, headers: resHeaders };
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
var console = console || {};
console.log = console.log || function() {};
console.error = console.error || function() {};
console.warn = console.warn || function() {};
console.info = console.info || function() {};
''';

  bool get _isJsSource => _currentSource?.type == 3;

  bool get _isApiSource => _currentSource?.type == 0 || _currentSource?.type == 1;

  Future<void> loadSource(VideoSource source) async {
    _currentSource = source;
    _isLoading = true;
    _error = null;
    _webViewReady = false;
    notifyListeners();

    try {
      if (_isJsSource) {
        await _disposeWebView();
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

  Future<void> refresh() async {
    if (_currentSource == null) return;
    await loadSource(_currentSource!);
  }

  String _buildApiUrl(String base, Map<String, String> params) {
    final uri = Uri.parse(base);
    final newParams = Map<String, String>.from(uri.queryParameters);
    newParams.addAll(params);
    return uri.replace(queryParameters: newParams).toString();
  }

  Future<Map<String, dynamic>> _fetchJson(String url) async {
    try {
      final response = await _dio.get(url,
          options: Options(
              responseType: ResponseType.plain,
              receiveTimeout: const Duration(seconds: 15)));
      final content = response.data.toString().trim();
      if (content.isEmpty) return {};
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('SpiderService: _fetchJson error: $e');
      return {};
    }
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

            await controller.evaluateJavascript(source: '''
if (typeof __jsEvalReturn === 'function') {
  var __spiderObj = __jsEvalReturn();
  if (__spiderObj) {
    if (typeof __spiderObj.init === 'function') window.init = __spiderObj.init;
    if (typeof __spiderObj.home === 'function') window.home = __spiderObj.home;
    if (typeof __spiderObj.homeVod === 'function') window.homeVod = __spiderObj.homeVod;
    if (typeof __spiderObj.category === 'function') window.category = __spiderObj.category;
    if (typeof __spiderObj.detail === 'function') window.detail = __spiderObj.detail;
    if (typeof __spiderObj.play === 'function') window.play = __spiderObj.play;
    if (typeof __spiderObj.search === 'function') window.search = __spiderObj.search;
    if (typeof __spiderObj.destroy === 'function') window.destroy = __spiderObj.destroy;
  }
}
''');

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
    final jsWrapper = '''try {
  var __r = $jsExpression;
  if (__r === undefined || __r === null) { "null" }
  else if (typeof __r === "string") { __r }
  else { JSON.stringify(__r) }
} catch(e) { JSON.stringify({__error: e.message}) }''';
    final result = await controller.evaluateJavascript(source: jsWrapper);
    if (result == null) return {};
    if (result is Map<String, dynamic>) {
      if (result.containsKey('__error')) {
        debugPrint('SpiderService: JS error: ${result['__error']}');
        return {};
      }
      return result;
    }
    if (result is Map) {
      final map = Map<String, dynamic>.from(result);
      if (map.containsKey('__error')) {
        debugPrint('SpiderService: JS error: ${map['__error']}');
        return {};
      }
      return map;
    }
    final jsonStr = result.toString();
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
      if (parsed is Map) {
        return Map<String, dynamic>.from(parsed);
      }
      return {};
    } catch (e) {
      debugPrint('SpiderService: JSON decode error: $e, raw: ${jsonStr.substring(0, jsonStr.length > 200 ? 200 : jsonStr.length)}');
      return {};
    }
  }

  Future<Map<String, dynamic>> homeContent() async {
    if (_currentSource == null) return {'class': [], 'list': []};
    try {
      if (_isApiSource) return await _apiHome();
      return await _jsSpiderHome();
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
      if (_isApiSource) return await _apiCategory(tid, page);
      return await _jsSpiderCategory(tid, page, extend);
    } catch (e) {
      debugPrint('categoryContent error: $e');
      return {'page': page, 'pagecount': 1, 'list': [], 'count': 0};
    }
  }

  Future<Map<String, dynamic>> detailContent(List<String> ids) async {
    if (_currentSource == null || ids.isEmpty) return {'list': []};
    try {
      if (_isApiSource) return await _apiDetail(ids);
      return await _jsSpiderDetail(ids);
    } catch (e) {
      debugPrint('detailContent error: $e');
      return {'list': []};
    }
  }

  Future<Map<String, dynamic>> searchContent(
      {required String key, int page = 1}) async {
    if (_currentSource == null) return {'list': [], 'page': page};
    try {
      if (_isApiSource) return await _apiSearch(key, page);
      return await _jsSpiderSearch(key, page);
    } catch (e) {
      debugPrint('searchContent error: $e');
      return {'list': [], 'page': page};
    }
  }

  Future<Map<String, dynamic>> playerContent(
      {required String flag, required String id}) async {
    if (_currentSource == null) return {'parse': 0, 'url': '', 'header': {}};
    try {
      if (_isApiSource) return await _apiPlay(flag, id);
      return await _jsSpiderPlay(flag, id);
    } catch (e) {
      debugPrint('playerContent error: $e');
      return {'parse': 0, 'url': '', 'header': {}};
    }
  }

  Future<Map<String, dynamic>> _apiHome() async {
    final api = _currentSource!.api ?? '';
    if (api.isEmpty) return {'class': [], 'list': []};
    var data = await _fetchJson(_buildApiUrl(api, {'ac': 'home'}));
    if (data.isEmpty || (!data.containsKey('class') && !data.containsKey('list'))) {
      data = await _fetchJson(_buildApiUrl(api, {'ac': 'list'}));
    }
    return data;
  }

  Future<Map<String, dynamic>> _apiCategory(String tid, int page) async {
    final api = _currentSource!.api ?? '';
    if (api.isEmpty) return {'page': page, 'pagecount': 1, 'list': [], 'count': 0};
    return await _fetchJson(_buildApiUrl(api, {'ac': 'list', 't': tid, 'pg': '$page'}));
  }

  Future<Map<String, dynamic>> _apiDetail(List<String> ids) async {
    final api = _currentSource!.api ?? '';
    if (api.isEmpty) return {'list': []};
    return await _fetchJson(_buildApiUrl(api, {'ac': 'detail', 'ids': ids.join(',')}));
  }

  Future<Map<String, dynamic>> _apiSearch(String key, int page) async {
    final api = _currentSource!.api ?? '';
    if (api.isEmpty) return {'list': [], 'page': page};
    return await _fetchJson(_buildApiUrl(api, {'wd': key, 'pg': '$page'}));
  }

  Future<Map<String, dynamic>> _apiPlay(String flag, String id) async {
    final api = _currentSource!.api ?? '';
    if (api.isEmpty) return {'parse': 0, 'url': '', 'header': {}};
    final data = await _fetchJson(_buildApiUrl(api, {'ac': 'detail', 'ids': id}));
    final list = data['list'] as List?;
    if (list == null || list.isEmpty) return {'parse': 0, 'url': '', 'header': {}};
    final vod = list.first as Map<String, dynamic>;
    final vodPlayUrl = vod['vod_play_url'] as String? ?? '';
    return {'parse': 0, 'url': vodPlayUrl, 'header': {}};
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
          "category('$escapedTid', '$page', true, $extendJson)");
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
      final escapedId = ids.isNotEmpty ? ids.first.replaceAll("'", "\\'") : '';
      final result = await _evaluateSpider("detail('$escapedId')");
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
