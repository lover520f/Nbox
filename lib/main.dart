import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'package:nbox/app.dart';
import 'package:nbox/core/services/storage_service.dart';
import 'package:nbox/core/services/config_service.dart';
import 'package:nbox/core/services/spider_service.dart';
import 'package:nbox/core/services/player_service.dart';
import 'package:nbox/core/services/proxy_service.dart';
import 'package:nbox/core/models/video_source.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  Hive.registerAdapter(VideoSourceAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(FilterAdapter());
  
  await StorageService.init();
  
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await windowManager.ensureInitialized();
    WindowManager.instance.setMinimumSize(const Size(1280, 720));
    WindowManager.instance.setMaximumSize(const Size(1920, 1080));
    await windowManager.setTitle('Nbox - 牛盒');
  }
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
  ]);
  
  if (Platform.isAndroid || Platform.isIOS) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConfigService()),
        ChangeNotifierProvider(create: (_) => SpiderService()),
        ChangeNotifierProvider(create: (_) => PlayerService()),
        ChangeNotifierProvider(create: (_) => ProxyService()),
      ],
      child: const NboxApp(),
    ),
  );
}
