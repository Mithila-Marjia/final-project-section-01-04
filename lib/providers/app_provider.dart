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

  Stream<QuerySnapshot> getOrdersByPhoneStream(String phoneNumber) {
    return FirebaseService.firestore
        .collection('orders')
        .where('customerPhone', isEqualTo: phoneNumber)
        .snapshots();
  }
}
