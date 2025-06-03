import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/colors.dart';

import 'order_details_page.dart';

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
            snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final items = List<Map<String, dynamic>>.from(
                data['items'] ?? [],
              );
              return items.any(
                (item) => matchedShopIds.contains(item['shopId']),
              );
            }).toList();

        if (matchedOrders.isEmpty) {
          return const Center(child: Text("No orders found for your shops."));
        }

        return ListView.builder(
          itemCount: matchedOrders.length,
          itemBuilder: (context, index) {
            final data = matchedOrders[index].data() as Map<String, dynamic>;
            return OrderCard(orderData: data, matchedShopIds: matchedShopIds);
          },
        );
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final List<String> matchedShopIds;

  const OrderCard({
    super.key,
    required this.orderData,
    required this.matchedShopIds,
  });

  @override
  Widget build(BuildContext context) {
    final items = List<Map<String, dynamic>>.from(orderData['items'] ?? []);
    final matchedItems =
        items.where((item) => matchedShopIds.contains(item['shopId'])).toList();
    final imageItem = matchedItems.firstWhere(
      (i) => (i['imageUrl'] ?? '').isNotEmpty,
      orElse: () => {},
    );
    final totalItems = matchedItems.fold<int>(
      0,
      (sum, item) => sum + ((item['quantity'] ?? 0) as int),
    );

    final deliveryDetails = orderData['deliveryDetails'] ?? {};
    final orderType = deliveryDetails['orderType'] ?? '';
    final orderTime =
        orderType == 'Schedule Order'
            ? 'Scheduled: ${deliveryDetails['scheduledDate']} ${deliveryDetails['scheduledTimeSlot']}'
            : 'Placed: ${orderData['orderDateTime']}';

    final status = (orderData['orderStatus'] ?? '').toString();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      imageItem.isNotEmpty
                          ? Image.network(
                            imageItem['imageUrl'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => const Icon(
                                  Icons.image_not_supported,
                                  size: 60,
                                ),
                          )
                          : const Icon(Icons.shopping_bag, size: 60),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${orderData['orderId']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '$totalItems items • ₹${(orderData['orderTotal'] ?? 0).toStringAsFixed(2)}',
                      ),
                      Text(
                        status,
                        style: TextStyle(
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  orderTime,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Chip(
                  label: Text(orderType),
                  backgroundColor:
                      orderType == 'Schedule Order'
                          ? AppColors.lightGreen
                          : AppColors.secondaryColor.withOpacity(0.2),
                  labelStyle: TextStyle(color: AppColors.primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailsPage(orderData: orderData),
                    ),
                  );
                },
                child: const Text(
                  "View Details",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready for pickup':
        return Colors.green;
      case 'on the way':
        return Colors.teal;
      case 'delivered':
        return Colors.green[800]!;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
