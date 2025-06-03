import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eqcart_rider/screens/main/main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../utils/colors.dart';
import 'no_shop_nearby_page.dart';

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
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text("Location Page"),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLatLng!,
              zoom: 16,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (controller) => _controller.complete(controller),
            onCameraMove: _onCameraMove,
          ),

          // Pin Icon in center
          Icon(Icons.location_on, size: 50, color: AppColors.secondaryColor),

          // Bottom Card
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (_currentLatLng == null) return;

                        try {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) return;

                          // 1. Reverse geocoding
                          List<Placemark> placemarks =
                              await placemarkFromCoordinates(
                                _currentLatLng!.latitude,
                                _currentLatLng!.longitude,
                              );

                          String readableAddress = "Unknown Location";
                          if (placemarks.isNotEmpty) {
                            final place = placemarks.first;
                            readableAddress =
                                "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}";
                          }

                          List<String> matchedShopIds = [];

                          // Helper function to process both collections
                          Future<void> checkShops(
                            String settingsCol,
                            String shopsCol,
                          ) async {
                            final settingsSnap =
                                await FirebaseFirestore.instance
                                    .collection(settingsCol)
                                    .get();

                            for (var doc in settingsSnap.docs) {
                              final shopId = doc.id;
                              final riderDistance =
                                  double.tryParse(
                                    doc.data()['riderDistance'].toString(),
                                  ) ??
                                  0;

                              if (riderDistance == 0) continue;

                              final shopDoc =
                                  await FirebaseFirestore.instance
                                      .collection(shopsCol)
                                      .doc(shopId)
                                      .get();

                              final shopLocation = shopDoc.data()?['location'];
                              if (shopLocation == null) continue;

                              double shopLat = shopLocation['latitude'];
                              double shopLng = shopLocation['longitude'];

                              double distanceInMeters =
                                  Geolocator.distanceBetween(
                                    _currentLatLng!.latitude,
                                    _currentLatLng!.longitude,
                                    shopLat,
                                    shopLng,
                                  );

                              if (distanceInMeters <= riderDistance * 1000) {
                                matchedShopIds.add(shopId);
                              }
                            }
                          }

                          // 2. Check both 'shops_settings' and 'own_shops_settings'
                          await checkShops('shops_settings', 'shops');
                          await checkShops('own_shops_settings', 'own_shops');

                          // 3. Save address and matched shop IDs to Firestore
                          await FirebaseFirestore.instance
                              .collection('riders_info')
                              .doc(user.uid)
                              .set({
                                'address': {
                                  'address': readableAddress,
                                  'latitude': _currentLatLng!.latitude,
                                  'longitude': _currentLatLng!.longitude,
                                  'createDateTime':
                                      FieldValue.serverTimestamp(),
                                  'matched_shop_ids': matchedShopIds,
                                },
                              }, SetOptions(merge: true));

                          if (matchedShopIds.isEmpty) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NoShopsNearbyPage(),
                              ),
                            );
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MainPage(),
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to save location: $e'),
                            ),
                          );
                        }
                      },

                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text("Confirm Location"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
