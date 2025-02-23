import 'package:aarogya_vishwas/UI/Homescreen/Homescreen.dart';
import 'package:aarogya_vishwas/UI/authscreen/authscreen.dart';
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.email).get();

        if (userDoc.exists && mounted) {
          setState(() {
            _displayName = userDoc['displayName'];
            _email = userDoc['email'];
            _photoURL = userDoc['photoURL'];
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  // Simplified and fixed logout function
  Future<void> _logout(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(
          Duration(milliseconds: 100)); // Small delay to ensure UI updates
      await _auth.signOut();

      if (!mounted) return;

      // Navigate to auth screen and clear stack
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => AuthScreen()));
    } catch (e) {
      print('Error during logout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to logout. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                    (route) =>
                        false, // This removes all previous routes from the stack
                  );
                },
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                AppLocalizations.of(context)!.translate('Profile'),
              ),
            ],
          ),
          centerTitle: true,
          backgroundColor: Colors.teal,
          automaticallyImplyLeading: false, // Remove back button
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
                      : AssetImage('assets/default_profile.png')
                          as ImageProvider,
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
                  onPressed: _isLoading ? null : () => _logout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
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
      ),
    );
  }
}
