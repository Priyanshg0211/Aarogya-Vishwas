import 'package:aarogya_vishwas/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSelectionScreen extends StatefulWidget {
  @override
  _LanguageSelectionScreenState createState() =>
      _LanguageSelectionScreenState();
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
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16.0),
              children: languages.entries.map((entry) {
                return ListTile(
                  title: Text(entry.key),
                  trailing: _selectedLanguageCode == entry.value
                      ? Icon(Icons.check,
                          color: Colors.teal) // Show tick if selected
                      : null, // No tick if not selected
                  onTap: () async {
                    // Save the selected language code to shared preferences
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setString('languageCode', entry.value);

                    // Update the UI to show the tick
                    setState(() {
                      _selectedLanguageCode = entry.value;
                    });
                  },
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: MediaQuery.sizeOf(context).width * 0.9,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  splashFactory: NoSplash.splashFactory,
                  shadowColor: Colors.transparent,
                ),
                onPressed: _selectedLanguageCode == null
                    ? null
                    : () {
                        // Navigate to the home screen with the selected language
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MyApp(locale: Locale(_selectedLanguageCode!)),
                          ),
                        );
                      },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Confirm',
                      style: TextStyle(
                        fontFamily: 'Product Sans',
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
