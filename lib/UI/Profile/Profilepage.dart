import 'package:aarogya_vishwas/localization/app_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Profilepage extends StatefulWidget {
  const Profilepage({super.key});

  @override
  State<Profilepage> createState() => _ProfilepageState();
}

class _ProfilepageState extends State<Profilepage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _displayName;
  String? _email;
  String? _photoURL;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.email).get();

      if (userDoc.exists) {
        setState(() {
          _displayName = userDoc['displayName'];
          _email = userDoc['email'];
          _photoURL = userDoc['photoURL'];
        });
      }
    }
  }

  // Logout function
  Future<void> _logout(BuildContext context) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        await _auth.signOut(); // Sign out the user
        print('User signed out successfully');
        Navigator.pushReplacementNamed(context, '/auth'); // Navigate to AuthScreen
      } else {
        print('No user is currently signed in');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No user is currently signed in.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error during logout: $e'); // Log the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to logout. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.translate('profile'),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Image
              CircleAvatar(
                radius: 60,
                backgroundImage: _photoURL != null
                    ? NetworkImage(_photoURL!)
                    : AssetImage('assets/default_profile.png') as ImageProvider,
              ),
              SizedBox(height: 20),

              // Display Name
              Text(
                _displayName ?? 'Loading...',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),

              // Email
              Text(
                _email ?? 'Loading...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 40),

              // Logout Button
              ElevatedButton(
                onPressed: () => _logout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.translate('logout'),
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}