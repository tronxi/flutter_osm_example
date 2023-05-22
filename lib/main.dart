import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("OpenStreetMap Example"),
        ),
        body: const Center(child: WidgetMap()));
  }
}

class WidgetMap extends StatefulWidget {
  const WidgetMap({Key? key}) : super(key: key);

  @override
  State<WidgetMap> createState() => _WidgetMapState();
}

class _WidgetMapState extends State<WidgetMap> {
  late final List<Marker> _markers;

  @override
  void initState() {
    _markers = [_createMarker(LatLng(39.86867330365601, -4.365601442330021))];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(39.86867330365601, -4.365601442330021),
        zoom: 15,
        onTap: (tapPosition, point) => _addMarker(point),
      ),
      children: [
        TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
        MarkerLayer(
          markers: _markers,
        )
      ],
    );
  }

  void _addMarker(LatLng point) {
    setState(() {
      _markers.add(_createMarker(point));
    });
  }

  Marker _createMarker(LatLng point) {
    return Marker(
        point: point,
        width: 80,
        height: 80,
        builder: (context) => IconButton(
            onPressed: () => print(point),
            icon: Icon(Icons.location_on_sharp,
                color: Theme.of(context).primaryColor)));
  }
}
