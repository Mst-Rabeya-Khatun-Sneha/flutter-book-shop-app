import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pages/home_page.dart';
import '../pages/admin_dashboard.dart';

class AdminRoleSwitcher extends StatefulWidget {
  const AdminRoleSwitcher({super.key});

  @override
  State<AdminRoleSwitcher> createState() => _AdminRoleSwitcherState();
}

class _AdminRoleSwitcherState extends State<AdminRoleSwitcher> {
  bool isAdminView = true;
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
      if (userRole != 'admin') isAdminView = false; // non-admin cannot access admin
    });
  }

  void toggleRole() {
    setState(() {
      isAdminView = !isAdminView;
    });
  }

  PopupMenuButton<String> buildMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'switch') {
          toggleRole(); // toggle admin/user view
        } else if (value == 'logout') {
          await FirebaseAuth.instance.signOut();
        }
      },
      itemBuilder: (context) {
        List<PopupMenuEntry<String>> items = [
          if (userRole == 'admin')
            const PopupMenuItem(
              value: 'switch',
              child: Text("Switch Role", style: TextStyle(color: Colors.blue)),
            ),
          const PopupMenuItem(
            value: 'logout',
            child: Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ];
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
    );
  }

  AppBar buildAppBar(String title) {
    return AppBar(
      title: Text(title),
      actions: [buildMenu()],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userRole == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: buildAppBar(isAdminView ? "Admin Dashboard" : "Online Bookstore"),
      body: isAdminView
          ? AdminDashboardPage(
        // pass toggleRole to AdminDashboardPage if needed
      )
          : const HomePage(),
    );
  }
}
