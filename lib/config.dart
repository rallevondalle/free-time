/// Supabase project settings. Override at build time:
///   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_KEY=...
const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: 'http://localhost:54321');
const supabaseKey = String.fromEnvironment('SUPABASE_KEY', defaultValue: '');
