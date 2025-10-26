import 'package:dio/dio.dart';
import './http_proxy.dart';
import 'dart:convert';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  late final Dio _dio;
  static const String apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String ohmyApiKey = String.fromEnvironment('OHMYGPT_API_KEY');
  static const String provider = String.fromEnvironment('PROVIDER', defaultValue: 'gemini');
  static const String ohmyModel = String.fromEnvironment(
    'OHMYGPT_MODEL',
    defaultValue: 'gpt-4o-mini',
  );
  // Support both OHMYGPT_BASE_URL and legacy OHMYGPT_API_BASE_URL
  static const String ohmyBaseUrl = String.fromEnvironment(
    'OHMYGPT_BASE_URL',
    defaultValue: '',
  );
  static const String ohmyApiBaseUrlLegacy = String.fromEnvironment(
    'OHMYGPT_API_BASE_URL',
    defaultValue: '',
  );

  // Proxy controls (all optional)
  static const String proxyEnabledStr = String.fromEnvironment(
    'PROXY_ENABLED',
    defaultValue: 'false',
  );
  static const int proxyPort = int.fromEnvironment(
    'PROXY_PORT',
    defaultValue: 7890,
  );
  static const String proxyHost = String.fromEnvironment(
    'PROXY_HOST',
    defaultValue: '',
  );
  static const String proxyAllowBadCertStr = String.fromEnvironment(
    'PROXY_ALLOW_BAD_CERT',
    defaultValue: 'false',
  );

  // Debug logging (optional): set LLM_DEBUG=true to print requests/responses
  static const String llmDebugStr = String.fromEnvironment(
    'LLM_DEBUG',
    defaultValue: 'false',
  );

  factory GeminiService() => _instance;

  GeminiService._internal() {
    _initializeService();
  }

  void _initializeService() {
    // Validate required keys for selected provider
    if (provider == 'gpt') {
      if (ohmyApiKey.isEmpty) {
        throw Exception('OHMYGPT_API_KEY must be provided via --dart-define');
      }
    } else {
      if (apiKey.isEmpty) {
        throw Exception('GEMINI_API_KEY must be provided via --dart-define');
      }
    }

    // Choose base URL by provider
    String resolvedOhmy = ohmyBaseUrl.isNotEmpty
        ? ohmyBaseUrl
        : (ohmyApiBaseUrlLegacy.isNotEmpty
            ? ohmyApiBaseUrlLegacy
            : 'https://api.ohmygpt.com');
    // Normalize to include /v1 suffix if missing
    if (resolvedOhmy.endsWith('/')) {
      resolvedOhmy = resolvedOhmy.substring(0, resolvedOhmy.length - 1);
    }
    if (!resolvedOhmy.endsWith('/v1')) {
      resolvedOhmy = resolvedOhmy + '/v1';
    }

    final baseUrl = provider == 'gpt'
        ? resolvedOhmy
        : 'https://generativelanguage.googleapis.com/v1';

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    // Optional proxy: only enable if PROXY_ENABLED=true (or 1)
    final proxyEnabled = proxyEnabledStr.toLowerCase() == 'true' || proxyEnabledStr == '1';
    final allowBadCert = proxyAllowBadCertStr.toLowerCase() == 'true' || proxyAllowBadCertStr == '1';
    if (proxyEnabled) {
      try {
        configureDioProxy(
          _dio,
          host: proxyHost.isEmpty ? null : proxyHost,
          port: proxyPort,
          allowBadCert: allowBadCert,
        );
      } catch (_) {
        // Proxy is best-effort; ignore if platform doesn't support it
      }
    }

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (provider == 'gpt') {
          // OhMyGPT/OpenAI-compatible endpoint
          options.headers.putIfAbsent('Authorization', () => 'Bearer ' + ohmyApiKey);
          // Ensure no Gemini-specific query param
          options.queryParameters.remove('key');
        } else {
          // Gemini endpoint; adjust version for some models
          final pathSegments = options.path.split('/');
          final model =
              pathSegments.length > 2 ? pathSegments[2].split(':')[0] : null;
          if (model != null && _requiresV1Beta(model)) {
            options.baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
          }
          if (!options.queryParameters.containsKey('key')) {
            options.queryParameters['key'] = apiKey;
          }
        }
        handler.next(options);
      },
      onError: (error, handler) {
        print('LLM API Error: ' + (error.message ?? 'unknown'));
        handler.next(error);
      },
    ));

    // Optional debug logging (redacts API keys)
    final llmDebug = llmDebugStr.toLowerCase() == 'true' || llmDebugStr == '1';
    if (llmDebug) {
      _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          try {
            final auth = options.headers['Authorization']?.toString();
            final redactedAuth = _redactAuth(auth);
            final fullUrl = options.baseUrl + options.path + _queryString(options.queryParameters);
            print('[LLM][REQ] ' + options.method + ' ' + fullUrl);
            if (redactedAuth != null) print('[LLM][HDR] Authorization: ' + redactedAuth);
            final ct = options.headers['Content-Type']?.toString() ?? options.contentType.toString();
            if (ct.isNotEmpty) print('[LLM][HDR] Content-Type: ' + ct);
            if (options.data != null) {
              final bodyStr = _safeJsonString(options.data);
              print('[LLM][BODY] ' + _truncate(bodyStr));
            }
          } catch (_) {}
          handler.next(options);
        },
        onResponse: (response, handler) {
          try {
            print('[LLM][RES] ' + response.statusCode.toString() + ' ' + (response.requestOptions.baseUrl + response.requestOptions.path));
            if (response.data != null && response.requestOptions.responseType != ResponseType.stream) {
              final bodyStr = _safeJsonString(response.data);
              print('[LLM][DATA] ' + _truncate(bodyStr));
            } else if (response.requestOptions.responseType == ResponseType.stream) {
              print('[LLM][DATA] <stream>');
            }
          } catch (_) {}
          handler.next(response);
        },
        onError: (e, handler) {
          try {
            final status = e.response?.statusCode;
            final url = e.requestOptions.baseUrl + e.requestOptions.path;
            print('[LLM][ERR] ' + (status?.toString() ?? 'ERR') + ' ' + url);
            final data = e.response?.data;
            if (data != null) {
              print('[LLM][DATA] ' + _truncate(_safeJsonString(data)));
            } else if (e.message != null) {
              print('[LLM][MSG] ' + e.message!);
            }
          } catch (_) {}
          handler.next(e);
        },
      ));
    }
  }

  static String? _redactAuth(String? auth) {
    if (auth == null) return null;
    // Redact bearer tokens: keep prefix and first/last 4 chars
    final parts = auth.split(' ');
    if (parts.length == 2 && parts[0].toLowerCase() == 'bearer') {
      final token = parts[1];
      if (token.length <= 10) return 'Bearer ********';
      return 'Bearer ' + token.substring(0, 4) + '...' + token.substring(token.length - 4);
    }
    return '***redacted***';
  }

  static String _queryString(Map<String, dynamic> qp) {
    if (qp.isEmpty) return '';
    final enc = qp.entries
        .map((e) => Uri.encodeQueryComponent(e.key) + '=' + Uri.encodeQueryComponent(e.value.toString()))
        .join('&');
    return '?' + enc;
  }

  static String _safeJsonString(dynamic data) {
    try {
      if (data is String) return data;
      if (data is Map || data is List) return jsonEncode(data);
      return data.toString();
    } catch (_) {
      return '<unprintable>';
    }
  }

  static String _truncate(String s, [int max = 2000]) {
    if (s.length <= max) return s;
    return s.substring(0, max) + '...<truncated>';
  }

  bool _requiresV1Beta(String modelId) {
  return modelId.contains('preview') ||
        modelId.contains('exp') ||
        modelId.contains('thinking') ||
        modelId.startsWith('imagen-') ||
        modelId.contains('image-preview') ||
        modelId.contains('tts') ||
    modelId.contains('live') ||
    // Newer Gemini 2.x models generally require v1beta endpoints
    modelId.contains('gemini-2') ||
    modelId.contains('2.5') ||
    modelId.contains('2.0');
  }

  Dio get dio => _dio;
  String get authApiKey => apiKey;
  String get providerName => provider;
}

