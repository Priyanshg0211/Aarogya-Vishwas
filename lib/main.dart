import 'package:aarogya_vishwas/Feature/AI%20model/widget/ModelUI.dart';
import 'package:aarogya_vishwas/Feature/splashscreen/Splashscreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medical Report Analysis',
      home: Splashscreen(),
    );
  }
}