import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trace_craft/app.dart';
import 'package:trace_craft/services/ad_service.dart';
import 'package:trace_craft/services/camera_service.dart';
import 'package:trace_craft/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Database (Hive + TypeAdapters for Session & UserSettings)
  await DatabaseService.init();

  // Initialize Camera hardware stub
  await CameraService.initCameras();

  // Initialize AdMob stub
  await AdService.init();

  runApp(
    const ProviderScope(
      child: TraceCraftApp(),
    ),
  );
}
