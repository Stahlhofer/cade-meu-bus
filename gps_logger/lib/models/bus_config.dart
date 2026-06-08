class BusConfig {
  final String nome;

  final String topic;

  BusConfig({required this.nome, required this.topic});

  factory BusConfig.empty() {
    return BusConfig(nome: '', topic: '');
  }
  factory BusConfig.basic() {
    return BusConfig(nome: 'ONIBUS 1', topic: 'panambi/bus01');
  }
  Map<String, dynamic> toJson() {
    return {'nome': nome, 'topic': topic};
  }

  factory BusConfig.fromJson(Map<String, dynamic> json) {
    return BusConfig(
      nome: json['nome'] ?? '',

      topic: json['topic'] ?? '',
    );
  }

  BusConfig copyWith({String? nome, String? topic}) {
    return BusConfig(
      nome: nome ?? this.nome,

      topic: topic ?? this.topic,
    );
  }
}
