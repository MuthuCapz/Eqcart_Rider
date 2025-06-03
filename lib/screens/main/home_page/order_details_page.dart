import 'package:flutter/material.dart';

class OrderDetailsPage extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const OrderDetailsPage({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    final items = List<Map<String, dynamic>>.from(orderData['items'] ?? []);
    final deliveryDetails =
        orderData['deliveryDetails'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildInfoRow('Order ID', orderData['orderId']),
            _buildInfoRow('Order Status', orderData['orderStatus']),
            _buildInfoRow('Order Total', '₹${orderData['orderTotal']}'),
            _buildInfoRow('Payment Method', orderData['paymentMethod']),
            _buildInfoRow('Payment Status', orderData['paymentStatus']),
            _buildInfoRow('Delivery Tip', '₹${orderData['deliveryTip'] ?? 0}'),
            _buildInfoRow('Shipping Address', orderData['shippingAddress']),
            _buildInfoRow('Order Date & Time', orderData['orderDateTime']),
            _buildInfoRow('Order Type', deliveryDetails['orderType']),
            if (deliveryDetails['orderType'] == 'Schedule Order')
              _buildInfoRow(
                'Scheduled Time',
                '${deliveryDetails['scheduledDate']} at ${deliveryDetails['scheduledTimeSlot']}',
              ),
            const SizedBox(height: 16),
            const Text(
              'Items:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...items.map((item) => _buildItemCard(item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? '-',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading:
            item['imageUrl'] != null
                ? Image.network(
                  item['imageUrl'],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
                : const Icon(Icons.image, size: 50),
        title: Text(item['productName'] ?? 'Unnamed Product'),
        subtitle: Text(
          '${item['variantWeight']} • ₹${item['price']} x ${item['quantity']}',
        ),
        trailing: Text(
          '₹${(item['price'] * item['quantity']).toStringAsFixed(2)}',
        ),
      ),
    );
  }
}
