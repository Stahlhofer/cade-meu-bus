import 'bus_position.dart';

class BusData {
  final String busCode;

  final String nome;

  final String city;

  final String mqttTopic;

  final BusPosition position;

  BusData({
    required this.busCode,
    required this.nome,
    required this.city,
    required this.mqttTopic,
    required this.position,
  });

  factory BusData.fromJson(Map<String, dynamic> json) {
    return BusData(
      busCode: json['busCode'] ?? 'ERROR',

      nome: json['nome'] ?? 'ERROR',

      city: json['city'] ?? '',

      mqttTopic: json['mqttTopic'] ?? '',

      position: BusPosition.fromJson(json['position']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'busCode': busCode,
      'nome': nome,
      'city': city,
      'mqttTopic': mqttTopic,
      'position': position.toJson(),
    };
  }
}
