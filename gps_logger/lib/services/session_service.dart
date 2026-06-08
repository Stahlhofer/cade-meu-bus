import 'dart:async';
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../models/bus_config.dart';
import '../models/bus_data.dart';
import '../models/bus_position.dart';
import 'config_storage_service.dart';
import 'gps_service.dart';
import 'mqtt_service.dart';
import 'storage_service.dart';

class SessionService {
  final GpsService gpsService = GpsService();

  final StorageService storageService = StorageService();

  final ConfigStorageService configStorageService =
      ConfigStorageService();

  final MqttService mqttService = MqttService();

  Timer? timer;

  BusConfig? config;

  StreamController<BusData> _positionController =
      StreamController.broadcast();

  Stream<BusData> get positions => _positionController.stream;

  bool useMockData = false;

  List<BusData> mockPositions = [];

  int mockIndex = 0;

  Future<void> start({bool mock = false}) async {
    if (_positionController.isClosed) {
      _positionController = StreamController.broadcast();
    }

    useMockData = mock;

    /// CARREGA CONFIGURAÇÃO
    config = await configStorageService.loadConfig();

    if (config == null || config!.topic.isEmpty) {
      throw Exception('TOPIC NOT CONFIGURED');
    }

    /// MOCK
    if (useMockData) {
      await loadMockData();
    }
    WakelockPlus.enable();

    await mqttService.connect();

    timer = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (useMockData) {
        await sendMockPosition();
      } else {
        await captureAndSend();
      }
    });

    /// envio imediato
    if (useMockData) {
      await sendMockPosition();
    } else {
      await captureAndSend();
    }
  }

  String get fullTopic => 'cade-meu-bus/${config!.topic}';

  String get busCode {
    final parts = config!.topic.split('/');

    return parts.isNotEmpty ? parts.last : 'unknown';
  }

  String get city {
    final parts = config!.topic.split('/');

    return parts.isNotEmpty ? parts.first : 'unknown';
  }

  Future<void> captureAndSend() async {
    try {
      Position position = await gpsService.getCurrentPosition();

      final now = DateTime.now();

      final busData = BusData(
        busCode: busCode,

        nome: config!.nome,

        city: city,

        mqttTopic: fullTopic,

        position: BusPosition(
          timestamp: DateFormat('HH:mm dd-MM-yyyy').format(now),

          timeUnix: now.millisecondsSinceEpoch,

          latitude: position.latitude,

          longitude: position.longitude,

          speed: position.speed * 3.6,
        ),
      );

      /// STREAM LOCAL
      _positionController.add(busData);

      /// STORAGE
      await storageService.savePosition(busData);

      /// MQTT
      mqttService.publishJson(
        topic: fullTopic,

        json: jsonEncode(busData.toJson()),
      );

      print('PUBLISHED TO: $fullTopic');
    } catch (e) {
      print('SESSION ERROR: $e');
    }
  }

  void stop() async {
    WakelockPlus.disable();

    // cancela o loop de envio de dados
    timer?.cancel();

    // se desconecta do servidor MQTT
    mqttService.disconnect();

    _positionController.close();
  }

  Future<void> loadMockData() async {
    print('LOADING MOCK DATA ');
    final jsonString = await rootBundle.loadString(
      'assets/mock_data.json',
    );

    final List<dynamic> jsonList = jsonDecode(jsonString);

    mockPositions = jsonList.map((e) => BusData.fromJson(e)).toList();
  }

  Future<void> sendMockPosition() async {
    try {
      if (mockPositions.isEmpty) {
        print('MOCK DATA EMPTY');
        return;
      }

      /// reinicia loop
      if (mockIndex >= mockPositions.length) {
        mockIndex = 0;
      }

      final busData = mockPositions[mockIndex];

      mockIndex++;

      /// STREAM LOCAL
      _positionController.add(busData);

      /// STORAGE
      await storageService.savePosition(busData);

      /// MQTT
      mqttService.publishJson(
        topic: busData.mqttTopic,
        json: jsonEncode(busData.toJson()),
      );

      print(
        'MOCK PUBLISHED: ${busData.position.latitude}, '
        '${busData.position.longitude}',
      );
    } catch (e) {
      print('MOCK ERROR: $e');
    }
  }
}
