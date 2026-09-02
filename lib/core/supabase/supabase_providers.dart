import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_providers.g.dart';

/// Single source for the initialized Supabase client. Repositories depend on
/// this provider instead of reaching for the global singleton, which keeps them
/// mockable in tests.
@Riverpod(keepAlive: true)
SupabaseClient supabaseClient(Ref ref) => Supabase.instance.client;
