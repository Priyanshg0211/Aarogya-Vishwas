// lib/services/gemini_service.dart
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static GenerativeModel createModel() {
    const apiKey = 'AIzaSyAn_yK3nHk2FinFG4TPeWFQw0ZJd_umlmI'; // Replace with your actual API key
    return GenerativeModel(
      model: 'gemini-pro-vision',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 2048,
      ),
    );
  }
}