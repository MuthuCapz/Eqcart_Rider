import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eqcart_rider/screens/rider_details/rider_details_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auth_service.dart';
import '../login/login_page.dart';
import '../main/main_page.dart';
import '../map_pages/map_page.dart';
import '../rider_details/approval_screen/approval_comfirmed_screen.dart';
import '../rider_details/approval_screen/pending_approval_screen.dart';

class SplashScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/rider.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Gradient Overlay
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Centered Content with Button Slightly Lower
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 45),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    User? user = await _authService.getCurrentUser();
                    if (user != null) {
                      final uid = user.uid;

                      final riderDoc =
                          await FirebaseFirestore.instance
                              .collection('riders_info')
                              .doc(uid)
                              .get();

                      if (riderDoc.exists) {
                        final data = riderDoc.data();
                        final status = data?['approval_status'] ?? '';

                        if (status == 'pending') {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PendingApprovalScreen(),
                            ),
                          );
                        } else if (status == 'approved') {
                          final prefs = await SharedPreferences.getInstance();
                          final isConfirmedShown =
                              prefs.getBool('approvalConfirmedShown') ?? false;

                          if (!isConfirmedShown) {
                            // First time: show approval confirmation screen
                            await prefs.setBool('approvalConfirmedShown', true);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        const ApprovalConfirmedScreen(),
                              ),
                            );
                          } else {
                            final addressData = data?['address'] ?? {};
                            final mapLocation = addressData['map'];
                            final matchedShops =
                                addressData['matched_shop_ids'];

                            final bool goToMainPage =
                                mapLocation != null &&
                                matchedShops != null &&
                                matchedShops is List &&
                                matchedShops.isNotEmpty;

                            if (goToMainPage) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MainPage(),
                                ),
                              );
                            } else {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MapPage(),
                                ),
                              );
                            }
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Unknown status. Please contact support.',
                              ),
                            ),
                          );
                        }
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RiderDetailsPage(),
                          ),
                        );
                      }
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    }
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.withOpacity(0.8),
                    shadowColor: Colors.transparent,
                    side: BorderSide(color: Colors.green, width: 2),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
