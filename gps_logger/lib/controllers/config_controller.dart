import 'package:flutter/material.dart';

import '../models/bus_config.dart';

import '../services/config_storage_service.dart';

class ConfigController extends ChangeNotifier {
  final ConfigStorageService storageService = ConfigStorageService();

  BusConfig config = BusConfig.empty();

  bool loaded = false;

  Future<void> initialize() async {
    config = await storageService.loadConfig();

    loaded = true;

    notifyListeners();
  }

  Future<void> save({
    required String nome,
    required String topic,
  }) async {
    config = BusConfig(nome: nome, topic: topic);

    await storageService.saveConfig(config);

    notifyListeners();
  }

  String get nome => config.nome;

  String get topic => config.topic;

  bool get hasConfig => nome.isNotEmpty && topic.isNotEmpty;
}
