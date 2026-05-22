import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../controllers/config_controller.dart';

class ConfigView extends StatefulWidget {
  const ConfigView({super.key});

  @override
  State<ConfigView> createState() => _ConfigViewState();
}

class _ConfigViewState extends State<ConfigView> {
  final controller = ConfigController();

  final nomeController = TextEditingController();

  final topicController = TextEditingController();

  String storagePath = '';

  @override
  void initState() {
    super.initState();

    initialize();
  }

  Future<void> initialize() async {
    await controller.initialize();

    final dir = await getApplicationDocumentsDirectory();

    storagePath = '${dir.path}/cade-meu-bus/logs/';

    nomeController.text = controller.nome;

    topicController.text = controller.topic;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuração')),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do ônibus',
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: topicController,
              decoration: const InputDecoration(
                labelText: 'Tópico MQTT',
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorScheme.of(
                    context,
                  ).secondary.withAlpha(100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                  elevation: 2,
                ),

                onPressed: () async {
                  await controller.save(
                    nome: nomeController.text,

                    topic: topicController.text,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Configuração salva'),
                      ),
                    );
                  }
                },

                child: const Text(
                  'SALVAR',

                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 23,

                    letterSpacing: 4,
                  ),
                ),
              ),
            ),

            /// EMPURRA INFO PARA BAIXO
            const Spacer(),

            const Divider(),

            const SizedBox(height: 8),

            Text(
              'Diretório de armazenamento JSON',

              style: TextStyle(
                fontWeight: FontWeight.bold,

                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 6),

            SelectableText(
              storagePath,

              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
