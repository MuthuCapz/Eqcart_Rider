import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'order_showing_list_ui.dart';

class OrdersListView extends StatelessWidget {
  final List<String> matchedShopIds;

  const OrdersListView({super.key, required this.matchedShopIds});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collectionGroup('orders').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final matchedOrders =
            snapshot.data!.docs
                .where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final items = List<Map<String, dynamic>>.from(
                    data['items'] ?? [],
                  );
                  return items.any(
                    (item) => matchedShopIds.contains(item['shopId']),
                  );
                })
                .map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  data['documentReference'] = doc.reference;
                  return data;
                })
                .toList()
              ..sort((a, b) {
                final aTime =
                    DateTime.tryParse(a['orderDateTime'] ?? '') ?? DateTime(0);
                final bTime =
                    DateTime.tryParse(b['orderDateTime'] ?? '') ?? DateTime(0);
                return bTime.compareTo(aTime);
              });

        if (matchedOrders.isEmpty) {
          return const Center(child: Text("No orders found for your shops."));
        }

        return ListView.builder(
          itemCount: matchedOrders.length,
          itemBuilder: (context, index) {
            return OrderCard(
              orderData: matchedOrders[index],
              matchedShopIds: matchedShopIds,
            );
            ;
          },
        );
      },
    );
  }
}
