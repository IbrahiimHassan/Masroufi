import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/database/app_database.dart';
import 'core/l10n/app_strings.dart';
import 'core/settings/settings_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/auth/presentation/screens/auth_screen.dart';
import 'features/home/home_shell.dart';
import 'user_scope.dart';

class MasroufiApp extends StatelessWidget {
  const MasroufiApp({
    super.key,
    required this.appDatabase,
    required this.preferences,
  });

  final AppDatabase appDatabase;
  final SharedPreferences preferences;

  @override
  Widget build(BuildContext context) {
    // App-wide providers: settings (theme / language / currency) and auth.
    // The data providers are created per user in UserScope.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider(preferences)),
        ChangeNotifierProvider(
          create: (_) =>
              AuthProvider(AuthRepository(appDatabase), preferences)
                ..restoreSession(),
        ),
      ],
      child: _AppView(appDatabase: appDatabase),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView({required this.appDatabase});

  final AppDatabase appDatabase;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final arabic = settings.usesArabic;

    return MaterialApp(
      onGenerateTitle: (context) => AppStrings.of(context).appName,
      debugShowCheckedModeBanner: false,

      // Language: null = follow the phone. Arabic switches to right-to-left.
      locale: settings.locale,
      supportedLocales: AppStrings.supportedLocales,
      localizationsDelegates: const [
        AppStrings.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Theme: light, dark, or follow the phone.
      theme: AppTheme.light(arabic: arabic),
      darkTheme: AppTheme.dark(arabic: arabic),
      themeMode: settings.themeMode,

      // Honour the user's font size, but cap it so layouts don't break.
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        minScaleFactor: 0.85,
        maxScaleFactor: 1.4,
        child: child!,
      ),
      home: _AuthGate(appDatabase: appDatabase),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate({required this.appDatabase});

  final AppDatabase appDatabase;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isRestoring) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = auth.user;
    if (user == null) return const AuthScreen();

    return UserScope(
      key: ValueKey(user.id),
      appDatabase: appDatabase,
      userId: user.id,
      child: const HomeShell(),
    );
  }
}
