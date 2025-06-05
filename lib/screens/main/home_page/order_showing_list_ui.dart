import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/colors.dart';

import 'order_details_page.dart';
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
                                  color: _getStatusColor(
                                    status,
                                  ).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _getStatusColor(status),
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
                          _buildStatusStep(
                            context,
                            orderData,
                            Icons.check_circle,
                            'Accept',
                            'pending',
                            'accepted',
                          ),
                          _buildStatusConnector(
                            context,
                            orderData,
                            'pending',
                            'accepted',
                          ),
                          _buildStatusStep(
                            context,
                            orderData,
                            Icons.local_shipping,
                            'Picked',
                            'accepted',
                            'picked',
                          ),
                          _buildStatusConnector(
                            context,
                            orderData,
                            'accepted',
                            'picked',
                          ),
                          _buildStatusStep(
                            context,
                            orderData,
                            Icons.directions_bike,
                            'On the way',
                            'picked',
                            'on the way',
                          ),
                          _buildStatusConnector(
                            context,
                            orderData,
                            'picked',
                            'on the way',
                          ),
                          _buildStatusStep(
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
                      child: _buildActionButton(
                        context,
                        icon: Icons.map_outlined,
                        label: 'Map',
                        isPrimary: false,
                        onPressed: () => _handleTrackOrder(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
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

  Widget _buildStatusStep(
    BuildContext context,
    Map<String, dynamic> orderData,
    IconData icon,
    String label,
    String requiredStatus,
    String newStatus,
  ) {
    final currentStatus =
        (orderData['orderStatus'] ?? '').toString().toLowerCase();
    final isActive = currentStatus == requiredStatus;
    final isCompleted =
        _getStatusIndex(currentStatus) > _getStatusIndex(requiredStatus);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap:
          isActive
              ? () => _updateOrderStatus(context, orderData, newStatus)
              : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color:
              isCompleted
                  ? AppColors.secondaryColor.withOpacity(0.1)
                  : isActive
                  ? AppColors.primaryColor.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isCompleted
                    ? AppColors.secondaryColor
                    : isActive
                    ? AppColors.primaryColor
                    : Colors.grey.withOpacity(0.2),
            width: isActive || isCompleted ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color:
                  isCompleted
                      ? AppColors.secondaryColor
                      : isActive
                      ? AppColors.primaryColor
                      : Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color:
                    isCompleted
                        ? AppColors.secondaryColor
                        : isActive
                        ? AppColors.primaryColor
                        : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusConnector(
    BuildContext context,
    Map<String, dynamic> orderData,
    String previousStatus,
    String nextStatus,
  ) {
    final currentStatus =
        (orderData['orderStatus'] ?? '').toString().toLowerCase();
    final isCompleted =
        _getStatusIndex(currentStatus) > _getStatusIndex(previousStatus);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Center(
        child: Container(
          width: 20,
          height: 1,
          color:
              isCompleted
                  ? AppColors.secondaryColor
                  : Colors.grey.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? AppColors.primaryColor : Colors.white,
        foregroundColor: isPrimary ? Colors.white : AppColors.primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isPrimary ? AppColors.primaryColor : Colors.grey.shade300,
            width: 1,
          ),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      onPressed: onPressed,
    );
  }

  int _getStatusIndex(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0;
      case 'accepted':
        return 1;
      case 'picked':
        return 2;
      case 'on the way':
        return 3;
      case 'delivered':
        return 4;
      default:
        return -1;
    }
  }

  Future<void> _updateOrderStatus(
    BuildContext context,
    Map<String, dynamic> orderData,
    String newStatus,
  ) async {
    try {
      final docRef = orderData['documentReference'] as DocumentReference?;
      if (docRef != null) {
        await docRef.update({'orderStatus': newStatus});
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
    }
  }

  Future<void> _handleTrackOrder(BuildContext context) async {
    final hasPermission = await _handleLocationPermission(context);
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return AppColors.secondaryColor;
      case 'picked':
        return Colors.indigo;
      case 'on the way':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
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

class OrderCardUtils {
  static Widget buildStatusButton(
    BuildContext context,
    Map<String, dynamic> orderData,
    String label,
    String requiredStatus,
    String newStatus,
  ) {
    final currentStatus =
        (orderData['orderStatus'] ?? '').toString().toLowerCase();
    final canClick = currentStatus == requiredStatus;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: canClick ? AppColors.primaryColor : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Material(
        color: canClick ? AppColors.primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap:
              canClick
                  ? () async {
                    try {
                      final docRef =
                          orderData['documentReference'] as DocumentReference?;
                      if (docRef != null) {
                        await docRef.update({'orderStatus': newStatus});
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update status: $e')),
                      );
                    }
                  }
                  : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: canClick ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
