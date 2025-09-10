import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'book_details.dart';
import 'category_books_page.dart';
import 'profile_page.dart';
import '../pages/cart_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userRole;

  @override
  void initState() {
    super.initState();
    getUserRole();
  }

  Future<void> getUserRole() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      userRole = doc.data()?['role'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['Academic', 'Fiction', 'Non-fiction'];

    return Scaffold(
      // Only show AppBar if user role is not admin
      appBar: userRole != 'admin'
          ? AppBar(
        title: const Text("Online Bookstore"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              } else if (value == 'cart') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartPage()),
                );
              } else if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
              }
            },
            itemBuilder: (context) {
              List<PopupMenuEntry<String>> items = [
                const PopupMenuItem(
                  value: 'profile',
                  child: Text("Profile", style: TextStyle(color: Colors.blue)),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Text("Logout", style: TextStyle(color: Colors.red)),
                ),
              ];
              // Cart menu only for user role
              if (userRole == 'user') {
                items.insert(
                  1,
                  const PopupMenuItem(
                    value: 'cart',
                    child: Text("Cart", style: TextStyle(color: Colors.orange)),
                  ),
                );
              }
              return items;
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  "Menu",
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      )
          : null,

      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Colors.blue,
              child: const Text(
                "আপনার পছন্দের সকল বই একসাথে, এক প্লাটফর্মে",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Category Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: categories.map((cat) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                        ),
                        onPressed: () {
                          // Navigate to CategoryBooksPage with selected category
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryBooksPage(category: cat),
                            ),
                          );
                        },
                        child: Text(cat),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Latest Books Section (show all)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Latest Books",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('books').orderBy('title').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final books = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final data = books[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: Image.network(
                          data['imageUrl'] ?? '',
                          width: 40,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
                        ),
                        title: Text(data['title'] ?? ''),
                        subtitle: Text("৳${data['price'] ?? ''}"),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => BookDetailsPage(book: books[index])),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 20),
            // Footer Section
            Container(
              color: Colors.grey.shade100,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("About Us", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    "আমাদের কোম্পানি দীর্ঘদিন ধরে অনলাইন বই বিক্রির সাথে জড়িত। আমরা সর্বোচ্চ মানের বই সরবরাহ করি এবং গ্রাহকের সন্তুষ্টিকে সর্বোচ্চ গুরুত্ব দিই।",
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  const Text("Frequently Asked Questions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...[
                    "এই অ্যাপ থেকে বই কিভাবে অর্ডার করব?",
                    "কত দিনের মধ্যে ডেলিভারি হবে?",
                    "বই রিটার্ন করার নীতি কি?",
                    "কিভাবে পেমেন্ট করবেন?",
                    "কোন কোন ক্যাটাগরির বই পাওয়া যাবে?"
                  ].map((q) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text("• $q", style: const TextStyle(fontSize: 14, color: Colors.black87)),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
