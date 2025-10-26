import 'package:supabase_flutter/supabase_flutter.dart';

import './auth_service.dart';
import './supabase_service.dart';

class JournalService {
  static JournalService? _instance;
  static JournalService get instance => _instance ??= JournalService._();

  JournalService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Get all journal entries for current user
  Future<List<Map<String, dynamic>>> getJournalEntries({
    int? limit,
    String? searchQuery,
  }) async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      var query = _client
          .from('journal_entries')
          .select('id, title, content, preview, mood, word_count, created_at, is_favorite')
          .eq('user_id', userId);

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query
            .or('content.ilike.%$searchQuery%,preview.ilike.%$searchQuery%');
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit ?? 50);

      return List<Map<String, dynamic>>.from(response)
          .map((entry) => {
                ...entry,
                'preview': entry['preview'] ?? '',
                'mood': entry['mood'] ?? 'neutral',
                'word_count': entry['word_count'] ?? 0,
                'is_favorite': entry['is_favorite'] ?? false,
              })
          .toList();
    } catch (error) {
      print('Error fetching journal entries: $error');
      if (error.toString().contains('PGRST301')) {
        return []; // Empty result set
      }
      throw Exception('Get journal entries failed: $error');
    }
  }

  // Create new journal entry
  Future<Map<String, dynamic>> createJournalEntry({
    String? title,
    required String content,
    required String preview,
    required String mood,
  }) async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final wordCount = content.split(' ').length;

      final response = await _client
          .from('journal_entries')
          .insert({
            'user_id': userId,
            'title': title,
            'content': content,
            'preview': preview,
            'mood': mood,
            'word_count': wordCount,
          })
          .select()
          .single();

      // Update user stats
      await _updateUserStats();

      return response;
    } catch (error) {
      throw Exception('Create journal entry failed: $error');
    }
  }

  // Update journal entry
  Future<Map<String, dynamic>> updateJournalEntry({
    required String entryId,
    String? title,
    String? content,
    String? preview,
    String? mood,
    bool? isFavorite,
  }) async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final updates = <String, dynamic>{};
      if (title != null) updates['title'] = title;
      if (content != null) {
        updates['content'] = content;
        updates['word_count'] = content.split(' ').length;
      }
      if (preview != null) updates['preview'] = preview;
      if (mood != null) updates['mood'] = mood;
      if (isFavorite != null) updates['is_favorite'] = isFavorite;

      final response = await _client
          .from('journal_entries')
          .update(updates)
          .eq('id', entryId)
          .eq('user_id', userId)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Update journal entry failed: $error');
    }
  }

  // Delete journal entry
  Future<void> deleteJournalEntry(String entryId) async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client
          .from('journal_entries')
          .delete()
          .eq('id', entryId)
          .eq('user_id', userId);

      // Update user stats
      await _updateUserStats();
    } catch (error) {
      throw Exception('Delete journal entry failed: $error');
    }
  }

  // Get single journal entry
  Future<Map<String, dynamic>?> getJournalEntry(String entryId) async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('journal_entries')
          .select()
          .eq('id', entryId)
          .eq('user_id', userId)
          .single();

      return response;
    } catch (error) {
      if (error.toString().contains('PGRST116')) {
        return null; // Entry not found
      }
      throw Exception('Get journal entry failed: $error');
    }
  }

  // Update user stats (writing streak, total entries)
  Future<void> _updateUserStats() async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) return;

      // Get total entries count
      final entriesData = await _client
          .from('journal_entries')
          .select('id')
          .eq('user_id', userId)
          .count();

      // Get stories count
      final storiesData = await _client
          .from('generated_stories')
          .select('id')
          .eq('user_id', userId)
          .count();

      // Calculate writing streak (entries in consecutive days)
      final recentEntries = await _client
          .from('journal_entries')
          .select('created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(30);

      final streak = _calculateWritingStreak(recentEntries);

      // Update user profile
      await _client.from('user_profiles').update({
        'total_entries': entriesData.count,
        'stories_generated': storiesData.count,
        'current_streak': streak['current'],
        'longest_streak': streak['longest'],
        'writing_streak': streak['current'],
      }).eq('id', userId);
    } catch (error) {
      // Don't throw error for stats update failures
      print('Failed to update user stats: $error');
    }
  }

  // Calculate writing streak from entries
  Map<String, int> _calculateWritingStreak(List<Map<String, dynamic>> entries) {
    if (entries.isEmpty) return {'current': 0, 'longest': 0};

    final dates = entries
        .map((e) => DateTime.parse(e['created_at']))
        .map((date) => DateTime(date.year, date.month, date.day))
        .toSet()
        .toList();

    dates.sort((a, b) => b.compareTo(a)); // Most recent first

    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    for (int i = 0; i < dates.length; i++) {
      if (i == 0) {
        // Check if most recent entry is today or yesterday
        final daysDiff = todayDate.difference(dates[i]).inDays;
        if (daysDiff <= 1) {
          currentStreak = 1;
          tempStreak = 1;
        } else {
          currentStreak = 0;
          tempStreak = 0;
        }
      } else {
        final daysDiff = dates[i - 1].difference(dates[i]).inDays;
        if (daysDiff == 1) {
          // Consecutive day
          tempStreak++;
          if (i == dates.length - 1 ||
              dates[i - 1].difference(dates[i + 1]).inDays > 1) {
            // End of consecutive sequence or last entry
            if (currentStreak > 0 && i == tempStreak - 1) {
              currentStreak = tempStreak;
            }
            if (tempStreak > longestStreak) {
              longestStreak = tempStreak;
            }
          }
        } else {
          // Break in sequence
          if (tempStreak > longestStreak) {
            longestStreak = tempStreak;
          }
          tempStreak = 1; // Reset
        }
      }
    }

    if (tempStreak > longestStreak) {
      longestStreak = tempStreak;
    }

    return {
      'current': currentStreak,
      'longest': longestStreak > currentStreak ? longestStreak : currentStreak,
    };
  }

  // Subscribe to real-time journal entries changes
  RealtimeChannel subscribeToJournalEntries() {
    return _client
        .channel('journal_entries_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'journal_entries',
          callback: (payload) {
            // Handle real-time updates
            print('Journal entries updated: ${payload.eventType}');
          },
        )
        .subscribe();
  }
}
