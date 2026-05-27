# GPS Logger - Aplicativo de Rastreamento de Localização

Um aplicativo Flutter para registrar dados de GPS (latitude, longitude, velocidade e hora) em intervalos de 1 minuto, armazenando os dados em um arquivo JSON com suporte a múltiplas sessões de gravação.

## Funcionalidades

✅ **Rastreamento de GPS em Tempo Real**
- Coleta latitude, longitude, velocidade e timestamp a cada 1 minuto
- Precisão alta de localização (LocationAccuracy.best)

✅ **Armazenamento em JSON**
- Dados persistentes em arquivo JSON estruturado
- Múltiplas sessões de rastreamento no mesmo arquivo
- Cada sessão contém: ID, horário de início/fim, lista de pontos GPS

✅ **Funcionamento em Background**
- O app continua rastreando mesmo com a tela desligada
- Wake lock mantém o dispositivo ativo durante a gravação
- Suporte para execução contínua

✅ **Controle Manual**
- Botões para iniciar e parar gravação
- Visualização de sessões anteriores
- Detalhes de cada sessão (pontos coletados, estatísticas)

✅ **Interface Intuitiva**
- Tela principal com status da gravação
- Lista de todas as sessões
- Detalhes de cada sessão com mapa de pontos
- Cálculo automático de distância percorrida

## Permissões Necessárias (Android)

O aplicativo requer as seguintes permissões:

```xml
<!-- Permissões de GPS -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- Permissões para background -->
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.WAKE_LOCK" />

<!-- Permissões para arquivo -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

<!-- Notificações (Android 13+) -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

## Instalação

### 1. Clonar o projeto
```bash
git clone <seu-repositorio>
cd gps_logger
```

### 2. Instalar dependências
```bash
flutter pub get
```

### 3. Configurar Android (Opcional - para build otimizado)
```bash
flutter pub get
flutter build apk --release
```

## Uso

### Iniciar a Aplicação
```bash
flutter run
```

### Usar o GPS Logger

1. **Permitir Permissões**
   - Ao abrir o app, conceda permissões de localização
   - Habilite o serviço de localização do dispositivo

2. **Iniciar Gravação**
   - Clique no botão **"Iniciar"**
   - O app começará a coletar dados de GPS a cada 1 minuto
   - Uma nova sessão será criada

3. **Parar Gravação**
   - Clique no botão **"Parar"**
   - A sessão será finalizada e salva

4. **Visualizar Sessões**
   - Clique em **"Visualizar Sessões"**
   - Veja todas as sessões gravadas
   - Clique em uma sessão para ver detalhes

5. **Analisar Sessão**
   - Veja estatísticas: velocidade máxima, área coberta, distância
   - Lista completa de pontos GPS com timestamp e velocidade
   - Coordenadas em formato decimal

## Estrutura de Dados JSON

O arquivo `gps_sessions.json` armazena os dados no seguinte formato:

```json
{
  "sessions": [
    {
      "session_id": "session_1715000000000",
      "start_time": "2024-05-06 14:30:00",
      "end_time": "2024-05-06 14:45:00",
      "start_unix": 1715000000000,
      "end_unix": 1715000900000,
      "points_count": 15,
      "points": [
        {
          "latitude": -23.550520,
          "longitude": -46.633309,
          "speed": 12.5,
          "timestamp": "2024-05-06 14:30:05",
          "unix_timestamp": 1715000005000
        }
      ]
    }
  ]
}
```

## Localização do Arquivo de Dados

Os dados são salvos em:
```
Android: /data/data/com.example.gps_logger/files/gps_sessions.json
```

O caminho exato é exibido na tela inicial do aplicativo.

## Dependências

- **flutter**: Framework Flutter
- **geolocator**: Acesso ao GPS do dispositivo
- **path_provider**: Localização de diretórios do aplicativo
- **wakelock_plus**: Mantém o dispositivo ativo durante gravação
- **intl**: Formatação de datas e números
- **background_fetch**: Execução em background

## Requisitos do Sistema

- **Android**: API 21+
- **Flutter**: 3.11.4+
- **Dart**: 3.11.4+

## Notas Importantes

1. **Consumo de Bateria**: O app mantém o GPS ativo e a tela do dispositivo acordada durante a gravação. Isso consome bateria significativamente.

2. **Precisão de Localização**: A precisão depende:
   - Disponibilidade de satélites GPS
   - Proximidade de torres de celular (fallback para localização por rede)
   - Condições ambientais (céu aberto vs interior)

3. **Intervalo de 1 Minuto**: O aplicativo coleta um ponto a cada 1 minuto. Para intervalos diferentes, altere a constante `updateIntervalSeconds` em `services/gps_location_service.dart`.

4. **Permissões em Tempo Real**: 
   - Android 6+: Permissões de localização devem ser concedidas em tempo real
   - O app verifica automaticamente e solicita permissões na primeira execução

## Troubleshooting

### "Permissão de localização negada"
- Vá para Configurações > Aplicativos > GPS Logger > Permissões
- Ative "Localização" com a opção "Apenas durante o uso" ou "Sempre"

### "Serviço de localização não está habilitado"
- Ative o GPS nas configurações do dispositivo
- O app mostrará uma mensagem para habilitar o GPS

### Dados não aparecem no JSON
- Verifique se o app tem permissão para acessar o local
- Certifique-se de que o GPS está habilitado
- Verifique o caminho do arquivo na tela inicial

### App fecha durante gravação
- Isso pode acontecer em dispositivos com RAM limitada
- Feche outros apps para liberar memória
- Considere aumentar o intervalo de coleta

## Desenvolvimento

### Estrutura de Arquivos

```
lib/
├── main.dart                 # Entrada principal
├── models/
│   └── gps_data.dart        # Classes de dados (GPSPoint, GPSSession)
├── screens/
│   ├── home_screen.dart     # Tela principal
│   ├── sessions_list_screen.dart  # Lista de sessões
│   └── session_detail_screen.dart # Detalhes da sessão
└── services/
    ├── gps_location_service.dart  # Serviço de GPS
    └── gps_storage.dart          # Gerenciamento de armazenamento
```

### Modificar Intervalo de Coleta

Em `lib/services/gps_location_service.dart`:
```dart
static const int updateIntervalSeconds = 60; // Altere para o valor desejado
```

## Contribuindo

Sinta-se livre para contribuir melhorias, correções de bugs ou novas funcionalidades através de pull requests.

## Licença

Este projeto é distribuído sob a licença MIT.

## Suporte

Para relatar bugs ou sugerir melhorias, abra uma issue no repositório do projeto.

---

Desenvolvido com ❤️ usando Flutter
