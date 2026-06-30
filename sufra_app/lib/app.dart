import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'state/settings_provider.dart';

class SufraApp extends StatelessWidget {
  const SufraApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      title: 'سُفرة',
      debugShowCheckedModeBanner: false,
      theme: SufraTheme.light(),
      darkTheme: SufraTheme.dark(),
      themeMode: settings.themeMode,
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'), // Arabic — primary, RTL
        Locale('en'), // English — fallback
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        // Force RTL layout regardless of device locale, since this app is
        // built Arabic-first for an Arabic-speaking audience.
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}
