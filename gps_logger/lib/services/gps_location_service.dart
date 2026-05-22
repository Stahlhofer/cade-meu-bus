import 'dart:async';
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:gps_logger/models/bus_data.dart';
import 'package:gps_logger/models/bus_position.dart';
import 'package:gps_logger/services/mqtt_service.dart';

import '../models/gps_data.dart';
import 'gps_storage.dart';

class GPSLocationService {
  static const int updateIntervalSeconds = 60; // 1 minuto
  final GPSJsonStorage storage;
  final void Function(GPSSession session, GPSPoint point)?
  onPointRecorded;

  StreamSubscription<Position>? _positionStreamSubscription;
  GPSSession? _currentSession;
  bool _isRecording = false;

  GPSLocationService({required this.storage, this.onPointRecorded});

  bool get isRecording => _isRecording;

  GPSSession? get currentSession => _currentSession;

  final MqttService mqttService = MqttService();

  bool connected = false;

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

    try {
      await mqttService.connect();
      print(['connect', mqttService.connectionState]);
    } catch (e) {
      print("error on connect to the server $e");
    }

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
              // speed: position.speed,
              speed: 0.0,
              timestamp: DateTime.now(),
            );

            // Adiciona o ponto à sessão
            _currentSession!.points.add(gpsPoint);

            final bus = BusData(
              busCode: 'bus01',
              nome: '25 de Julho',
              city: 'panambi',
              mqttTopic: 'cade-meu-bus/panambi/bus01',
              position: BusPosition(
                timestamp: DateTime.now().toString(),
                timeUnix: DateTime.now().millisecondsSinceEpoch,
                latitude: position.latitude,
                longitude: position.longitude,
                speed: position.speed,
              ),
            );

            print(mqttService.connectionState);

            /// publica o paylod json para o broker mqtt
            if (mqttService.connectionState ==
                MqttConnectionStateCustom.idle) {
              await mqttService.connect();
            }

            if (mqttService.connectionState ==
                MqttConnectionStateCustom.connected) {
              print('PUBLISHING');
              try {
                mqttService.publish(jsonEncode(bus.toJson()));
              } catch (e) {
                print(e);
              }
            }

            // Atualiza a sessão no armazenamento
            await storage.updateSession(_currentSession!);

            onPointRecorded?.call(_currentSession!, gpsPoint);

            print(
              'GPS registrado: ${gpsPoint.latitude}, ${gpsPoint.longitude}, ${gpsPoint.speed}m/s',
            );

            print('${_currentSession!.points.length}');
          },
          onError: (error) {
            print('Erro ao receber posição: $error');
          },
        );
  }

  Future<void> stopRecording() async {
    if (!_isRecording || _currentSession == null) return;

    _isRecording = false;
    mqttService.disconnect();

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
