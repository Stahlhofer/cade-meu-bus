import 'package:flutter/material.dart';
import 'dart:async';

import '../models/bus_data.dart';
import '../services/mqtt_service.dart';
import '../services/session_service.dart';
import '../services/background_service.dart';
import 'dart:convert';

class TrackerController extends ChangeNotifier {
  MqttService mqttService = MqttService();

  late SessionService sessionService;

  final Map<String, BusData> buses = {};

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
  }

  Future<void> startSession() async {
    if (sessionBlocked) {
      print('SESSÃO BLOQUEADA - AGUARDE ANTES DE INICIAR NOVAMENTE');
      return;
    }

    counter = 0;
    try {
      print(simulation);

      // start background foreground service which will run SessionService
      await MyBackgroundServiceManager().startService(
        mock: simulation,
      );

      connected = true;
      sessionActive = true;
      notifyListeners();

      print("SUCCEEDED START BACKGROUND SERVICE");
    } catch (e) {
      connected = false;
      sessionActive = false;
      print("FAILED INITIALIZE $e");
    }

    // listen for position events coming from background service
    MyBackgroundServiceManager().on('position').listen((event) {
      try {
        final raw = (event['data'] ?? '').toString();
        final Map<String, dynamic> json = jsonDecode(raw);

        final bus = BusData.fromJson(json);

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
      // ask background service to stop and clean resources
      await MyBackgroundServiceManager().stopService();

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

  @override
  void dispose() {
    delayTimer?.cancel();
    super.dispose();
  }
}
