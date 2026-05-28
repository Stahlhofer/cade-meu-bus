import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../models/bus_data.dart';
import '../services/mqtt_service.dart';

class BusController extends ChangeNotifier {
  final MqttService mqttService = MqttService();

  final Map<String, BusData> buses = {};

  bool connected = false;

  Future<void> initialize() async {
    try {
      await mqttService.connect();

      connected = true;

      notifyListeners();

      mqttService.busStream.listen((BusData busData) {
        // Atualiza ônibus pelo código
        buses[busData.busCode] = busData;

        notifyListeners();
      });
    } catch (e) {
      debugPrint('Exception occurred: $e');
      connected = false;

      notifyListeners();
    }
  }

  List<BusData> get allBuses => buses.values.toList();

  String get lastRegister {
    if (buses.isEmpty) return '';

    final latest = buses.values.reduce(
      (a, b) => a.position.timeUnix > b.position.timeUnix ? a : b,
    );

    return latest.position.timestamp;
  }

  LatLng getCenter() {
    if (buses.isEmpty) {
      return LatLng(-28.30547397556633, -53.50550691397332);
    }

    return LatLng(
      buses.values.first.position.latitude,
      buses.values.first.position.longitude,
    );
  }
}
