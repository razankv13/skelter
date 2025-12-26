import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:skelter/services/ai/gemini_constants.dart';
import 'package:skelter/utils/app_flavor_env.dart';

/// Service class to handle Google Gemini AI operations
class GeminiService {

  factory GeminiService() {
    _instance ??= GeminiService._();
    return _instance!;
  }
  GeminiService._();

  static GeminiService? _instance;


  GenerativeModel? _model;
  GenerativeModel? _visionModel;

  /// Get Gemini API Key based on current environment
  String get _apiKey {
    final flavor = AppConfig.appFlavor;
    final String envKey = switch (flavor) {
      AppFlavor.dev => 'GEMINI_API_KEY_DEV',
      AppFlavor.stage => 'GEMINI_API_KEY_STAGE',
      AppFlavor.prod => 'GEMINI_API_KEY_PROD',
    };

    debugPrint('[Gemini] Looking for key: $envKey');
    final apiKey = dotenv.env[envKey];

    if (apiKey == null || apiKey.isEmpty || apiKey.contains('your_')) {
      debugPrint('[Gemini] API key not found or invalid for $envKey');
      throw Exception(
        'Gemini API key not configured for ${flavor.name} environment. '
        'Please add $envKey to .env file',
      );
    }

    debugPrint('[Gemini] API key found (length: ${apiKey.length})');
    return apiKey;
  }

  /// Initialize Gemini models
  void initialize() {
    try {
      debugPrint('[Gemini] Initializing Gemini Service...');
      final apiKey = _apiKey;

      // Initialize text generation model
      // Note: Using simple initialization without systemInstruction
      // as it may not be supported in all API versions
      _model = GenerativeModel(
        model: GeminiConstants.geminiProModel,
        apiKey: apiKey,
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
      _visionModel = GenerativeModel(
        model: GeminiConstants.geminiProVisionModel,
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: GeminiConstants.temperature,
          maxOutputTokens: GeminiConstants.maxOutputTokens,
          topP: GeminiConstants.topP,
          topK: GeminiConstants.topK,
          stopSequences: ['\n\n---\n\n', 'END_OF_DESCRIPTION'],
        ),
      );

      debugPrint('[Gemini] Service initialized successfully');
    } catch (e) {
      debugPrint('[Gemini] Initialization failed: $e');
      throw Exception('Failed to initialize Gemini Service: $e');
    }
  }

  /// Generate text content using Gemini
  Future<String> generateContent({
    required String prompt,
    Duration? timeout,
  }) async {
    debugPrint('[Gemini] Generate content called');
    debugPrint('[Gemini] Prompt length: ${prompt.length}');

    if (_model == null) {
      debugPrint('[Gemini] ERROR: Model not initialized!');
      throw Exception(
        'Gemini Service not initialized. Call initialize() first.',
      );
    }

    try {
      debugPrint('[Gemini] Sending request to Gemini API...');
      final response = await _model!
          .generateContent([Content.text(prompt)])
          .timeout(timeout ?? GeminiConstants.apiTimeout);

      debugPrint('[Gemini] Response received');
      final text = response.text;

      if (text == null || text.isEmpty) {
        debugPrint('[Gemini] ERROR: Empty response from API');
        throw Exception('Empty response from Gemini API');
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
        'Gemini Vision Service not initialized. Call initialize() first.',
      );
    }

    try {
      final content = <Content>[
        Content.multi([
          TextPart(prompt),
          // Note: For production, you'd need to download and convert images to 
          // DataPart
          // This is a simplified version
        ]),
      ];

      final response = await _visionModel!
          .generateContent(content)
          .timeout(timeout ?? GeminiConstants.apiTimeout);

      final text = response.text;
      if (text == null || text.isEmpty) {
        throw Exception('Empty response from Gemini Vision API');
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
        'Gemini Service not initialized. Call initialize() first.',
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
