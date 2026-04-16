import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/source.dart';

class AppProvider extends ChangeNotifier {
  int _currentIndex = 0;
  List<Source> _vodSources = [];
  List<Source> _liveSources = [];
  bool _isLoading = false;

  int get currentIndex => _currentIndex;
  List<Source> get vodSources => _vodSources;
  List<Source> get liveSources => _liveSources;
  bool get isLoading => _isLoading;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> loadSources() async {
    final box = Hive.box('sources');
    final vodData = box.get('vod_sources', defaultValue: []);
    final liveData = box.get('live_sources', defaultValue: []);
    
    _vodSources = (vodData as List).map((e) => Source.fromJson(e)).toList();
    _liveSources = (liveData as List).map((e) => Source.fromJson(e)).toList();
    
    if (_vodSources.isEmpty) {
      await addDefaultVodSource();
    }
    
    notifyListeners();
  }

  Future<void> addDefaultVodSource() async {
    final defaultSource = Source(
      id: 'default',
      name: '默认接口',
      url: 'http://ok213.top/tv',
      type: 'vod',
    );
    _vodSources.add(defaultSource);
    await _saveSources();
  }

  Future<void> addSource(Source source) async {
    if (source.type == 'vod') {
      _vodSources.add(source);
    } else {
      _liveSources.add(source);
    }
    await _saveSources();
    notifyListeners();
  }

  Future<void> removeSource(String id, String type) async {
    if (type == 'vod') {
      _vodSources.removeWhere((s) => s.id == id);
    } else {
      _liveSources.removeWhere((s) => s.id == id);
    }
    await _saveSources();
    notifyListeners();
  }

  Future<void> _saveSources() async {
    final box = Hive.box('sources');
    await box.put('vod_sources', _vodSources.map((e) => e.toJson()).toList());
    await box.put('live_sources', _liveSources.map((e) => e.toJson()).toList());
  }
}
