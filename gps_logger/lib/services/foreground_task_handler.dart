import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter/material.dart';

/// TaskHandler para controlar o Foreground Service
/// Gerencia o ciclo de vida e as ações do serviço em background
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(ForegroundTaskHandler());
}

class ForegroundTaskHandler extends TaskHandler {
  /// Stream para comunicar eventos do task handler
  static final _eventController =
      StreamController<String>.broadcast();

  static Stream<String> get eventStream => _eventController.stream;

  @override
  Future<void> onStart(
    DateTime timestamp,
    TaskStarter starter,
  ) async {
    debugPrint('[ForegroundTaskHandler] Serviço iniciado');
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    // Evento repetido conforme configurado
    debugPrint(
      '[ForegroundTaskHandler] Evento repetido em $timestamp',
    );
  }

  @override
  Future<void> onDestroy(
    DateTime timestamp,
    bool isNotificationPressed,
  ) async {
    debugPrint('[ForegroundTaskHandler] Serviço destruído');
    _eventController.add('service_destroyed');
  }

  void onButtonPressed(String id) {
    debugPrint('[ForegroundTaskHandler] Botão pressionado: $id');

    if (id == 'stop') {
      _eventController.add('stop_requested');
      FlutterForegroundTask.stopService();
    }
  }
}
