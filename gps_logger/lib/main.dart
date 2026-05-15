import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/gps_storage.dart';

import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o armazenamento
  final storage = GPSJsonStorage();
  await storage.initialize();

  runApp(MyApp(storage: storage));
}

class MyApp extends StatelessWidget {
  final GPSJsonStorage storage;

  const MyApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GPS Logger',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: HomeScreen(storage: storage),
    );
  }
}

Future<void> pedirPermissao() async {
  await Permission.storage.request();
}
