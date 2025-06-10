import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'order_showing_list_ui.dart';

class OrdersListView extends StatefulWidget {
  final List<String> matchedShopIds;

  const OrdersListView({super.key, required this.matchedShopIds});

  @override
  State<OrdersListView> createState() => _OrdersListViewState();
}

class _OrdersListViewState extends State<OrdersListView> {
  late Future<Map<String, String>> _shopNamesFuture;

  @override
  void initState() {
    super.initState();
    _shopNamesFuture = _fetchAllShopNames(widget.matchedShopIds);
  }

  Future<Map<String, String>> _fetchAllShopNames(List<String> shopIds) async {
    final Map<String, String> shopNames = {};

    // Fetch from 'shops' collection
    final shopsSnapshot =
        await FirebaseFirestore.instance
            .collection('shops')
            .where(FieldPath.documentId, whereIn: shopIds)
            .get();

    for (var doc in shopsSnapshot.docs) {
      shopNames[doc.id] = doc['shop_name'] ?? 'Unknown Shop';
    }

    // Find remaining shops in 'own_shops' collection
    final remainingIds =
        shopIds.where((id) => !shopNames.containsKey(id)).toList();
    if (remainingIds.isNotEmpty) {
      final ownShopsSnapshot =
          await FirebaseFirestore.instance
              .collection('own_shops')
              .where(FieldPath.documentId, whereIn: remainingIds)
              .get();

      for (var doc in ownShopsSnapshot.docs) {
        shopNames[doc.id] = doc['shop_name'] ?? 'Unknown Shop';
      }
    }

    return shopNames;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _shopNamesFuture,
      builder: (context, shopNamesSnapshot) {
        if (!shopNamesSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final shopNames = shopNamesSnapshot.data!;

        return StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collectionGroup('orders').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final now = DateTime.now();
            final cutoffDate = now.subtract(const Duration(days: 35));

            final matchedOrders =
                snapshot.data!.docs
                    .where((doc) {
                      final data = doc.data() as Map<String, dynamic>;

                      // Parse order date
                      final orderDate = DateTime.tryParse(
                        data['orderDateTime'] ?? '',
                      );
                      if (orderDate == null || orderDate.isBefore(cutoffDate)) {
                        return false;
                      }

                      final items = List<Map<String, dynamic>>.from(
                        data['items'] ?? [],
                      );
                      return items.any(
                        (item) =>
                            widget.matchedShopIds.contains(item['shopId']),
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
                        DateTime.tryParse(a['orderDateTime'] ?? '') ??
                        DateTime(0);
                    final bTime =
                        DateTime.tryParse(b['orderDateTime'] ?? '') ??
                        DateTime(0);
                    return bTime.compareTo(aTime);
                  });

            if (matchedOrders.isEmpty) {
              return const Center(
                child: Text("No orders found for your shops."),
              );
            }

            return ListView.builder(
              itemCount: matchedOrders.length,
              itemBuilder: (context, index) {
                final orderData = matchedOrders[index];
                final items = List<Map<String, dynamic>>.from(
                  orderData['items'] ?? [],
                );
                final firstShopId =
                    items.firstWhere(
                      (item) => widget.matchedShopIds.contains(item['shopId']),
                      orElse: () => {'shopId': ''},
                    )['shopId'];

                return OrderCard(
                  orderData: orderData,
                  matchedShopIds: widget.matchedShopIds,
                  shopName: shopNames[firstShopId] ?? 'Unknown Shop',
                );
              },
            );
          },
        );
      },
    );
  }
}
