import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class AppProvider with ChangeNotifier {
  int _currentIndex = 0;
  bool _isLoading = false;
  List<Map<String, dynamic>> _products = [];

  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get products => _products;

  AppProvider() {
    fetchProducts();
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot snapshot = await FirebaseService.firestore
          .collection('products')
          .get();

      _products = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'price': (data['price'] ?? 0).toDouble(),
          'image': data['image'] ?? '',
          'category': data['category'] ?? '',
        };
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      // If error, use sample data as fallback
    }
  }

  Future<Map<String, dynamic>?> getProductDetails(String productId) async {
    try {
      final doc = await FirebaseService.firestore
          .collection('products')
          .doc(productId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'price': (data['price'] ?? 0).toDouble(),
          'image': data['image'] ?? '',
          'category': data['category'] ?? '',
          'description': data['description'] ?? '',
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  List<Map<String, dynamic>> cartItems = [];

  void addToCart(Map<String, dynamic> product) {
    // Check if product already exists in cart
    final existingIndex = cartItems.indexWhere(
      (item) => item['id'] == product['id'],
    );
    if (existingIndex != -1) {
      // Increase quantity if already in cart
      cartItems[existingIndex]['quantity'] =
          (cartItems[existingIndex]['quantity'] ?? 1) + 1;
    } else {
      // Add new item with quantity 1
      cartItems.add({...product, 'quantity': 1});
    }
    notifyListeners();
  }

  void increaseQuantity(int index) {
    if (index < cartItems.length) {
      cartItems[index]['quantity'] = (cartItems[index]['quantity'] ?? 1) + 1;
      notifyListeners();
    }
  }

  void decreaseQuantity(int index) {
    if (index < cartItems.length) {
      final currentQuantity = cartItems[index]['quantity'] ?? 1;
      if (currentQuantity > 1) {
        cartItems[index]['quantity'] = currentQuantity - 1;
      } else {
        cartItems.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeFromCart(int index) {
    if (index < cartItems.length) {
      cartItems.removeAt(index);
      notifyListeners();
    }
  }

  double get totalPrice {
    double total = 0;
    for (var item in cartItems) {
      final quantity = item['quantity'] ?? 1;
      final price = item['price'] ?? 0.0;
      total += price * quantity;
    }
    return total;
  }

  Future<bool> placeOrder({
    required String customerName,
    required String customerPhone,
    required String customerAddress,
  }) async {
    try {
      if (cartItems.isEmpty) {
        return false;
      }

      final orderId = DateTime.now().millisecondsSinceEpoch.toString();
      final orderData = {
        'orderId': orderId,
        'items': cartItems
            .map(
              (item) => {
                'id': item['id'],
                'name': item['name'],
                'price': item['price'],
                'image': item['image'],
                'quantity': item['quantity'] ?? 1,
              },
            )
            .toList(),
        'total': totalPrice,
        'date': FieldValue.serverTimestamp(),
        'status': 'pending',
        'customerName': customerName,
        'customerPhone': customerPhone,
        'customerAddress': customerAddress,
      };

      await FirebaseService.firestore
          .collection('orders')
          .doc(orderId)
          .set(orderData);

      cartItems.clear();
      notifyListeners();

      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<QuerySnapshot> getOrdersByPhoneStream(String phoneNumber) {
    return FirebaseService.firestore
        .collection('orders')
        .where('customerPhone', isEqualTo: phoneNumber)
        .snapshots();
  }
}
