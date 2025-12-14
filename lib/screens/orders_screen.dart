import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String? _phoneNumber;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _searchOrders() {
    if (_phoneController.text.trim().isNotEmpty) {
      setState(() {
        _phoneNumber = _phoneController.text.trim();
      });
    }
  }

  void _clearSearch() {
    setState(() {
      _phoneNumber = null;
      _phoneController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: const Text(
          'My Orders',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: _phoneNumber != null
            ? [
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: _clearSearch,
                  tooltip: 'Clear search',
                ),
              ]
            : null,
      ),
      body: _phoneNumber == null
          ? _buildPhoneInputView()
          : StreamBuilder<QuerySnapshot>(
              stream: appProvider.getOrdersByPhoneStream(_phoneNumber!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 100,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No orders found',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No orders found for this phone number',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Sort documents by date (newest first)
                final sortedDocs = snapshot.data!.docs.toList()
                  ..sort((a, b) {
                    final aData = a.data() as Map<String, dynamic>?;
                    final bData = b.data() as Map<String, dynamic>?;
                    final aDate = (aData != null && aData.containsKey('date'))
                        ? aData['date'] as Timestamp?
                        : null;
                    final bDate = (bData != null && bData.containsKey('date'))
                        ? bData['date'] as Timestamp?
                        : null;
                    if (aDate == null && bDate == null) return 0;
                    if (aDate == null) return 1;
                    if (bDate == null) return -1;
                    return bDate.compareTo(aDate); // Descending order
                  });

                return ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: sortedDocs.length,
                  itemBuilder: (context, index) {
                    final doc = sortedDocs[index];
                    final order = doc.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Order #${order['orderId']?.toString().substring(order['orderId'].toString().length - 6) ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                      order['status'] ?? 'pending',
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    order['status'] ?? 'pending',
                                    style: TextStyle(
                                      color: _getStatusColor(
                                        order['status'] ?? 'pending',
                                      ),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Items: ${(order['items'] as List?)?.length ?? 0}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Display individual items
                            if (order['items'] != null &&
                                (order['items'] as List).isNotEmpty)
                              ...((order['items'] as List).map((item) {
                                final itemData = item as Map<String, dynamic>;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '• ${itemData['name'] ?? 'N/A'}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                      Text(
                                        'Qty: ${itemData['quantity'] ?? 1}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList()),
                            const SizedBox(height: 10),
                            Text(
                              'Total: ৳${(order['total'] ?? 0.0).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Divider(),
                            const SizedBox(height: 10),
                            Text(
                              'Customer: ${order['customerName'] ?? 'N/A'}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Phone: ${order['customerPhone'] ?? 'N/A'}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Address: ${order['customerAddress'] ?? 'N/A'}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildPhoneInputView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_android, size: 100, color: Colors.blue.shade700),
            const SizedBox(height: 30),
            const Text(
              'Enter Phone Number',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Enter your phone number to view your orders',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter phone number',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onSubmitted: (_) => _searchOrders(),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _searchOrders,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Search Orders',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
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
      case 'confirmed':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
