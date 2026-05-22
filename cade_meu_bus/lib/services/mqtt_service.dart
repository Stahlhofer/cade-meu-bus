import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../models/bus_data.dart';

enum MqttConnectionStateCustom {
  idle,
  connecting,
  connected,
  disconnected,
  error,
}

class MqttService {
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

  Future<void> connect() async {
    print('connet begin');
    _setupClient();

    try {
      print('MQTT connecting... broker $broker');

      connectionState = MqttConnectionStateCustom.connecting;

      await client.connect(username, password);

      if (client.connectionStatus?.state ==
          MqttConnectionState.connected) {
        print('MQTT connected');

        connectionState = MqttConnectionStateCustom.connected;

        _subscribeToTopic();
      } else {
        print('MQTT failed: ${client.connectionStatus}');

        connectionState = MqttConnectionStateCustom.error;

        client.disconnect();
      }
    } catch (e) {
      print('MQTT exception: $e');

      connectionState = MqttConnectionStateCustom.error;

      client.disconnect();
      throw Exception('Failed to connect to MQTT broker');
    }
  }

  void _setupClient() {
    print('setup');

    // client = MqttServerClient.withPort(broker, 'cade-meu-bus', port);
    client = MqttServerClient.withPort(
      broker,
      'cade_meu_bus_${DateTime.now().millisecondsSinceEpoch}',
      port,
    );

    client.secure = true;

    client.securityContext = SecurityContext.defaultContext;

    client.keepAlivePeriod = 20;

    // client.autoReconnect = true;

    client.logging(on: false);

    client.onConnected = _onConnected;

    client.onDisconnected = _onDisconnected;

    client.onSubscribed = _onSubscribed;

    final connMessage = MqttConnectMessage()
        .authenticateAs(username, password)
        .withClientIdentifier(
          'flutter_bus_tracker_${DateTime.now().millisecondsSinceEpoch}',
        )
        .startClean();

    client.connectionMessage = connMessage;
  }

  void _subscribeToTopic() {
    print('Subscribing topic: $baseTopic');

    client.subscribe(baseTopic, MqttQos.atMostOnce);

    client.updates?.listen((
      List<MqttReceivedMessage<MqttMessage>> events,
    ) {
      print('event');
      try {
        final receivedMessage = events[0];

        final MqttPublishMessage message =
            receivedMessage.payload as MqttPublishMessage;

        final String payload =
            MqttPublishPayload.bytesToStringAsString(
              message.payload.message,
            );

        final String topic = receivedMessage.topic;

        print('TOPIC: $topic');
        print('PAYLOAD: $payload');

        final Map<String, dynamic> json = jsonDecode(payload);

        final BusData busData = BusData.fromJson(json);

        _busStreamController.add(busData);
      } catch (e) {
        print('MQTT PARSE ERROR: $e');
      }
    });
  }

  void publish(String message) {
    final builder = MqttClientPayloadBuilder();

    builder.addString(message);

    client.publishMessage(
      baseTopic,
      MqttQos.atLeastOnce,
      builder.payload!,
    );
  }

  void disconnect() {
    client.disconnect();
  }

  void _onConnected() {
    print('MQTT connected callback');

    connectionState = MqttConnectionStateCustom.connected;
  }

  void _onDisconnected() {
    print('MQTT disconnected callback');

    connectionState = MqttConnectionStateCustom.disconnected;
  }

  void _onSubscribed(String topic) async {
    // client.updates.connectionState;
    print('Subscribed to $topic');
  }
}
