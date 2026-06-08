import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:gps_logger/views/config_view.dart';

import 'package:latlong2/latlong.dart';

import '../controllers/tracker_controller.dart';

class TrackerView extends StatefulWidget {
  const TrackerView({super.key});

  @override
  State<TrackerView> createState() => _TrackerViewState();
}

class _TrackerViewState extends State<TrackerView> {
  TrackerController controller = TrackerController();

  final MapController mapController = MapController();

  double _currentZoom = 13.0;

  void _onControllerChanged() {
    print("CALLER CONTROLLER CHANGE");
    // Se estivermos com um ônibus em foco, atualiza a posição da câmera para seguir
    final bus = controller.allBuses.firstOrNull;

    if (bus != null) {
      final point = LatLng(
        bus.position.latitude,
        bus.position.longitude,
      );

      try {
        mapController.move(point, _currentZoom);
      } catch (e) {
        // ônibus não encontrado mais -> desativa tracking
        print(e);
      }
    }

    setState(() {});
  }

  @override
  void initState() {
    controller.initialize();

    controller.addListener(_onControllerChanged);

    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerChanged);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("simulando? ${controller.simulation}");
    print("pontos enviados ${controller.counter}");

    return Scaffold(
      appBar: AppBar(
        title: const Text('LOGGER - CADÊ MEU BUS?'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      ConfigView(trackerController: controller),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: _buildSessionFAB(),
      body: Column(
        children: [
          /// STATUS BAR - Apenas conexão MQTT
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            color: controller.connected ? Colors.green : Colors.red,
            child: Center(
              child: Text(
                controller.connected
                    ? 'SERVIDOR CONECTADO'
                    : 'SERVIDOR DESCONECTADO',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          /// MAPA
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: controller.getCenter(),
                    initialZoom: _currentZoom,
                    onPositionChanged: (mapPosition, hasGesture) {
                      // // Se o usuário interagir manualmente com o mapa, desfoca o ônibus
                      // if (hasGesture && _trackedBusCode != null) {
                      //   setState(() {
                      //     _trackedBusCode = null;
                      //   });
                      // }
                    },
                    interactionOptions: const InteractionOptions(
                      // conjunto de bits
                      // .all obtém o codigo de todos (todos os bits em 1)
                      // "~" .rotate obtém o codigo inverso (bit em 0)
                      // "&" converge os bits de .all e ~.rotate num unico conjunto, ativando todas as opções menos o rotate
                      // flags:
                      //     InteractiveFlag.all &
                      //     ~InteractiveFlag.rotate,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.bus_tracker',
                    ),
                    MarkerLayer(
                      rotate: true,
                      markers: controller.buses.values.map((bus) {
                        String vel =
                            "${bus.position.speed.toStringAsFixed(1)} km/h";

                        return Marker(
                          point: LatLng(
                            bus.position.latitude,
                            bus.position.longitude,
                          ),
                          width: 200,
                          height: 120,
                          child: GestureDetector(
                            onTap: () {
                              // Alterna o tracking: se já está rastreando este ônibus, desfoca; senão, foca nele

                              final point = LatLng(
                                bus.position.latitude,
                                bus.position.longitude,
                              );

                              final targetZoom = _currentZoom < 13.0
                                  ? 13.0
                                  : _currentZoom;
                              _currentZoom = targetZoom;

                              mapController.move(point, targetZoom);

                              setState(() {});
                            },
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    " ${bus.nome.toUpperCase()} - $vel",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: .w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Icon(
                                  Icons.directions_bus,
                                  size: 48,
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                /// Informações no topo superior direito
                loadTrackInfo(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget loadTrackInfo() {
    // if (!controller.sessionActive) return SizedBox.shrink();
    return Positioned(
      top: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!controller.sessionActive)
              SizedBox.shrink()
            else ...[
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Pontos Enviados',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    controller.counter.toString(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
            ],
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Último envio',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                  ),
                ),
                Text(
                  controller.lastTimestamp,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionFAB() {
    final isBlocked = controller.sessionBlocked;

    return Column(
      mainAxisSize: .min,
      children: [
        FloatingActionButton(
          heroTag: 'ADD',
          mini: true,
          onPressed: () {
            setState(() {
              _currentZoom = (_currentZoom + 1).clamp(1.0, 19.0);
            });
            final center = controller.getCenter();
            mapController.move(center, _currentZoom);
          },
          child: const Icon(Icons.add),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'SUB',
          mini: true,

          onPressed: () {
            setState(() {
              _currentZoom = (_currentZoom - 1).clamp(1.0, 19.0);
            });
            final center = controller.getCenter();
            mapController.move(center, _currentZoom);
          },
          child: const Icon(Icons.remove),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          onPressed: isBlocked
              ? null
              : (controller.sessionActive
                    ? () => controller.stopSession()
                    : () async {
                        try {
                          await controller.startSession();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.redAccent,
                              content: Center(
                                child: Text(
                                  'Falha de conexão com o servidor.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      }),
          backgroundColor: isBlocked
              ? Colors.grey
              : (controller.sessionActive
                    ? Colors.red
                    : Colors.green),
          disabledElevation: 0,
          elevation: isBlocked ? 0 : 6,
          child: Icon(
            isBlocked
                ? Icons.lock_clock
                : (controller.sessionActive
                      ? Icons.stop
                      : Icons.play_arrow),
            size: 28,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
