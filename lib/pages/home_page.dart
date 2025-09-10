import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'add_book.dart';
import 'category_books_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("📚 Online Bookstore"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          if (user == null)
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: const Text(
                "Login / Sign In",
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.deepPurple),
              child: Text(
                user != null ? user.email! : "Guest",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                if (user != null) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ProfilePage()));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Cart'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const CartPage()));
              },
            ),
            if (user != null)
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Colors.grey.shade200,
              child: const Text(
                "আপনার পছন্দের সকল বই এক প্লাটফর্মে",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Categories Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CategoryBooksPage(category: 'Academic'),
                        ),
                      );
                    },
                    child: const Text("Academic"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CategoryBooksPage(category: 'Fiction'),
                        ),
                      );
                    },
                    child: const Text("Fiction"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CategoryBooksPage(category: 'Non Fiction'),
                        ),
                      );
                    },
                    child: const Text("Non Fiction"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bestseller Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.orange.shade100,
              child: const Text(
                "Bestseller",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
            ),
            SizedBox(
              height: 250,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('books')
                    .orderBy('sold', descending: true)
                    .limit(5)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No bestseller books"));
                  }
                  final books = snapshot.data!.docs;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      var book = books[index].data() as Map<String, dynamic>;
                      return Container(
                        width: 140,
                        margin: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  book['imageUrl'] ?? '',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image_not_supported,
                                      size: 80, color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              book['title'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "৳${book['price'] ?? ''}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // About Us Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "আমাদের সম্পর্কে",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "আমরা একটি অনলাইন বুকস্টোর, যেখানে আপনি আপনার প্রিয় বই সহজে পেতে পারেন। আমাদের লক্ষ্য হল বই পড়াকে সহজ এবং আনন্দদায়ক করা।",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // FAQ Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Frequently Asked Questions",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text("Q1: কিভাবে অর্ডার করতে পারি?\nA1: আপনার পছন্দের বই কার্টে যোগ করুন এবং চেকআউট করুন।\n"),
                  Text("Q2: ডেলিভারি কতদিনে হবে?\nA2: সাধারণত ২-৫ কার্যদিবসের মধ্যে।\n"),
                  Text("Q3: রিটার্ন পলিসি কী?\nA3: আপনি বই রিসিভ করার ৭ দিনের মধ্যে রিটার্ন করতে পারবেন।\n"),
                  Text("Q4: পেমেন্ট মেথড কী?\nA4: ক্রেডিট/ডেবিট কার্ড, বিকাশ, নগদ প্রভৃতি।\n"),
                  Text("Q5: কাস্টমার সাপোর্ট কীভাবে যোগাযোগ করবে?\nA5: আপনি আমাদের ইমেইল বা হটলাইন দিয়ে যোগাযোগ করতে পারেন।\n"),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButton: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const AddBookPage()));
        },
        child: const Text("Add Books"),
      ),
    );
  }
}
