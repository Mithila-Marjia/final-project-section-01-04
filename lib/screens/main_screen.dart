import 'package:ecom/screens/cart_screen.dart';
import 'package:ecom/screens/orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'home_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        List<Widget> screens = [
          const HomeScreen(),
          const CartScreen(),
          const OrdersScreen(),
        ];

        return Scaffold(
          body: screens[appProvider.currentIndex],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: appProvider.currentIndex,
              onTap: (index) {
                appProvider.setCurrentIndex(index);
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: Colors.blue.shade700,
              unselectedItemColor: Colors.grey.shade600,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 12,
              ),
              elevation: 8,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    appProvider.currentIndex == 0
                        ? Icons.home_rounded
                        : Icons.home_outlined,
                    size: 26,
                  ),
                  activeIcon: Icon(Icons.home_rounded, size: 28),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        appProvider.currentIndex == 1
                            ? Icons.shopping_cart_rounded
                            : Icons.shopping_cart_outlined,
                        size: 26,
                      ),
                      if (appProvider.cartItems.isNotEmpty)
                        Positioned(
                          right: -8,
                          top: -8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Center(
                              child: Text(
                                appProvider.cartItems.length > 9
                                    ? '9+'
                                    : '${appProvider.cartItems.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  activeIcon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.shopping_cart_rounded, size: 28),
                      if (appProvider.cartItems.isNotEmpty)
                        Positioned(
                          right: -8,
                          top: -8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Center(
                              child: Text(
                                appProvider.cartItems.length > 9
                                    ? '9+'
                                    : '${appProvider.cartItems.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: 'My Cart',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    appProvider.currentIndex == 2
                        ? Icons.receipt_long_rounded
                        : Icons.receipt_long_outlined,
                    size: 26,
                  ),
                  activeIcon: Icon(Icons.receipt_long_rounded, size: 28),
                  label: 'My Orders',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
