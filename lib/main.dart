import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'shared/models/scan_result.dart';
import 'shared/services/inference_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ScanResultAdapter());
  Hive.registerAdapter(AlternativeMatchAdapter());
  await Hive.openBox<ScanResult>('scan_history');

  // Initialize InferenceService (loads real model or sets mock mode)
  await InferenceService.initialize();

  runApp(const ProviderScope(child: FishTaxaApp()));
}

class FishTaxaApp extends ConsumerWidget {
  const FishTaxaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'FishTaxa',
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: ref.watch(appRouterProvider),
      debugShowCheckedModeBanner: false,
    );
  }
}