class GeminiClient {
  final Dio dio;
  final String apiKey;
  final String provider;

  GeminiClient(this.dio, this.apiKey, {this.provider = 'gemini'});

  String _getEndpointMethod(String model,
      {bool isStream = false, bool isPredict = false}) {
    if (isPredict) return ':predict';
    if (isStream) return ':streamGenerateContent';
    return ':generateContent';
  }

  Future<GeminiCompletion> generateStoryFromJournal({
    required String journalTitle,
    required String journalContent,
    required String genre,
    required Map<String, dynamic> options,
    String model = 'gemini-2.5-flash',
    CancelToken? cancelToken,
    Function(String)? onProgressUpdate,
  }) async {
    // Build request outside try so we can reuse for fallback
    onProgressUpdate?.call('Analyzing journal entry...');

    final prompt = _buildStoryPrompt(
      journalTitle: journalTitle,
      journalContent: journalContent,
      genre: genre,
      options: options,
    );

    final contents = [
      {
        'role': 'user',
        'parts': [
          {'text': prompt}
        ]
      }
    ];

    final generationConfig = {
      'temperature': (options['creativity'] as double? ?? 0.7).clamp(0.1, 1.0),
      'topP': 0.8,
      'topK': 32,
      'maxOutputTokens': _getMaxTokensFromLength(
          options['length'] as String? ?? 'Medium'),
    };

    onProgressUpdate?.call('Generating ${genre.toLowerCase()} story...');

    try {
      if (provider == 'gpt') {
        // Map to OpenAI-compatible chat completions
  final temp = generationConfig['temperature'];
        final mappedBase = <String, dynamic>{
          'model': GeminiService.ohmyModel,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          if (temp != null) 'temperature': double.parse(temp.toStringAsFixed(1)),
          // 'top_p': generationConfig['topP'],
          'max_tokens': generationConfig['maxOutputTokens'],
          'stream': false,
        };

        Future<Response<dynamic>> _post(Map<String, dynamic> payload) {
          return dio.post(
            '/chat/completions',
            data: payload,
            cancelToken: cancelToken,
          );
        }

        try {
          final response = await _post(mappedBase);
          onProgressUpdate?.call('Processing story content...');
          final parsed = _parseStoryResponse(response.data);
          // Some providers/models may return empty content with finish_reason="length".
          // If content is empty, retry with a stable known-good model.
          if ((parsed.text).trim().isEmpty) {
            final fallback = Map<String, dynamic>.from(mappedBase);
            fallback['model'] = 'gpt-4o-mini';
            // Optionally lower max tokens slightly to reduce truncation risk
            if (fallback['max_tokens'] is int && (fallback['max_tokens'] as int) > 1200) {
              fallback['max_tokens'] = 1200;
            }
            final response2 = await _post(fallback);
            onProgressUpdate?.call('Processed with fallback model...');
            return _parseStoryResponse(response2.data);
          }
          return parsed;
        } on DioException catch (e) {
          final msg = e.response?.data is Map
              ? (e.response?.data['error']?['message']?.toString() ?? '')
              : (e.message ?? '');
          final status = e.response?.statusCode ?? 0;
          final tempIssue = msg.toLowerCase().contains('temperature') ||
              msg.toLowerCase().contains('not support');
          if (status >= 400 && status < 500 && tempIssue) {
            // Retry without temperature field
            final mappedRetry = Map<String, dynamic>.from(mappedBase);
            mappedRetry.remove('temperature');
            final response = await _post(mappedRetry);
            onProgressUpdate?.call('Processing story content...');
            return _parseStoryResponse(response.data);
          }
          // Retry with a known-good default model if model is invalid
          final modelIssue = msg.toLowerCase().contains('model') ||
              msg.toLowerCase().contains('no such model') ||
              msg.toLowerCase().contains('not found');
          if (status >= 400 && status < 500 && modelIssue) {
            final fallback = Map<String, dynamic>.from(mappedBase);
            fallback['model'] = 'gpt-4o-mini';
            final response = await _post(fallback);
            onProgressUpdate?.call('Processed with fallback model...');
            return _parseStoryResponse(response.data);
          }
          rethrow;
        }
      } else {
        final endpoint = _getEndpointMethod(model);
        final response = await dio.post(
          '/models/' + model + endpoint,
          data: {
            'contents': contents,
            'generationConfig': generationConfig,
            'safetySettings': _getSafetySettings(),
          },
          cancelToken: cancelToken,
        );
        onProgressUpdate?.call('Processing story content...');
        return _parseStoryResponse(response.data);
      }
    } on DioException catch (e) {
      // Retry with a stable fallback model if version/endpoint mismatch or 404
      final message = e.response?.data?['error']?['message']?.toString() ?? '';
      final status = e.response?.statusCode ?? 0;
      final shouldFallback =
          provider != 'gpt' && model != 'gemini-1.5-flash' &&
          (status == 404 ||
              message.contains('Method not found') ||
              message.contains('Unsupported') ||
              message.contains('version'));

      if (e.type != DioExceptionType.cancel && shouldFallback) {
        try {
          final fallbackModel = 'gemini-1.5-flash';
          final fallbackEndpoint = _getEndpointMethod(fallbackModel);
          final response = await dio.post(
            '/models/$fallbackModel$fallbackEndpoint',
            data: {
              'contents': contents,
              'generationConfig': generationConfig,
              'safetySettings': _getSafetySettings(),
            },
            cancelToken: cancelToken,
          );
          onProgressUpdate?.call('Processed with fallback model...');
          return _parseStoryResponse(response.data);
        } catch (e2) {
          // Fall through to error handling below with original error context
        }
      }

      if (e.type == DioExceptionType.cancel) {
        throw GeminiException(
          statusCode: 499,
          message: 'Story generation was cancelled by user',
        );
      }
      throw GeminiException(
        statusCode: e.response?.statusCode ?? 500,
        message: _handleGeminiError(e),
      );
    }
  }

