import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
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
  late LatLng? _current;
  late double _currentHeading;
  final MapController _mapController = MapController();

  @override
  void initState() {
    _markers = [];
    _currentHeading = 0;
    _current = LatLng(0, 0);
    _determinePosition().then((value) {
      _current = LatLng(value.latitude, value.longitude);
      _markers.add(_createCompassMarker());
      _moveToCurrent();
      _initCompass();
      _followPosition();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        maxZoom: 18,
        zoom: 15,
        onTap: (tapPosition, point) => _addMarker(point),
      ),
      nonRotatedChildren: [
        Positioned(
            bottom: 16.0,
            right: 16.0,
            child: IconButton(
                onPressed: _moveToCurrent,
                icon: const Icon(Icons.location_searching)))
      ],
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

  void _moveToCurrent() {
    if (_current != null) {
      _mapController.move(_current!, 15);
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  }

  Marker _createCompassMarker() {
    return Marker(
      width: 80,
      height: 80,
      point: _current!,
      builder: (context) => Transform.rotate(
        angle: (_currentHeading * (math.pi / 180)),
        child: const Icon(
          Icons.keyboard_arrow_up,
          color: Colors.blueAccent,
          size: 80,
        ),
      ),
    );
  }

  void _initCompass() {
    if (kIsWeb) return;
    if (Platform.isAndroid || Platform.isIOS) {
      FlutterCompass.events?.listen((event) {
        setState(() {
          _currentHeading = event.heading ?? 0;
        });
      });
    }
  }

  void _followPosition() {
    Geolocator.getPositionStream(
        locationSettings:
        const LocationSettings(accuracy: LocationAccuracy.high))
        .listen(
            (event) => setState(() {
              _current = LatLng(event.latitude, event.longitude);
            }));
  }
}
