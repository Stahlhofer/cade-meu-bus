import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/bus_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final BusController controller = BusController();

  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();

    controller.initialize();

    // WidgetsBinding.instance.addPostFrameCallback((_) {});
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.removeListener(() {});
    super.dispose();
  }

  // todo - implementar logica de validação
  /// o aplicativo deve realizar uma pequena validação dos dados de ônibus recebidos
  /// visto que atualmente, um novo ônibus é adicionado a cada novo codigo de pacote
  /// mesmo que seja informado apenas 1 pacote.
  ///
  /// O aplicativo deve validar e remover cadastros inválidos, ou que estejam inativos por um determinado período
  // todo - implementar botão de centralização fixada em ônibus, baseado no toque do icone.
  /// a visualização do mapa pode ficar fixa em um determinado ônibus, sendo necessário apenas apertar sobre o icone
  /// do onibus, mas a ainda deve permitir navegar, aumentar ou diminuir zoom, etc
  // todo - implementar direção fixa do icone do onibus para o topo da tela

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CADE MEU BUS?'),
        surfaceTintColor: ColorScheme.of(context).secondary,
        centerTitle: true,
      ),
      floatingActionButton: Container(
        width: 120,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Text('Ultimo Registro', style: TextStyle(fontSize: 15)),
            Text(
              controller.lastRegister.split(' ').first,
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: controller.connected ? Colors.green : Colors.red,
            child: Center(
              child: Text(
                controller.connected
                    ? 'SERVIDOR CONECTADO'
                    : 'SERVIDOR DESCONECTADO',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: controller.getCenter(),
                initialZoom: 13,
              ),
              children: [
                /// MAPA
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.cade-meu-bus',
                ),

                /// ÔNIBUS
                MarkerLayer(
                  markers: controller.allBuses.map((bus) {
                    return Marker(
                      point: LatLng(
                        bus.position.latitude,
                        bus.position.longitude,
                      ),
                      width: 200,
                      height: 100,
                      rotate: true,

                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "${bus.nome} - ${bus.position.speed} km/h",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),

                          const Icon(
                            Icons.directions_bus,
                            color: Colors.blue,
                            size: 42,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