  Future<GeminiCompletion> enhanceJournalEntry({
    required String journalContent,
    required String
        enhancementType, // 'expand', 'improve', 'sentiment_analysis'
    String model = 'gemini-2.5-flash',
    CancelToken? cancelToken,
  }) async {
    try {
      final prompt = _buildEnhancementPrompt(journalContent, enhancementType);

      final contents = [
        {
          'role': 'user',
          'parts': [
            {'text': prompt}
          ]
        }
      ];

      final generationConfig = {
        'temperature': 0.7,
        'topP': 0.8,
        'topK': 32,
        'maxOutputTokens': 1024,
      };

      final endpoint = _getEndpointMethod(model);
      final response = await dio.post(
        '/models/$model$endpoint',
        data: {
          'contents': contents,
          'generationConfig': generationConfig,
          'safetySettings': _getSafetySettings(),
        },
        cancelToken: cancelToken,
      );

      return _parseStoryResponse(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        throw GeminiException(
          statusCode: 499,
          message: 'Enhancement was cancelled by user',
        );
      }
      throw GeminiException(
        statusCode: e.response?.statusCode ?? 500,
        message: _handleGeminiError(e),
      );
    }
  }

  Future<GeminiCompletion> generateWritingPrompts({
    String? mood,
    String? theme,
    int count = 5,
    String model = 'gemini-2.5-flash',
    CancelToken? cancelToken,
  }) async {
    try {
      final prompt =
          _buildWritingPromptsPrompt(mood: mood, theme: theme, count: count);

      final contents = [
        {
          'role': 'user',
          'parts': [
            {'text': prompt}
          ]
        }
      ];

      final generationConfig = {
        'temperature': 0.8,
        'topP': 0.9,
        'topK': 40,
        'maxOutputTokens': 512,
      };

      final endpoint = _getEndpointMethod(model);
      final response = await dio.post(
        '/models/$model$endpoint',
        data: {
          'contents': contents,
          'generationConfig': generationConfig,
          'safetySettings': _getSafetySettings(),
        },
        cancelToken: cancelToken,
      );

      return _parseStoryResponse(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        throw GeminiException(
          statusCode: 499,
          message: 'Prompt generation was cancelled by user',
        );
      }
      throw GeminiException(
        statusCode: e.response?.statusCode ?? 500,
        message: _handleGeminiError(e),
      );
    }
  }

