import 'package:flutter/material.dart';
import 'dart:async';

import '../models/bus_data.dart';
import '../services/mqtt_service.dart';
import '../services/session_service.dart';
import '../services/foreground_service_manager.dart';
import '../services/foreground_task_handler.dart';

class TrackerController extends ChangeNotifier {
  MqttService mqttService = MqttService();

  late SessionService sessionService;

  final ForegroundServiceManager _foregroundServiceManager =
      ForegroundServiceManager();

  final Map<String, BusData> buses = {};

  int counter = 0;

  bool connected = false;

  bool sessionActive = false;

  bool sessionBlocked = false;

  String lastTimestamp = '';

  Timer? delayTimer;

  bool simulation = false;

  StreamSubscription<String>? _foregroundTaskSubscription;

  Future<void> initialize() async {
    counter = 0;
    // startCallback();
    sessionService = SessionService();

    // Escuta eventos do foreground task handler
    _foregroundTaskSubscription = ForegroundTaskHandler.eventStream
        .listen((event) {
          if (event == 'stop_requested') {
            debugPrint(
              '[TrackerController] Stop solicitado pela notificação',
            );
            stopSession();
          } else if (event == 'service_destroyed') {
            debugPrint('[TrackerController] Serviço destruído');
            sessionActive = false;
            notifyListeners();
          }
        });
  }

  Future<void> startSession() async {
    if (sessionBlocked) {
      debugPrint(
        'SESSÃO BLOQUEADA - AGUARDE ANTES DE INICIAR NOVAMENTE',
      );
      return;
    }

    counter = 0;
    try {
      debugPrint(simulation.toString());

      // Solicita permissões necessárias
      final permissionsGranted = await _foregroundServiceManager
          .requestPermissions();

      if (!permissionsGranted) {
        debugPrint('PERMISSÕES NEGADAS PARA FOREGROUND SERVICE');
        connected = false;
        sessionActive = false;
        notifyListeners();
        return;
      }

      // Inicia o foreground service
      await _foregroundServiceManager.startService();

      // Inicia a sessão de tracking
      await sessionService.start(mock: simulation);

      connected = true;
      sessionActive = true;
      notifyListeners();

      debugPrint("SUCCEEDED INITIALIZE");
    } catch (e) {
      connected = false;
      sessionActive = false;
      debugPrint("FAILED INITIALIZE $e");
      notifyListeners();
    }

    sessionService.positions.listen((bus) {
      counter++;
      debugPrint("NEW DATA  ${bus.toJson()} ");
      buses[bus.busCode] = bus;

      lastTimestamp = bus.position.timestamp.replaceAll('-', '/');

      notifyListeners();
    });
  }

  Future<void> stopSession() async {
    try {
      // Para o foreground service
      await _foregroundServiceManager.stopService();

      // Para a sessão de tracking
      sessionService.stop();

      // Faz cleanup completo
      await sessionService.dispose();

      sessionActive = false;
      connected = false;
      sessionBlocked = true;
      notifyListeners();

      // Timer de 2 segundos de bloqueio
      delayTimer = Timer(const Duration(seconds: 2), () {
        sessionBlocked = false;
        notifyListeners();
      });

      debugPrint(
        'SESSÃO TERMINADA - BLOQUEIO DE 2 SEGUNDOS INICIADO',
      );
    } catch (e) {
      debugPrint('ERRO AO PARAR SESSÃO: $e');
    }
  }

  @override
  void dispose() {
    delayTimer?.cancel();
    _foregroundTaskSubscription?.cancel();
    try {
      sessionService.dispose();
    } catch (e) {
      debugPrint('ERRO AO FINALIZAR SESSION SERVICE: $e');
    }
    super.dispose();
  }
}
