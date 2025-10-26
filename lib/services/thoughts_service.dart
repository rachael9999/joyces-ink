import 'package:supabase_flutter/supabase_flutter.dart';

import './auth_service.dart';
import './supabase_service.dart';

class ThoughtsService {
  static ThoughtsService? _instance;
  static ThoughtsService get instance => _instance ??= ThoughtsService._();

  ThoughtsService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Get all thoughts for current user
  Future<List<Map<String, dynamic>>> getThoughts({
    int? limit,
    String? category,
    String? searchQuery,
    bool? isFavorite,
  }) async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      var query = _client.from('thoughts').select().eq('user_id', userId);

      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      if (isFavorite == true) {
        query = query.eq('is_favorite', true);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('content', '%$searchQuery%');
      }

      final response =
          await query.order('created_at', ascending: false).limit(limit ?? 50);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      if (error.toString().contains('PGRST301')) {
        return []; // Empty result set
      }
      throw Exception('Get thoughts failed: $error');
    }
  }

  // Create new thought
  Future<Map<String, dynamic>> createThought({
    required String content,
    String category = 'uncategorized',
    bool isFavorite = false,
  }) async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final wordCount = content.split(' ').length;

      final response = await _client
          .from('thoughts')
          .insert({
            'user_id': userId,
            'content': content,
            'category': category,
            'word_count': wordCount,
            'is_favorite': isFavorite,
          })
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Create thought failed: $error');
    }
  }

  // Update thought
  Future<Map<String, dynamic>> updateThought({
    required String thoughtId,
    String? content,
    String? category,
    bool? isFavorite,
  }) async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final updates = <String, dynamic>{};
      if (content != null) {
        updates['content'] = content;
        updates['word_count'] = content.split(' ').length;
      }
      if (category != null) updates['category'] = category;
      if (isFavorite != null) updates['is_favorite'] = isFavorite;

      final response = await _client
          .from('thoughts')
          .update(updates)
          .eq('id', thoughtId)
          .eq('user_id', userId)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Update thought failed: $error');
    }
  }

  // Delete thought
  Future<void> deleteThought(String thoughtId) async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client
          .from('thoughts')
          .delete()
          .eq('id', thoughtId)
          .eq('user_id', userId);
    } catch (error) {
      throw Exception('Delete thought failed: $error');
    }
  }

  // Get thought categories statistics
  Future<Map<String, int>> getThoughtCategoriesStats() async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('thoughts')
          .select('category')
          .eq('user_id', userId);

      final Map<String, int> stats = {};
      for (final thought in response) {
        final category = thought['category'] as String;
        stats[category] = (stats[category] ?? 0) + 1;
      }

      return stats;
    } catch (error) {
      if (error.toString().contains('PGRST301')) {
        return {}; // Empty result set
      }
      throw Exception('Get thought categories stats failed: $error');
    }
  }

  // Get favorite thoughts
  Future<List<Map<String, dynamic>>> getFavoriteThoughts() async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('thoughts')
          .select()
          .eq('user_id', userId)
          .eq('is_favorite', true)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      if (error.toString().contains('PGRST301')) {
        return []; // Empty result set
      }
      throw Exception('Get favorite thoughts failed: $error');
    }
  }

  // Get thoughts count by category
  Future<Map<String, dynamic>> getThoughtsStatistics() async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final totalData = await _client
          .from('thoughts')
          .select('id')
          .eq('user_id', userId)
          .count();

      final favoritesData = await _client
          .from('thoughts')
          .select('id')
          .eq('user_id', userId)
          .eq('is_favorite', true)
          .count();

      final categoriesData = await _client
          .from('thoughts')
          .select('category')
          .eq('user_id', userId);

      final uniqueCategories =
          categoriesData.map((t) => t['category']).toSet().length;

      return {
        'total': totalData.count,
        'favorites': favoritesData.count,
        'categories': uniqueCategories,
      };
    } catch (error) {
      return {'total': 0, 'favorites': 0, 'categories': 0};
    }
  }

  // Subscribe to real-time thoughts changes
  RealtimeChannel subscribeToThoughts() {
    return _client
        .channel('thoughts_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'thoughts',
          callback: (payload) {
            print('Thoughts updated: ${payload.eventType}');
          },
        )
        .subscribe();
  }
}
