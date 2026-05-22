import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gps_logger/controllers/bus_controller.dart';
import 'package:latlong2/latlong.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CADE MEU BUS?'),
        surfaceTintColor: ColorScheme.of(context).secondary,
        centerTitle: true,
      ),
      floatingActionButton: Column(),
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
