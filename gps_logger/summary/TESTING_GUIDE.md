# Guia de Testes - GPS Logger

## 🧪 Como Testar o GPS Logger

Este guia descreve como testar todas as funcionalidades do aplicativo.

---

## 1️⃣ Teste Inicial: Instalação e Permissões

### Passo 1: Build do App
```bash
cd c:\projetos\gps_logger
flutter clean
flutter pub get
flutter run
```

### Passo 2: Verificar Interface
- [ ] App abre sem erros
- [ ] Tela inicial exibe: "GPS Logger" no AppBar
- [ ] Botões "Iniciar" e "Parar" aparecem
- [ ] Status mostra "Pronto para começar"

### Passo 3: Solicitar Permissões
- [ ] App solicita permissão de localização
- [ ] Conceda "Sempre" ou "Apenas durante o uso"
- [ ] Status atualiza corretamente

### Passo 4: Verificar Localização
- [ ] Se GPS estiver desabilitado, app mostra mensagem
- [ ] Habilite GPS em Configurações
- [ ] App mostra "Pronto para começar"

---

## 2️⃣ Teste Funcional: Gravação Básica

### Cenário: Primeira Sessão

```
Tempo Total Estimado: 5 minutos
```

**Passo 1:** Abrir o app

**Passo 2:** Clicar em "Iniciar"
- [ ] Botão "Iniciar" fica desabilitado
- [ ] Botão "Parar" fica habilitado
- [ ] Status muda para "Gravação iniciada..."
- [ ] Indicador muda para vermelho
- [ ] Card "Sessão Atual" aparece

**Passo 3:** Esperar 2 minutos
- [ ] Contador de "Pontos Registrados" aumenta
- [ ] Pontos aumentam a cada 1 minuto (ou menos se GPS responder mais rápido)
- [ ] App não trava

**Passo 4:** Clicar em "Parar"
- [ ] Botão "Parar" fica desabilitado
- [ ] Botão "Iniciar" fica habilitado
- [ ] Status muda para "Gravação finalizada"
- [ ] Indicador muda para verde
- [ ] Mostra "Última Sessão" com número de pontos

**Esperado:**
- Pelo menos 2 pontos registrados
- Dados salvos automaticamente

---

## 3️⃣ Teste de Background: Tela Desligada

### Cenário: Gravação com Tela Desligada

```
Tempo Total Estimado: 3 minutos
```

**Passo 1:** Iniciar gravação (como no teste anterior)

**Passo 2:** Desligar a tela (botão power)
- [ ] App continua rodando em background
- [ ] GPS continua coletando

**Passo 3:** Aguardar 2 minutos com tela desligada

**Passo 4:** Ligar a tela
- [ ] Pontos continuaram sendo coletados
- [ ] Contador aumentou

**Passo 5:** Parar gravação

**Esperado:**
- Dados coletados mesmo com tela desligada
- Wake lock funcionando corretamente

---

## 4️⃣ Teste de Múltiplas Sessões

### Cenário: Múltiplas Gravações

```
Tempo Total Estimado: 10 minutos
```

**Primeira Sessão:**
- [ ] Clique "Iniciar"
- [ ] Aguarde 2 minutos
- [ ] Clique "Parar"
- [ ] Anote o número de pontos

**Segunda Sessão:**
- [ ] Clique "Iniciar"
- [ ] Aguarde 2 minutos
- [ ] Clique "Parar"

**Terceira Sessão:**
- [ ] Clique "Iniciar"
- [ ] Aguarde 1 minuto
- [ ] Clique "Parar"

**Verificação:**
- [ ] Clique "Visualizar Sessões"
- [ ] Aparecem 3 sessões na lista
- [ ] Cada uma mostra data, hora e número de pontos
- [ ] IDs são diferentes

**Esperado:**
- 3 sessões separadas no mesmo arquivo JSON
- Dados de todas as sessões preservados

---

## 5️⃣ Teste de Visualização de Detalhes

### Cenário: Explorar Detalhes de uma Sessão

**Passo 1:** Em "Visualizar Sessões", clique em qualquer sessão

**Passo 2:** Verificar "Informações da Sessão"
- [ ] ID exibido corretamente
- [ ] Início e fim mostram datas/horas
- [ ] Duração calculada corretamente
- [ ] Contagem de pontos correta

**Passo 3:** Verificar "Estatísticas"
- [ ] Velocidade máxima exibida em m/s e km/h
- [ ] Latitude mínima e máxima mostradas
- [ ] Longitude mínima e máxima mostradas
- [ ] Distância aproximada calculada

**Passo 4:** Verificar "Pontos Coletados"
- [ ] Lista completa de pontos
- [ ] Cada ponto mostra:
  - [ ] Número do ponto
  - [ ] Hora exata
  - [ ] Latitude/Longitude
  - [ ] Velocidade em m/s e km/h

**Esperado:**
- Todas as informações são precisas
- Cálculos estão corretos
- Interface responde rapidamente

---

## 6️⃣ Teste de Dados JSON

### Cenário: Verificar Arquivo JSON

**Passo 1:** Conectar dispositivo via USB

**Passo 2:** Ativar Debug USB em Desenvolvimento

