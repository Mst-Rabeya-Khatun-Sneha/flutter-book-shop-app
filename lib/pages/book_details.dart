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
    if (reviewController.text.trim().isEmpty) return;

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
      appBar: AppBar(title: Text(data['title'] ?? 'Book Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                data['imageUrl'] ?? '',
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.image_not_supported,
                    size: 100, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 12),

            // Price
            Text(
              "Price: ৳${data['price']}",
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
            const SizedBox(height: 10),

            // Description
            if (data['description'] != null &&
                data['description'].toString().isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Description",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    data['description'],
                    style: const TextStyle(fontSize: 15, height: 1.4),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // Add to Cart Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: addToCart,
                icon: const Icon(Icons.shopping_cart),
                label: const Text("Add to Cart"),
              ),
            ),
            const Divider(height: 30),

            // Reviews Section
            const Text(
              "Reviews",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('books')
                  .doc(widget.book.id)
                  .collection('reviews')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text("No reviews yet"),
                  );
                }
                final reviews = snapshot.data!.docs;
                return Column(
                  children: reviews.map((doc) {
                    var r = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      leading: const Icon(Icons.person, color: Colors.grey),
                      title: Text(r['review']),
                      subtitle: Text(r['user'] ?? "Anonymous"),
                    );
                  }).toList(),
                );
              },
            ),

            // Write Review
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextField(
                controller: reviewController,
                decoration: InputDecoration(
                  labelText: "Write a review",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
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
