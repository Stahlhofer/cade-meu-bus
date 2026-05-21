// // This is a basic Flutter widget test.
// //
// // To perform an interaction with a widget in your test, use the WidgetTester
// // utility in the flutter_test package. For example, you can send tap and scroll
// // gestures. You can also use WidgetTester to find child widgets in the widget
// // tree, read text, and verify that the values of widget properties are correct.

// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';

// import 'package:cade_meu_bus/main.dart';

// void main() {
//   testWidgets('Counter increments smoke test', (
//     WidgetTester tester,
//   ) async {
//     // Build our app and trigger a frame.
//     await tester.pumpWidget(const MyApp());

//     // Verify that our counter starts at 0.
//     expect(find.text('0'), findsOneWidget);
//     expect(find.text('1'), findsNothing);

//     // Tap the '+' icon and trigger a frame.
//     await tester.tap(find.byIcon(Icons.add));
//     await tester.pump();

//     // Verify that our counter has incremented.
//     expect(find.text('0'), findsNothing);
//     expect(find.text('1'), findsOneWidget);
//   });
// }

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

main() {
  test('conn test', () {
    MQTTClientWrapper newClient = MQTTClientWrapper();
    newClient.prepareMqttClient();
  });
}

// connection states for easy identification
enum MqttCurrentConnectionState {
  idle,
  connecting,
  connected,
  disconnected,
  errorWhenConnecting,
}

enum MqttSubscriptionState { idle, subscribe }

class MQTTClientWrapper {
  late MqttServerClient client;

  MqttCurrentConnectionState connectionState =
      MqttCurrentConnectionState.idle;
  MqttSubscriptionState subscriptionState =
      MqttSubscriptionState.idle;

  // String topic = 'cade-meu-bus/bus1';
  String topic = 'mqtt_client/testtopic';

  // using async tasks, so the connection won't hinder the code flow
  void prepareMqttClient() async {
    _setupMqttClient();
    await _connectClient();
    _subscribeToTopic(topic);
    _publishMessage('Hello');
  }

  // waiting for the connection, if an error occurs, print it and disconnect
  Future<void> _connectClient() async {
    try {
      print('client connecting....');
      connectionState = MqttCurrentConnectionState.connecting;
      client.keepAlivePeriod = 15;
      await client.connect('admin', 'AdminBus1');
    } on Exception catch (e) {
      print('client exception - $e');
      connectionState =
          MqttCurrentConnectionState.errorWhenConnecting;
      client.disconnect();
    }

    // when connected, print a confirmation, else print an error
    if (client.connectionStatus?.state ==
        MqttConnectionState.connected) {
      connectionState = MqttCurrentConnectionState.connected;
      print('client connected');
    } else {
      print(
        'ERROR client connection failed - disconnecting, status is ${client.connectionStatus}',
      );
      connectionState =
          MqttCurrentConnectionState.errorWhenConnecting;
      client.disconnect();
    }
  }

  void _setupMqttClient() {
    client = MqttServerClient.withPort(
      '674c53d176e240b28b22745ada68b842.s1.eu.hivemq.cloud',
      'admin',
      8883,
    );
    //  the next 2 lines are necessary to connect with tls, which is used by HiveMQ Cloud
    client.secure = true;
    client.securityContext = SecurityContext.defaultContext;
    client.keepAlivePeriod = 20;
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribe;
  }

  void _subscribeToTopic(String topicName) {
    print('Subscribing to the $topicName topic');
    client.subscribe(topicName, MqttQos.atMostOnce);

    // print the message when it is received
    client.updates?.listen((
      List<MqttReceivedMessage<MqttMessage>> c,
    ) {
      final MqttPublishMessage recMess =
          c[0].payload as MqttPublishMessage;
      var message = MqttPublishPayload.bytesToStringAsString(
        recMess.payload.message,
      );

      print('YOU GOT A NEW MESSAGE:');
      print(message);
    });
  }

  void _publishMessage(String message) {
    final MqttClientPayloadBuilder builder =
        MqttClientPayloadBuilder();
    builder.addString(message);

    print('Publishing message "$message" to topic $topic');
    client.publishMessage(
      topic,
      MqttQos.exactlyOnce,
      builder.payload!,
    );
  }

  // callbacks for different events
  void _onSubscribe(String topic) {
    print('Subscription confirmed for topic $topic');
    subscriptionState = MqttSubscriptionState.subscribe;
  }

  void _onDisconnected() {
    print('onDisconnected client callback - Client disconnection');
    connectionState = MqttCurrentConnectionState.disconnected;
  }

  void _onConnected() {
    connectionState = MqttCurrentConnectionState.connected;
    print(
      'OnConnected client callback - Client connection was successful',
    );
  }
}
