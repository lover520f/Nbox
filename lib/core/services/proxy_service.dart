import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ProxyService extends ChangeNotifier {
  Dio _dio = Dio();
  
  bool _isRunning = false;
  int _port = 7890;
  String? _currentProxyUrl;
  List<ProxyLog> _logs = [];

  bool get isRunning => _isRunning;
  int get port => _port;
  String? get currentProxyUrl => _currentProxyUrl;
  List<ProxyLog> get logs => _logs;

  Future<void> start({int port = 7890}) async {
    if (_isRunning) return;

    try {
      _port = port;
      _currentProxyUrl = 'http://127.0.0.1:$port';
      _isRunning = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to start proxy: $e');
      _error = '代理启动失败: $e';
      notifyListeners();
    }
  }

  Future<void> stop() async {
    if (!_isRunning) return;

    try {
      _isRunning = false;
      _currentProxyUrl = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to stop proxy: $e');
    }
  }

  Future<String?> proxyRequest({
    required String url,
    String? method,
    Map<String, String>? headers,
    dynamic body,
    int timeout = 30,
  }) async {
    try {
      final options = Options(
        method: method ?? 'GET',
        headers: headers,
        sendTimeout: Duration(seconds: timeout),
        receiveTimeout: Duration(seconds: timeout),
      );

      final response = await _dio.request(
        url,
        data: body,
        options: options,
      );

      _addLog(ProxyLog(
        url: url,
        method: method ?? 'GET',
        statusCode: response.statusCode ?? 0,
        timestamp: DateTime.now(),
      ));

      return response.data?.toString();
    } catch (e) {
      debugPrint('Proxy request failed: $e');
      _addLog(ProxyLog(
        url: url,
        method: method ?? 'GET',
        error: e.toString(),
        timestamp: DateTime.now(),
      ));
      return null;
    }
  }

  void _addLog(ProxyLog log) {
    _logs.insert(0, log);
    if (_logs.length > 100) {
      _logs.removeLast();
    }
    notifyListeners();
  }

  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }

  String? _error;
  String? get error => _error;

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}

class ProxyLog {
  final String url;
  final String method;
  final int? statusCode;
  final String? error;
  final DateTime timestamp;

  ProxyLog({
    required this.url,
    required this.method,
    this.statusCode,
    this.error,
    required this.timestamp,
  });

  bool get isSuccess => statusCode != null && statusCode! >= 200 && statusCode! < 300;
}
