import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gps_logger/models/bus_data.dart';
import 'package:gps_logger/models/bus_position.dart';
import 'package:gps_logger/services/mqtt_service.dart';

void main() {
  test('description', () async {
    final MqttService mqtt = MqttService();
    try {
      await mqtt.connect();

      final bus = BusData(
        busCode: 'bus01',
        nome: '25 de Julho',
        city: 'panambi',
        mqttTopic: 'cade-meu-bus/panambi/bus01',
        position: BusPosition(
          timestamp: DateTime.now().toString(),
          timeUnix: DateTime.now().millisecondsSinceEpoch,
          latitude: 29.0,
          longitude: 29.0,
          speed: 0.0,
        ),
      );

      mqtt.publishJson(
        topic: bus.mqttTopic,
        json: jsonEncode(bus.toJson()),
      );
    } catch (e) {
      print(e);
    }
  });
}
