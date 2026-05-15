import 'package:flutter/material.dart';
import 'package:gps_logger/services/gps_storage.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import '../models/gps_data.dart';

class SessionDetailScreen extends StatelessWidget {
  final GPSJsonStorage storage;
  final GPSSession session;
  final void Function() onSessionDeleted;

  const SessionDetailScreen({
    super.key,
    required this.session,
    required this.storage,
    required this.onSessionDeleted,
  });

  Future<void> _deleteSession(
    GPSSession session,
    BuildContext context,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir sessão?'),
        content: const Text(
          'Essa ação remove o arquivo de log desta sessão.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await storage.deleteSession(session.sessionId);
    // if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    final startTime = DateFormat(
      'dd/MM/yyyy HH:mm:ss',
    ).format(session.startTime);
    final endTime = session.endTime != null
        ? DateFormat('dd/MM/yyyy HH:mm:ss').format(session.endTime!)
        : 'Em gravação';
    final duration = session.endTime != null
        ? session.endTime!.difference(session.startTime).inMinutes
        : DateTime.now().difference(session.startTime).inMinutes;

    double minLat = session.points.isNotEmpty
        ? session.points.first.latitude
        : 0;
    double maxLat = minLat;
    double minLon = session.points.isNotEmpty
        ? session.points.first.longitude
        : 0;
    double maxLon = minLon;
    double maxSpeed = 0;
    double totalDistance = 0;

    for (final point in session.points) {
      minLat = point.latitude < minLat ? point.latitude : minLat;
      maxLat = point.latitude > maxLat ? point.latitude : maxLat;
      minLon = point.longitude < minLon ? point.longitude : minLon;
      maxLon = point.longitude > maxLon ? point.longitude : maxLon;
      maxSpeed = point.speed > maxSpeed ? point.speed : maxSpeed;
    }

    // Calcula distância aproximada entre pontos
    for (int i = 1; i < session.points.length; i++) {
      final p1 = session.points[i - 1];
      final p2 = session.points[i];
      final distance = _calculateDistance(
        p1.latitude,
        p1.longitude,
        p2.latitude,
        p2.longitude,
      );
      totalDistance += distance;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Sessão'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Excluir sessão',
            onPressed: () async {
              await _deleteSession(session, context);
              onSessionDeleted.call();
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.delete_outline),
            color: Colors.red,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card de informações gerais
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informações da Sessão',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _InfoRow('ID:', session.sessionId),
                      _InfoRow('Início:', startTime),
                      _InfoRow('Fim:', endTime),
                      _InfoRow('Duração:', '$duration minutos'),
                      _InfoRow(
                        'Pontos Registrados:',
                        '${session.points.length}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Card de estatísticas
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estatísticas',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(
                        'Velocidade Máxima:',
                        '${maxSpeed.toStringAsFixed(2)} m/s (${(maxSpeed * 3.6).toStringAsFixed(2)} km/h)',
                      ),
                      _InfoRow(
                        'Latitude Mín:',
                        minLat.toStringAsFixed(6),
                      ),
                      _InfoRow(
                        'Latitude Máx:',
                        maxLat.toStringAsFixed(6),
                      ),
                      _InfoRow(
                        'Longitude Mín:',
                        minLon.toStringAsFixed(6),
                      ),
                      _InfoRow(
                        'Longitude Máx:',
                        maxLon.toStringAsFixed(6),
                      ),
                      _InfoRow(
                        'Distância Aproximada:',
                        '${(totalDistance * 1000).toStringAsFixed(2)} metros',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Lista de pontos
              Text(
                'Pontos Coletados (${session.points.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              session.points.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Nenhum ponto coletado'),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: session.points.length,
                      itemBuilder: (context, index) {
                        final point = session.points[index];
                        final time = DateFormat(
                          'HH:mm:ss',
                        ).format(point.timestamp);
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Ponto ${index + 1}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      time,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Lat: ${point.latitude.toStringAsFixed(6)} | Lon: ${point.longitude.toStringAsFixed(6)}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall,
                                ),
                                Text(
                                  'Velocidade: ${point.speed.toStringAsFixed(2)} m/s (${(point.speed * 3.6).toStringAsFixed(2)} km/h)',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.blue),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Fórmula de Haversine para calcular distância entre dois pontos GPS
    const earthRadius = 6371000; // raio da Terra em metros

    final cosLat1 = cos(_toRad(lat1));
    final cosLat2 = cos(_toRad(lat2));
    final dLatDiv2 = _toRad(lat2 - lat1) / 2;
    final dLonDiv2 = _toRad(lon2 - lon1) / 2;

    final sinDLatDiv2 = sin(dLatDiv2);
    final sinDLonDiv2 = sin(dLonDiv2);

    final a =
        (sinDLatDiv2 * sinDLatDiv2) +
        (sinDLonDiv2 * sinDLonDiv2 * cosLat1 * cosLat2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRad(double deg) {
    return deg * pi / 180;
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
