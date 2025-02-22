import 'package:aarogya_vishwas/firebase_options.dart';
import 'package:aarogya_vishwas/localization/app_localization.dart';
import 'package:aarogya_vishwas/UI/splashscreen/Splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: 'https://qkwvraqegdlxenrrzzbn.supabase.co', // Replace with your Supabase URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFrd3ZyYXFlZ2RseGVucnJ6emJuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAyNTAyMjUsImV4cCI6MjA1NTgyNjIyNX0.YZeu3bp3fbL8D6b-v30NHi9ajadTI0_s2FrwCC8VwT4', // Replace with your Supabase anon key
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('languageCode');
    if (languageCode != null) {
      setState(() {
        _locale = Locale(languageCode);
      });
    }
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aarogya Vishwas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Product Sans Medium',
      ),
      locale: _locale,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('hi', 'IN'),
        Locale('bn', 'BD'),
        Locale('te', 'IN'),
        Locale('mr', 'IN'),
        Locale('ta', 'IN'),
        Locale('gu', 'IN'),
        Locale('kn', 'IN'),
        Locale('pa', 'IN'),
        Locale('or', 'IN'),
        Locale('ml', 'IN'),
        Locale('ur', 'PK'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Splashscreen(onLocaleChange: setLocale),
    );
  }
}