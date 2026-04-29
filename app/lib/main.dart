import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_constants.dart';
import 'config/supabase_config.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';
import 'widgets/gradient_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.publishableKey,
  );
  runApp(const ProviderScope(child: ThreeZonesApp()));
}

class ThreeZonesApp extends StatelessWidget {
  const ThreeZonesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      builder: (context, child) => GradientBackground(
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
