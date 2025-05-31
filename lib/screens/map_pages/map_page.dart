import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentLatLng;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndFetchLocation();
  }

  Future<void> _checkPermissionAndFetchLocation() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentLatLng = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    } else {
      openAppSettings();
    }
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _currentLatLng = position.target;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Pick a Location")),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLatLng!,
              zoom: 16,
            ),
            myLocationEnabled: true,
            onMapCreated: (controller) => _controller.complete(controller),
            onCameraMove: _onCameraMove,
          ),
          const Icon(Icons.location_pin, size: 40, color: Colors.red),
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _currentLatLng);
              },
              child: const Text("Select This Location"),
            ),
          ),
        ],
      ),
    );
  }
}
