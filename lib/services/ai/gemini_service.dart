import 'dart:async';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:skelter/services/ai/gemini_constants.dart';

/// Service class to handle Firebase AI (Gemini) operations
/// Uses Firebase AI SDK which requires Firebase project setup with Vertex AI 
/// API enabled

class GeminiService {
  factory GeminiService() {
    _instance ??= GeminiService._();
    return _instance!;
  }

  GeminiService._();

  static GeminiService? _instance;

  GenerativeModel? _model;
  GenerativeModel? _visionModel;

  /// Initialize Gemini models via Firebase AI
  /// Requires Firebase to be initialized first
  void initialize() {
    try {
      debugPrint('[Gemini] Initializing Firebase AI Gemini Service...');

      // Initialize text generation model using Firebase AI
      // Firebase AI uses the Developer API backend (no API key needed in code)
      _model = FirebaseAI.googleAI().generativeModel(
        model: GeminiConstants.geminiProModel,
        generationConfig: GenerationConfig(
          temperature: GeminiConstants.temperature,
          maxOutputTokens: GeminiConstants.maxOutputTokens,
          topP: GeminiConstants.topP,
          topK: GeminiConstants.topK,
          stopSequences: ['\n\n---\n\n', 'END_OF_DESCRIPTION'],
        ),
      );

      debugPrint(
        '[Gemini] Text model initialized: ${GeminiConstants.geminiProModel}',
      );

      // Initialize vision model for image analysis
      _visionModel = FirebaseAI.googleAI().generativeModel(
        model: GeminiConstants.geminiProVisionModel,
        generationConfig: GenerationConfig(
          temperature: GeminiConstants.temperature,
          maxOutputTokens: GeminiConstants.maxOutputTokens,
          topP: GeminiConstants.topP,
          topK: GeminiConstants.topK,
          stopSequences: ['\n\n---\n\n', 'END_OF_DESCRIPTION'],
        ),
      );

      debugPrint('[Gemini] Firebase AI Service initialized successfully');
    } catch (e) {
      debugPrint('[Gemini] Initialization failed: $e');
      throw Exception('Failed to initialize Firebase AI Gemini Service: $e');
    }
  }

  /// Generate text content using Gemini via Firebase AI
  Future<String> generateContent({
    required String prompt,
    Duration? timeout,
  }) async {
    debugPrint('[Gemini] Generate content called');
    debugPrint('[Gemini] Prompt length: ${prompt.length}');

    if (_model == null) {
      debugPrint('[Gemini] ERROR: Model not initialized!');
      throw Exception(
        'Firebase AI Gemini Service not initialized. Call initialize() first.',
      );
    }

    try {
      debugPrint('[Gemini] Sending request to Firebase AI Gemini API...');
      final response = await _model!
          .generateContent([Content.text(prompt)])
          .timeout(timeout ?? GeminiConstants.apiTimeout);

      debugPrint('[Gemini] Response received');
      final text = response.text;

      if (text == null || text.isEmpty) {
        debugPrint('[Gemini] ERROR: Empty response from API');
        throw Exception('Empty response from Firebase AI Gemini API');
      }

      debugPrint('[Gemini] Success: Generated ${text.length} characters');
      return text;
    } on TimeoutException catch (e) {
      debugPrint('[Gemini] ERROR: Timeout - $e');
      throw Exception('Request timeout: $e');
    } catch (e) {
      debugPrint('[Gemini] ERROR: $e');
      throw Exception('Failed to generate content: $e');
    }
  }

  /// Generate content with image analysis
  Future<String> generateContentWithImages({
    required String prompt,
    required List<String> imageUrls,
    Duration? timeout,
  }) async {
    if (_visionModel == null) {
      throw Exception(
        'Firebase AI Gemini Vision Service not initialized. '
        'Call initialize() first.',
      );
    }

    try {
      final content = <Content>[
        Content.multi([
          TextPart(prompt),
          // Note: For production, you'd need to download and convert images to
          // InlineDataPart using FileData or InlineData
          // This is a simplified version
        ]),
      ];

      final response = await _visionModel!
          .generateContent(content)
          .timeout(timeout ?? GeminiConstants.apiTimeout);

      final text = response.text;
      if (text == null || text.isEmpty) {
        throw Exception('Empty response from Firebase AI Gemini Vision API');
      }

      return text;
    } catch (e) {
      throw Exception('Failed to generate content with images: $e');
    }
  }

  /// Generate streaming content (for real-time responses)
  Stream<String> generateContentStream({required String prompt}) async* {
    if (_model == null) {
      throw Exception(
        'Firebase AI Gemini Service not initialized. Call initialize() first.',
      );
    }

    try {
      final response = _model!.generateContentStream([Content.text(prompt)]);

      await for (final chunk in response) {
        final text = chunk.text;
        if (text != null && text.isNotEmpty) {
          yield text;
        }
      }
    } catch (e) {
      throw Exception('Failed to generate streaming content: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _model = null;
    _visionModel = null;
    _instance = null;
  }
}
