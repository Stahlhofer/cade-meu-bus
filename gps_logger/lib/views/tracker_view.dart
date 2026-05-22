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

  @override
  void initState() {
    super.initState();

    controller.initialize();

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
    print("pontos ${controller.counter}");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadê Meu Bus'),
        centerTitle: true,
      ),
      floatingActionButton: loadConfigButton(context),
      body: Column(
        children: [
          /// STATUS BAR
          loadStatusBar(),

          /// MAPA
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(
                  -28.290912713706224,
                  -53.499054137856284,
                ),
                initialZoom: 15,
              ),

              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                  userAgentPackageName: 'com.example.bus_tracker',
                ),

                MarkerLayer(
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

                            child: Column(
                              children: [
                                Text(
                                  " ${bus.nome.toUpperCase()} - $vel",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: .w600,
                                  ),
                                ),
                              ],
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

  Container loadStatusBar() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),

      color: controller.connected ? Colors.green : Colors.red,

      child: Stack(
        alignment: Alignment.center,

        children: [
          /// STATUS CENTRAL
          Center(
            child: Text(
              controller.connected
                  ? 'MQTT CONNECTED'
                  : 'MQTT DISCONNECTED',

              style: const TextStyle(
                fontSize: 20,

                fontWeight: FontWeight.bold,

                color: Colors.white,
              ),
            ),
          ),

          /// INFO DIREITA
          Align(
            alignment: Alignment.centerRight,

            child: Row(
              mainAxisAlignment: .end,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,

                  crossAxisAlignment: CrossAxisAlignment.end,

                  children: [
                    Text(
                      'Pontos Enviados',

                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),

                    Text(
                      controller.counter.toString(),

                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 10),
                Column(
                  mainAxisSize: MainAxisSize.min,

                  crossAxisAlignment: CrossAxisAlignment.end,

                  children: [
                    Text(
                      'Último envio',

                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),

                    Text(
                      controller.lastTimestamp,

                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ElevatedButton loadConfigButton(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.zero),
        fixedSize: WidgetStatePropertyAll(const Size(56, 56)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),

      onPressed: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => ConfigView()),
        // );
        showDialog(
          context: context,

          builder: (_) {
            return Dialog(
              backgroundColor: Colors.white,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),

                child: SizedBox(
                  width: 400,
                  height: 343,

                  child: ConfigView(),
                ),
              ),
            );
          },
        );
      },
      child: Icon(Icons.settings_rounded, size: 30),
    );
  }
}
