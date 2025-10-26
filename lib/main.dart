import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mesh_app/presentation/screens/home/home_screen.dart';
import 'package:mesh_app/presentation/theme/app_theme.dart';
import 'package:mesh_app/services/app_state_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

class MeshApp extends StatelessWidget {
  const MeshApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mesh',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
