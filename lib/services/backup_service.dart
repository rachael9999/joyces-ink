import 'dart:convert';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import './auth_service.dart';
import './settings_service.dart';
import './supabase_service.dart';
import './journal_service.dart';

class BackupService {
  static BackupService? _instance;
  static BackupService get instance => _instance ??= BackupService._();

  BackupService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Bucket to store JSON backups
  static const String _bucket = 'backups';

  // Backup all entries for current user, returns number of files uploaded
  Future<int> backupAllEntries() async {
    final userId = AuthService.instance.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final entries = await JournalService.instance.getJournalEntries(limit: 1000);
    int uploaded = 0;
    for (final e in entries) {
      final ok = await _backupEntryMap(e);
      if (ok) uploaded++;
    }

    await SettingsService.instance.setLastBackupAt(DateTime.now());
    return uploaded;
  }

  // Backup a single entry by id (fetch then upload)
  Future<bool> backupEntryById(String entryId) async {
    final entry = await JournalService.instance.getJournalEntry(entryId);
    if (entry == null) return false;
    final normalized = {...entry};
    // Ensure attachments are embedded if not present
    final attachments = await _fetchEntryAttachments(entryId);
    normalized['attachments'] = attachments;
    return _backupEntryMap(normalized);
  }

  // Backup a provided entry map (should include attachments if available)
  Future<bool> backupEntry(Map<String, dynamic> entry) async {
    return _backupEntryMap(entry);
  }

  Future<bool> _backupEntryMap(Map<String, dynamic> entry) async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final id = (entry['id'] ?? '').toString();
      if (id.isEmpty) return false;

      final data = {
        'id': id,
        'title': entry['title'],
        'content': entry['content'],
        'preview': entry['preview'],
        'mood': entry['mood'],
        'word_count': entry['word_count'],
        'created_at': entry['created_at'],
        'attachments': entry['attachments'] ?? <String>[],
      };

      final bytes = Uint8List.fromList(utf8.encode(const JsonEncoder.withIndent('  ').convert(data)));
      final path = '$userId/$id.json';
      final storage = _client.storage.from(_bucket);
      await storage.uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(contentType: 'application/json', upsert: true),
      );
      return true;
    } catch (e) {
      // Non-fatal; return false if backup fails for this entry
      return false;
    }
  }

  Future<List<String>> _fetchEntryAttachments(String entryId) async {
    try {
      final res = await _client
          .from('journal_entry_attachments')
          .select('url')
          .eq('entry_id', entryId);
      return List<Map<String, dynamic>>.from(res)
          .map((e) => e['url']?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    } catch (_) {
      return <String>[];
    }
  }
}