**Passo 3:** Abrir File Manager (ou usar ADB)
```bash
adb shell
cd /data/data/com.example.gps_logger/files/
ls -la
cat gps_sessions.json
```

**Verificações:**
- [ ] Arquivo `gps_sessions.json` existe
- [ ] Conteúdo é JSON válido
- [ ] Contém array "sessions"
- [ ] Cada sessão tem os campos corretos
- [ ] Cada ponto tem os campos corretos

**Estrutura Esperada:**
```json
{
  "sessions": [
    {
      "session_id": "session_[timestamp]",
      "start_time": "YYYY-MM-DD HH:mm:ss",
      "end_time": "YYYY-MM-DD HH:mm:ss",
      "start_unix": [número],
      "end_unix": [número],
      "points_count": [número],
      "points": [...]
    }
  ]
}
```

---

## 7️⃣ Teste de Permissões

### Cenário: Negar e Permitir Permissões

**Passo 1:** Remover permissões
- Configurações > Aplicativos > GPS Logger > Permissões
- Desative "Localização"

**Passo 2:** Abrir o app
- [ ] App mostra "Permissão de localização negada!"
- [ ] Status não muda

**Passo 3:** Tentar clicar "Iniciar"
- [ ] Mostra mensagem de erro ou solicita permissão

**Passo 4:** Reabilitar permissão
- [ ] Volte a Configurações
- [ ] Ative "Localização"

**Passo 5:** Voltar ao app
- [ ] Status muda para "Pronto para começar"
- [ ] App funciona normalmente

**Esperado:**
- App não funciona sem permissão
- Mensagens claras ao usuário
- Funciona após conceder permissão

---

## 8️⃣ Teste de Erros

### Cenário 1: GPS Desabilitado

**Passo 1:** Desabilitar GPS
- Configurações > Localização > Desabilitado

**Passo 2:** Abrir o app
- [ ] Mostra "Serviço de localização não está habilitado!"

**Passo 3:** Clicar "Iniciar"
- [ ] Mostra erro indicando GPS desabilitado

**Passo 4:** Habilitar GPS
- [ ] Mostra "Pronto para começar"

### Cenário 2: Sem Sinal GPS

**Passo 1:** Abrir app dentro de um prédio

**Passo 2:** Iniciar gravação
- [ ] App não crasheia
- [ ] Continua tentando coletar

**Passo 3:** Sair para área aberta
- [ ] Após ~30 segundos, pontos começam a aparecer

**Passo 4:** Parar gravação
- [ ] Se nenhum ponto foi coletado, aceitar gracefully

**Esperado:**
- App não trava em situações de erro
- Mensagens úteis ao usuário
- Recuperação automática quando GPS disponível

---

## 9️⃣ Teste de Performance

### Cenário: Gravação Longa

**Passo 1:** Iniciar gravação

**Passo 2:** Deixar rodando por 10+ minutos
- [ ] App continua respondendo
- [ ] Sem lag na interface
- [ ] Sem memory leaks
- [ ] Tela não congela

**Passo 3:** Parar e visualizar
- [ ] Dados carregam rapidamente
- [ ] Lista de pontos scrollável
- [ ] App não trava

**Esperado:**
- App mantém performance com muitos pontos
- Interface responsiva o tempo todo

---

## 🔟 Teste de Edição de Código

### Cenário: Alterar Intervalo de Coleta

**Passo 1:** Editar `lib/services/gps_location_service.dart`
```dart
static const int updateIntervalSeconds = 30; // Altere de 60 para 30
```

**Passo 2:** Hot reload
```
Pressione 'r' no terminal Flutter
```

**Passo 3:** Testar com novo intervalo
- [ ] Pontos coletados a cada 30 segundos
- [ ] Mais rápido que antes

**Passo 4:** Reverter para 60 segundos
- [ ] Hot reload
- [ ] Volta a coletar a cada 60 segundos

**Esperado:**
- Hot reload funciona
- Mudanças aplicadas corretamente

---

## 📋 Checklist de Testes

Marque cada teste como concluído:

### Testes Básicos
- [ ] Teste 1: Instalação e Permissões ✅
- [ ] Teste 2: Gravação Básica ✅
- [ ] Teste 3: Background ✅
- [ ] Teste 4: Múltiplas Sessões ✅
- [ ] Teste 5: Visualização ✅
- [ ] Teste 6: JSON ✅
- [ ] Teste 7: Permissões ✅

### Testes Avançados
- [ ] Teste 8: Tratamento de Erros ✅
- [ ] Teste 9: Performance ✅
- [ ] Teste 10: Edição de Código ✅

---

## 🐛 Relatório de Bugs

Se encontrar algum problema durante os testes, documumente:

**Template:**
```
### Bug: [Título]
- **Como Reproduzir:** [Passos]
- **Resultado Esperado:** [O que deveria acontecer]
- **Resultado Obtido:** [O que aconteceu]
- **Dispositivo/SDK:** [Modelo e Android version]
- **Screenshot:** [Se aplicável]
```

---

## ✅ Conclusão dos Testes

Se todos os 10 testes forem bem-sucedidos, o aplicativo está pronto para:
- Uso em produção
- Distribuição na Google Play Store
- Compartilhamento com outros usuários

---

**Bom teste!** 🚀🧪✨
