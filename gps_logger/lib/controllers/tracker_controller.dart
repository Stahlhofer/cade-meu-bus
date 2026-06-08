import 'package:flutter/material.dart';
import 'package:gps_logger/services/notification_service.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

import '../models/bus_data.dart';
import '../services/mqtt_service.dart';
import '../services/session_service.dart';

class TrackerController extends ChangeNotifier {
  MqttService mqttService = MqttService();

  late NotificationService notification;

  late SessionService sessionService;

  final Map<String, BusData> buses = {};

  List<BusData> get allBuses => buses.values.toList();

  int counter = 0;

  bool connected = false;

  bool sessionActive = false;

  bool sessionBlocked = false;

  String lastTimestamp = '';

  Timer? delayTimer;

  bool simulation = false;

  Future<void> initialize() async {
    counter = 0;
    sessionService = SessionService();
    notification = NotificationService();

    await notification.initialize();
  }

  Future<void> startSession() async {
    if (sessionBlocked) {
      print('SESSÃO BLOQUEADA - AGUARDE ANTES DE INICIAR NOVAMENTE');
      return;
    }

    counter = 0;
    try {
      await sessionService.start(mock: simulation);

      connected = true;
      sessionActive = true;
      notifyListeners();
    } catch (e) {
      connected = false;
      sessionActive = false;
      print("FAILED INITIALIZE $e");
    }

    await notification.showNotification(
      id: 0,
      title: 'Conexão ATIVA',
      body: 'Envio de dados da posição atual em andamento',
    );

    // listen for position events coming from background service
    sessionService.positions.listen((bus) {
      try {
        counter++;
        buses[bus.busCode] = bus;

        lastTimestamp = bus.position.timestamp.replaceAll('-', '/');

        notifyListeners();
      } catch (e) {
        print('ERROR PROCESSING BG EVENT: $e');
      }
    });
  }

  Future<void> stopSession() async {
    try {
      sessionService.stop();

      sessionActive = false;
      connected = false;
      sessionBlocked = true;
      notifyListeners();

      // Timer de 2 segundos de bloqueio
      delayTimer = Timer(const Duration(seconds: 2), () {
        sessionBlocked = false;
        notifyListeners();
      });

      print('SESSÃO TERMINADA - BLOQUEIO DE 2 SEGUNDOS INICIADO');
    } catch (e) {
      print('ERRO AO PARAR SESSÃO: $e');
    }
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

  @override
  void dispose() {
    delayTimer?.cancel();
    super.dispose();
  }
}
