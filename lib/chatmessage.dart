import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final XFile? imageFile;
  final TextStyle textStyle;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.imageFile,
    required this.textStyle, 
  });
}