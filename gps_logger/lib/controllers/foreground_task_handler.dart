import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:gps_logger/main.dart';

import '../services/session_service.dart';
import '../models/bus_data.dart';

@pragma('vm:entry-point')
void startCallback() {
  print("[TASK_HANDLER] start callback");
  FlutterForegroundTask.setTaskHandler(handler);
}

class ForegroundTaskHandler extends TaskHandler {
  static final _eventController =
      StreamController<String>.broadcast();

  static Stream<String> get eventStream => _eventController.stream;

  final SessionService sessionService = SessionService();

  StreamSubscription<BusData>? _positionsSubscription;

  int counter = 0;

  @override
  Future<void> onStart(
    DateTime timestamp,
    TaskStarter starter,
  ) async {
    debugPrint('[ForegroundTaskHandler] Serviço iniciado');

    try {
      /// Inicia sessão existente
      await sessionService.start(mock: false);

      /// Escuta atualizações de posição
      _positionsSubscription = sessionService.positions.listen((bus) {
        counter++;

        debugPrint('NEW DATA ${bus.toJson()}');

        /// Atualiza notificação
        FlutterForegroundTask.updateService(
          notificationTitle: 'Rastreamento ativo',
          notificationText: 'Pacotes enviados: $counter',
        );

        /// Comunicação opcional com UI
        FlutterForegroundTask.sendDataToMain({
          'type': 'position_update',
          'counter': counter,
          'busCode': bus.busCode,
        });
      });
    } catch (e, stack) {
      debugPrint('[ForegroundTaskHandler] Erro: $e');

      debugPrintStack(stackTrace: stack);
    }
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    debugPrint('[ForegroundTaskHandler] Alive: $timestamp');
  }

  @override
  Future<void> onDestroy(
    DateTime timestamp,
    bool isNotificationPressed,
  ) async {
    debugPrint('[ForegroundTaskHandler] Serviço destruído');

    try {
      /// Cancela stream
      await _positionsSubscription?.cancel();

      /// Finaliza sessão
      sessionService.stop();

      _eventController.add('service_destroyed');
    } catch (e) {
      debugPrint('[ForegroundTaskHandler] Erro destroy: $e');
    }
  }

  @override
  void onNotificationButtonPressed(String id) {
    debugPrint('[ForegroundTaskHandler] Botão: $id');

    if (id == 'stop') {
      _eventController.add('stop_requested');

      FlutterForegroundTask.stopService();
    }
  }
}
