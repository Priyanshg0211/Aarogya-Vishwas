import 'dart:async';
import 'dart:io';
import 'package:aarogya_vishwas/Feature/AI%20model/widget/chatmessage.dart';
import 'package:aarogya_vishwas/Feature/AI%20model/Constant/apiservice.dart';
import 'package:aarogya_vishwas/UI/Homescreen/Homescreen.dart';
import 'package:aarogya_vishwas/localization/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';

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

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    _addMessage(ChatMessage(text: text, isUser: true, textStyle: TextStyle()));
    _setGeneratingResponse(true);
    APIService.instance.getGeminiResponse(text, callback: (message) {
      if (mounted) {
        _addMessage(message);
        _setGeneratingResponse(false);
      }
    });
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
            fontFamily: 'SofiaPro',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          );

          _addMessage(ChatMessage(
            text: AppLocalizations.of(context)!
                .translate('summarizeMedicalReport'),
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
          APIService.instance.getGeminiResponse(defaultPrompt, imageFile: file,
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
          });
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
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ), // Back icon
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeScreen())); // Navigate back
          },
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!
              .translate('appTitle'), // Localized title
          style: TextStyle(
            fontFamily: 'Product Sans Medium',
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Add logout functionality
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _handleRefresh,
            backgroundColor: Colors.grey[900],
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
                    SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.translate(
                          'generatingReportSummary'), // Localized text
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
                color: message.isUser ? Colors.white : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: message.isUser
                  ? Text(message.text)
                  : MarkdownBody(
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
                hintText: AppLocalizations.of(context)!
                    .translate('sendMessage'), // Localized hint text
                hintStyle: TextStyle(
                  fontFamily: 'SofiaPro',
                  fontWeight: FontWeight.w400,
                  color: Colors.white54,
                ),
                filled: true,
                fillColor: Colors.grey[600],
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
                    color: Colors.black,
                  ),
                  onPressed: _sendMediaMessage,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Colors.black,
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
