import 'package:flutter/material.dart';

import 'pages/home_page.dart';
import 'services/local_storage_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = LocalStorageService();

  runApp(PasswordVaultApp(storageService: storageService));
}

/// Root widget of the application.
class PasswordVaultApp extends StatelessWidget {
  final LocalStorageService storageService;

  const PasswordVaultApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: HomePage(storageService: storageService),
    );
  }
}
