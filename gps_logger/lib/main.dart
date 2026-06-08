import 'package:flutter/material.dart';
import 'package:gps_logger/services/notification_service.dart';
import 'controllers/config_controller.dart';

import 'views/tracker_view.dart';
import 'services/gps_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o armazenamento
  final storage = GPSJsonStorage();
  await storage.initialize();
  final configController = ConfigController();

  await configController.initialize();
  await NotificationService().initialize();

  runApp(MyApp(storage: storage));
}

class MyApp extends StatelessWidget {
  final GPSJsonStorage storage;

  const MyApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
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
