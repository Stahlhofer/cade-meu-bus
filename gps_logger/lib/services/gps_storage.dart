import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/gps_data.dart';

class GPSJsonStorage {
  static const String fileName = 'gps_sessions.json';
  late File _file;

  Future<void> initialize() async {
    final directory = await getApplicationDocumentsDirectory();
    _file = File('${directory.path}/$fileName');
  }

  Future<File> get file async {
    if (!_file.existsSync()) {
      await _file.create(recursive: true);
      await _file.writeAsString(jsonEncode({'sessions': []}));
    }
    return _file;
  }

  Future<List<GPSSession>> getSessions() async {
    try {
      final file = await this.file;
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      final sessions = (json['sessions'] as List)
          .map((s) => GPSSession.fromJson(s as Map<String, dynamic>))
          .toList();
      return sessions;
    } catch (e) {
      return [];
    }
  }

  Future<void> addSession(GPSSession session) async {
    try {
      final file = await this.file;
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      final sessions = json['sessions'] as List;
      sessions.add(session.toJson());
      await file.writeAsString(jsonEncode(json));
    } catch (e) {
      print('Erro ao adicionar sessão: $e');
    }
  }

  Future<void> updateSession(GPSSession session) async {
    try {
      final file = await this.file;
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      final sessions = json['sessions'] as List;

      final index = sessions.indexWhere(
        (s) =>
            (s as Map<String, dynamic>)['session_id'] ==
            session.sessionId,
      );

      if (index != -1) {
        sessions[index] = session.toJson();
        await file.writeAsString(jsonEncode(json));
      }
    } catch (e) {
      print('Erro ao atualizar sessão: $e');
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
    final file = await this.file;
    return file.path;
  }

  Future<void> clear() async {
    try {
      final file = await this.file;
      await file.writeAsString(jsonEncode({'sessions': []}));
    } catch (e) {
      print('Erro ao limpar arquivo: $e');
    }
  }
}
