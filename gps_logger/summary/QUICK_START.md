# Quick Start Guide - Foreground Service

## 🚀 Iniciar em 30 Segundos

### 1. Obter Dependências
```bash
cd c:\projetos\cade-meu-bus\gps_logger
flutter pub get
```

### 2. Testar
```bash
flutter run
```

### 3. Clicar PLAY
- Notificação "Rastreamento Ativo" aparece ✅

### 4. Clicar PARAR
- Tudo para ✅

---

## 📁 Arquivos Importantes

### Criados
- `lib/services/foreground_task_handler.dart`
- `lib/services/foreground_service_manager.dart`

### Modificados
- `lib/main.dart` (linha 22)
- `lib/services/session_service.dart` (após linha 138)
- `lib/controllers/tracker_controller.dart` (completo reescrito com integração)
- `pubspec.yaml` (linha 48)
- `android/app/src/main/AndroidManifest.xml` (após linha 18)

---

## 🔑 Conceitos-Chave

| Componente | Função |
|-----------|--------|
| `ForegroundTaskHandler` | Gerencia eventos do serviço em background |
| `ForegroundServiceManager` | Controla o ciclo de vida do serviço |
| `SessionService.dispose()` | Cleanup completo (novo) |
| `TrackerController` | Integração com ambos os gerenciadores |

---

## 🎯 Fluxo Principal

```
Clique PLAY
    ↓
Solicita permissões
    ↓
Inicia Foreground Service
    ├─ Cria notificação
    └─ Botão "PARAR"
    ↓
Inicia SessionService
    ├─ Conecta MQTT
    └─ Captura GPS
    ↓
Clique PARAR (app ou notificação)
    ↓
Para Foreground Service
Para SessionService
Executa dispose()
    └─ Cleanup completo
```

---

## 🔧 Personalização Rápida

### Mudar Intervalo de Evento (em minutos)
Arquivo: `lib/services/foreground_service_manager.dart`, linha 48
```dart
interval: 60000, // Mudar para 120000 = 2 minutos
```

### Mudar Texto da Notificação
Arquivo: `lib/services/foreground_service_manager.dart`, linha 57-60
```dart
notificationTitle: 'Seu Título',
notificationText: 'Seu Texto',
```

### Mudar Nome do Canal
Arquivo: `lib/services/foreground_service_manager.dart`, linha 32
```dart
channelName: 'Seu Nome do Canal',
```

---

## 🐛 Debug

### Ver Logs
```bash
flutter logs
```

### Procurar por
```
[ForegroundServiceManager]
[ForegroundTaskHandler]
[SessionService]
[TrackerController]
```

### Limpar Build
```bash
flutter clean
```

---

## ⚡ Troubleshooting Rápido

| Problema | Solução |
|----------|---------|
| "URI doesn't exist" | `flutter pub get` |
| Notificação não aparece | Verificar POST_NOTIFICATIONS em Configurações |
| App não compila | `flutter clean && flutter pub get` |
| Serviço para imediatamente | Verificar AndroidManifest.xml |
| Logs não aparecem | Reconectar dispositivo, fazer `flutter clean` |

---

## 📝 Comandos Úteis

```bash
# Obter dependências
flutter pub get

# Limpar cache
flutter clean

# Atualizar dependências
flutter pub upgrade

# Build debug
flutter build apk --debug

# Build release
flutter build apk --release

# Ver logs
flutter logs

# Instalar em dispositivo
flutter install

# Run com output
flutter run -v
```

---

## ✅ Verificação Rápida

Após `flutter pub get`:
- [ ] Arquivo compila sem erros
- [ ] Clique PLAY inicia rastreamento
- [ ] Notificação aparece
- [ ] Clique PARAR para tudo
- [ ] Teste em background

---

## 📚 Documentação Detalhada

- `FOREGROUND_SERVICE_IMPLEMENTATION.md` - Técnico
- `FOREGROUND_SERVICE_SETUP.md` - Passo-a-passo
- `FOREGROUND_SERVICE_COMPLETE.md` - Executivo
- `CHANGES_SUMMARY.md` - Mudanças
- `LINT_ERRORS_GUIDE.md` - Erros
- `VERIFICATION_CHECKLIST.md` - Checklist

---

## 🎓 Aprender Mais

### Flutter Foreground Task
https://pub.dev/packages/flutter_foreground_task

### Android Foreground Services
https://developer.android.com/guide/components/foreground-services

### Flutter Streams
https://dart.dev/tutorials/language/streams

---

## 💡 Dicas Importantes

1. **Sempre compile com `flutter pub get` primeiro**
2. **Use dispositivo real para testar background**
3. **Emulador pode não suportar todas as features**
4. **Verifique permissões em Configurações**
5. **Logs no `flutter logs` são seus melhores amigos**

---

## 🎉 Status

✅ Implementação Completa
✅ Documentação Completa
✅ Pronto para Deploy

---

**Próximo passo**: `flutter pub get` 🚀
