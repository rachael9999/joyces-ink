import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'gemini_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import 'auth_service.dart';
import 'story_service.dart';

class ShareAssets {
  final String clip; // short engaging main plot/quote
  final String imagePrompt; // generated detailed visual prompt
  final Uint8List imageBytes; // PNG/JPEG bytes

  ShareAssets({
    required this.clip,
    required this.imagePrompt,
    required this.imageBytes,
  });
}

class ShareService {
  static ShareService? _instance;
  static ShareService get instance => _instance ??= ShareService._();
  ShareService._();

  Dio get _dio => GeminiService().dio; // Reuse configured Dio (provider-aware)
  String get _provider => GeminiService().providerName;

  // Generate a short engaging clip and an image prompt via LLM, then create an image
  // with OhMyGPT/OpenAI-compatible Images API using model "flux-1.1-pro".
  Future<ShareAssets> generateClipAndImage({
    required String title,
    required String storyContent,
    String? genre,
    String textModelOverride = '',
    String imageModel = 'flux-1.1-pro',
    CancelToken? cancelToken,
  }) async {
    // Step 1: Ask LLM to produce a JSON with { clip, image_prompt }
    final clipAndPrompt = await _generateClipAndPrompt(
      title: title,
      storyContent: storyContent,
      genre: genre,
      textModelOverride: textModelOverride,
      cancelToken: cancelToken,
    );

    // Step 2: Generate an image using OhMyGPT Images API (OpenAI-compatible)
    final Uint8List imageBytes = await _generateImage(
      prompt: clipAndPrompt['image_prompt'] ?? 'Beautiful abstract background, soft gradients',
      model: imageModel,
      cancelToken: cancelToken,
    );

    return ShareAssets(
      clip: clipAndPrompt['clip'] ?? '',
      imagePrompt: clipAndPrompt['image_prompt'] ?? '',
      imageBytes: imageBytes,
    );
  }

  // Generate only an engaging share clip (no image generation/upload)
  Future<String> generateClipOnly({
    required String title,
    required String storyContent,
    String? genre,
    String textModelOverride = '',
    CancelToken? cancelToken,
  }) async {
    final res = await _generateClipAndPrompt(
      title: title,
      storyContent: storyContent,
      genre: genre,
      textModelOverride: textModelOverride,
      cancelToken: cancelToken,
    );
    return (res['clip'] ?? '').toString();
  }

  // Generate assets, upload image to Supabase Storage (bucket: share-assets),
  // and persist the clip/image URL to generated_stories.
  Future<ShareAssets> generateAndPersistAssets({
    required String storyId,
    required String title,
    required String content,
    String? genre,
    String imageModel = 'flux-1.1-pro',
    CancelToken? cancelToken,
  }) async {
    final assets = await generateClipAndImage(
      title: title,
      storyContent: content,
      genre: genre,
      imageModel: imageModel,
      cancelToken: cancelToken,
    );

    // Upload image to Storage
    String? publicUrl;
    try {
      publicUrl = await _uploadImageToStorage(
        imageBytes: assets.imageBytes,
        storyId: storyId,
      );
    } catch (_) {
      // If upload fails, continue without URL
    }

    // Persist share fields
    try {
      await StoryService.instance.updateGeneratedStory(
        storyId: storyId,
        shareClip: assets.clip,
        shareImageUrl: publicUrl,
      );
    } catch (_) {}

    return assets;
  }