  Stream<String> streamStoryGeneration({
    required String journalTitle,
    required String journalContent,
    required String genre,
    required Map<String, dynamic> options,
    String model = 'gemini-2.5-flash',
    CancelToken? cancelToken,
  }) async* {
    try {
      final prompt = _buildStoryPrompt(
        journalTitle: journalTitle,
        journalContent: journalContent,
        genre: genre,
        options: options,
      );

      final generationConfig = {
        'temperature': (options['creativity'] as double? ?? 0.7).clamp(0.1, 1.0),
        'topP': 0.8,
        'topK': 32,
        'maxOutputTokens': _getMaxTokensFromLength(
            options['length'] as String? ?? 'Medium'),
      };

      if (provider == 'gpt') {
  final temp = generationConfig['temperature'];
        final basePayload = <String, dynamic>{
          'model': GeminiService.ohmyModel,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          if (temp != null) 'temperature': double.parse(temp.toStringAsFixed(1)),
          // 'top_p': generationConfig['topP'],
          'max_tokens': generationConfig['maxOutputTokens'],
          'stream': true,
        };

        Future<Response<dynamic>> _post(Map<String, dynamic> payload) {
          return dio.post(
            '/chat/completions',
            data: payload,
            options: Options(
              responseType: ResponseType.stream,
              headers: {'Accept': 'text/event-stream'},
            ),
            cancelToken: cancelToken,
          );
        }

        Response response;
        try {
          response = await _post(basePayload);
        } on DioException catch (e) {
          final msg = e.response?.data is Map
              ? (e.response?.data['error']?['message']?.toString() ?? '')
              : (e.message ?? '');
          final status = e.response?.statusCode ?? 0;
          final tempIssue = msg.toLowerCase().contains('temperature') ||
              msg.toLowerCase().contains('not support');
          if (status >= 400 && status < 500 && tempIssue) {
            final retryPayload = Map<String, dynamic>.from(basePayload);
            retryPayload.remove('temperature');
            response = await _post(retryPayload);
          } else {
            final modelIssue = msg.toLowerCase().contains('model') ||
                msg.toLowerCase().contains('no such model') ||
                msg.toLowerCase().contains('not found');
            if (status >= 400 && status < 500 && modelIssue) {
              final retryPayload = Map<String, dynamic>.from(basePayload);
              retryPayload['model'] = 'gpt-4o-mini';
              response = await _post(retryPayload);
            } else {
              rethrow;
            }
          }
        }

        final stream = response.data as ResponseBody;
        await for (var line in LineSplitter().bind(utf8.decoder.bind(stream.stream))) {
          if (!line.startsWith('data:')) continue;
          final data = line.replaceFirst('data:', '').trim();
          if (data.isEmpty) continue;
          if (data == '[DONE]') break;
          try {
            final chunk = jsonDecode(data) as Map<String, dynamic>;
            final choices = chunk['choices'] as List?;
            if (choices != null && choices.isNotEmpty) {
              final delta = choices[0]['delta'] as Map<String, dynamic>?;
              final content = delta?['content'] ?? choices[0]['message']?['content'];
              if (content is String && content.isNotEmpty) {
                yield content;
              }
            }
          } catch (_) {
            // ignore malformed lines
          }
        }
      } else {
        final contents = [
          {
            'role': 'user',
            'parts': [
              {'text': prompt}
            ]
          }
        ];

        final endpoint = _getEndpointMethod(model, isStream: true);
        final response = await dio.post(
          '/models/$model$endpoint',
          data: {
            'contents': contents,
            'generationConfig': generationConfig,
            'safetySettings': _getSafetySettings(),
          },
          options: Options(responseType: ResponseType.stream),
          cancelToken: cancelToken,
        );

        final stream = response.data as ResponseBody;
        await for (var line in LineSplitter().bind(utf8.decoder.bind(stream.stream))) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data == '[DONE]') break;

            try {
              final json = jsonDecode(data) as Map<String, dynamic>;
              if (json.containsKey('candidates') &&
                  json['candidates'].isNotEmpty &&
                  json['candidates'][0].containsKey('content') &&
                  json['candidates'][0]['content'].containsKey('parts') &&
                  json['candidates'][0]['content']['parts'].isNotEmpty) {
                final text = json['candidates'][0]['content']['parts'][0]['text'];
                if (text != null && text.isNotEmpty) {
                  yield text;
                }
              }
            } catch (e) {
              // Skip malformed data
            }
          }
        }
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        throw GeminiException(
          statusCode: 499,
          message: 'Stream was cancelled by user',
        );
      }
      throw GeminiException(
        statusCode: e.response?.statusCode ?? 500,
        message: _handleGeminiError(e),
      );
    }
  }

  // Helper Methods

  String _buildStoryPrompt({
    required String journalTitle,
    required String journalContent,
    required String genre,
    required Map<String, dynamic> options,
  }) {
    final length = options['length'] as String? ?? 'Medium';
    final perspective = options['perspective'] as String? ?? 'First Person';
    final writingStyle = options['writingStyle'] as String? ?? 'Descriptive';
    final targetAudience = options['targetAudience'] as String? ?? 'All Ages';
    final endingStyle = options['endingStyle'] as String? ?? 'Conclusive';
    final pacing = options['pacing'] as double? ?? 0.6;
    final toneIntensity = options['toneIntensity'] as double? ?? 0.5;

  return '''
Transform the following journal entry into a compelling ${genre.toLowerCase()} story.

Journal Title: "$journalTitle"
Journal Entry: "$journalContent"

Story Requirements:
- Genre: $genre
- Length: $length (${_getLengthDescription(length)})
- Perspective: $perspective
- Writing Style: $writingStyle
- Target Audience: $targetAudience
- Ending Style: $endingStyle
- Pacing: ${_getPacingDescription(pacing)}
- Tone Intensity: ${_getToneIntensityDescription(toneIntensity)}

CRITICAL OUTPUT FORMAT (do not include anything before or after the markers):
**title**
# <Write a concise story title here>
<Write the full story body here in Markdown. Use **bold** for emphasis and _italics_ for 斜体.>
**end**

Instructions:
1. Keep all output strictly between the **title** and **end** markers.
2. The first line after **title** MUST be a Markdown H1 with the story title (e.g., "# The Hidden Garden").
3. Write the body using Markdown so bold (**bold**) and italics (_italics_) render correctly.
 4. Do NOT echo the journal title or any metadata above the H1; only output the formatted title and story body between the markers.
 5. Maintain the core emotional essence and key events from the journal entry.
 6. Expand the narrative with ${genre.toLowerCase()}-appropriate elements, characters, and plot developments.
 7. Use $writingStyle with $perspective perspective, $endingStyle ending, ${_getPacingDescription(pacing)} pacing, and ${_getToneIntensityDescription(toneIntensity)} tone intensity.
''';
  }

  String _buildEnhancementPrompt(
      String journalContent, String enhancementType) {
    switch (enhancementType) {
      case 'expand':
        return '''
Please expand and enhance the following journal entry while maintaining its personal tone and authenticity:

"$journalContent"

Instructions:
- Add more descriptive details and sensory information
- Expand on emotions and thoughts mentioned
- Include relevant context or background
- Maintain the original voice and perspective
- Keep the personal, authentic journal style
- Make it more engaging while staying true to the original experience
''';

      case 'improve':
        return '''
Please improve the writing quality of this journal entry while preserving its original meaning and personal voice:

"$journalContent"

Instructions:
- Enhance clarity and flow
- Improve word choice and sentence structure
- Fix any grammatical issues
- Make it more engaging to read
- Maintain the personal, intimate tone
- Preserve all original thoughts and experiences
''';

      case 'sentiment_analysis':
        return '''
Please analyze the emotional content and sentiment of this journal entry:

"$journalContent"

Provide:
1. Overall emotional tone (positive, negative, neutral, mixed)
2. Primary emotions detected (joy, sadness, anxiety, excitement, etc.)
3. Emotional intensity level (low, moderate, high)
4. Key emotional themes or patterns
5. Suggestions for emotional well-being or reflection

Format your response as a thoughtful analysis that could help the writer understand their emotional state and patterns.
''';

      default:
        return '''
Please analyze and provide insights about this journal entry:

"$journalContent"

Provide thoughtful observations about the content, themes, and emotional tone.
''';
    }
  }

  String _buildWritingPromptsPrompt({
    String? mood,
    String? theme,
    required int count,
  }) {
    String contextualInfo = '';
    if (mood != null) contextualInfo += 'Mood: $mood\n';
    if (theme != null) contextualInfo += 'Theme: $theme\n';

    return '''
Generate $count creative and inspiring writing prompts for journal entries.

${contextualInfo.isNotEmpty ? 'Context:\n$contextualInfo' : ''}

Requirements:
- Each prompt should inspire thoughtful, personal reflection
- Make them specific enough to spark ideas but open enough for personal interpretation
- Include a mix of introspective, experiential, and creative prompts
- Vary the style (questions, scenarios, statements)
- Make them suitable for daily journaling practice

Format each prompt as a separate numbered item (1., 2., 3., etc.)
''';
  }

  int _getMaxTokensFromLength(String length) {
    switch (length.toLowerCase()) {
      case 'short':
        return 800;
      case 'medium':
        return 1500;
      case 'long':
        return 2500;
      default:
        return 1500;
    }
  }

  String _getLengthDescription(String length) {
    switch (length.toLowerCase()) {
      case 'short':
        return '500-800 words';
      case 'medium':
        return '1000-1500 words';
      case 'long':
        return '2000-2500 words';
      default:
        return '1000-1500 words';
    }
  }

  String _getPacingDescription(double pacing) {
    if (pacing < 0.3) return 'slow, contemplative';
    if (pacing < 0.7) return 'moderate, balanced';
    return 'fast, dynamic';
  }

  String _getToneIntensityDescription(double intensity) {
    if (intensity < 0.3) return 'subtle, understated';
    if (intensity < 0.7) return 'moderate, balanced';
    return 'intense, dramatic';
  }

  GeminiCompletion _parseStoryResponse(Map<String, dynamic> responseData) {
    // OpenAI/OhMyGPT style response
    if (responseData['choices'] != null && responseData['choices'].isNotEmpty) {
      final first = responseData['choices'][0];
      final text = (first['message']?['content'] ?? first['text'] ?? '').toString();
      if (text.isNotEmpty) return GeminiCompletion(text: text);
    }

    // Gemini style response
    if (responseData['candidates'] != null &&
        responseData['candidates'].isNotEmpty &&
        responseData['candidates'][0]['content'] != null) {
      final parts = responseData['candidates'][0]['content']['parts'];
      final text = parts.isNotEmpty ? parts[0]['text'] : '';
      return GeminiCompletion(text: text);
    } else {
      throw GeminiException(
        statusCode: 500,
        message: 'Failed to parse response or empty response',
      );
    }
  }

  List<Map<String, dynamic>> _getSafetySettings() {
    return [
      {
        'category': 'HARM_CATEGORY_HARASSMENT',
        'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
      },
      {
        'category': 'HARM_CATEGORY_HATE_SPEECH',
        'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
      },
      {
        'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
        'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
      },
      {
        'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
        'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
      }
    ];
  }

  String _handleGeminiError(DioException error) {
    final message = error.response?.data?['error']?['message'] ?? error.message;

    if (message.contains('429')) {
      return 'Rate limit exceeded. Please wait a moment before trying again.';
    }
    if (message.contains('SAFETY')) {
      return 'Content was blocked by safety filters. Please modify your request.';
    }
    if (message.contains('API key')) {
      return 'API key is invalid or missing. Please check your configuration.';
    }
    if (message.contains('version')) {
      return 'Endpoint version mismatch. Check model compatibility with v1/v1beta.';
    }
    if (message.contains('quota')) {
      return 'API quota exceeded. Please check your usage limits.';
    }

    return message ?? 'An unexpected error occurred. Please try again.';
  }
}

