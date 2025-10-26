import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // Track initialization state more reliably
  static bool _isInitialized = false;
  static SupabaseClient? _clientInstance;

  // Initialize Supabase - call this in main()
  static Future<void> initialize() async {
    if (_isInitialized && _clientInstance != null) {
      return; // Already initialized
    }

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
        'SUPABASE_URL and SUPABASE_ANON_KEY must be defined using --dart-define.',
      );
    }

    try {
      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
      _clientInstance = Supabase.instance.client;
      _isInitialized = true;
    } catch (error) {
      _isInitialized = false;
      _clientInstance = null;
      throw Exception('Failed to initialize Supabase: $error');
    }
  }

  // Get Supabase client with enhanced null safety
  SupabaseClient get client {
    try {
      // Check our internal tracking first
      if (!_isInitialized || _clientInstance == null) {
        throw Exception(
          'Supabase is not initialized. Please call SupabaseService.initialize() first.',
        );
      }

      // Double-check Supabase internal state
      if (!Supabase.instance.isInitialized) {
        throw Exception(
          'Supabase internal state is not initialized. Please restart the app.',
        );
      }

      // Return cached client to avoid potential null issues
      return _clientInstance!;
    } catch (error) {
      throw Exception('Failed to get Supabase client: $error');
    }
  }

  // Check if Supabase is properly initialized with enhanced checks
  bool get isInitialized {
    try {
      return _isInitialized &&
          _clientInstance != null &&
          Supabase.instance.isInitialized;
    } catch (e) {
      return false;
    }
  }

  // Method to reset initialization state if needed
  static void resetInitialization() {
    _isInitialized = false;
    _clientInstance = null;
  }
}
