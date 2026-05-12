# Como Usar o GPS Logger

## Guia de Uso Prático

### 1. Iniciar o Aplicativo

```bash
flutter run
```

O app abrirá com a tela inicial mostrando:
- Status: "Pronto para começar"
- Indicador verde (não gravando)
- Botões: Iniciar, Parar, Visualizar Sessões

### 2. Conceder Permissões

Na primeira execução, o app solicitará:

1. **Permissão de Localização**
   - Selecione "Apenas durante o uso" ou "Sempre"
   - "Sempre" é recomendado para gravação em background

2. **Habilitar Serviço de Localização**
   - Se o GPS estiver desabilitado, o app pedirá para habilitá-lo
   - Acesse Configurações > Localização > GPS

### 3. Iniciar uma Sessão de Gravação

```
1. Clique no botão "Iniciar" (verde)
2. O indicador muda para vermelho
3. Status muda para "Gravação iniciada..."
4. A sessão atual é exibida com ID único
```

**O que acontece:**
- Uma nova sessão é criada com ID baseado em timestamp
- O app começa a coletar coordenadas a cada 1 minuto
- Cada ponto registra: latitude, longitude, velocidade, hora exata
- Os dados são salvos automaticamente após cada coleta

### 4. Durante a Gravação

**Você pode:**
- Andar ou dirigir normalmente
- Deixar a tela desligada (o app continua gravando)
- Abrir outros apps (gravação continua em background)
- Pedir para visualizar sessões anteriores

**O app:**
- Coleta dados a cada 1 minuto
- Atualiza o contador de "Pontos Registrados"
- Exibe status em tempo real

### 5. Parar a Sessão

```
1. Clique no botão "Parar" (vermelho)
2. O indicador muda para verde
3. Status muda para "Gravação finalizada"
4. A sessão é encerrada e salva
5. Mostra "Última Sessão" com o número de pontos
```

### 6. Visualizar Sessões Anteriores

```
1. Clique em "Visualizar Sessões"
2. Uma lista com todas as sessões será exibida
3. Cada sessão mostra:
   - Número da sessão
   - Data e hora de início
   - Número de pontos coletados
   - Status (Em gravação ou Finalizada)
```

### 7. Analisar uma Sessão

```
1. Na lista, clique em uma sessão
2. A tela de detalhes mostra:
```

**Informações Gerais:**
- ID da sessão (único)
- Horário de início e fim
- Duração em minutos
- Total de pontos coletados

**Estatísticas:**
- Velocidade máxima (m/s e km/h)
- Latitude mínima e máxima
- Longitude mínima e máxima
- Distância total aproximada em metros

**Pontos Coletados:**
- Lista completa com índice
- Hora de cada ponto
- Coordenadas (latitude/longitude)
- Velocidade no ponto (m/s e km/h)

## Exemplos de Uso

### Exemplo 1: Registrar uma Corrida

```
1. Abra o app
2. Clique "Iniciar"
3. Saia para correr
4. Após terminar, volte ao app
5. Clique "Parar"
6. Visualize a sessão para ver sua rota
```

### Exemplo 2: Monitorar Viagem de Carro

```
1. Antes de sair: Clique "Iniciar"
2. Coloque o telefone no suporte
3. Deixe a tela desligada
4. Dirija normalmente
5. Ao chegar: Clique "Parar"
6. Analise a velocidade máxima e distância
```

### Exemplo 3: Rastrear Trajeto Completo do Dia

```
1. Manhã: Clique "Iniciar"
2. Saia para trabalhar
3. Ao chegar no trabalho: Clique "Parar"
4. Tarde: Clique "Iniciar" novamente
5. Vá para outro local
6. Ao sair: Clique "Parar"
7. Visualizar Sessões mostra 2 trajetos separados
```

## Entender os Dados

### Formato de Localização

Coordenadas são exibidas em **graus decimais**:
```
Latitude: -23.550520 (negativo = sul do equador)
Longitude: -46.633309 (negativo = oeste do meridiano)
```

**Exemplo: São Paulo, Brasil**
- Latitude: -23.550520
- Longitude: -46.633309

### Velocidade

Exibida em dois formatos:
```
m/s (metros por segundo): 12.5 m/s
km/h (quilômetros por hora): 45.0 km/h

Conversão: km/h = m/s × 3.6
```

### Timestamp

Cada ponto tem dois formatos de hora:
```
Legível: "2024-05-06 14:30:05"
Unix: 1715000005000 (milissegundos desde 01/01/1970)
```

## Arquivo de Dados

### Localização

```
Caminho: /data/data/com.example.gps_logger/files/gps_sessions.json
```

Exibido na tela inicial do app.

### Estrutura JSON

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
        },
        // ... mais pontos
      ]
    },
    // ... mais sessões
  ]
}
```

### Acessar o Arquivo

**No Android (via ADB):**
```bash
adb shell
cd /data/data/com.example.gps_logger/files/
cat gps_sessions.json
```

**Via File Manager:**
- Conecte o dispositivo via USB
- Ative "Depuração USB"
- Use um file manager para acessar a pasta do app

## Dicas e Truques

### 1. Economizar Bateria
- Use a tela desligada durante o rastreamento
- Coloque o dispositivo em Modo Econômico
- Feche outros apps que usem GPS

### 2. Melhorar Precisão
- Use ao ar livre (sem obstrução de céu)
- Aguarde 30 segundos para GPS travar
- Use perto de torres de celular para melhor triangulação

### 3. Analisar Dados Posteriormemente
- Extraia o arquivo JSON
- Importe em ferramentas como:
  - Google Earth (converter para KML)
  - QGIS (análise geoespacial)
  - Python (análise de dados)

### 4. Aumentar/Diminuir Frequência
- Edite `lib/services/gps_location_service.dart`
- Altere: `static const int updateIntervalSeconds = 60;`
- Recompile: `flutter run`

## Solução de Problemas

### Problema: "Permissão negada"
**Solução:**
1. Abra Configurações > Aplicativos
2. Encontre "GPS Logger"
3. Vá em Permissões
4. Ative "Localização"
5. Selecione "Sempre" ou "Apenas durante o uso"

### Problema: "Serviço de localização desabilitado"
**Solução:**
1. Abra Configurações > Localização
2. Ative o GPS
3. Volte ao app e tente novamente

### Problema: Sem dados sendo coletados
**Solução:**
- Aguarde 1 minuto completo (intervalo de coleta)
- Saia de locais fechados (prédios, tunéis)
- Verifique se o GPS tem sinal (ícone de GPS na barra de status)
- Reinicie o app

### Problema: App congelado
**Solução:**
- Feche outros apps usando GPS/localização
- Libere memória RAM
- Reinicie o dispositivo
- Aumente o intervalo de coleta

## Próximos Passos

Após usar o GPS Logger:

1. **Exportar Dados**
   - Copie o arquivo JSON
   - Processe em programas de análise

2. **Visualizar em Mapa**
   - Converta para KML
   - Abra no Google Maps ou Google Earth

3. **Análise Estatística**
   - Use scripts Python para processar dados
   - Calcule velocidade média, tempo de parada, etc.

4. **Compartilhar Dados**
   - Envie o JSON por email
   - Sincronize com a nuvem
   - Importe em outros apps

---

**Divirta-se rastreando!** 🚀📍
