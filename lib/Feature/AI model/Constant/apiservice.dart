import 'package:aarogya_vishwas/Feature/AI%20model/widget/chatmessage.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

typedef void MessageCallback(ChatMessage message);

class APIService {
  static final APIService instance = APIService();

  final List<String> apiKeys = [
    'AIzaSyD17qRKuvWm3El7o1HGbf8oMJIz5QgXmJI', // Primary key
    'AIzaSyDgGVCUWSr3t9VGiFyy1FNUsPG53fdmk10', // Secondary key
  ];
  
  int _currentKeyIndex = 0;
  late GenerativeModel _model;

  APIService() {
    _initializeModel();
  }

  void _initializeModel() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash', // Changed from 'gemini-1.5-pro-latest'
      apiKey: apiKeys[_currentKeyIndex],
      generationConfig: GenerationConfig(
        temperature: 0.3,
        topP: 0.95,
        topK: 64,
        maxOutputTokens: 8192,
      ),
    );
  }

  void _switchToNextApiKey() {
    if (apiKeys.length > 1) {
      _currentKeyIndex = (_currentKeyIndex + 1) % apiKeys.length;
      _initializeModel();
      print('Switched to API key ${_currentKeyIndex + 1}');
    }
  }

  // Simple in-memory cache to reduce API calls
  final Map<String, String> _responseCache = {};

  String _generateCacheKey(String prompt, XFile? imageFile) {
    return imageFile != null 
        ? '${prompt}_with_image_${imageFile.name}'
        : prompt;
  }

  Future<void> getGeminiResponse(
    String prompt, {
    XFile? imageFile,
    required MessageCallback callback,
    required String targetLanguage,
  }) async {
    try {
      // Check cache first (only for text-only requests)
      if (imageFile == null) {
        final cacheKey = _generateCacheKey(prompt, null);
        if (_responseCache.containsKey(cacheKey)) {
          callback(ChatMessage(
            text: _responseCache[cacheKey]!,
            isUser: false,
            textStyle: const TextStyle(),
          ));
          return;
        }
      }

      List<Content> contents = [];

      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        contents.add(Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', bytes),
        ]));
      } else {
        contents.add(Content.text(prompt));
      }

      final response = await _generateWithRetry(contents);

      if (response.text != null && response.text!.isNotEmpty) {
        // Cache the response (only for text-only requests)
        if (imageFile == null) {
          final cacheKey = _generateCacheKey(prompt, null);
          _responseCache[cacheKey] = response.text!;
        }

        callback(ChatMessage(
          text: response.text!,
          isUser: false,
          textStyle: const TextStyle(),
        ));
      } else {
        throw Exception('Empty response from Gemini API');
      }
    } catch (e) {
      print('Error details: $e');
      
      if (e.toString().contains('quota') || e.toString().contains('429')) {
        callback(ChatMessage(
          text: "API quota exceeded. Please try again later or consider upgrading your plan.",
          isUser: false,
          textStyle: const TextStyle(),
        ));
      } else {
        callback(ChatMessage(
          text: "Sorry, I couldn't process that request. Error: $e",
          isUser: false,
          textStyle: const TextStyle(),
        ));
      }
    }
  }

  // Retry logic with API key rotation
  Future<GenerateContentResponse> _generateWithRetry(List<Content> contents, {int maxRetries = 3}) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        return await _model.generateContent(contents);
      } catch (e) {
        print('Attempt ${attempt + 1} failed: $e');
        
        // If quota exceeded, try switching API key
        if ((e.toString().contains('quota') || e.toString().contains('429')) && apiKeys.length > 1) {
          _switchToNextApiKey();
          continue; // Try immediately with new key
        }
        
        if (attempt == maxRetries - 1) rethrow;
        
        // Wait before retry (exponential backoff)
        await Future.delayed(Duration(seconds: (attempt + 1) * 2));
      }
    }
    throw Exception('Max retries exceeded');
  }

  // Alternative method for streaming responses (optional)
  Future<void> getGeminiResponseStream(
    String prompt, {
    XFile? imageFile,
    required MessageCallback callback,
    required String targetLanguage,
  }) async {
    try {
      List<Content> contents = [];

      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        contents.add(Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', bytes),
        ]));
      } else {
        contents.add(Content.text(prompt));
      }

      // Generate streaming content
      final response = _model.generateContentStream(contents);
      
      StringBuffer fullResponse = StringBuffer();
      
      await for (final chunk in response) {
        if (chunk.text != null) {
          fullResponse.write(chunk.text);
          // You can update UI progressively here if needed
        }
      }

      if (fullResponse.isNotEmpty) {
        callback(ChatMessage(
          text: fullResponse.toString(),
          isUser: false,
          textStyle: const TextStyle(),
        ));
      } else {
        throw Exception('Empty response from Gemini API');
      }
    } catch (e) {
      print('Error details: $e');
      callback(ChatMessage(
        text: "Sorry, I couldn't process that request. Error: $e",
        isUser: false,
        textStyle: const TextStyle(),
      ));
    }
  }
}