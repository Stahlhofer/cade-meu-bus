import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/bus_data.dart';

class StorageService {
  Future<void> savePosition(BusData data) async {
    final permission = await Permission.storage.request();

    if (permission.isDenied) return;

    final directory = await getApplicationDocumentsDirectory();

    String timeUnix = DateTime.now().millisecondsSinceEpoch
        .toString()
        .substring(7);

    final file = File(
      '${directory.path}/cade-meu-bus/logs/gps_history_$timeUnix.json',
    );

    List<dynamic> existing = [];

    if (!await file.exists()) {
      file.createSync(recursive: true);
    }
    if (await file.exists()) {
      final content = await file.readAsString();

      if (content.isNotEmpty) {
        existing = jsonDecode(content);
      }
    }

    existing.add(data.toJson());

    await file.writeAsString(jsonEncode(existing));
  }
}
