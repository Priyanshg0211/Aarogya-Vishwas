import 'package:aarogya_vishwas/UI/Homescreen/Homescreen.dart';
import 'package:aarogya_vishwas/localization/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class ConsultationScreen extends StatefulWidget {
  @override
  _ConsultationScreenState createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _issueController = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  String userEmail = '';
  String currentLanguage = 'en'; // Default language
  late TextInputType keyboardType;

  @override
  void initState() {
    super.initState();
    _fetchUserEmail();
    _setupFirestoreListener();
  }

  void _initializeKeyboard(BuildContext context) {
    // Get the current language from your app's language settings
    currentLanguage = AppLocalizations.of(context)?.locale.languageCode ?? 'en';
    _updateKeyboardType();
  }

  void _updateKeyboardType() {
    // Set keyboard type based on language
    switch (currentLanguage) {
      case 'hi':
        keyboardType = TextInputType.text;
        break;
      default:
        keyboardType = TextInputType.text;
    }
  }

  void _fetchUserEmail() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email ?? '';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.translate('userNotLoggedIn') ??
                'User not logged in',
          ),
        ),
      );
    }
  }

  void _setupFirestoreListener() {
    if (userEmail.isEmpty) return;

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
            _showNotification(
              AppLocalizations.of(context)?.translate('consultationAccepted') ??
                  'Consultation Accepted',
              AppLocalizations.of(context)?.translate('consultationAcceptedDesc') ??
                  'Your consultation has been accepted.',
            );
          }
        }
      }
    });
  }

  void _requestConsultation() async {
    if (_nameController.text.isEmpty || _issueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.translate('fillAllFields') ??
                'Please fill all fields',
          ),
        ),
      );
      return;
    }

    if (userEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.translate('userEmailNotFound') ??
                'User email not found',
          ),
        ),
      );
      return;
    }

    await _firestore
        .collection('users')
        .doc(userEmail)
        .collection('consultations')
        .add({
      "name": _nameController.text,
      "issue": _issueController.text,
      "status": "Pending",
      "timestamp": DateTime.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)?.translate('consultationRequested') ??
              'Consultation requested',
        ),
      ),
    );

    _nameController.clear();
    _issueController.clear();
  }

  void _showNotification(String title, String body) {
    _scaffoldKey.currentState?.showSnackBar(
      SnackBar(
        content: Text("$title: $body"),
        duration: Duration(seconds: 5),
      ),
    );
  }

  void _joinVideoCall() async {
    const url = "https://meet.google.com/abc-xyz-123";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.translate('videoCallLaunchError') ??
                'Could not launch video call',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _initializeKeyboard(context); // Initialize keyboard here

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
         leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomeScreen()));
          },
        ),
        title: Text(
          AppLocalizations.of(context)?.translate('telemedicine') ??
              'Telemedicine',
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText:
                    AppLocalizations.of(context)?.translate('yourName') ?? 'Your Name',
              ),
              keyboardType: keyboardType,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _issueController,
              decoration: InputDecoration(
                labelText:
                    AppLocalizations.of(context)?.translate('describeIssue') ??
                        'Describe Issue',
              ),
              maxLines: 3,
              keyboardType: keyboardType,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _requestConsultation,
              child: Text(
                AppLocalizations.of(context)?.translate('requestConsultation') ??
                    'Request Consultation',
              ),
            ),
            SizedBox(height: 32),
            Text(
              AppLocalizations.of(context)?.translate('yourConsultations') ??
                  'Your Consultations',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
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
                      final consultation =
                          consultations[index].data() as Map<String, dynamic>;
                      final status = consultation['status'];
                      final issue = consultation['issue'];
                      final name = consultation['name'];

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            "$name - ${AppLocalizations.of(context)?.translate(status.toLowerCase()) ?? status}",
                          ),
                          subtitle: Text(issue),
                          trailing: status == "Accepted"
                              ? IconButton(
                                  icon: Icon(Icons.video_call),
                                  onPressed: _joinVideoCall,
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
}