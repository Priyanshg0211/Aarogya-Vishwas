import 'package:aarogya_vishwas/UI/Onboarding/onboardingscreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final Function(Locale) onLocaleChange;

  const LanguageSelectionScreen({
    Key? key,
    required this.onLocaleChange,
  }) : super(key: key);

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
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguageCode = prefs.getString('languageCode');
    });
  }

  Future<void> _selectLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', languageCode);
    
    setState(() {
      _selectedLanguageCode = languageCode;
    });
    
    widget.onLocaleChange(Locale(languageCode));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Language',style: TextStyle(color: Colors.white,fontFamily: 'Product Sans Medium'),),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: languages.entries.map((entry) {
                return ListTile(
                  title: Text(entry.key),
                  trailing: _selectedLanguageCode == entry.value
                      ? const Icon(Icons.check, color: Colors.teal)
                      : null,
                  onTap: () => _selectLanguage(entry.value),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
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
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OnboardingScreen(
                              locale: Locale(_selectedLanguageCode!),
                              onLocaleChange: widget.onLocaleChange,
                            ),
                          ),
                        );
                      },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
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