  Future<String?> _uploadImageToStorage({
    required Uint8List imageBytes,
    required String storyId,
  }) async {
    final client = SupabaseService.instance.client;
    final userId = AuthService.instance.currentUser?.id;
    if (userId == null) return null;

    final bucket = client.storage.from('share-assets');
    final path = userId + '/' + storyId + '/bg_' + DateTime.now().millisecondsSinceEpoch.toString() + '.png';

    try {
      await bucket.uploadBinary(path, imageBytes, fileOptions: const FileOptions(contentType: 'image/png', upsert: true));
      final url = bucket.getPublicUrl(path);
      return url;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, String>> _generateClipAndPrompt({
    required String title,
    required String storyContent,
    String? genre,
    String textModelOverride = '',
    CancelToken? cancelToken,
  }) async {
    // Only supported when provider is 'gpt' (OpenAI-compatible)
    if (_provider != 'gpt') {
      // Fallback: minimal clip from content
      final safeClip = _firstChars(storyContent, 240);
      return {
        'clip': safeClip,
        'image_prompt': 'Atmospheric, cinematic background that matches the story mood',
      };
    }

    final model = (textModelOverride.isNotEmpty)
        ? textModelOverride
        : GeminiService.ohmyModel;

    final prompt = '''
You are helping prepare a social share card for a short story.
Given the story title and content, produce a concise JSON object with exactly these keys:
"clip": a gripping, standalone teaser (240-360 characters) that captures the main plot hook, no hashtags, no emojis, no quotes around it.
"image_prompt": a rich visual description for a background image, photographic or illustrated, with style keywords, mood, lighting, and composition. Avoid text in the image.

Story Title: "$title"
Genre: ${genre ?? 'Unknown'}
Story Content:
$storyContent

Output STRICTLY a JSON object only, no commentary.
''';

    final payload = {
      'model': model,
      'messages': [
        {
          'role': 'user',
          'content': prompt,
        }
      ],
      'stream': false,
      // Some providers are strict about temperature; omit unless necessary
    };

    try {
      final response = await _dio.post(
        '/chat/completions',
        data: payload,
        cancelToken: cancelToken,
      );
      final data = response.data;
      final msg = data['choices']?[0]?['message']?['content']?.toString() ?? '';
      final jsonText = _extractJson(msg);
      final parsed = json.decode(jsonText);
      return {
        'clip': (parsed['clip'] ?? '').toString().trim(),
        'image_prompt': (parsed['image_prompt'] ?? '').toString().trim(),
      };
    } on DioException {
      // Fallback to a naive clip on error
      final safeClip = _firstChars(storyContent, 240);
      return {
        'clip': safeClip,
        'image_prompt': 'Atmospheric, cinematic background that matches the story mood',
      };
    } catch (_) {
      final safeClip = _firstChars(storyContent, 240);
      return {
        'clip': safeClip,
        'image_prompt': 'Atmospheric, cinematic background that matches the story mood',
      };
    }
  }

  Future<Uint8List> _generateImage({
    required String prompt,
    String model = 'flux-1.1-pro',
    String size = '1024x1024',
    CancelToken? cancelToken,
  }) async {
    // OpenAI-compatible Images API
    try {
      final response = await _dio.post(
        '/images/generations',
        data: {
          'model': model,
          'prompt': prompt,
          'size': size,
          'response_format': 'b64_json',
        },
        cancelToken: cancelToken,
      );
      final data = response.data;
      final first = (data['data'] as List?)?.first;
      final b64 = first?['b64_json']?.toString();
      if (b64 != null && b64.isNotEmpty) {
        return base64.decode(b64);
      }
      // Fallback: try url
      final url = first?['url']?.toString();
      if (url != null && url.isNotEmpty) {
        final img = await _dio.get(url, options: Options(responseType: ResponseType.bytes));
        return Uint8List.fromList((img.data as List<int>));
      }
      throw Exception('No image data');
    } on DioException {
      // As a last resort, return a 1x1 transparent PNG
      return Uint8List.fromList(base64.decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGP4BwQAAp0B9Q4UQb8AAAAASUVORK5CYII='));
    }
  }

  String _firstChars(String s, int max) {
    final t = s.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (t.length <= max) return t;
    return t.substring(0, max - 1) + '…';
  }

  // Try to extract a JSON object from a string that may contain extra text
  String _extractJson(String s) {
    final start = s.indexOf('{');
    final end = s.lastIndexOf('}');
    if (start >= 0 && end > start) return s.substring(start, end + 1);
    return '{"clip":"","image_prompt":""}';
  }
}
