# gps_logger

# GPS Logger 📍🚀

Um aplicativo Flutter completo para registrar dados de GPS em tempo real no Android, com armazenamento em JSON e funcionamento em background.

## ✨ Funcionalidades Principais

✅ **Rastreamento de GPS** - Coleta latitude, longitude, velocidade e timestamp a cada 1 minuto  
✅ **Armazenamento JSON** - Múltiplas sessões no mesmo arquivo  
✅ **Background** - Continua gravando mesmo com tela desligada  
✅ **Controle Manual** - Iniciar e parar gravação com botões  
✅ **Visualização** - Dados organizados em interface intuitiva  
✅ **Estatísticas** - Velocidade máxima, distância, área coberta  

## 🎯 Começar Rápido

### 1. Clonar e Instalar
```bash
git clone <seu-repositorio>
cd gps_logger
flutter pub get
```

### 2. Executar
```bash
flutter run
```

### 3. Usar
- Abra o app
- Conceda permissão de localização
- Clique em **"Iniciar"** para começar gravação
- Clique em **"Parar"** para finalizar
- Veja dados em **"Visualizar Sessões"**

## 📱 Requisitos

- **Android:** API 21+ (Android 5.0+)
- **Flutter:** 3.11.4+
- **Dart:** 3.11.4+

## 📦 Dependências

```yaml
geolocator: ^9.0.2          # GPS
path_provider: ^2.1.1       # Armazenamento
background_fetch: ^1.1.2    # Background
wakelock_plus: ^1.2.3       # Keep screen on
intl: ^0.19.0               # Formatação
```

## 📂 Estrutura

```
lib/
├── main.dart                    # Entrada
├── models/gps_data.dart        # Modelos
├── screens/                    # UI
│   ├── home_screen.dart
│   ├── sessions_list_screen.dart
│   └── session_detail_screen.dart
└── services/                   # Lógica
    ├── gps_location_service.dart
    └── gps_storage.dart
```

## 🔐 Permissões

```xml
ACCESS_FINE_LOCATION          # GPS preciso
ACCESS_COARSE_LOCATION        # GPS por rede
WAKE_LOCK                     # Manter ativo
READ_EXTERNAL_STORAGE         # Ler arquivos
WRITE_EXTERNAL_STORAGE        # Escrever arquivos
POST_NOTIFICATIONS            # Notificações
```

## 📊 Formato de Dados

Arquivo `gps_sessions.json`:
```json
{
  "sessions": [
    {
      "session_id": "session_1715000000000",
      "start_time": "2024-05-06 14:30:00",
      "end_time": "2024-05-06 14:45:00",
      "points_count": 15,
      "points": [
        {
          "latitude": -23.550520,
          "longitude": -46.633309,
          "speed": 12.5,
          "timestamp": "2024-05-06 14:30:05"
        }
      ]
    }
  ]
}
```

## 🛠️ Build

### Versão Debug
```bash
flutter run
```

### Versão Release
```bash
flutter build apk --release
```

## 📖 Documentação Completa

- **[EXECUTIVE_SUMMARY.md](EXECUTIVE_SUMMARY.md)** - Visão geral do projeto
- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Instalação e configuração
- **[USAGE_GUIDE.md](USAGE_GUIDE.md)** - Como usar o app
- **[TESTING_GUIDE.md](TESTING_GUIDE.md)** - Testes e validações
- **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** - Detalhes técnicos
- **[DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md)** - Índice de documentação

## 🎓 Exemplos de Uso

### Rastreamento de Corrida
1. Clique "Iniciar"
2. Saia para correr
3. Clique "Parar"
4. Veja velocidade máxima e distância

### Monitoramento de Viagem
1. Clique "Iniciar" antes de sair
2. Deixe tela desligada durante o trajeto
3. Clique "Parar" ao chegar
4. Analise toda a rota

## 🚀 Próximos Passos

1. Ler [SETUP_GUIDE.md](SETUP_GUIDE.md) para instalação
2. Executar `flutter run`
3. Seguir [USAGE_GUIDE.md](USAGE_GUIDE.md) para usar
4. Consultar [TESTING_GUIDE.md](TESTING_GUIDE.md) para testar

## 🐛 Solução de Problemas

**"Permissão negada"**
→ Vá em Configurações > Aplicativos > GPS Logger > Permissões > Localização

**"Serviço de localização desabilitado"**
→ Ative GPS em Configurações > Localização

**"Sem dados sendo coletados"**
→ Saia para área aberta, aguarde 30 segundos para GPS travar

Para mais informações, veja [SETUP_GUIDE.md](SETUP_GUIDE.md) - Troubleshooting

## 📝 Licença

MIT License

## 🙌 Contribuições

Contribuições são bem-vindas! Sinta-se à vontade para:
- Reportar bugs
- Sugerir melhorias
- Enviar pull requests

---

**GPS Logger** - Rastreamento de localização simples e eficiente 📍


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
