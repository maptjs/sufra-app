import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

class SufraApp extends StatelessWidget {
  const SufraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سُفرة',
      debugShowCheckedModeBanner: false,
      theme: SufraTheme.light(),
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
