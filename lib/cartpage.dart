import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view your cart')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('carts')
            .doc(user.uid)
            .collection('items')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load cart.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }
          double total = docs.fold(0.0, (sum, doc) {
            final data = doc.data() as Map<String, dynamic>;
            final price = (data['price'] is num) ? (data['price'] as num).toDouble() : 0.0;
            final quantity = (data['quantity'] is num) ? (data['quantity'] as num).toInt() : 1;
            return sum + (price * quantity);
          });
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final title = data['title'] as String? ?? 'Untitled';
                    final price = (data['price'] is num) ? (data['price'] as num).toDouble() : 0.0;
                    final quantity = (data['quantity'] is num) ? (data['quantity'] as num).toInt() : 1;
                    return ListTile(
                      title: Text(title),
                      subtitle: Text('\$${price.toStringAsFixed(2)} x $quantity'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('carts')
                              .doc(user.uid)
                              .collection('items')
                              .doc(docs[index].id)
                              .delete();
                        },
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: \$${total.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/payment', arguments: total);
                      },
                      child: const Text('Proceed to Payment'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}