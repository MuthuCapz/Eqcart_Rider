import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderMapPage extends StatefulWidget {
  final String shippingAddress;

  const OrderMapPage({super.key, required this.shippingAddress});

  @override
  State<OrderMapPage> createState() => _OrderMapPageState();
}

class _OrderMapPageState extends State<OrderMapPage> {
  late GoogleMapController _mapController;
  LatLng? _currentLocation;
  LatLng? _destination;
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initMapData();
  }

  Future<void> _initMapData() async {
    await _getCurrentLocation();
    await _getDestinationLatLng(widget.shippingAddress);
    if (_currentLocation != null && _destination != null) {
      _addMarkers();
      _setMapBounds();
      _getDirections();
    }
  }

  Future<void> _getCurrentLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }
    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation = LatLng(pos.latitude, pos.longitude);
    });
  }

  Future<void> _getDestinationLatLng(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        setState(() {
          _destination = LatLng(locations[0].latitude, locations[0].longitude);
        });
      }
    } catch (e) {
      print("Error getting destination: $e");
    }
  }

  void _addMarkers() {
    _markers.addAll([
      Marker(
        markerId: const MarkerId("rider"),
        position: _currentLocation!,
        infoWindow: const InfoWindow(title: "Your Location"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
      Marker(
        markerId: const MarkerId("destination"),
        position: _destination!,
        infoWindow: const InfoWindow(title: "Shipping Address"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    ]);
  }

  void _setMapBounds() {
    final bounds = LatLngBounds(
      southwest: LatLng(
        _currentLocation!.latitude < _destination!.latitude
            ? _currentLocation!.latitude
            : _destination!.latitude,
        _currentLocation!.longitude < _destination!.longitude
            ? _currentLocation!.longitude
            : _destination!.longitude,
      ),
      northeast: LatLng(
        _currentLocation!.latitude > _destination!.latitude
            ? _currentLocation!.latitude
            : _destination!.latitude,
        _currentLocation!.longitude > _destination!.longitude
            ? _currentLocation!.longitude
            : _destination!.longitude,
      ),
    );
    _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  Future<void> _getDirections() async {
    final apiKey = "AIzaSyCsch2Dos82VGx3jvHDseoOpVj0gbktOqQ";
    final url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${_currentLocation!.latitude},${_currentLocation!.longitude}&destination=${_destination!.latitude},${_destination!.longitude}&key=$apiKey";

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data['routes'].isNotEmpty) {
      final points = data['routes'][0]['overview_polyline']['points'];
      final List<LatLng> polylineCoords = _decodePolyline(points);
      setState(() {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: polylineCoords,
            color: Colors.blue,
            width: 5,
          ),
        );
      });
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polyline;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Order Route")),
      body:
          _currentLocation == null || _destination == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentLocation!,
                  zoom: 13,
                ),
                markers: _markers,
                polylines: _polylines,
                onMapCreated: (controller) {
                  _mapController = controller;
                },
              ),
    );
  }
}
