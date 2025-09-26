import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'search_page.dart';
import 'cartpage.dart';
import 'add_products.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Home tab initially

  // Pages in order: Home (ProductsGridView), Add Products, Search, Cart
  final List<Widget> _pages = const [
    ProductsGridView(), // Index 0: Home
    AddProductsPage(), // Index 1: Add Products
    SearchPage(), // Index 2: Search
    CartPage(), // Index 3: Cart
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Commerce'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Ensure all labels are visible
        selectedItemColor: Colors.blue, // Highlight selected tab
        unselectedItemColor: Colors.grey, // Dim unselected tabs
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
        ],
      ),
    );
  }
}

class ProductsGridView extends StatelessWidget {
  const ProductsGridView({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Failed to load products.'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(
            child: Text(
              'No products available yet. Please add some!',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(8),
          child: GridView.builder(
            itemCount: docs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              final productDoc = docs[index];
              final data = productDoc.data();
              if (data == null || data is! Map<String, dynamic>) {
                print('Invalid document at index $index: $data');
                return const SizedBox.shrink();
              }
              final imageUrl = data['image_url'] as String? ?? '';
              final title = data['title'] as String? ?? 'Untitled';
              final price = (data['price'] is num) ? (data['price'] as num).toDouble() : 0.0;
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/details', arguments: {
                      'id': productDoc.id,
                      ...data, // Include all fields
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Icon(Icons.broken_image, size: 50),
                            ),
                          )
                              : const Center(child: Icon(Icons.broken_image, size: 50)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}