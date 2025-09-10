import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddBookPage extends StatefulWidget {
  final String? bookId;
  final Map<String, dynamic>? existingData;

  const AddBookPage({super.key, this.bookId, this.existingData});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final imageUrlController = TextEditingController();
  final descriptionController = TextEditingController();
  String selectedCategory = 'Academic';

  final List<String> categories = ['Academic', 'Fiction', 'Non Fiction'];

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      titleController.text = widget.existingData!['title'] ?? '';
      priceController.text = widget.existingData!['price']?.toString() ?? '';
      imageUrlController.text = widget.existingData!['imageUrl'] ?? '';
      descriptionController.text = widget.existingData!['description'] ?? '';
      selectedCategory = widget.existingData!['category'] ?? 'Academic';
    }
  }

  Future<void> addBook() async {
    if (titleController.text.trim().isEmpty || priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠ Please fill title & price")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('books').add({
      'title': titleController.text.trim(),
      'price': double.tryParse(priceController.text.trim()) ?? 0,
      'imageUrl': imageUrlController.text.trim(),
      'description': descriptionController.text.trim(),
      'category': selectedCategory,
    });

    Navigator.pop(context);
  }

  Future<void> updateBook(String id) async {
    await FirebaseFirestore.instance.collection('books').doc(id).update({
      'title': titleController.text.trim(),
      'price': double.tryParse(priceController.text.trim()) ?? 0,
      'imageUrl': imageUrlController.text.trim(),
      'description': descriptionController.text.trim(),
      'category': selectedCategory,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.bookId != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? "Edit Book" : "Add Book")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Book Title"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Price"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(labelText: "Image URL"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text("Category: ", style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: selectedCategory,
                    items: categories
                        .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedCategory = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // TextButton instead of ElevatedButton
              TextButton(
                onPressed: () {
                  if (isEditing) {
                    updateBook(widget.bookId!);
                  } else {
                    addBook();
                  }
                },
                child: Text(
                  isEditing ? "Update Book" : "Add Book",
                  style: const TextStyle(color: Colors.blue, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
