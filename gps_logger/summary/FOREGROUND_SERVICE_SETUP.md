# Guia de Próximos Passos - Foreground Service

## 1. Instalação de Dependências
```bash
flutter pub get
```

## 2. Compilação e Teste
```bash
# Build do app
flutter build apk --release

# Ou para testar em debug
flutter run
```

## 3. Configurações Recomendadas

### AndroidManifest.xml Adicional (Opcional)
Se você quiser adicionar configurações mais robustas ao Foreground Service:

```xml
<service
    android:name="com.pravera.flutter_foreground_task.service.ForegroundService"
    android:foregroundServiceType="location" />
```

## 4. Testes Sugeridos

### Teste 1: Iniciar Rastreamento
1. Abra o app
2. Clique no botão PLAY
3. Verifique se a notificação "Rastreamento Ativo" aparece
4. Verifique se o contador de pontos enviados aumenta

### Teste 2: Parar via Notificação
1. Com rastreamento ativo
2. Clique no botão "PARAR" da notificação
3. Verifique se a notificação desaparece
4. Verifique se o rastreamento parou

### Teste 3: Parar via App
1. Com rastreamento ativo
2. Clique no botão STOP (vermelho) no app
3. Verifique se a notificação desaparece
4. Verifique se o rastreamento parou

### Teste 4: Background
1. Inicie rastreamento
2. Desligue a tela do aparelho
3. Espere alguns minutos
4. Acenda a tela novamente
5. Verifique se o contador aumentou
6. Verifique se a notificação ainda está lá

### Teste 5: Permissões (Android 13+)
1. Vá em Configurações > Aplicativos > GPS Logger > Permissões
2. Garanta que "Notificações" está permitida
3. Teste iniciar rastreamento
4. Remova a permissão de notificação
5. Teste iniciar rastreamento novamente
6. Deve mostrar erro ou solicitar permissão

## 5. Possíveis Erros e Soluções

### Erro: "Target of URI doesn't exist"
- **Causa**: Dependência não instalada
- **Solução**: Execute `flutter pub get`

### Erro: "Permissão negada"
- **Causa**: POST_NOTIFICATIONS não concedida
- **Solução**: Vá em Configurações e permita notificações

### Serviço para logo após iniciar
- **Causa**: Foreground Service requer configuração correta
- **Solução**: Verifique se `ForegroundTaskHandler` está registrado em `main.dart`

### Notificação não aparece
- **Causa**: Falta de POST_NOTIFICATIONS em Android 13+
- **Solução**: Solicite permissão antes de iniciar o serviço

## 6. Melhorias Futuras

### Optional: Service Data Persistence
```dart
// Persistir dados do serviço em SharedPreferences
await _preferences.setBool('service_running', true);
```

### Optional: Notificação com Cores
```dart
notificationButtons: [
  NotificationButton(
    id: 'stop',
    text: 'PARAR',
    textColor: Colors.red,
  ),
],
```

### Optional: Múltiplos Botões
```dart
notificationButtons: [
  NotificationButton(id: 'pause', text: 'PAUSAR'),
  NotificationButton(id: 'stop', text: 'PARAR'),
],
```

### Optional: Eventos Repetidos
Configure em `ForegroundTaskOptions`:
```dart
foregroundTaskOptions: const ForegroundTaskOptions(
  interval: 60000, // Executar a cada 60 segundos
  isOnceEvent: false,
)
```

## 7. Verificação de Implementação

### Checklist de Integração
- [ ] `pubspec.yaml` tem `flutter_foreground_task`
- [ ] `AndroidManifest.xml` tem FOREGROUND_SERVICE e FOREGROUND_SERVICE_LOCATION
- [ ] `main.dart` inicializa `ForegroundTaskHandler`
- [ ] `ForegroundTaskHandler` existe em `lib/services/`
- [ ] `ForegroundServiceManager` existe em `lib/services/`
- [ ] `SessionService` tem método `dispose()`
- [ ] `TrackerController` integrado com ForegroundServiceManager
- [ ] Botão de notificação lida com ID 'stop'
- [ ] StreamSubscription do ForegroundTaskHandler está no dispose()

## 8. Estrutura de Arquivos

```
lib/
├── main.dart (modificado)
├── controllers/
│   └── tracker_controller.dart (modificado)
├── services/
│   ├── foreground_task_handler.dart (novo)
│   ├── foreground_service_manager.dart (novo)
│   ├── session_service.dart (modificado)
│   ├── gps_service.dart
│   └── mqtt_service.dart
└── views/
    └── tracker_view.dart

android/
└── app/
    └── src/
        └── main/
            └── AndroidManifest.xml (modificado)
```

## 9. Configuração Avançada (Opcional)

### Para adicionar logs persistentes:
```dart
// Em ForegroundTaskHandler
@override
Future<void> onRepeatEvent(DateTime timestamp) async {
  print('[ForegroundService] Ainda rodando em $timestamp');
  // Aqui você pode fazer logging, capturar dados, etc
}
```

### Para monitorar o estado do serviço:
```dart
// Em ForegroundServiceManager
bool get isServiceRunning => _isServiceRunning;

// Use em qualquer lugar:
if (ForegroundServiceManager().isServiceRunning) {
  print('Serviço está rodando');
}
```

## 10. Performance

- **Intervalo de eventos**: 60 segundos (pode ser alterado)
- **Prioridade do canal**: HIGH (não reduz)
- **WakeLock**: Habilitado (necessário para background)
- **Permissões**: Mínimas necessárias

Se tiver problemas de bateria, aumente o intervalo em `ForegroundTaskOptions`.

---

**Próximo passo**: Execute `flutter pub get` e compile o app!
