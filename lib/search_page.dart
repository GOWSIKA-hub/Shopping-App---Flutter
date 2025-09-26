import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Products')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.trim());
              },
            ),
          ),
          Expanded(
            child: _searchQuery.isEmpty
                ? const Center(child: Text('Enter a search term to find products.'))
                : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .where('title', isGreaterThanOrEqualTo: _searchQuery)
                  .where('title', isLessThanOrEqualTo: '$_searchQuery\uf8ff')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Failed to load products.'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text('No products found.'));
                }
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>?;
                    if (data == null) return const SizedBox.shrink();
                    final title = data['title'] as String? ?? 'Untitled';
                    final price = (data['price'] is num) ? (data['price'] as num).toDouble() : 0.0;
                    return ListTile(
                      title: Text(title),
                      subtitle: Text('\$${price.toStringAsFixed(2)}'),
                      onTap: () {
                        Navigator.pushNamed(context, '/details', arguments: {
                          'id': docs[index].id,
                          ...data,
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}