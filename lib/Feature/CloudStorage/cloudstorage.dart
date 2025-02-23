import 'package:aarogya_vishwas/Feature/CloudStorage/ImageViewerScreen.dart';
import 'package:aarogya_vishwas/Feature/CloudStorage/PdfViewerScreen.dart';
import 'package:aarogya_vishwas/UI/Homescreen/Homescreen.dart';
import 'package:aarogya_vishwas/localization/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

class DriveScreen extends StatefulWidget {
  const DriveScreen({Key? key}) : super(key: key);

  @override
  _DriveScreenState createState() => _DriveScreenState();
}

class _DriveScreenState extends State<DriveScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;
  String userEmail = '';
  List<Map<String, dynamic>> uploadedDocs = [];
  bool isGridView = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    _loadUploadedDocs();
  }

  Future<void> _loadUploadedDocs() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
    });

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userEmail)
          .collection('uploaded_docs')
          .orderBy('uploaded_at', descending: true)
          .get();

      if (!mounted) return;

      setState(() {
        uploadedDocs = snapshot.docs.map((doc) => doc.data()).toList();
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.translate('error_occurred') ?? 'An error occurred: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      );

      if (result == null) return;

      if (!mounted) return;

      setState(() {
        isLoading = true;
      });

      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;
      String filePath = '$userEmail/$fileName';

      // Upload to Supabase
      await _supabase.storage.from('user_documents').upload(filePath, file);

      final String fileUrl =
          _supabase.storage.from('user_documents').getPublicUrl(filePath);

      // Store metadata in Firestore
      await _firestore
          .collection('users')
          .doc(userEmail)
          .collection('uploaded_docs')
          .add({
        'name': fileName,
        'url': fileUrl,
        'type': fileName.split('.').last.toLowerCase(),
        'uploaded_at': DateTime.now(),
        'size': file.lengthSync(), // File size in bytes
      });

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.translate('file_uploaded_successfully') ?? 
            'File uploaded successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );

      _loadUploadedDocs();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.translate('upload_error') ?? 
            'Error uploading file: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteFile(Map<String, dynamic> doc) async {
    try {
      final String filePath = '$userEmail/${doc['name']}';
      
      // Delete from Supabase storage
      await _supabase.storage.from('user_documents').remove([filePath]);

      // Delete from Firestore
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userEmail)
          .collection('uploaded_docs')
          .where('url', isEqualTo: doc['url'])
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.translate('file_deleted') ?? 
            'File deleted successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );

      _loadUploadedDocs();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.translate('delete_error') ?? 
            'Error deleting file: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openFile(Map<String, dynamic> doc) async {
    final String fileUrl = doc['url'];
    final String fileType = doc['type'].toString().toLowerCase();

    try {
      if (fileType == 'pdf') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerScreen(pdfUrl: fileUrl),
          ),
        );
      } else if (['jpg', 'jpeg', 'png'].contains(fileType)) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageViewerScreen(imageUrl: fileUrl),
          ),
        );
      } else {
        if (await canLaunch(fileUrl)) {
          await launch(fileUrl);
        } else {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)?.translate('could_not_open_file') ?? 
                'Could not open file',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.translate('error_opening_file') ?? 
            'Error opening file: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildFileItem(Map<String, dynamic> doc) {
    final String fileName = doc['name'];
    final String fileUrl = doc['url'];
    final String fileType = doc['type'].toString().toLowerCase();
    final DateTime uploadedAt = (doc['uploaded_at'] as Timestamp).toDate();
    final int fileSize = doc['size'] ?? 0;

    String formattedSize = '';
    if (fileSize < 1024) {
      formattedSize = '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      formattedSize = '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      formattedSize = '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _openFile(doc),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (fileType == 'pdf')
              Icon(Icons.picture_as_pdf, size: 50, color: Colors.red)
            else if (['jpg', 'jpeg', 'png'].contains(fileType))
              CachedNetworkImage(
                imageUrl: fileUrl,
                height: 50,
                width: 50,
                fit: BoxFit.cover,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              )
            else if (['doc', 'docx'].contains(fileType))
              Icon(Icons.description, size: 50, color: Colors.blue)
            else
              Icon(Icons.insert_drive_file, size: 50),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  Text(
                    fileName,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formattedSize,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${uploadedAt.day}/${uploadedAt.month}/${uploadedAt.year}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
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
        backgroundColor: Colors.teal,
        title: Text(
          AppLocalizations.of(context)?.translate('my_drive') ?? 'My Drive',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.white,),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(isGridView ? Icons.list : Icons.grid_view,color: Colors.white,),
            onPressed: _toggleView,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: _uploadFile,
        child: const Icon(Icons.upload,color: Colors.white,),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : uploadedDocs.isEmpty
              ? Center(
                  child: Text(
                    AppLocalizations.of(context)?.translate('no_files_uploaded') ?? 
                    'No files uploaded yet',
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUploadedDocs,
                  child: isGridView
                      ? GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.85,
                          ),
                          padding: const EdgeInsets.all(8),
                          itemCount: uploadedDocs.length,
                          itemBuilder: (context, index) {
                            return _buildFileItem(uploadedDocs[index]);
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: uploadedDocs.length,
                          itemBuilder: (context, index) {
                            final doc = uploadedDocs[index];
                            return Dismissible(
                              key: Key(doc['url']),
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 16),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) => _deleteFile(doc),
                              child: ListTile(
                                leading: _getFileIcon(doc['type']),
                                title: Text(doc['name']),
                                subtitle: Text(
                                  '${AppLocalizations.of(context)?.translate('uploaded_on') ?? 'Uploaded on'}: '
                                  '${doc['uploaded_at'].toDate().toString()}',
                                ),
                                onTap: () => _openFile(doc),
                              ),
                            );
                          },
                        ),
                ),
    );
  }

  Widget _getFileIcon(String fileType) {
    fileType = fileType.toLowerCase();
    if (fileType == 'pdf') {
      return const Icon(Icons.picture_as_pdf, color: Colors.red);
    } else if (['jpg', 'jpeg', 'png'].contains(fileType)) {
      return const Icon(Icons.image, color: Colors.blue);
    } else if (['doc', 'docx'].contains(fileType)) {
      return const Icon(Icons.description, color: Colors.blue);
    }
    return const Icon(Icons.insert_drive_file);
  }

  void _toggleView() {
    setState(() {
      isGridView = !isGridView;
    });
  }
}