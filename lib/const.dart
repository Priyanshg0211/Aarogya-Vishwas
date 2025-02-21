import 'dart:convert';
import 'package:aarogya_vishwas/chatmessage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

typedef void MessageCallback(ChatMessage message);

class APIService {
  static final APIService instance = APIService();

  final String apiKey =
      'AIzaSyAn_yK3nHk2FinFG4TPeWFQw0ZJd_umlmI';
  final String apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro-latest:generateContent';

  Future<void> getGeminiResponse(String prompt, {XFile? imageFile, required MessageCallback callback}) async {
    try {
      List<Map<String, dynamic>> contents = [];

      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        final base64Image = base64Encode(bytes);
        contents.add({
          'parts': [
            {'text': prompt},
            {
              'inline_data': {'mime_type': 'image/jpeg', 'data': base64Image}
            }
          ]
        });
      } else {
        contents.add({'parts': [{'text': prompt}]});
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': apiKey,
        },
        body: jsonEncode({
          'contents': contents,
          'generationConfig': {
            'temperature': 0.3,
            'topP': 0.95,
            'topK': 64,
            'maxOutputTokens': 8192,
          },
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['candidates'] != null &&
            jsonResponse['candidates'].isNotEmpty &&
            jsonResponse['candidates'][0]['content'] != null) {
          String geminiResponse =
              jsonResponse['candidates'][0]['content']['parts'][0]['text'];

          callback(ChatMessage(text: geminiResponse, isUser: false, textStyle: TextStyle()));
        } else {
          throw Exception('Unexpected response structure from Gemini API');
        }
      } else {
        throw Exception(
            'Failed to get response from Gemini API: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      print('Error details: $e');
      callback(ChatMessage(
          text: "Sorry, I couldn't process that request. Error: $e",
          isUser: false, textStyle: TextStyle(
            
          ), ));
    }
  }
}