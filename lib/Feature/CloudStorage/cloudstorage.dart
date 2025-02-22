import 'package:aarogya_vishwas/Feature/CloudStorage/ImageViewerScreen.dart';
import 'package:aarogya_vishwas/Feature/CloudStorage/PdfViewerScreen.dart';
import 'package:aarogya_vishwas/UI/Homescreen/Homescreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

class DriveScreen extends StatefulWidget {
  @override
  _DriveScreenState createState() => _DriveScreenState();
}

class _DriveScreenState extends State<DriveScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;
  String userEmail = ''; // Initialize with empty string
  List<Map<String, dynamic>> uploadedDocs = [];
  bool isGridView = true; // Toggle between grid and list view

  @override
  void initState() {
    super.initState();
    userEmail =
        FirebaseAuth.instance.currentUser?.email ?? ''; // Set user email
    _loadUploadedDocs();
  }

  Future<void> _loadUploadedDocs() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userEmail)
          .collection('uploaded_docs')
          .get();
      setState(() {
        uploadedDocs = snapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading files: $e')),
      );
    }
  }

  Future<void> _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;
      String filePath = '$userEmail/$fileName'; // Store in user-specific folder

      try {
        // Upload to Supabase
        await _supabase.storage.from('user_documents').upload(filePath, file);

        // Get the file URL
        final String fileUrl =
            _supabase.storage.from('user_documents').getPublicUrl(filePath);

        // Save metadata to Firestore
        await _firestore
            .collection('users')
            .doc(userEmail)
            .collection('uploaded_docs')
            .add({
          'name': fileName,
          'url': fileUrl,
          'type': fileName.split('.').last, // File type (e.g., pdf, jpg)
          'uploaded_at': DateTime.now(),
        });

        // Refresh the list
        _loadUploadedDocs();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _toggleView() {
    setState(() {
      isGridView = !isGridView;
    });
  }

  void _openFile(Map<String, dynamic> doc) async {
    final String fileUrl = doc['url'];
    final String fileType = doc['type'];

    if (fileType == 'pdf') {
      // Open PDF in PDF Viewer
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerScreen(pdfUrl: fileUrl),
        ),
      );
    } else if (fileType == 'jpg' || fileType == 'png') {
      // Open Image in Image Viewer
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageViewerScreen(imageUrl: fileUrl),
        ),
      );
    } else {
      // Open other files in a browser
      if (await canLaunch(fileUrl)) {
        await launch(fileUrl);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open file')),
        );
      }
    }
  }

  Widget _buildFileItem(Map<String, dynamic> doc) {
    final String fileName = doc['name'];
    final String fileUrl = doc['url'];
    final String fileType = doc['type'];

    return GestureDetector(
      onTap: () => _openFile(doc), // Pass the entire document
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (fileType == 'pdf')
              Icon(Icons.picture_as_pdf, size: 50, color: Colors.red)
            else if (fileType == 'jpg' || fileType == 'png')
              CachedNetworkImage(
                imageUrl: fileUrl,
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              )
            else
              Icon(Icons.insert_drive_file, size: 50),
            SizedBox(height: 8),
            Text(
              fileName,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Drive'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Back icon
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeScreen())); // Navigate back
          },
        ),
        actions: [
          IconButton(
            icon: Icon(isGridView ? Icons.list : Icons.grid_view),
            onPressed: _toggleView,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadFile,
        child: Icon(Icons.upload),
      ),
      body: uploadedDocs.isEmpty
          ? Center(child: Text('No files uploaded yet.'))
          : RefreshIndicator(
              onRefresh: _loadUploadedDocs, // Refresh function
              child: isGridView
                  ? GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      padding: EdgeInsets.all(8),
                      itemCount: uploadedDocs.length,
                      itemBuilder: (context, index) {
                        return _buildFileItem(uploadedDocs[index]);
                      },
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(8),
                      itemCount: uploadedDocs.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: _buildFileItem(uploadedDocs[index]),
                          title: Text(uploadedDocs[index]['name']),
                          subtitle: Text(
                              'Uploaded on ${uploadedDocs[index]['uploaded_at'].toDate().toString()}'),
                          onTap: () => _openFile(uploadedDocs[index]),
                        );
                      },
                    ),
            ),
    );
  }
}
