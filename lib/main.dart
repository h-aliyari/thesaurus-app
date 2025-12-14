import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'provider/thesaurus_provider.dart';
import 'provider/theme_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThesaurusProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer2<ThesaurusProvider, ThemeProvider>(
        builder: (context, thesaurusProvider, themeProvider, _) {
          return MaterialApp.router(
            routerConfig: router,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeProvider.themeMode,
            locale: thesaurusProvider.locale,
            supportedLocales: const [
              Locale('fa'),
              Locale('en'),
              Locale('ar'),
            ],
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              return Directionality(
                textDirection: thesaurusProvider.direction,
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}