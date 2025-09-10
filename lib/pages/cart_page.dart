import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  Future<void> removeItem(String id) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("🛒 Your Cart")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('cart')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Cart is empty"));
          }

          final cartItems = snapshot.data!.docs;

          return ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              var book = cartItems[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: book['imageUrl'] != null
                      ? Image.network(book['imageUrl'], width: 50, errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported))
                      : const Icon(Icons.book),
                  title: Text(book['title'] ?? ''),
                  subtitle: Text("৳${book['price'] ?? 0}"),
                  trailing: TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () => removeItem(cartItems[index].id),
                    child: const Text("Remove"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
