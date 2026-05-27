# ⚡ Quick Reference - GPS Logger

Guia rápido com comandos e informações mais usadas.

---

## 🚀 Comandos Principais

### Instalar Dependências
```bash
cd c:\projetos\gps_logger
flutter pub get
```

### Executar o App
```bash
flutter run
```

### Executar Release
```bash
flutter build apk --release
```

### Hot Reload (salve o arquivo)
```
Pressione 'r' no terminal
```

### Hot Restart
```
Pressione 'R' no terminal
```

### Limpar Cache
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📱 Acessar Arquivo de Dados

### Via ADB
```bash
adb shell
cd /data/data/com.example.gps_logger/files/
cat gps_sessions.json
```

### Via ADB (Copiar Arquivo)
```bash
adb pull /data/data/com.example.gps_logger/files/gps_sessions.json
```

---

## ⚙️ Customizações Comuns

### Alterar Intervalo de Coleta
**Arquivo:** `lib/services/gps_location_service.dart`
```dart
// Mude esta linha (padrão: 60 segundos)
static const int updateIntervalSeconds = 60;
```

### Alterar Nome do Arquivo
**Arquivo:** `lib/services/gps_storage.dart`
```dart
// Mude esta linha
static const String fileName = 'gps_sessions.json';
```

### Alterar Precisão de GPS
**Arquivo:** `lib/services/gps_location_service.dart`
```dart
// Opções: best, high, medium, low
accuracy: LocationAccuracy.best,
```

### Desabilitar Wake Lock
**Arquivo:** `lib/screens/home_screen.dart`
```dart
// Comente estas linhas
// await WakelockPlus.enable();
// await WakelockPlus.disable();
```

---

## 📊 Arquitetura Rápida

```
User toca "Iniciar"
        ↓
GPSLocationService.startRecording()
        ↓
Cria GPSSession nova
        ↓
Inicia stream Geolocator
        ↓
A cada ponto: cria GPSPoint
        ↓
GPSJsonStorage.updateSession()
        ↓
Escreve em arquivo JSON
```

---

## 🎯 Fluxo de Dados

```json
HomeScreen (UI)
    ↓
GPSLocationService (Lógica)
    ↓
GPSPoint (Dado)
    ↓
GPSSession (Coleção)
    ↓
GPSJsonStorage (Persistência)
    ↓
gps_sessions.json (Arquivo)
```

---

## 🔑 Classes Principais

| Classe | Arquivo | Responsabilidade |
|--------|---------|------------------|
| `GPSPoint` | models/gps_data.dart | Um ponto de GPS |
| `GPSSession` | models/gps_data.dart | Coleção de pontos |
| `GPSLocationService` | services/gps_location_service.dart | Coleta de GPS |
| `GPSJsonStorage` | services/gps_storage.dart | Armazenamento |
| `HomeScreen` | screens/home_screen.dart | Tela principal |

---

## 📍 Métodos Mais Usados

### GPSLocationService

```dart
// Iniciar coleta
await locationService.startRecording();

// Parar coleta
await locationService.stopRecording();

// Obter sessão atual
GPSSession? session = locationService.currentSession;

// Verificar permissão
bool allowed = await locationService.requestLocationPermission();
```

### GPSJsonStorage

```dart
// Obter todas sessões
List<GPSSession> sessions = await storage.getSessions();

// Obter sessão atual
GPSSession? current = await storage.getCurrentSession();

// Adicionar sessão
await storage.addSession(session);

// Atualizar sessão
await storage.updateSession(session);

// Obter caminho do arquivo
String path = await storage.getFilePath();

// Limpar dados
await storage.clear();
```

---

## 🎨 Estados da UI

| Estado | Indicador | Botão Iniciar | Botão Parar |
|--------|-----------|---------------|------------|
| Parado | 🟢 Verde | Habilitado | Desabilitado |
| Gravando | 🔴 Vermelho | Desabilitado | Habilitado |
| Erro | 🟡 Amarelo | Desabilitado | Desabilitado |

---

## 💾 Estrutura do JSON

### Sessão
```json
{
  "session_id": "session_[unix_timestamp]",
  "start_time": "YYYY-MM-DD HH:mm:ss",
  "end_time": "YYYY-MM-DD HH:mm:ss",
  "start_unix": [número],
  "end_unix": [número],
  "points_count": [número],
  "points": [...]
}
```

