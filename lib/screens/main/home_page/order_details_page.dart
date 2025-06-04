import 'package:flutter/material.dart';
import '../../../utils/colors.dart';

class OrderDetailsPage extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const OrderDetailsPage({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    final items = List<Map<String, dynamic>>.from(orderData['items'] ?? []);
    final deliveryDetails =
        orderData['deliveryDetails'] as Map<String, dynamic>? ?? {};

    Color getStatusColor(String? status) {
      switch (status?.toLowerCase()) {
        case 'delivered':
          return Colors.green;
        case 'pending':
          return Colors.orange;
        case 'cancelled':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: const Text(
          'Order Details',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoTile('Order ID', orderData['orderId']),
                  _infoTileWithBadge(
                    'Order Status',
                    orderData['orderStatus'],
                    color: getStatusColor(orderData['orderStatus']),
                  ),
                  const SizedBox(height: 8),
                  _priceTile('Order Total', '₹${orderData['orderTotal']}'),
                  _infoTile('Payment Method', orderData['paymentMethod']),
                  _infoTile('Payment Status', orderData['paymentStatus']),
                  _infoTile(
                    'Delivery Tip',
                    '₹${orderData['deliveryTip'] ?? 0}',
                  ),
                  _infoTile('Shipping Address', orderData['shippingAddress']),
                  _infoTile('Order Date & Time', orderData['orderDateTime']),
                  _infoTile('Order Type', deliveryDetails['orderType']),
                  if (deliveryDetails['orderType'] == 'Schedule Order')
                    _infoTile(
                      'Scheduled Time',
                      '${deliveryDetails['scheduledDate']} at ${deliveryDetails['scheduledTimeSlot']}',
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Ordered Items',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            ...items.map((item) => _buildItemCard(item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _infoTile(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTileWithBadge(
    String label,
    String? value, {
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value ?? '-',
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.secondaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    final price = (item['price'] ?? 0).toDouble();
    final quantity = (item['quantity'] ?? 0);
    final total = price * quantity;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child:
                item['imageUrl'] != null
                    ? Image.network(
                      item['imageUrl'],
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Icon(
                            Icons.broken_image,
                            size: 70,
                            color: Colors.grey[300],
                          ),
                    )
                    : Icon(Icons.image, size: 70, color: Colors.grey[300]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['productName'] ?? 'Unnamed Product',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['variantWeight'] ?? '',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${price.toStringAsFixed(2)} × $quantity',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            '₹${total.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
