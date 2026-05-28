import 'package:flutter/material.dart';
import 'controllers/config_controller.dart';
import 'package:permission_handler/permission_handler.dart';

import 'views/tracker_view.dart';
import 'services/gps_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o armazenamento
  final storage = GPSJsonStorage();
  await storage.initialize();
  final configController = ConfigController();

  await configController.initialize();

  // Inicializa o Foreground Task Handler
  // Necessário para o flutter_foreground_task funcionar
  // FlutterForegroundTask.setTaskHandler(ForegroundTaskHandler());

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 20, 40, 56),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      // home: HomeView(storage: storage),
      home: TrackerView(),
    );
  }
}

Future<void> pedirPermissao() async {
  await Permission.storage.request();
}
