import 'package:supabase_flutter/supabase_flutter.dart';
import './auth_service.dart';
import './supabase_service.dart';

class SparkleService {
  static SparkleService? _instance;
  static SparkleService get instance => _instance ??= SparkleService._();
  SparkleService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Allowed enum values for public.thought_category
  static const Set<String> _allowedCategories = {
    'philosophy',
    'business_ideas',
    'random_thoughts',
    'story_ideas',
    'random_facts',
    'uncategorized',
  };

  String _normalizeCategory(String? category) {
    if (category == null || category.trim().isEmpty) return 'uncategorized';
    final c = category.trim().toLowerCase().replaceAll(' ', '_');
    if (_allowedCategories.contains(c)) return c;
    // Common aliases mapping
    switch (c) {
      case 'general':
      case 'misc':
      case 'others':
      case 'other':
        return 'uncategorized';
      case 'idea':
      case 'ideas':
      case 'story_idea':
        return 'story_ideas';
      case 'random':
        return 'random_thoughts';
      default:
        return 'uncategorized';
    }
  }

  // Get all sparkles for current user
  Future<List<Map<String, dynamic>>> getSparkles({
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

      final response = await query.order('created_at', ascending: false);

      // Normalize fields for UI consumption
      final List<Map<String, dynamic>> items =
          List<Map<String, dynamic>>.from(response);

      return items.map((raw) {
        final map = Map<String, dynamic>.from(raw);

        // Ensure content
        final String content = (map['content'] as String?) ?? '';

        // Parse created_at into a DateTime 'date' field expected by UI
        final dynamic createdAtRaw = map['created_at'];
        DateTime date;
        if (createdAtRaw is String) {
          try {
            date = DateTime.parse(createdAtRaw);
          } catch (_) {
            date = DateTime.now();
          }
        } else if (createdAtRaw is DateTime) {
          date = createdAtRaw;
        } else {
          date = DateTime.now();
        }

        // Compute simple word count for display
        final int wordCount = content.trim().isEmpty
            ? 0
            : content.trim().split(RegExp(r'\s+')).length;

        // Provide sensible defaults expected by UI
  map['category'] = (map['category'] as String?) ?? 'uncategorized';
        map['is_favorite'] = (map['is_favorite'] as bool?) ?? false;
        map['date'] = date; // UI expects a non-null DateTime here
        map['wordCount'] = wordCount;

        return map;
      }).toList();
    } catch (error) {
      if (error.toString().contains('PGRST301')) {
        return []; // Empty result set
      }
      throw Exception('Get sparkles failed: $error');
    }
  }

  // Create a new sparkle
  Future<void> createSparkle({
    required String content,
    String category = 'uncategorized',
  }) async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final normalizedCategory = _normalizeCategory(category);
      final wordCount = content.trim().isEmpty
          ? 0
          : content.trim().split(RegExp(r'\s+')).length;

      await _client.from('thoughts').insert({
        'user_id': userId,
        'content': content,
        'category': normalizedCategory,
        'word_count': wordCount,
        'is_favorite': false,
      });
    } catch (error) {
      throw Exception('Create sparkle failed: $error');
    }
  }

  // Update an existing sparkle
  Future<void> updateSparkle({
    required String sparkleId,
    String? content,
    String? category,
    bool? isFavorite,
  }) async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final Map<String, dynamic> updates = {};
      if (content != null) {
        updates['content'] = content;
        updates['word_count'] = content.trim().isEmpty
            ? 0
            : content.trim().split(RegExp(r'\s+')).length;
      }
      if (category != null) updates['category'] = _normalizeCategory(category);
      if (isFavorite != null) updates['is_favorite'] = isFavorite;

      await _client
          .from('thoughts')
          .update(updates)
          .eq('id', sparkleId)
          .eq('user_id', userId);
    } catch (error) {
      throw Exception('Update sparkle failed: $error');
    }
  }

  // Delete a sparkle
  Future<void> deleteSparkle(String sparkleId) async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client
          .from('thoughts')
          .delete()
          .eq('id', sparkleId)
          .eq('user_id', userId);
    } catch (error) {
      throw Exception('Delete sparkle failed: $error');
    }
  }

  // Get sparkle categories statistics
  Future<Map<String, int>> getSparkleCategoriesStats() async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('thoughts')
          .select('category')
          .eq('user_id', userId);

      final Map<String, int> stats = {};
      for (final sparkle in response) {
        final category = sparkle['category'] as String;
        stats[category] = (stats[category] ?? 0) + 1;
      }
      return stats;
    } catch (error) {
      if (error.toString().contains('PGRST301')) {
        return {}; // Empty result set
      }
      throw Exception('Get sparkle categories stats failed: $error');
    }
  }

  // Get favorite sparkles
  Future<List<Map<String, dynamic>>> getFavoriteSparkles() async {
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
      throw Exception('Get favorite sparkles failed: $error');
    }
  }

  // Get sparkles count by category
  Future<Map<String, dynamic>> getSparkleStatistics() async {
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

  // Subscribe to real-time sparkle changes
  RealtimeChannel subscribeToSparkles() {
    return _client
        .channel('sparkles_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'thoughts',
          callback: (payload) {
            print('Received sparkles change: $payload');
          },
        )
        .subscribe();
  }
}