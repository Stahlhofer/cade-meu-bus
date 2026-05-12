import 'package:flutter/material.dart';

import '../models/gps_data.dart';
import '../services/gps_storage.dart';
import 'session_detail_screen.dart';

class SessionsListScreen extends StatefulWidget {
  final GPSJsonStorage storage;

  const SessionsListScreen({super.key, required this.storage});

  @override
  State<SessionsListScreen> createState() =>
      _SessionsListScreenState();
}

class _SessionsListScreenState extends State<SessionsListScreen> {
  late Future<List<GPSSession>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = widget.storage.getSessions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sessões Gravadas'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<GPSSession>>(
        future: _sessionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar sessões: ${snapshot.error}',
              ),
            );
          }

          final sessions = snapshot.data ?? [];

          if (sessions.isEmpty) {
            return const Center(
              child: Text('Nenhuma sessão gravada ainda'),
            );
          }

          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              final startTime =
                  '${session.startTime.day}/${session.startTime.month}/${session.startTime.year} ${session.startTime.hour}:${session.startTime.minute.toString().padLeft(2, '0')}';
              final pointsCount = session.points.length;
              final isActive = session.endTime == null;

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? Colors.red[100]
                          : Colors.green[100],
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.red : Colors.green,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    'Sessão ${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Início: $startTime'),
                      Text('Pontos: $pointsCount'),
                      if (isActive)
                        const Text(
                          'Em gravação...',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).primaryColor,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            SessionDetailScreen(session: session),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
