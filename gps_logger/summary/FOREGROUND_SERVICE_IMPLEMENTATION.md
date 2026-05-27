# Implementação do Foreground Service - Resumo Técnico

## Overview
Implementação completa de um Foreground Service persistente no Android para manter o tracking de GPS ativo com a tela desligada e aparelho bloqueado.

## Arquivos Criados

### 1. `lib/services/foreground_task_handler.dart`
- **Responsabilidade**: TaskHandler para o flutter_foreground_task
- **Funcionalidades**:
  - Gerencia eventos do foreground service (start, repeat, destroy)
  - Processa cliques nos botões da notificação
  - Emite eventos via Stream para comunicar ações ao app
  - Botão "PARAR" que dispara `stop_requested`

```dart
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(ForegroundTaskHandler());
}

class ForegroundTaskHandler extends TaskHandler {
  static final _eventController = StreamController<String>.broadcast();
  static Stream<String> get eventStream => _eventController.stream;
  
  @override
  void onButtonPressed(String id) {
    if (id == 'stop') {
      _eventController.add('stop_requested');
      FlutterForegroundTask.stopService();
    }
  }
}
```

### 2. `lib/services/foreground_service_manager.dart`
- **Responsabilidade**: Gerenciar ciclo de vida do Foreground Service
- **Funcionalidades**:
  - Inicializar e configurar o serviço
  - Iniciar/parar o serviço
  - Solicitar e verificar permissões (POST_NOTIFICATIONS, LOCATION)
  - Atualizar notificação
  - Singleton pattern para garantir instância única

```dart
class ForegroundServiceManager {
  static final ForegroundServiceManager _instance = 
      ForegroundServiceManager._internal();
  
  Future<void> startService() async {
    await FlutterForegroundTask.init(...);
    await FlutterForegroundTask.startService(
      notificationTitle: 'Rastreamento Ativo',
      notificationText: 'Seu ônibus está sendo rastreado',
      notificationButtons: [
        NotificationButton(id: 'stop', text: 'PARAR'),
      ],
    );
  }
}
```

## Arquivos Modificados

### 1. `pubspec.yaml`
- **Adicionado**: `flutter_foreground_task: ^5.3.1`

### 2. `android/app/src/main/AndroidManifest.xml`
```xml
<!-- Permissões para Foreground Service  -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />
```

### 3. `lib/main.dart`
```dart
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'services/foreground_task_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ... inicialização
  
  // Inicializa o Foreground Task Handler
  FlutterForegroundTask.setTaskHandler(ForegroundTaskHandler());
  
  runApp(MyApp(storage: storage));
}
```

### 4. `lib/services/session_service.dart`
- **Adicionado**: Método `dispose()` para cleanup completo
  - Cancela timer de rastreamento
  - Desconecta MQTT
  - Fecha stream controller
  - Tratamento de erros em cada etapa

```dart
Future<void> dispose() async {
  try {
    timer?.cancel();
    timer = null;
    
    try {
      mqttService.disconnect();
    } catch (e) {
      print('SESSION DISPOSE: Erro ao desconectar MQTT: $e');
    }
    
    if (!_positionController.isClosed) {
      try {
        _positionController.close();
      } catch (e) {
        print('SESSION DISPOSE: Erro ao fechar stream: $e');
      }
    }
  } catch (e) {
    print('SESSION DISPOSE: Erro geral: $e');
  }
}
```

### 5. `lib/controllers/tracker_controller.dart`
- **Adicionado**: Integração com ForegroundServiceManager
- **Adicionado**: Listener para eventos do ForegroundTaskHandler
- **Modificado**: `startSession()` 
  - Verifica e solicita permissões
  - Inicia foreground service
  - Mantém sessão de tracking
- **Modificado**: `stopSession()`
  - Para o foreground service
  - Para o tracking
  - Executa cleanup completo
- **Modificado**: `dispose()` com cleanup seguro

