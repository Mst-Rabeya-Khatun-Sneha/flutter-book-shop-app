import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BookDetailsPage extends StatefulWidget {
  final QueryDocumentSnapshot book;
  const BookDetailsPage({super.key, required this.book});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  final reviewController = TextEditingController();

  Future<void> addToCart() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .add(widget.book.data() as Map<String, dynamic>);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Book added to cart!")),
    );
  }

  Future<void> addReview() async {
    await FirebaseFirestore.instance
        .collection('books')
        .doc(widget.book.id)
        .collection('reviews')
        .add({
      'review': reviewController.text.trim(),
      'user': FirebaseAuth.instance.currentUser!.email,
      'timestamp': FieldValue.serverTimestamp(),
    });
    reviewController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.book.data() as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(title: Text(data['title'])),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(data['imageUrl'], height: 200, fit: BoxFit.cover),
            const SizedBox(height: 10),
            Text("Price: ৳${data['price']}", style: const TextStyle(fontSize: 18, color: Colors.green)),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: addToCart, child: const Text("Add to Cart")),
            const Divider(),
            const Text("Reviews", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('books')
                  .doc(widget.book.id)
                  .collection('reviews')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Text("No reviews yet");
                final reviews = snapshot.data!.docs;
                return Column(
                  children: reviews.map((doc) {
                    var r = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(r['review']),
                      subtitle: Text(r['user'] ?? "Anonymous"),
                    );
                  }).toList(),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: reviewController,
                decoration: InputDecoration(
                  labelText: "Write a review",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: addReview,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
