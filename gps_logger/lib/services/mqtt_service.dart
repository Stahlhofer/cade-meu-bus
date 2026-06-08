import 'dart:async';
import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter/material.dart';

import '../models/bus_data.dart';

enum MqttConnectionStateCustom {
  idle,
  connecting,
  connected,
  disconnected,
  error,
}

class MqttService {
  static final MqttService _instance = MqttService._internal();

  factory MqttService() {
    return _instance;
  }

  MqttService._internal();

  bool _initialized = false;

  late MqttServerClient client;

  final String broker = const String.fromEnvironment('MQTT_URL');

  final int port = 8883;

  final String username = const String.fromEnvironment('USER');
  final String password = const String.fromEnvironment('PASSWORD');

  final String baseTopic = 'cade-meu-bus/#';

  MqttConnectionStateCustom connectionState =
      MqttConnectionStateCustom.idle;
  final StreamController<BusData> _busStreamController =
      StreamController<BusData>.broadcast();

  Stream<BusData> get busStream => _busStreamController.stream;

  MqttConnectionState get clientStatus =>
      client.connectionStatus?.state ?? MqttConnectionState.faulted;

  Future<void> connect() async {
    try {
      if (!_initialized) _setupClient();

      _initialized = true;

      debugPrint('MQTT connecting...');

      connectionState = MqttConnectionStateCustom.connecting;

      await client.connect(username, password);

      if (client.connectionStatus?.state ==
          MqttConnectionState.connected) {
        debugPrint('MQTT connected');

        connectionState = MqttConnectionStateCustom.connected;

        // _subscribeToTopic();
      } else {
        debugPrint('MQTT failed: ${client.connectionStatus}');

        connectionState = MqttConnectionStateCustom.error;

        client.disconnect();
      }
    } catch (e) {
      debugPrint('MQTT exception: $e');

      connectionState = MqttConnectionStateCustom.error;

      client.disconnect();
      throw Exception('Failed to connect to MQTT broker');
    }

    return;
  }

  void _setupClient() {
    client = MqttServerClient.withPort(
      broker,
      'gps_logger_${DateTime.now().millisecondsSinceEpoch}',
      port,
    );

    client.secure = true;

    client.securityContext = SecurityContext.defaultContext;

    client.keepAlivePeriod = 20;

    client.autoReconnect = true;

    client.logging(on: false);

    client.onConnected = _onConnected;

    client.onDisconnected = _onDisconnected;

    client.onSubscribed = _onSubscribed;

    final connMessage = MqttConnectMessage()
        .authenticateAs(username, password)
        .withClientIdentifier(
          'gps_logger_${DateTime.now().millisecondsSinceEpoch}',
        )
        .startClean();

    client.connectionMessage = connMessage;
  }

  void publishJson({required String topic, required String json}) {
    debugPrint("PUBLISHING: $topic, $json");
    final builder = MqttClientPayloadBuilder();

    builder.addString(json);
    try {
      client.publishMessage(
        topic,
        MqttQos.atLeastOnce,
        builder.payload!,
        retain: true,
      );
    } catch (e) {
      print('PUBLISH EXCEPTIOn $e');
    }
  }

  void disconnect() {
    client.disconnect();
  }

  void _onConnected() {
    debugPrint('MQTT connected callback');

    connectionState = MqttConnectionStateCustom.connected;
  }

  void _onDisconnected() {
    debugPrint('MQTT disconnected callback');

    connectionState = MqttConnectionStateCustom.disconnected;
  }

  void _onSubscribed(String topic) {
    debugPrint('Subscribed to $topic');
  }
}
