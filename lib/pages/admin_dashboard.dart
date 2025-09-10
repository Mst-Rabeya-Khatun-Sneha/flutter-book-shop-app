import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_book.dart';
import 'role_switcher.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool isAdminView = true;

  void switchRole() {
    setState(() {
      isAdminView = !isAdminView;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isAdminView) {
      // যদি role switch হয়, সরাসরি HomePage দেখাবে
      return const AdminRoleSwitcher();
    }

    return Scaffold(
      // AppBar সরানো হলো
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('books').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final books = snapshot.data!.docs;
          if (books.isEmpty) return const Center(child: Text("No books added yet"));

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: Image.network(
                    book['imageUrl'] ?? '',
                    width: 50,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
                  ),
                  title: Text(book['title'] ?? ''),
                  subtitle: Text("৳${book['price'] ?? ''}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddBookPage(bookId: books[index].id, existingData: book),
                            ),
                          );
                        },
                        child: const Text("Edit", style: TextStyle(color: Colors.blue)),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          FirebaseFirestore.instance.collection('books').doc(books[index].id).delete();
                        },
                        child: const Text("Delete", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddBookPage()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
