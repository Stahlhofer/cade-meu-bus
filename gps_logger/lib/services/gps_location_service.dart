import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../models/gps_data.dart';
import 'gps_storage.dart';

class GPSLocationService {
  static const int updateIntervalSeconds = 60; // 1 minuto
  final GPSJsonStorage storage;

  StreamSubscription<Position>? _positionStreamSubscription;
  GPSSession? _currentSession;
  bool _isRecording = false;

  GPSLocationService({required this.storage});

  bool get isRecording => _isRecording;

  GPSSession? get currentSession => _currentSession;

  Future<bool> requestLocationPermission() async {
    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<void> startRecording() async {
    if (_isRecording) return;

    // Verifica permissões
    final hasPermission = await requestLocationPermission();
    if (!hasPermission) {
      throw Exception('Permissão de localização não foi concedida');
    }

    // Verifica se o serviço de localização está habilitado
    final isEnabled = await isLocationServiceEnabled();
    if (!isEnabled) {
      throw Exception('Serviço de localização não está habilitado');
    }

    _isRecording = true;

    // Cria uma nova sessão
    final sessionId =
        'session_${DateTime.now().millisecondsSinceEpoch}';
    _currentSession = GPSSession(
      sessionId: sessionId,
      startTime: DateTime.now(),
    );

    // Adiciona a sessão ao armazenamento
    await storage.addSession(_currentSession!);

    // Inicia o stream de posição
    _positionStreamSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 0,
            timeLimit: Duration(seconds: updateIntervalSeconds),
          ),
        ).listen(
          (Position position) async {
            if (!_isRecording || _currentSession == null) return;

            // Cria um novo ponto GPS
            final gpsPoint = GPSPoint(
              latitude: position.latitude,
              longitude: position.longitude,
              speed: position.speed,
              timestamp: DateTime.now(),
            );

            // Adiciona o ponto à sessão
            _currentSession!.points.add(gpsPoint);

            // Atualiza a sessão no armazenamento
            await storage.updateSession(_currentSession!);

            print(
              'GPS registrado: ${gpsPoint.latitude}, ${gpsPoint.longitude}, ${gpsPoint.speed}m/s',
            );
          },
          onError: (error) {
            print('Erro ao receber posição: $error');
          },
        );
  }

  Future<void> stopRecording() async {
    if (!_isRecording || _currentSession == null) return;

    _isRecording = false;

    // Cancela o stream
    await _positionStreamSubscription?.cancel();

    // Finaliza a sessão
    _currentSession!.endTime = DateTime.now();

    // Atualiza a sessão no armazenamento
    await storage.updateSession(_currentSession!);

    print(
      'Gravação finalizada. Pontos registrados: ${_currentSession!.points.length}',
    );

    _currentSession = null;
  }

  Future<void> dispose() async {
    if (_isRecording) {
      await stopRecording();
    }
    await _positionStreamSubscription?.cancel();
  }
}
