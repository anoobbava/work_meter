import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './app_state.dart';

import './services/app_theme.dart';
import './pages/login.dart';
import './config/app_config.dart';

void main() {
  // Initialize and validate configuration
  AppConfig.printConfig();
  if (!AppConfig.validateConfig()) {
    print('Configuration validation failed. Please check your environment variables.');
  }
  
  runApp(
    ChangeNotifierProvider<AppState>(
      create: (context) => AppState(),
      child: WorkMeter(),
    ),
  );
}

class WorkMeter extends StatefulWidget {
  @override
  _WorkMeterState createState() => _WorkMeterState();
}

class _WorkMeterState extends State<WorkMeter> {
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: appState.isDarkModeOn ? ThemeMode.dark : ThemeMode.light,
          home: LoginPage(),
        );
      },
    );
  }
}
