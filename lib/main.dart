import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/env.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/landing/presentation/screens/landing_page.dart';

Future<void> main() async {
  _registerInterLicense();

  // Web only ever serves the marketing landing page — the real app depends
  // on native features (camera, image_picker) that aren't built for web, so
  // there's no Supabase init, no dart-defines, and no router on this path.
  if (kIsWeb) {
    runApp(const PropertyIQWebApp());
    return;
  }

  WidgetsFlutterBinding.ensureInitialized();
  Env.assertConfigured();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    // The stored credential is the legacy anon key; passed via the current
    // (non-deprecated) publishableKey parameter, which the SDK uses as the
    // public apikey header.
    publishableKey: Env.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: PropertyIQApp()));
}

/// Surfaces Inter's OFL 1.1 text in Settings > About > Licenses.
///
/// Flutter's LicenseRegistry auto-collects LICENSE files from pub
/// dependencies, but Inter is bundled directly as an asset (see
/// pubspec.yaml and app_theme.dart), not pulled in via a package, so it
/// needs registering by hand for the credit to appear.
void _registerInterLicense() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/fonts/Inter-OFL.txt');
    yield LicenseEntryWithLineBreaks(['Inter'], license);
  });
}

/// Lightweight root for the web build: just the landing page, no auth/router.
class PropertyIQWebApp extends StatelessWidget {
  const PropertyIQWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PropertyIQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const LandingPage(),
    );
  }
}

/// Root widget: wires the router + light/dark themes. Theme follows the OS
/// setting (both themes are mandatory per the design system).
class PropertyIQApp extends ConsumerWidget {
  const PropertyIQApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'PropertyIQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
