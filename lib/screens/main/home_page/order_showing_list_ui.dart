import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/colors.dart';
import 'order_details_page.dart';

import 'order_showing_utils.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final List<String> matchedShopIds;
  final String? shopName;

  const OrderCard({
    super.key,
    required this.orderData,
    required this.matchedShopIds,
    this.shopName,
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
      opacity: isDelivered ? 0.8 : 1.0,
      child: AbsorbPointer(
        absorbing: isDelivered,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
          ),
          child: Column(
            children: [
              // Header section with order info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order image
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryColor.withOpacity(0.8),
                            AppColors.secondaryColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child:
                            imageItem.isNotEmpty
                                ? Image.network(
                                  imageItem['imageUrl'],
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => Center(
                                        child: Icon(
                                          Icons.shopping_bag_rounded,
                                          size: 30,
                                          color: Colors.white,
                                        ),
                                      ),
                                )
                                : Center(
                                  child: Icon(
                                    Icons.shopping_bag_rounded,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Order details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (shopName != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                shopName!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(
                                  'Order #${orderData['orderId']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: OrderCardUtils.getStatusColor(
                                    status,
                                  ).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: OrderCardUtils.getStatusColor(
                                      status,
                                    ),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$totalItems items • ₹${(orderData['orderTotal'] ?? 0).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.lightGreen.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  orderType == 'Scheduled Order'
                                      ? Icons.calendar_today_rounded
                                      : Icons.access_time_rounded,
                                  size: 14,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  orderTime,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Status progression bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          OrderCardUtils.buildStatusStep(
                            context,
                            orderData,
                            Icons.check_circle,
                            'Accept',
                            'pending',
                            'accepted',
                          ),
                          OrderCardUtils.buildStatusConnector(
                            context,
                            orderData,
                            'pending',
                            'accepted',
                          ),
                          OrderCardUtils.buildStatusStep(
                            context,
                            orderData,
                            Icons.local_shipping,
                            'Picked',
                            'accepted',
                            'picked',
                          ),
                          OrderCardUtils.buildStatusConnector(
                            context,
                            orderData,
                            'accepted',
                            'picked',
                          ),
                          OrderCardUtils.buildStatusStep(
                            context,
                            orderData,
                            Icons.directions_bike,
                            'On the way',
                            'picked',
                            'on the way',
                          ),
                          OrderCardUtils.buildStatusConnector(
                            context,
                            orderData,
                            'picked',
                            'on the way',
                          ),
                          OrderCardUtils.buildStatusStep(
                            context,
                            orderData,
                            Icons.verified_user,
                            'Delivered',
                            'on the way',
                            'delivered',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Action buttons section
              Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OrderCardUtils.buildActionButton(
                        context,
                        icon: Icons.map_outlined,
                        label: 'Direction',
                        isPrimary: false,
                        onPressed: () => _handleTrackOrder(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OrderCardUtils.buildActionButton(
                        context,
                        icon: Icons.remove_red_eye_outlined,
                        label: 'View Details',
                        isPrimary: true,
                        onPressed: () async {
                          final items = orderData['items'] as List;
                          final shopId = items.first['shopId'];

                          // Try to fetch from shops
                          final shopDoc =
                              await FirebaseFirestore.instance
                                  .collection('shops')
                                  .doc(shopId)
                                  .get();
                          String? shopName;

                          if (shopDoc.exists) {
                            shopName = shopDoc['shop_name'];
                          } else {
                            final ownShopDoc =
                                await FirebaseFirestore.instance
                                    .collection('own_shops')
                                    .doc(shopId)
                                    .get();
                            if (ownShopDoc.exists) {
                              shopName = ownShopDoc['shop_name'];
                            }
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => OrderDetailsPage(
                                    orderData: orderData,
                                    shopName: shopName,
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleTrackOrder(BuildContext context) async {
    final hasPermission = await OrderCardUtils.handleLocationPermission(
      context,
    );
    if (!hasPermission) return;

    try {
      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final shippingAddress = orderData['shippingAddress'] as String?;
      if (shippingAddress == null || shippingAddress.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Shipping address not available")),
        );
        return;
      }

      List<Location> locations = await locationFromAddress(shippingAddress);
      if (locations.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not find location")),
        );
        return;
      }

      final destination = locations.first;
      final uri = Uri(
        scheme: 'https',
        host: 'www.google.com',
        path: 'maps/dir/',
        queryParameters: {
          'api': '1',
          'origin': '${currentPosition.latitude},${currentPosition.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'travelmode': 'driving',
        },
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cannot open Google Maps")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Map error: $e")));
    }
  }
}
