import 'dart:async';
import 'dart:io';
import 'package:aarogya_vishwas/Feature/AI%20model/Constant/apiservice.dart';
import 'package:aarogya_vishwas/Feature/AI%20model/widget/chatmessage.dart';
import 'package:aarogya_vishwas/UI/Homescreen/Homescreen.dart';
import 'package:aarogya_vishwas/localization/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart' show XFile;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ChatMessage> messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isGeneratingResponse = false;
  Timer? _debounce;
  bool _isPickerActive = false;
  String _selectedLanguage = 'en';
  final FlutterTts flutterTts = FlutterTts();

  final Map<String, String> languages = {
    'en': 'English',
    'hi': 'Hindi',
    'bn': 'Bengali',
    'mr': 'Marathi',
  };

  @override
  void initState() {
    super.initState();
    _initializeTTS();
  }

  Future<void> _initializeTTS() async {
    await flutterTts.setLanguage(_selectedLanguage);
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    flutterTts.stop();
    super.dispose();
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    _addMessage(ChatMessage(text: text, isUser: true, textStyle: TextStyle()));
    _setGeneratingResponse(true);
    APIService.instance.getGeminiResponse(
      text,
      targetLanguage: _selectedLanguage,
      callback: (message) {
        if (mounted) {
          _addMessage(message);
          _setGeneratingResponse(false);
        }
      },
    );
  }

  Future<void> _speakText(String text) async {
    await flutterTts.setLanguage(_selectedLanguage);
    await flutterTts.speak(text);
  }

  Future<void> _generateAndSharePDF(String text) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text(
                    'Medical Report Summary',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  text,
                  style: pw.TextStyle(fontSize: 14),
                ),
              ],
            );
          },
        ),
      );

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final fileName =
          'medical_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${directory.path}/$fileName';

      // Save the PDF
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // Create XFile from the saved PDF
      final xFile = XFile(file.path);

      // Share the file
      await Share.shareXFiles(
        [xFile],
        text: 'Medical Report Summary',
      );
    } catch (e) {
      print('Error generating/sharing PDF: $e');
      // Optionally show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _setGeneratingResponse(bool value) {
    if (mounted) {
      setState(() {
        _isGeneratingResponse = value;
      });
    }
  }

  void _addMessage(ChatMessage message) {
    if (mounted) {
      setState(() {
        messages.insert(0, message);
      });
      _scrollController.animateTo(
        0.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMediaMessage() async {
    if (_isPickerActive) return;

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      _isPickerActive = true;
      try {
        ImagePicker picker = ImagePicker();
        XFile? file = await picker.pickImage(source: ImageSource.gallery);
        if (file != null && mounted) {
          TextStyle messageTextStyle = TextStyle(
            fontFamily: 'Product Sans Medium',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          );

          _addMessage(ChatMessage(
            text: AppLocalizations.of(context)!
                .translate('Summarize this Medical Report'),
            isUser: true,
            imageFile: file,
            textStyle: messageTextStyle,
          ));

          const String defaultPrompt = """
You are an advanced medical report analysis AI. Your task is to extract and summarize the key information from the uploaded medical report image. Follow these structured steps for extraction and summarization:

Patient Information
Patient Name: Extract the full name.
Age & Gender: Extract the age in years, months, and days along with the gender.
UHID: Extract the Unique Hospital Identification Number.
Bed/Ward: Mention the bed/ward details if available.
Referring Doctor: Extract the name of the referring doctor.
Prescribed By: Extract the name of the prescribing doctor.
Patient Address: Extract the address if available.

Test Details
For each test listed in the report, extract the following details in a structured format:
Test Name: Name of the test performed.
Result: Numerical value of the result.
Unit: Mention the measurement unit (e.g., sec, INR, ratio).
Biological Reference Range: Extract the normal reference range.
Method: Specify the method used if mentioned.

Abnormal Values
Identify and highlight any test results that fall outside the normal reference range.
Indicate whether the result is higher or lower than the normal range.

Summary
Provide a brief medical summary based on the extracted results, including:

A general overview of the report.
Any significant abnormalities and their potential medical implications.
If applicable, mention if further clinical correlation is required.
          """;

          _setGeneratingResponse(true);
          APIService.instance.getGeminiResponse(
            defaultPrompt,
            imageFile: file,
            targetLanguage: _selectedLanguage,
            callback: (ChatMessage message) {
              if (mounted) {
                _addMessage(ChatMessage(
                  text: message.text,
                  isUser: false,
                  imageFile: message.imageFile,
                  textStyle: messageTextStyle,
                ));
                _setGeneratingResponse(false);
              }
            },
          );
        }
      } finally {
        _isPickerActive = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.translate('appTitle'),
          style: TextStyle(
            fontFamily: 'Product Sans Medium',
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.language, color: Colors.white),
            onSelected: (String value) {
              setState(() => _selectedLanguage = value);
              _initializeTTS();
            },
            itemBuilder: (BuildContext context) {
              return languages.entries.map((entry) {
                return PopupMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _handleRefresh,
            backgroundColor: Colors.teal,
            color: Colors.white,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageItem(messages[index]);
                    },
                  ),
                ),
                _buildMessageComposer(),
              ],
            ),
          ),
          if (_isGeneratingResponse)
            Center(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!
                          .translate('generatingReportSummary'),
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Product Sans',
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    if (mounted) {
      setState(() {
        messages.clear();
      });
    }
  }

  Widget _buildMessageItem(ChatMessage message) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      child: Align(
        alignment:
            message.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: message.isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (message.imageFile != null)
              GestureDetector(
                onTap: () {
                  _showImageDialog(message.imageFile!.path);
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 8),
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    image: DecorationImage(
                      image: FileImage(File(message.imageFile!.path)),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Icon(Icons.zoom_in, color: Colors.white),
                ),
              ),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.teal.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.teal.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  message.isUser
                      ? Text(message.text)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MarkdownBody(
                              data: message.text,
                              styleSheet: MarkdownStyleSheet(
                                p: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'SofiaPro',
                                ),
                                strong: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'SofiaPro',
                                ),
                              ),
                            ),
                            if (!message.isUser) ...[
                              SizedBox(height: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.volume_up,
                                        color: Colors.teal),
                                    onPressed: () => _speakText(message.text),
                                    constraints: BoxConstraints.tightFor(
                                      width: 35,
                                      height: 35,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(Icons.picture_as_pdf,
                                        color: Colors.teal),
                                    onPressed: () =>
                                        _generateAndSharePDF(message.text),
                                    constraints: BoxConstraints.tightFor(
                                      width: 35,
                                      height: 35,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageDialog(String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(imagePath),
                      width: MediaQuery.of(context).size.width * 0.8,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              cursorColor: Colors.white,
              controller: _textController,
              decoration: InputDecoration(
                hintText:
                    AppLocalizations.of(context)!.translate('Send Message'),
                hintStyle: TextStyle(
                  fontFamily: 'Product Sans Mediumr',
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
                filled: true,
                fillColor: Colors.teal,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: Colors.white,
                    width: 1.0,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 14.0,
                ),
                prefixIcon: IconButton(
                  icon: Icon(
                    Icons.image,
                    color: Colors.white,
                  ),
                  onPressed: _sendMediaMessage,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                  onPressed: () => _handleSubmitted(_textController.text),
                ),
              ),
              style: TextStyle(
                fontFamily: 'Product Sans Medium',
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
              onSubmitted: (_) => _handleSubmitted(_textController.text),
            ),
          ),
        ],
      ),
    );
  }
}
