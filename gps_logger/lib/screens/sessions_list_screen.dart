import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    _loadSessions();
  }

  void _loadSessions() {
    _sessionsFuture = widget.storage.getSessions();
  }

  Future<void> _deleteSession(GPSSession session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir sessao?'),
        content: const Text(
          'Essa acao remove o arquivo de log desta sessao.',
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

    await widget.storage.deleteSession(session.sessionId);
    if (!mounted) return;

    setState(_loadSessions);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sessao excluida')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sessoes Gravadas'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => setState(_loadSessions),
            icon: Icon(Icons.refresh),
          ),
        ],
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
                'Erro ao carregar sessoes: ${snapshot.error}',
              ),
            );
          }

          final sessions = snapshot.data ?? [];

          if (sessions.isEmpty) {
            return const Center(
              child: Text('Nenhuma sessao gravada ainda'),
            );
          }

          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              // final startTime =
              //     '${session.startTime.day}/${session.startTime.month}/${session.startTime.year} ${session.startTime.hour}:${session.startTime.minute.toString().padLeft(2, '0')}';
              String startTime = DateFormat(
                'HH:MM:ss dd-MM-yyyy',
              ).format(session.startTime);
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
                    'Sessao ${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Inicio: $startTime'),
                      Text('Pontos: $pointsCount'),
                      if (isActive)
                        const Text(
                          'Em gravacao...',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Excluir sessao',
                        onPressed: isActive
                            ? null
                            : () => _deleteSession(session),
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red,
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
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
