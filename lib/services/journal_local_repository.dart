import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../core/text_metrics.dart';
import 'local_db.dart';

class JournalLocalRepository {
  JournalLocalRepository._();
  static final JournalLocalRepository instance = JournalLocalRepository._();

  Database get _db => LocalDb.instance.db;
  final _uuid = const Uuid();

  Future<List<Map<String, dynamic>>> getJournalEntries({
    int? limit,
    String? searchQuery,
  }) async {
    final where = <String>[];
    final args = <Object?>[];

    if (searchQuery != null && searchQuery.isNotEmpty) {
      where.add('(content LIKE ? OR preview LIKE ?)');
      final like = '%$searchQuery%';
      args..add(like)..add(like);
    }

    final entries = await _db.query(
      'journal_entries',
      columns: [
        'id','title','content','preview','mood','word_count','created_at','is_favorite'
      ],
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'datetime(created_at) DESC',
      limit: limit,
    );

    // Fetch attachments per entry
    final result = <Map<String, dynamic>>[];
    for (final e in entries) {
      final atts = await _db.query(
        'journal_entry_attachments',
        columns: ['url'],
        where: 'entry_id = ?',
        whereArgs: [e['id']],
      );
      result.add({
        ...e,
        'attachments': atts.map((a) => a['url'] as String).toList(),
        'is_favorite': (e['is_favorite'] ?? 0) == 1,
        'preview': e['preview'] ?? '',
        'mood': e['mood'] ?? 'neutral',
      });
    }
    return result;
  }

  Future<Map<String, dynamic>> createJournalEntry({
    String? title,
    required String content,
    required String preview,
    required String mood,
  }) async {
    final id = _uuid.v4();
    final wordCount = TextMetrics.countWords(content);
    final createdAt = DateTime.now().toIso8601String();
    await _db.insert('journal_entries', {
      'id': id,
      'title': title,
      'content': content,
      'preview': preview,
      'mood': mood,
      'word_count': wordCount,
      'created_at': createdAt,
      'is_favorite': 0,
    });
    return await getJournalEntry(id) ?? {
      'id': id,
      'title': title,
      'content': content,
      'preview': preview,
      'mood': mood,
      'word_count': wordCount,
      'created_at': createdAt,
      'is_favorite': false,
      'attachments': <String>[],
    };
  }

  Future<Map<String, dynamic>?> getJournalEntry(String entryId) async {
    final rows = await _db.query(
      'journal_entries',
      where: 'id = ?',
      whereArgs: [entryId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final atts = await _db.query(
      'journal_entry_attachments',
      columns: ['url'],
      where: 'entry_id = ?',
      whereArgs: [entryId],
    );
    final e = rows.first;
    return {
      ...e,
      'attachments': atts.map((a) => a['url'] as String).toList(),
      'is_favorite': (e['is_favorite'] ?? 0) == 1,
      'preview': e['preview'] ?? '',
      'mood': e['mood'] ?? 'neutral',
    };
  }

  Future<Map<String, dynamic>> updateJournalEntry({
    required String entryId,
    String? title,
    String? content,
    String? preview,
    String? mood,
    bool? isFavorite,
    String? createdAt,
  }) async {
    final updates = <String, Object?>{};
    if (title != null) updates['title'] = title;
    if (content != null) {
      updates['content'] = content;
      updates['word_count'] = TextMetrics.countWords(content);
    }
    if (preview != null) updates['preview'] = preview;
    if (mood != null) updates['mood'] = mood;
    if (isFavorite != null) updates['is_favorite'] = isFavorite ? 1 : 0;
    if (createdAt != null) updates['created_at'] = createdAt;

    if (updates.isNotEmpty) {
      await _db.update(
        'journal_entries',
        updates,
        where: 'id = ?',
        whereArgs: [entryId],
      );
    }
    final updated = await getJournalEntry(entryId);
    if (updated == null) throw Exception('Entry not found');
    return updated;
  }

  Future<void> deleteJournalEntry(String entryId) async {
    await _db.delete(
      'journal_entry_attachments',
      where: 'entry_id = ?',
      whereArgs: [entryId],
    );
    await _db.delete(
      'journal_entries',
      where: 'id = ?',
      whereArgs: [entryId],
    );
  }

  Future<int> replaceEntryAttachments({
    required String entryId,
    required List<String> urls,
  }) async {
    await _db.delete(
      'journal_entry_attachments',
      where: 'entry_id = ?',
      whereArgs: [entryId],
    );
    int count = 0;
    for (final u in urls) {
      await _db.insert('journal_entry_attachments', {
        'entry_id': entryId,
        'url': u,
      });
      count++;
    }
    return count;
  }

  // Store attachment bytes in app documents under attachments/<entryId>/<fileName>
  Future<String?> saveAttachmentBytes({
    required Uint8List bytes,
    required String entryId,
    required String fileName,
  }) async {
    final Directory baseDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(baseDir.path, 'attachments', entryId));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final filePath = p.join(dir.path, fileName);
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    return file.path; // Return local file path
  }
}
