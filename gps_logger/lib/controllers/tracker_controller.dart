import 'package:flutter/material.dart';

import '../models/bus_data.dart';
import '../services/mqtt_service.dart';
import '../services/session_service.dart';

class TrackerController extends ChangeNotifier {
  MqttService mqttService = MqttService();

  late SessionService sessionService;

  final Map<String, BusData> buses = {};

  int counter = 0;

  bool connected = false;

  String lastTimestamp = '';

  Future<void> initialize() async {
    counter = 0;
    sessionService = SessionService(
      // busCode: 'bus01',
      // city: 'panambi',
    );
    try {
      await sessionService.start().then((_) {
        connected = true;
        notifyListeners();
      });

      print("SUCCEEDED INITIALIZE");
    } catch (e) {
      connected = false;
      print("FAILED INITIALIZE $e");
    }

    sessionService.positions.listen((bus) {
      counter++;
      print("NEW DATA  ${bus.toJson()} ");
      buses[bus.busCode] = bus;

      lastTimestamp = bus.position.timestamp.replaceAll('-', '/');

      notifyListeners();
    });
  }
}
