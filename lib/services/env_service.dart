// Lightweight build-time environment accessors
// Use with --dart-define=DATA_BACKEND=sqlite to enable local-only mode

class EnvService {
  // Values are compile-time constants provided via --dart-define
  static const String dataBackend = String.fromEnvironment(
    'DATA_BACKEND',
    defaultValue: 'supabase',
  );

  static bool get useSqlite => dataBackend.toLowerCase() == 'sqlite';
}
