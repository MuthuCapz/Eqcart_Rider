import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import '../../../utils/colors.dart';

class OrderCardUtils {
  static Widget buildStatusStep(
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
        getStatusIndex(currentStatus) > getStatusIndex(requiredStatus);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap:
          isActive
              ? () => updateOrderStatus(context, orderData, newStatus)
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

  static Widget buildStatusConnector(
    BuildContext context,
    Map<String, dynamic> orderData,
    String previousStatus,
    String nextStatus,
  ) {
    final currentStatus =
        (orderData['orderStatus'] ?? '').toString().toLowerCase();
    final isCompleted =
        getStatusIndex(currentStatus) > getStatusIndex(previousStatus);

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

  static Widget buildActionButton(
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

  static int getStatusIndex(String status) {
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

  static Color getStatusColor(String status) {
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

  static Future<void> updateOrderStatus(
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

  static Future<bool> handleLocationPermission(BuildContext context) async {
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
