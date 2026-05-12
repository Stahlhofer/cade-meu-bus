import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../models/gps_data.dart';
import '../services/gps_location_service.dart';
import '../services/gps_storage.dart';
import 'sessions_list_screen.dart';

class HomeScreen extends StatefulWidget {
  final GPSJsonStorage storage;

  const HomeScreen({super.key, required this.storage});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GPSLocationService _locationService;
  bool _isRecording = false;
  GPSSession? _currentSession;
  String _statusMessage = 'Pronto para começar';
  String _filePath = '';
  int _pointsCount = 0;

  @override
  void initState() {
    super.initState();
    _locationService = GPSLocationService(storage: widget.storage);
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Obtém o caminho do arquivo
    _filePath = await widget.storage.getFilePath();

    // Verifica permissões
    final hasPermission = await _locationService
        .requestLocationPermission();
    if (!hasPermission) {
      setState(() {
        _statusMessage = 'Permissão de localização negada!';
      });
    }

    // Verifica se o serviço está habilitado
    final isEnabled = await _locationService
        .isLocationServiceEnabled();
    if (!isEnabled) {
      setState(() {
        _statusMessage =
            'Serviço de localização não está habilitado!';
      });
    }

    // Habilita o wake lock para manter o app ativo
    await WakelockPlus.enable();

    setState(() {
      _statusMessage = 'Pronto para começar';
    });
  }

  Future<void> _startRecording() async {
    try {
      await _locationService.startRecording();
      setState(() {
        _isRecording = true;
        _statusMessage = 'Gravação iniciada...';
        _currentSession = _locationService.currentSession;
        _pointsCount = 0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao iniciar gravação: $e')),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _locationService.stopRecording();
      setState(() {
        _isRecording = false;
        _statusMessage = 'Gravação finalizada';
        _pointsCount = _currentSession?.points.length ?? 0;
        _currentSession = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao parar gravação: $e')),
      );
    }
  }

  @override
  void dispose() {
    _locationService.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS Logger'),
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card de status
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isRecording
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _statusMessage,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Card de informações da sessão
              if (_isRecording && _currentSession != null)
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sessão Atual',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ID da Sessão:',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelSmall,
                                ),
                                Text(
                                  _currentSession!.sessionId
                                      .replaceAll('session_', ''),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Pontos Registrados:',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelSmall,
                                ),
                                Text(
                                  '${_currentSession!.points.length}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              else if (!_isRecording && _pointsCount > 0)
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Última Sessão',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Pontos registrados: $_pointsCount',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // Botões de controle
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isRecording
                          ? null
                          : _startRecording,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Iniciar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isRecording ? _stopRecording : null,
                      icon: const Icon(Icons.stop),
                      label: const Text('Parar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Botão para visualizar sessões
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          SessionsListScreen(storage: widget.storage),
                    ),
                  );
                },
                icon: const Icon(Icons.history),
                label: const Text('Visualizar Sessões'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 32),

              // Informação de arquivo
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Arquivo de Dados',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _filePath,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