```dart
class TrackerController extends ChangeNotifier {
  final ForegroundServiceManager _foregroundServiceManager =
      ForegroundServiceManager();
  
  StreamSubscription<String>? _foregroundTaskSubscription;
  
  Future<void> initialize() async {
    // ... código existente
    
    // Escuta eventos do foreground task handler
    _foregroundTaskSubscription =
        ForegroundTaskHandler.eventStream.listen((event) {
      if (event == 'stop_requested') {
        stopSession();
      } else if (event == 'service_destroyed') {
        sessionActive = false;
        notifyListeners();
      }
    });
  }
  
  Future<void> startSession() async {
    // Solicita permissões
    final permissionsGranted =
        await _foregroundServiceManager.requestPermissions();
    
    // Inicia foreground service
    await _foregroundServiceManager.startService();
    
    // Inicia tracking
    await sessionService.start(mock: simulation);
  }
  
  Future<void> stopSession() async {
    // Para foreground service
    await _foregroundServiceManager.stopService();
    
    // Para tracking
    sessionService.stop();
    
    // Cleanup
    await sessionService.dispose();
  }
}
```

## Fluxo de Execução

### Iniciar Rastreamento
1. Usuário clica no botão "PLAY" no app
2. `TrackerController.startSession()` é chamado
3. Solicita permissões via `ForegroundServiceManager.requestPermissions()`
4. Inicia o Foreground Service com notificação persistente
5. Inicia a `SessionService` para capturar posições
6. Notificação exibe: "Rastreamento Ativo" com botão "PARAR"

### Parar Rastreamento (Cenários)

#### Cenário 1: Botão PARAR na Notificação
1. Usuário clica "PARAR" na notificação
2. `ForegroundTaskHandler.onButtonPressed('stop')` é executado
3. Emite evento `'stop_requested'` via Stream
4. `TrackerController` recebe o evento
5. `TrackerController.stopSession()` é chamado
6. Executa cleanup completo

#### Cenário 2: Botão STOP no App
1. Usuário clica no botão "STOP" no FloatingActionButton
2. `TrackerController.stopSession()` é chamado diretamente
3. Para o Foreground Service
4. Para o tracking
5. Executa cleanup completo

#### Cenário 3: App em Background Destruído
1. Sistema encerra o app
2. `TrackerController.dispose()` é chamado
3. Finaliza subscriptions
4. Executa cleanup da SessionService

## Garante Requisitos

### ✓ Manter o serviço ativo com tela desligada e aparelho bloqueado
- Foreground Service com WakeLock habilitado
- Notificação persistente (não pode ser removida)
- Executa em background contínuo

### ✓ Exibir notificação persistente "Rastreamento ativo"
- Configurado em `ForegroundServiceManager.startService()`
- Título: "Rastreamento Ativo"
- Texto: "Seu ônibus está sendo rastreado"
- Channel: HIGH priority

### ✓ Botão "PARAR" na notificação
- Implementado em `ForegroundTaskHandler`
- ID: 'stop'
- Texto: 'PARAR'

### ✓ Ao clicar "PARAR"
- Encerra o stream de localização ✓
- Desconecta MQTT ✓
- Finaliza SessionService ✓
- Remove a notificação (automático ao parar o service) ✓
- Para o Foreground Service ✓

### ✓ Permissões Android 13+
- POST_NOTIFICATIONS: Solicitada via `ForegroundServiceManager`
- ACCESS_FINE_LOCATION: Solicitada via GpsService
- FOREGROUND_SERVICE: Declarada no AndroidManifest
- FOREGROUND_SERVICE_LOCATION: Declarada no AndroidManifest

### ✓ Não duplicar streams GPS
- SessionService usa singleton `GpsService`
- Nenhuma reinicialização múltipla
- Única instância de stream por sessão

### ✓ Não reiniciar múltiplas instâncias
- `ForegroundServiceManager` usa Singleton
- Verifica se serviço já está rodando
- Bloqueia reinicializações concorrentes

### ✓ Manter sessão MQTT ao trocar estado
- MQTT permanece conectado enquanto Foreground Service rodando
- Desconecção apenas ao clicar "PARAR"
- Não afetado por mudanças de tela do app

## Testes Sugeridos

1. **Iniciar rastreamento**: Verificar se notificação aparece
2. **Desligar tela**: Verificar se tracking continua
3. **Clicar PARAR na notificação**: Verificar parada completa
4. **Clicar STOP no app**: Verificar parada completa
5. **Forçar parada do app**: Verificar cleanup
6. **Negar permissões**: Verificar erro gracioso
7. **Múltiplas iniciações**: Verificar que não duplica

## Segurança e Performance

- **Cleanup ordenado**: Evita memory leaks
- **Error handling**: Tratamento em cada etapa critica
- **Singleton patterns**: Evita múltiplas instâncias
- **Logging**: Debug informações em cada passo importante
- **Stream disposal**: Sempre fecha streams
- **Timer cancellation**: Sempre cancela timers
