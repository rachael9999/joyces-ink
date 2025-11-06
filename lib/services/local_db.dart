import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class LocalDb {
  LocalDb._();
  static final LocalDb instance = LocalDb._();

  Database? _db;

  Future<void> init() async {
    if (kIsWeb) {
      // sqflite is not supported on web
      return;
    }
    if (_db != null) return;

    final Directory appDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(appDir.path, 'joyces_ink.db');
    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await _createSchema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Handle future migrations here
      },
    );
  }

  Database get db {
    final database = _db;
    if (database == null) {
      throw StateError('LocalDb not initialized. Call LocalDb.instance.init() early.');
    }
    return database;
  }

  Future<void> _createSchema(Database db) async {
    // Core journaling tables (single-user local mode, so no user_id column)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS journal_entries (
        id TEXT PRIMARY KEY,
        title TEXT,
        content TEXT NOT NULL,
        preview TEXT,
        mood TEXT,
        word_count INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        is_favorite INTEGER NOT NULL DEFAULT 0
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS journal_entry_attachments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entry_id TEXT NOT NULL,
        url TEXT NOT NULL,
        FOREIGN KEY (entry_id) REFERENCES journal_entries(id) ON DELETE CASCADE
      );
    ''');
  }
}
