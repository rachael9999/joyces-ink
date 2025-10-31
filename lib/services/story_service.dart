import 'package:supabase_flutter/supabase_flutter.dart';

import './auth_service.dart';
import './supabase_service.dart';

class StoryService {
  static StoryService? _instance;
  static StoryService get instance => _instance ??= StoryService._();

  StoryService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Allowed DB enum values for public.story_genre
  static const Set<String> _allowedGenres = {
    'fantasy', 'romance', 'adventure', 'mystery', 'sci_fi', 'drama', 'thriller', 'comedy'
  };

  // Normalize UI/display genres to DB enum values
  String _normalizeGenre(String genre) {
    final g = genre.trim().toLowerCase();
    // Direct matches
    if (_allowedGenres.contains(g)) return g;

    // Common aliases/mappings from UI
    switch (g) {
      case 'horror':
        return 'thriller';
      case 'chick-flick':
      case 'chick flick':
        return 'romance';
      case 'sci-fi':
      case 'science fiction':
        return 'sci_fi';
      default:
        // Fallback to a safe default
        return 'drama';
    }
  }

  bool _isValidUuid(String? value) {
    if (value == null) return false;
    final v = value.trim();
      final uuidRegex = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
      );
    return uuidRegex.hasMatch(v);
  }

  // Delete a story by ID
  Future<void> deleteStory(String storyId) async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client
          .from('generated_stories')
          .delete()
          .match({'id': storyId, 'user_id': userId});
    } catch (e) {
      throw Exception('Failed to delete story: $e');
    }
  }

  // Get all generated stories for current user
  Future<List<Map<String, dynamic>>> getGeneratedStories({
    int? limit,
    String? genre,
  }) async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      var query = _client
          .from('generated_stories')
          .select('*, journal_entries(title, preview)')
          .eq('user_id', userId);

      if (genre != null && genre.isNotEmpty) {
        query = query.eq('genre', genre);
      }

      final response =
          await query.order('created_at', ascending: false).limit(limit ?? 20);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      if (error.toString().contains('PGRST301')) {
        return []; // Empty result set
      }
      throw Exception('Get generated stories failed: $error');
    }
  }

  // Create new generated story
  Future<Map<String, dynamic>> createGeneratedStory({
    String? journalEntryId,
    required String title,
    required String content,
    required String genre,
    int? rating,
    bool isFavorite = false,
  }) async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final wordCount = content.split(' ').length;
      final readingTimeMinutes = (wordCount / 200).ceil();

      // Normalize inputs to match DB constraints
      final normalizedGenre = _normalizeGenre(genre);
      final safeJournalEntryId = _isValidUuid(journalEntryId) ? journalEntryId : null;

      final response = await _client
          .from('generated_stories')
          .insert({
            'user_id': userId,
            'journal_entry_id': safeJournalEntryId,
            'title': title,
            'content': content,
            'genre': normalizedGenre,
            'word_count': wordCount,
            'reading_time_minutes': readingTimeMinutes,
            'rating': rating,
            'is_favorite': isFavorite,
          })
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Create generated story failed: $error');
    }
  }

  // Update generated story
  Future<Map<String, dynamic>> updateGeneratedStory({
    required String storyId,
    String? title,
    String? content,
    String? genre,
    int? rating,
    bool? isFavorite,
    String? shareClip,
    String? shareImageUrl,
  }) async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final updates = <String, dynamic>{};
      if (title != null) updates['title'] = title;
      if (content != null) {
        updates['content'] = content;
        updates['word_count'] = content.split(' ').length;
        updates['reading_time_minutes'] =
            (content.split(' ').length / 200).ceil();
      }
      if (genre != null) updates['genre'] = _normalizeGenre(genre);
      if (rating != null) updates['rating'] = rating;
      if (isFavorite != null) updates['is_favorite'] = isFavorite;
  if (shareClip != null) updates['share_clip'] = shareClip;
  if (shareImageUrl != null) updates['share_image_url'] = shareImageUrl;

      final response = await _client
          .from('generated_stories')
          .update(updates)
          .eq('id', storyId)
          .eq('user_id', userId)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Update generated story failed: $error');
    }
  }

  // Delete generated story
  Future<void> deleteGeneratedStory(String storyId) async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client
          .from('generated_stories')
          .delete()
          .eq('id', storyId)
          .eq('user_id', userId);
    } catch (error) {
      throw Exception('Delete generated story failed: $error');
    }
  }

  // Get single generated story
  Future<Map<String, dynamic>?> getGeneratedStory(String storyId) async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('generated_stories')
          .select('*, journal_entries(title, preview)')
          .eq('id', storyId)
          .eq('user_id', userId)
          .single();

      return response;
    } catch (error) {
      if (error.toString().contains('PGRST116')) {
        return null; // Story not found
      }
      throw Exception('Get generated story failed: $error');
    }
  }

  // Get story comments
  Future<List<Map<String, dynamic>>> getStoryComments(String storyId) async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('story_comments')
          .select('*, user_profiles(full_name)')
          .eq('story_id', storyId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      if (error.toString().contains('PGRST301')) {
        return []; // Empty result set
      }
      throw Exception('Get story comments failed: $error');
    }
  }

  // Add story comment
  Future<Map<String, dynamic>> addStoryComment({
    required String storyId,
    required String content,
  }) async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('story_comments')
          .insert({
            'story_id': storyId,
            'user_id': userId,
            'content': content,
          })
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Add story comment failed: $error');
    }
  }

  // Get favorite stories
  Future<List<Map<String, dynamic>>> getFavoriteStories() async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('generated_stories')
          .select('*, journal_entries(title, preview)')
          .eq('user_id', userId)
          .eq('is_favorite', true)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      if (error.toString().contains('PGRST301')) {
        return []; // Empty result set
      }
      throw Exception('Get favorite stories failed: $error');
    }
  }

  // Get stories by genre
  Future<List<Map<String, dynamic>>> getStoriesByGenre(String genre) async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('generated_stories')
          .select('*, journal_entries(title, preview)')
          .eq('user_id', userId)
          .eq('genre', genre)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      if (error.toString().contains('PGRST301')) {
        return []; // Empty result set
      }
      throw Exception('Get stories by genre failed: $error');
    }
  }

  // Subscribe to real-time story changes
  RealtimeChannel subscribeToStories() {
    return _client
        .channel('stories_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'generated_stories',
          callback: (payload) {
            print('Stories updated: ${payload.eventType}');
          },
        )
        .subscribe();
  }
}
