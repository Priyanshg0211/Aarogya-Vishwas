import 'package:aarogya_vishwas/Homescreen/onboardingscreen.dart';
import 'package:aarogya_vishwas/Homescreen/selectlanguage.dart';
import 'package:aarogya_vishwas/firebase_options.dart';
import 'package:aarogya_vishwas/localization/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart'; // Add this import

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final Locale? locale;

  const MyApp({this.locale, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aarogya Vishwas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Product Sans Medium',
      ),
      locale: locale,
      supportedLocales: [
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
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: locale == null ? LanguageSelectionScreen() : OnboardingScreen(),
    );
  }
}