// Data Classes
class GeminiCompletion {
  final String text;
  GeminiCompletion({required this.text});
}

class GeminiException implements Exception {
  final int statusCode;
  final String message;

  GeminiException({required this.statusCode, required this.message});

  @override
  String toString() => 'GeminiException: $statusCode - $message';
}

// Request Manager for handling cancellable requests
class GeminiRequestManager {
  CancelToken? _cancelToken;
  bool _isProcessing = false;
  String _processingStage = '';
  double _processingProgress = 0.0;

  bool get isProcessing => _isProcessing;
  String get processingStage => _processingStage;
  double get processingProgress => _processingProgress;

  Future<T> startRequest<T>(
    Future<T> Function(CancelToken cancelToken, Function(String) onProgress)
        requestFunction,
  ) async {
    _cancelToken = CancelToken();
    _isProcessing = true;
    _processingProgress = 0.0;
    _processingStage = 'Initializing request...';

    try {
      final result = await requestFunction(_cancelToken!, (stage) {
        _processingStage = stage;
        _processingProgress = (_processingProgress + 20).clamp(0, 90);
      });

      _processingProgress = 100;
      _processingStage = 'Complete!';

      return result;
    } finally {
      _isProcessing = false;
      _cancelToken = null;
    }
  }

  void cancelRequest() {
    if (_cancelToken != null) {
      _cancelToken!.cancel('Request cancelled by user');
      _isProcessing = false;
      _processingStage = 'Cancelled';
      _processingProgress = 0;
    }
  }
}
