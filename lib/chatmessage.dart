import 'dart:io';

class ChatMessage {
  final String content;
  final bool isUser;
  final String type;
  final File? file;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.type,
    this.file,
  });
}