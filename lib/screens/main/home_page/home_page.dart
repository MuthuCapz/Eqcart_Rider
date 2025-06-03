import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/colors.dart';
import 'home_page_function.dart';

class HomeOrdersPage extends StatelessWidget {
  const HomeOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String riderId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('riders_info')
                .doc(riderId)
                .snapshots(),
        builder: (context, riderSnapshot) {
          if (riderSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!riderSnapshot.hasData || !riderSnapshot.data!.exists) {
            return const Center(child: Text("No rider data found."));
          }

          final riderData = riderSnapshot.data!.data() as Map<String, dynamic>;
          final matchedShopIds = List<String>.from(
            riderData['address']['matched_shop_ids'] ?? [],
          );

          if (matchedShopIds.isEmpty) {
            return const Center(
              child: Text("No shops assigned to this rider."),
            );
          }

          return OrdersListView(matchedShopIds: matchedShopIds);
        },
      ),
    );
  }
}
