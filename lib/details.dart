import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailsPage extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailsPage({super.key, required this.product});

  Future<void> _addToCart(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add to cart')),
      );
      return;
    }
    try {
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(user.uid)
          .collection('items')
          .add({
        'product_id': product['id'],
        'title': product['title'],
        'price': product['price'],
        'image_url': product['image_url'],
        'quantity': 1,
        'added_at': Timestamp.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to cart!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to cart: $e')),
      );
    }
  }

  Future<void> _buyProduct(BuildContext context) async {
    final productId = product['id'];
    final quantityAvailable = (product['quantity'] is num) ? (product['quantity'] as num).toInt() : 0;
    if (quantityAvailable <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product is out of stock')),
      );
      return;
    }

    final TextEditingController quantityController = TextEditingController();

    // Show dialog to ask quantity to buy
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter quantity to buy (Available: $quantityAvailable)'),
        content: TextField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Quantity'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final enteredQuantity = int.tryParse(quantityController.text);
              if (enteredQuantity == null || enteredQuantity <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid positive number')),
                );
                return;
              }
              if (enteredQuantity > quantityAvailable) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Not enough stock available')),
                );
                return;
              }
              Navigator.of(context).pop(true);
            },
            child: const Text('Buy'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final int quantityToBuy = int.parse(quantityController.text);
      final double price = (product['price'] is num) ? (product['price'] as num).toDouble() : 0.0;

      try {
        final productDoc = FirebaseFirestore.instance.collection('products').doc(productId);
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final snapshot = await transaction.get(productDoc);
          final currentQuantity = (snapshot['quantity'] is num) ? (snapshot['quantity'] as num).toInt() : 0;
          if (quantityToBuy > currentQuantity) {
            throw Exception('Not enough quantity available');
          }
          transaction.update(productDoc, {'quantity': currentQuantity - quantityToBuy});
        });

        // Navigate to payment page passing total price
        Navigator.pushNamed(context, '/payment', arguments: price * quantityToBuy);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchased $quantityToBuy item(s)!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = product['image_url'] as String? ?? '';
    final title = product['title'] as String? ?? 'Untitled';
    final description = product['description'] as String? ?? 'No description';
    final manufacturer = product['manufacturer'] as String? ?? 'Unknown';
    final price = (product['price'] is num) ? (product['price'] as num).toDouble() : 0.0;
    final quantity = (product['quantity'] is num) ? (product['quantity'] as num).toInt() : 0;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            imageUrl.isNotEmpty
                ? Image.network(
              imageUrl,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.broken_image, size: 100),
              ),
            )
                : const Center(child: Icon(Icons.broken_image, size: 100)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${price.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, color: Colors.green.shade700),
            ),
            const SizedBox(height: 8),
            Text('Manufacturer: $manufacturer'),
            const SizedBox(height: 8),
            Text('Description: $description'),
            const SizedBox(height: 8),
            Text('Quantity Available: $quantity'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _buyProduct(context),
                  child: const Text('Buy Now'),
                ),

                ElevatedButton(
                  onPressed: () => _addToCart(context),
                  child: const Text('Add to Cart'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
