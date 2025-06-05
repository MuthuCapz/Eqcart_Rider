import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../utils/colors.dart';

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

    return ElevatedButton(
      onPressed:
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
      style: ElevatedButton.styleFrom(
        backgroundColor: canClick ? AppColors.primaryColor : Colors.grey[300],
        foregroundColor: canClick ? Colors.white : Colors.black54,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}
