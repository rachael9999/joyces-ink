import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static SettingsService? _instance;
  static SettingsService get instance => _instance ??= SettingsService._();

  SettingsService._();

  static const String _kPrivacyMode = 'privacy_mode';
  static const String _kAutoBackupEnabled = 'auto_backup_enabled';
  static const String _kLastBackupAt = 'last_backup_at';

  bool _loaded = false;
  bool _privacyMode = false;
  bool _autoBackupEnabled = false;
  DateTime? _lastBackupAt;

  final StreamController<void> _changeController =
      StreamController<void>.broadcast();

  Stream<void> get onChanged => _changeController.stream;

  bool get isLoaded => _loaded;
  bool get privacyMode => _privacyMode;
  bool get autoBackupEnabled => _autoBackupEnabled;
  DateTime? get lastBackupAt => _lastBackupAt;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _privacyMode = prefs.getBool(_kPrivacyMode) ?? false;
    _autoBackupEnabled = prefs.getBool(_kAutoBackupEnabled) ?? false;
    final last = prefs.getString(_kLastBackupAt);
    _lastBackupAt = last != null ? DateTime.tryParse(last) : null;
    _loaded = true;
    _changeController.add(null);
  }

  Future<void> setPrivacyMode(bool value) async {
    _privacyMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPrivacyMode, value);
    _changeController.add(null);
  }

  Future<void> setAutoBackupEnabled(bool value) async {
    _autoBackupEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAutoBackupEnabled, value);
    _changeController.add(null);
  }

  Future<void> setLastBackupAt(DateTime time) async {
    _lastBackupAt = time;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastBackupAt, time.toIso8601String());
    _changeController.add(null);
  }

  void dispose() {
    _changeController.close();
  }
}
