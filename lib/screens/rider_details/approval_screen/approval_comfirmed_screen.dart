import 'package:eqcart_rider/screens/map_pages/map_page.dart';
import 'package:flutter/material.dart';

import '../../../utils/colors.dart';

class ApprovalConfirmedScreen extends StatefulWidget {
  const ApprovalConfirmedScreen({super.key});

  @override
  State<ApprovalConfirmedScreen> createState() =>
      _ApprovalConfirmedScreenState();
}

class _ApprovalConfirmedScreenState extends State<ApprovalConfirmedScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MapPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified, color: AppColors.secondaryColor, size: 80),
            const SizedBox(height: 20),
            const Text(
              'You are Approved!',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Redirecting to your dashboard...',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
