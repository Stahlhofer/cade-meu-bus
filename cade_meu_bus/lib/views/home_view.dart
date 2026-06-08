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

  double _currentZoom = 13.0;

  String? _trackedBusCode;

  void _onControllerChanged() {
    // Se estivermos com um ônibus em foco, atualiza a posição da câmera para seguir
    if (_trackedBusCode != null) {
      try {
        final bus = controller.allBuses.firstWhere(
          (b) => b.busCode == _trackedBusCode,
        );
        final point = LatLng(
          bus.position.latitude,
          bus.position.longitude,
        );
        mapController.move(point, _currentZoom);
      } catch (e) {
        // ônibus não encontrado mais -> desativa tracking
        _trackedBusCode = null;
      }
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    controller.initialize();

    controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerChanged);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CADE MEU BUS?'),
        surfaceTintColor: ColorScheme.of(context).secondary,
        centerTitle: true,
      ),

      body: Column(
        children: [
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
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: controller.getCenter(),
                    initialZoom: _currentZoom,
                    onPositionChanged: (mapPosition, hasGesture) {
                      // Se o usuário interagir manualmente com o mapa, desfoca o ônibus
                      if (hasGesture && _trackedBusCode != null) {
                        setState(() {
                          _trackedBusCode = null;
                        });
                      }
                    },
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
                        String vel =
                            "${bus.position.speed.toStringAsFixed(1)} km/h";

                        return Marker(
                          point: LatLng(
                            bus.position.latitude,
                            bus.position.longitude,
                          ),
                          width: 200,
                          height: 100,
                          rotate: true,

                          child: GestureDetector(
                            onTap: () {
                              // Alterna o tracking: se já está rastreando este ônibus, desfoca; senão, foca nele
                              if (_trackedBusCode == bus.busCode) {
                                setState(() {
                                  _trackedBusCode = null;
                                });
                                return;
                              }

                              _trackedBusCode = bus.busCode;

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

                                const Icon(
                                  Icons.directions_bus,
                                  color: Colors.blue,
                                  size: 42,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                // Controles de zoom e último registro no canto inferior direito
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        mini: true,
                        onPressed: () {
                          setState(() {
                            _currentZoom = (_currentZoom + 1).clamp(
                              1.0,
                              19.0,
                            );
                          });
                          final center = controller.getCenter();
                          mapController.move(center, _currentZoom);
                        },
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        mini: true,
                        onPressed: () {
                          setState(() {
                            _currentZoom = (_currentZoom - 1).clamp(
                              1.0,
                              19.0,
                            );
                          });
                          final center = controller.getCenter();
                          mapController.move(center, _currentZoom);
                        },
                        child: const Icon(Icons.remove),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 120,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Ultimo Registro',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              controller.lastRegister
                                  .split(' ')
                                  .first,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
