import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Gerenciador do Foreground Service
/// Responsável por inicializar, configurar e parar o serviço
class ForegroundServiceManager {
  static final ForegroundServiceManager _instance =
      ForegroundServiceManager._internal();

  factory ForegroundServiceManager() {
    return _instance;
  }

  ForegroundServiceManager._internal();

  bool _isServiceRunning = false;

  bool get isServiceRunning => _isServiceRunning;

  /// Inicializa e inicia o Foreground Service
  Future<void> startService() async {
    if (_isServiceRunning) {
      print('[ForegroundServiceManager] Serviço já está em execução');
      return;
    }

    try {
      // Configura a notificação do foreground service
      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          id: 888,
          channelId: 'gps_tracking_channel',
          channelName: 'Rastreamento GPS',
          channelDescription:
              'Notificação de rastreamento ativo de GPS',
        ),
        iosNotificationOptions: const IOSNotificationOptions(
          showNotification: true,
          playSound: false,
        ),
        foregroundTaskOptions: ForegroundTaskOptions(
          eventAction: ForegroundTaskEventAction.repeat(1000),
          autoRunOnBoot: false,
          allowWakeLock: true,
        ),
      );

      // Inicia o serviço
      await FlutterForegroundTask.startService(
        serviceId: 888,
        notificationTitle: 'Rastreamento Ativo',
        notificationText: 'Seu ônibus está sendo rastreado',
        notificationButtons: [
          const NotificationButton(id: 'stop', text: 'PARAR'),
        ],
      );

      _isServiceRunning = true;
      print(
        '[ForegroundServiceManager] Foreground Service iniciado com sucesso',
      );
    } catch (e) {
      print('[ForegroundServiceManager] Erro ao iniciar serviço: $e');
      rethrow;
    }
  }

  /// Para o Foreground Service
  Future<void> stopService() async {
    if (!_isServiceRunning) {
      print(
        '[ForegroundServiceManager] Serviço já não está em execução',
      );
      return;
    }

    try {
      await FlutterForegroundTask.stopService();
      _isServiceRunning = false;
      print(
        '[ForegroundServiceManager] Foreground Service parado com sucesso',
      );
    } catch (e) {
      print('[ForegroundServiceManager] Erro ao parar serviço: $e');
      rethrow;
    }
  }

  /// Atualiza a notificação
  Future<void> updateNotification({
    required String title,
    required String text,
  }) async {
    try {
      await FlutterForegroundTask.updateService(
        notificationTitle: title,
        notificationText: text,
      );
    } catch (e) {
      print(
        '[ForegroundServiceManager] Erro ao atualizar notificação: $e',
      );
    }
  }

  /// Verifica permissões necessárias
  Future<bool> checkPermissions() async {
    final isNotificationPermissionGranted =
        await FlutterForegroundTask.checkNotificationPermission();

    print(
      '[ForegroundServiceManager] Notificação: $isNotificationPermissionGranted',
    );

    return isNotificationPermissionGranted ==
        NotificationPermission.granted;
  }

  /// Solicita permissões necessárias
  Future<bool> requestPermissions() async {
    print('[ForegroundServiceManager] Solicitando permissões...');

    final notificationPermission =
        await FlutterForegroundTask.requestNotificationPermission();

    print(
      '[ForegroundServiceManager] Permissão notificação: $notificationPermission',
    );

    return notificationPermission == NotificationPermission.granted;
  }
}
