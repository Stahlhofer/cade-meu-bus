import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/gps_data.dart';
import 'package:path_provider/path_provider.dart';

class GPSJsonStorage {
  // static const String logsDirectoryPath = './assets/logs';

  late Directory _logsDirectory;

  Future<void> initialize() async {
    Directory appDocDirectory =
        await getApplicationDocumentsDirectory();

    _logsDirectory = Directory('${appDocDirectory.path}/assets/logs');

    if (!await _logsDirectory.exists()) {
      await _logsDirectory.create(recursive: true);
    }
  }

  Future<Directory> get logsDirectory async {
    if (!await _logsDirectory.exists()) {
      await _logsDirectory.create(recursive: true);
    }
    return _logsDirectory;
  }

  Future<File> _sessionFile(String sessionId) async {
    final directory = await logsDirectory;
    return File('${directory.path}/$sessionId.json');
  }

  Future<List<GPSSession>> getSessions() async {
    try {
      final directory = await logsDirectory;
      final files = directory
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .toList();

      final sessions = <GPSSession>[];
      debugPrint('files.length: ${files.length}');
      for (final file in files) {
        final content = await file.readAsString();

        if (content.trim().isEmpty) continue;

        final json = jsonDecode(content) as Map<String, dynamic>;

        // if (json['sessions'] is List) {
        //   sessions.addAll(
        //     (json['sessions'] as List).map(
        //       (s) => GPSSession.fromJson(s as Map<String, dynamic>),
        //     ),
        //   );
        // } else {
        // sessions.add(GPSSession.fromJson(json));
        // }

        sessions.add(GPSSession.fromJson(json));
      }

      sessions.sort((a, b) => a.startTime.compareTo(b.startTime));
      return sessions;
    } catch (e) {
      debugPrint('ERROR: $e');
      return [];
    }
  }

  Future<void> addSession(GPSSession session) async {
    try {
      final file = await _sessionFile(session.sessionId);
      await file.writeAsString(jsonEncode(session.toJson()));
    } catch (e) {
      debugPrint('Erro ao adicionar sessão: $e');
    }
  }

  Future<void> updateSession(GPSSession session) async {
    try {
      final file = await _sessionFile(session.sessionId);
      await file.writeAsString(jsonEncode(session.toJson()));
    } catch (e) {
      debugPrint('Erro ao atualizar sessão: $e');
    }
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      final file = await _sessionFile(sessionId);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Erro ao excluir sessão: $e');
    }
  }

  Future<GPSSession?> getCurrentSession() async {
    try {
      final sessions = await getSessions();
      if (sessions.isEmpty) return null;

      final currentSession = sessions.lastWhere(
        (s) => s.endTime == null,
        orElse: () =>
            GPSSession(sessionId: 'none', startTime: DateTime.now()),
      );

      return currentSession.sessionId != 'none'
          ? currentSession
          : null;
    } catch (e) {
      return null;
    }
  }

  Future<String> getFilePath() async {
    final directory = await logsDirectory;
    return directory.path;
  }

  Future<void> clear() async {
    try {
      final directory = await logsDirectory;
      final files = directory.listSync().whereType<File>().where(
        (file) => file.path.endsWith('.json'),
      );

      for (final file in files) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Erro ao limpar arquivos: $e');
    }
  }
}
