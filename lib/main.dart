import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'app.dart';
import 'core/services/storage_service.dart';
import 'core/services/config_service.dart';
import 'core/services/spider_service.dart';
import 'core/services/player_service.dart';
import 'core/services/proxy_service.dart';
import 'core/models/video_source.dart';

const String appVersion = '1.2.0';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(VideoSourceAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(FilterAdapter());

  await StorageService.init();

  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await windowManager.ensureInitialized();
    WindowManager.instance.setMinimumSize(const Size(800, 600));
    await windowManager.setTitle('牛盒');
  }

  if (Platform.isAndroid || Platform.isIOS) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
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
