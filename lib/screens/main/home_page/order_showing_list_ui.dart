import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/colors.dart';
import 'order_details_page.dart';
import 'order_map_page.dart';
import 'order_showing_utils.dart';

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
        orderType == 'Scheduled Order'
            ? 'Scheduled: ${deliveryDetails['scheduledDate']} ${deliveryDetails['scheduledTimeSlot']}'
            : 'Placed: ${orderData['orderDateTime']}';

    final status = (orderData['orderStatus'] ?? '').toString();
    final isDelivered = status.toLowerCase() == 'delivered';

    return Opacity(
      opacity: isDelivered ? 0.4 : 1.0,
      child: AbsorbPointer(
        absorbing: isDelivered,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 6,
          shadowColor: Colors.black12,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child:
                          imageItem.isNotEmpty
                              ? Image.network(
                                imageItem['imageUrl'],
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => const Icon(
                                      Icons.image_not_supported,
                                      size: 70,
                                      color: Colors.grey,
                                    ),
                              )
                              : Container(
                                width: 70,
                                height: 70,
                                color: AppColors.lightGreen,
                                child: const Icon(
                                  Icons.shopping_bag,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${orderData['orderId']}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$totalItems items • ₹${(orderData['orderTotal'] ?? 0).toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              orderType,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppColors.secondaryColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      children: [
                        Chip(
                          label: Text(status),
                          labelStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          backgroundColor: OrderCardUtils.getStatusColor(
                            status,
                          ),
                        ),
                        const SizedBox(height: 8),
                        IconButton(
                          icon: const Icon(Icons.map, color: Colors.green),
                          tooltip: 'Track on Map',
                          onPressed: () async {
                            final hasPermission =
                                await _handleLocationPermission(context);
                            if (!hasPermission) return;
                            try {
                              // 1. Get current device location
                              Position currentPosition =
                                  await Geolocator.getCurrentPosition(
                                    desiredAccuracy: LocationAccuracy.high,
                                  );

                              // 2. Extract shipping address from orderData
                              final shippingAddress =
                                  orderData['shippingAddress'] as String?;

                              if (shippingAddress == null ||
                                  shippingAddress.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Shipping address not available",
                                    ),
                                  ),
                                );
                                return;
                              }

                              // 3. Convert shipping address to coordinates
                              List<Location> locations =
                                  await locationFromAddress(shippingAddress);

                              if (locations.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Could not find location for shipping address",
                                    ),
                                  ),
                                );
                                return;
                              }

                              final destination = locations.first;

                              // 4. Create Google Maps directions URL
                              final uri = Uri(
                                scheme: 'https',
                                host: 'www.google.com',
                                path: 'maps/dir/',
                                queryParameters: {
                                  'api': '1',
                                  'origin':
                                      '${currentPosition.latitude},${currentPosition.longitude}',
                                  'destination':
                                      '${destination.latitude},${destination.longitude}',
                                  'travelmode': 'driving',
                                },
                              );

                              if (await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Could not open Google Maps"),
                                  ),
                                );
                              }
                            } catch (e) {
                              // Handle errors gracefully
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Error opening map: $e"),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      orderTime,
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryColor,
                        side: BorderSide(color: AppColors.primaryColor),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => OrderDetailsPage(orderData: orderData),
                          ),
                        );
                      },
                      child: const Text("View Details"),
                    ),
                  ],
                ),
                const Divider(height: 20, thickness: 1.2),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    OrderCardUtils.buildStatusButton(
                      context,
                      orderData,
                      'Confirm',
                      'pending',
                      'accepted',
                    ),
                    OrderCardUtils.buildStatusButton(
                      context,
                      orderData,
                      'Packing',
                      'accepted',
                      'preparing',
                    ),
                    OrderCardUtils.buildStatusButton(
                      context,
                      orderData,
                      'On the way',
                      'preparing',
                      'on the way',
                    ),
                    OrderCardUtils.buildStatusButton(
                      context,
                      orderData,
                      'Delivered',
                      'on the way',
                      'delivered',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _handleLocationPermission(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied")),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission permanently denied")),
      );
      return false;
    }

    return true;
  }
}
