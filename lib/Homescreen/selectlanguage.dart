import 'package:aarogya_vishwas/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSelectionScreen extends StatefulWidget {
  @override
  _LanguageSelectionScreenState createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final Map<String, String> languages = {
    'English': 'en',
    'Hindi': 'hi',
    'Bengali': 'bn',
    'Telugu': 'te',
    'Marathi': 'mr',
    'Tamil': 'ta',
    'Gujarati': 'gu',
    'Kannada': 'kn',
    'Punjabi': 'pa',
    'Odia': 'or',
    'Malayalam': 'ml',
    'Urdu': 'ur',
  };

  String? _selectedLanguageCode;

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  Future<void> _loadSelectedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguageCode = prefs.getString('languageCode');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Language'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: languages.entries.map((entry) {
          return ListTile(
            title: Text(entry.key),
            trailing: _selectedLanguageCode == entry.value
                ? Icon(Icons.check, color: Colors.teal) // Show tick if selected
                : null, // No tick if not selected
            onTap: () async {
              // Save the selected language code to shared preferences
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('languageCode', entry.value);

              // Update the UI to show the tick
              setState(() {
                _selectedLanguageCode = entry.value;
              });

              // Navigate to the home screen with the selected language
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MyApp(locale: Locale(entry.value)),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}