### Ponto
```json
{
  "latitude": [número decimal],
  "longitude": [número decimal],
  "speed": [número em m/s],
  "timestamp": "YYYY-MM-DD HH:mm:ss",
  "unix_timestamp": [número em ms]
}
```

---

## 🔐 Permissões Necessárias

```xml
android.permission.ACCESS_FINE_LOCATION
android.permission.ACCESS_COARSE_LOCATION
android.permission.WAKE_LOCK
android.permission.RECEIVE_BOOT_COMPLETED
android.permission.READ_EXTERNAL_STORAGE
android.permission.WRITE_EXTERNAL_STORAGE
android.permission.POST_NOTIFICATIONS
```

---

## 🐛 Debug Rápido

### Visualizar Logs
```bash
flutter logs
```

### Print Debugação
```dart
print('Debug: valor = $valor');
```

### Verificar Estado
```dart
// No HomeScreen
print('isRecording: $_isRecording');
print('currentSession: $_currentSession');
```

---

## 📈 Cálculos Úteis

### Converter m/s para km/h
```dart
double kmh = ms * 3.6;
```

### Converter para milhas/hora
```dart
double mph = ms * 2.237;
```

### Distância Haversine
```dart
// Implementada em SessionDetailScreen._calculateDistance()
double distance = _calculateDistance(lat1, lon1, lat2, lon2);
```

---

## 🗺️ Caminho de Arquivos

### Android
```
/data/data/com.example.gps_logger/files/gps_sessions.json
```

### Linux/Mac (simulador)
```
~/.config/flutter/emulators/
```

### Windows (simulador)
```
C:\Users\<user>\AppData\Local\Android\sdk\
```

---

## 📞 Informações Úteis

### Intervalo Padrão
- Coleta: **1 minuto (60 segundos)**
- Exibição: Real-time

### Precisão GPS
- Configuração: **LocationAccuracy.best**
- Margem: ±5-10 metros (depende do dispositivo)

### Consumo de Bateria
- Aproximado: 15-20% por hora de gravação contínua
- Com tela desligada: 5-10% por hora

### Armazenamento
- Por ponto: ~150 bytes
- 100 pontos: ~15 KB
- 1000 pontos: ~150 KB

---

## ✅ Checklist de Deploy

- [ ] `flutter clean` executado
- [ ] `flutter pub get` executado
- [ ] Não há erros na compilação
- [ ] Permissões configuradas em AndroidManifest.xml
- [ ] App testado em dispositivo físico
- [ ] Todos os 10 testes passaram
- [ ] Arquivo JSON é criado corretamente
- [ ] Background funciona com tela desligada

---

## 🎯 Testes Rápidos

### Teste 1: Básico
```
1. flutter run
2. Clique "Iniciar"
3. Aguarde 2 min
4. Clique "Parar"
✅ Se tem pontos, ok!
```

### Teste 2: Background
```
1. Iniciar gravação
2. Desligar tela
3. Aguardar 2 min
4. Ligar tela
✅ Se pontos aumentaram, ok!
```

### Teste 3: JSON
```
1. Terminar gravação
2. adb pull ...gps_sessions.json
3. Abrir arquivo
✅ Se JSON válido, ok!
```

---

## 🚨 Troubleshooting Rápido

| Problema | Solução |
|----------|---------|
| "Permissão negada" | Ir em Configurações > Permissões > Localização |
| "GPS desabilitado" | Ativar GPS em Configurações > Localização |
| "Sem pontos" | Aguardar 1 minuto ou sair para área aberta |
| "App trava" | flutter clean && flutter run |
| "Hot reload não funciona" | Pressione 'R' (hot restart) em vez de 'r' |

---

## 🎓 Recursos Externos

- [Flutter Docs](https://flutter.dev/docs)
- [Geolocator Package](https://pub.dev/packages/geolocator)
- [Android GPS](https://developer.android.com/guide/topics/location)
- [Haversine Formula](https://en.wikipedia.org/wiki/Haversine_formula)

---

## 📱 Versões de Android

| Versão | Nome | API | Suporte |
|--------|------|-----|---------|
| Android 5.0 | Lollipop | 21 | ✅ Mínimo |
| Android 8.0 | Oreo | 26 | ✅ |
| Android 10 | Q | 29 | ✅ |
| Android 12 | S | 31 | ✅ |
| Android 13 | T | 33 | ✅ |
| Android 14 | U | 34 | ✅ |

---

**Quick Reference v1.0** - Última atualização: 11 de maio de 2026
