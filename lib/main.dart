import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mesh_app/presentation/screens/home/home_screen.dart';
import 'package:mesh_app/presentation/screens/splash/splash_screen.dart';
import 'package:mesh_app/presentation/theme/app_theme.dart';
import 'package:mesh_app/services/app_state_provider.dart';
import 'package:mesh_app/core/algorithms/encryption_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize encryption with secure keys
  await EncryptionService.initialize();

  // Set preferred orientations - PORTRAIT ONLY
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize app state
  final appState = AppStateProvider();
  await appState.initialize();

  runApp(
    ChangeNotifierProvider<AppStateProvider>.value(
      value: appState,
      child: const MeshApp(),
    ),
  );
}

class MeshApp extends StatefulWidget {
  const MeshApp({super.key});

  @override
  State<MeshApp> createState() => _MeshAppState();
}

class _MeshAppState extends State<MeshApp> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mesh',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _showSplash
          ? SplashScreen(
              onInitializationComplete: () {
                setState(() {
                  _showSplash = false;
                });
              },
            )
          : const HomeScreen(),
    );
  }
}
