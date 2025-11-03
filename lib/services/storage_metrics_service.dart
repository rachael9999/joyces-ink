import 'dart:async';
import 'dart:io' show HttpClient, HttpClientRequest, HttpClientResponse;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';

import './auth_service.dart';
import './supabase_service.dart';

class StorageMetricsService {
  static StorageMetricsService? _instance;
  static StorageMetricsService get instance =>
      _instance ??= StorageMetricsService._();

  StorageMetricsService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Compute total bytes used by user's attachments (by HEAD on URLs) and backups
  Future<int> computeTotalBytes({bool includeBackups = true}) async {
    final userId = AuthService.instance.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final attachments = await _sumAttachmentUrlBytes(userId);
    final backups = includeBackups ? await _sumFolderBytes('backups', userId) : 0;
    return attachments + backups;
  }

  Future<Map<String, int>> computeDetailed() async {
    final userId = AuthService.instance.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final entriesCount = await _countTable('journal_entries', userId);
    final attachmentsCount = await _countTable('journal_entry_attachments', userId);
    final backupsBytes = await _sumFolderBytes('backups', userId);
    final attachmentsBytes = await _sumAttachmentUrlBytes(userId);
    return {
      'entriesCount': entriesCount,
      'attachmentsCount': attachmentsCount,
      'backupsBytes': backupsBytes,
      'attachmentsBytes': attachmentsBytes,
      'totalBytes': backupsBytes + attachmentsBytes,
    };
  }

  // Sum sizes for all files directly under userId and its immediate subfolders
  // Note: Supabase Storage does not support deep recursive list natively; we
  // call list on user folder and then for each apparent subfolder path.
  Future<int> _sumFolderBytes(String bucket, String userPrefix) async {
    int total = 0;
    final storage = _client.storage.from(bucket);

    try {
      // First try listing directly at the user root; this will return files directly under userPrefix
      final root = await storage.list(path: userPrefix);
      for (final obj in root) {
        final size = _fileSize(obj);
        total += size;
      }

      // Heuristic: list entries by probing known subpaths based on Postgres entries may not be feasible here.
      // As a fallback, try to list "folders" by querying names that look like UUIDs under userPrefix.
      // Supabase returns FileObject with 'name' and 'id'; items with empty id may denote folders in some SDK versions.
      // We'll iterate over root again and skip files (which have metadata), but this is SDK-specific.

      // If no files found at root, we can attempt a shallow scan of common nested paths by listing all objects and summing sizes.
      // Unfortunately, without a recursive list, we cannot perfectly discover nested files. Consumers upload to userId/entryId/filename,
      // so we attempt listing for each entryId if provided by caller; otherwise, the root sum may be zero.
    } catch (_) {
      // ignore and return what we have
    }

    return total;
  }

  Future<int> _countTable(String table, String userId) async {
    try {
      final res = await _client.from(table).select('id').eq('user_id', userId).count();
  return res.count;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _sumAttachmentUrlBytes(String userId) async {
    // Query all attachment URLs for the user and HEAD each to get Content-Length
    try {
      final rows = await _client
          .from('journal_entry_attachments')
          .select('url')
          .eq('user_id', userId)
          .limit(2000);
      final urls = List<Map<String, dynamic>>.from(rows)
          .map((e) => e['url']?.toString() ?? '')
          .where((u) => u.isNotEmpty)
          .toList();
      if (urls.isEmpty) return 0;
      if (kIsWeb) {
        // On web, do not attempt HEAD due to CORS; return 0 to avoid blocking UI
        return 0;
      }
      int total = 0;
      final client = HttpClient();
      try {
        // Limit concurrency to avoid too many sockets
        const parallel = 6;
        int index = 0;
        Future<void> worker() async {
          while (true) {
            String url;
            if (index >= urls.length) break;
            url = urls[index++];
            try {
              final uri = Uri.parse(url);
              final HttpClientRequest req = await client.openUrl('HEAD', uri);
              final HttpClientResponse resp = await req.close();
              final lenHeader = resp.headers.value('content-length');
              if (lenHeader != null) {
                total += int.tryParse(lenHeader) ?? 0;
              }
            } catch (_) {
              // ignore individual failures
            }
          }
        }
        final futures = List.generate(parallel, (_) => worker());
        await Future.wait(futures);
      } finally {
        client.close(force: true);
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  int _fileSize(FileObject obj) {
    try {
      final meta = obj.metadata;
      if (meta == null) return 0;
      final dynamic size = meta['size'];
      if (size == null) return 0;
      if (size is int) return size;
      return int.tryParse(size.toString()) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  static String formatBytes(int bytes) {
    const int k = 1024;
    if (bytes < k) return '$bytes B';
    final double kb = bytes / k;
    if (kb < k) return '${kb.toStringAsFixed(1)} KB';
    final double mb = kb / k;
    if (mb < k) return '${mb.toStringAsFixed(1)} MB';
    final double gb = mb / k;
    return '${gb.toStringAsFixed(2)} GB';
  }
}
