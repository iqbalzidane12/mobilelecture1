import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? currentUser;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  late TextEditingController _ageController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;

    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _bioController = TextEditingController();
    _ageController = TextEditingController();

    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  // LOAD DATA FROM FIRESTORE
  Future<void> _loadUserProfile() async {
    if (currentUser == null) return;

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        setState(() {
          _nameController.text = data['full_name'] ?? '';
          _emailController.text = data['email'] ?? '';
          _bioController.text = data['description'] ?? '';
          _ageController.text = data['age']?.toString() ?? '';
        });
      } else {
        _showSnackBar('No profile data found');
      }
    } catch (e) {
      _showSnackBar('Error loading profile: $e');
    }
  }

  // UPDATE FIRESTORE DOCUMENT
  Future<void> _updateProfile() async {
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .set({
        'full_name': _nameController.text,
        'email': _emailController.text,
        'description': _bioController.text,
        'age': int.tryParse(_ageController.text) ?? 0,
      }, SetOptions(merge: true));

      _showSnackBar('Profile updated successfully!');
    } catch (e) {
      _showSnackBar('Error updating profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Full Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _bioController,
              decoration: const InputDecoration(labelText: "Description"),
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: "Age"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _updateProfile,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Save Changes"),
            )
          ],
        ),
      ),
    );
  }
}
