import 'package:flutter/material.dart';
import 'package:mobilelecture1/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: false,
        actions: [
          GestureDetector(
            onTap: () {
              // open profile page later
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade300,
                child: const Icon(Icons.person, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Text(
          user != null
              ? "Welcome, ${user.displayName ?? user.email ?? "User"}"
              : "You're not logged in",
          style: const TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
