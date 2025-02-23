import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this

class ConsultationScreen extends StatefulWidget {
  @override
  _ConsultationScreenState createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Add this
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _issueController = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  String userEmail = ''; // Initialize as empty

  @override
  void initState() {
    super.initState();
    _fetchUserEmail(); // Fetch the user's email
    _setupFirestoreListener();
  }

  // Fetch the user's email
  void _fetchUserEmail() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email ?? '';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not logged in")),
      );
    }
  }

  // Set up a Firestore listener for consultation updates
  void _setupFirestoreListener() {
    if (userEmail.isEmpty) return; // Skip if userEmail is not set

    _firestore
        .collection('users')
        .doc(userEmail)
        .collection('consultations')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          final consultation = change.doc.data() as Map<String, dynamic>;
          if (consultation['status'] == "Accepted") {
            print("Consultation accepted! Showing notification..."); // Debug log
            _showNotification("Consultation Accepted",
                "Your consultation has been accepted. Connect via phone or video.");
          }
        }
      }
    });
  }

  // Request a consultation
  void _requestConsultation() async {
    if (_nameController.text.isEmpty || _issueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    if (userEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User email not found")),
      );
      return;
    }

    // Add consultation request to Firestore
    await _firestore
        .collection('users')
        .doc(userEmail)
        .collection('consultations')
        .add({
      "name": _nameController.text,
      "issue": _issueController.text,
      "status": "Pending", // Pending, Accepted, Completed
      "timestamp": DateTime.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Consultation requested successfully!")),
    );

    _nameController.clear();
    _issueController.clear();
  }

  // Show a notification using Snackbar
  void _showNotification(String title, String body) {
    _scaffoldKey.currentState?.showSnackBar(
      SnackBar(
        content: Text("$title: $body"),
        duration: Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text("Telemedicine Consultation")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Your Name"),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _issueController,
              decoration: InputDecoration(labelText: "Describe your issue"),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _requestConsultation,
              child: Text("Request Consultation"),
            ),
            SizedBox(height: 32),
            Text("Your Consultations", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(userEmail)
                    .collection('consultations')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final consultations = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: consultations.length,
                    itemBuilder: (context, index) {
                      final consultation = consultations[index].data() as Map<String, dynamic>;
                      final status = consultation['status'];
                      final issue = consultation['issue'];
                      final name = consultation['name'];

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text("$name - $status"),
                          subtitle: Text(issue),
                          trailing: status == "Accepted"
                              ? IconButton(
                                  icon: Icon(Icons.video_call),
                                  onPressed: () {
                                    // Simulate joining a video call
                                    _joinVideoCall();
                                  },
                                )
                              : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Simulate joining a video call
  void _joinVideoCall() async {
    // Replace with your video call link (e.g., Zoom, Google Meet)
    const url = "https://meet.google.com/abc-xyz-123";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not launch video call")),
      );
    }
  }
}