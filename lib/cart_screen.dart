import 'package:flutter/material.dart';
import 'package:pawpal/product_management.dart';
import 'package:pawpal/product_managemnet.dart'; // Import Product class

class Order {
  final Product product;
  final int quantity;
  final String paymentMethod;
  final int totalAmount;
  final String status;

  Order({
    required this.product,
    required this.quantity,
    required this.paymentMethod,
    required this.totalAmount,
    required this.status,
  });
}

class CartScreen extends StatelessWidget {
  static List<Order> orders = []; // Static list to hold orders

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Cart'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Cart'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCartTab(),
            _buildHistoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildCartTab() {
    return Center(
      child: Text('Keranjang Kosong'), // Display empty cart message
    );
  }

  Widget _buildHistoryTab() {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return ListTile(
          title: Text(order.product.name),
          subtitle: Text('Status: ${order.status} - Total: Rp${order.totalAmount}'),
          trailing: Text('x${order.quantity}'),
        );
      },
    );
  }
}