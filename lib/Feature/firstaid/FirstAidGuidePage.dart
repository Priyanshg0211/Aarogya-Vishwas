import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';

class FirstAidGuidePage extends StatefulWidget {
  @override
  _FirstAidGuidePageState createState() => _FirstAidGuidePageState();
}

class _FirstAidGuidePageState extends State<FirstAidGuidePage> {
  final FlutterTts flutterTts = FlutterTts();
  String selectedLanguage = 'en'; // Default language is English
  bool isTtsInitialized = false;

  // Sample first aid categories and instructions
  final List<Map<String, dynamic>> firstAidCategories = [
    {
      'title': 'Heart Attack',
      'steps': [
        'Call emergency services immediately.',
        'Help the person sit down and rest.',
        'If the person is conscious, give them an aspirin to chew.',
        'Perform CPR if the person becomes unresponsive.',
      ],
    },
    {
      'title': 'Burn Injuries',
      'steps': [
        'Cool the burn under running water for 10-15 minutes.',
        'Cover the burn with a sterile dressing.',
        'Do not apply ice or creams.',
        'Seek medical help if the burn is severe.',
      ],
    },
    {
      'title': 'Snake Bites',
      'steps': [
        'Keep the person calm and still.',
        'Do not cut the wound or try to suck out the venom.',
        'Immobilize the affected limb and keep it at heart level.',
        'Take the person to a hospital immediately.',
      ],
    },
  ];

  // Language options
  final Map<String, String> languages = {
    'en': 'English',
    'hi': 'Hindi',
    'ta': 'Tamil',
    'bn': 'Bengali',
  };

  @override
  void initState() {
    super.initState();
    initializeTts();
  }

  Future<void> initializeTts() async {
    try {
      // Check if the selected language is supported
      final languages = await flutterTts.getLanguages;
      if (languages.contains(selectedLanguage)) {
        await flutterTts.setLanguage(selectedLanguage);
        await flutterTts.setSpeechRate(0.5); // Adjust speech rate
        await flutterTts.setVolume(1.0); // Set volume to max
        await flutterTts.setPitch(1.0); // Set pitch to normal
        setState(() {
          isTtsInitialized = true;
        });
        print('TTS initialized successfully. Supported languages: $languages');
      } else {
        print('Selected language ($selectedLanguage) is not supported.');
      }
    } catch (e) {
      print('Failed to initialize TTS: $e');
    }
  }

  @override
  void dispose() {
    flutterTts.stop(); // Stop TTS when the page is disposed
    super.dispose();
  }

  Future<void> speakInstructions(String text) async {
    if (!isTtsInitialized) {
      print('TTS is not initialized.');
      return;
    }

    try {
      await flutterTts.speak(text);
      print('Speaking: $text');
    } catch (e) {
      print('Failed to speak: $e');
    }
  }

  Future<void> speakCategoryInstructions(String title, List<String> steps) async {
    String fullInstructions = "What to do in case of $title? ${steps.join('. ')}";
    await speakInstructions(fullInstructions);
  }

  Future<void> callEmergency() async {
    const emergencyNumber = 'tel:102'; // Replace with your country's emergency number
    if (await canLaunch(emergencyNumber)) {
      await launch(emergencyNumber);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not call emergency services')),
      );
    }
  }

  void changeLanguage(String? language) {
    if (language != null) {
      setState(() {
        selectedLanguage = language;
      });
      initializeTts(); // Reinitialize TTS with the new language
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offline First Aid Guide'),
        actions: [
          IconButton(
            icon: Icon(Icons.emergency),
            onPressed: callEmergency, // Emergency SOS button
          ),
          DropdownButton<String>(
            value: selectedLanguage,
            onChanged: changeLanguage,
            items: languages.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: firstAidCategories.length,
        itemBuilder: (context, index) {
          final category = firstAidCategories[index];
          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ExpansionTile(
              title: Text(
                category['title'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              trailing: IconButton(
                icon: Icon(Icons.volume_up),
                onPressed: () => speakCategoryInstructions(category['title'], category['steps']),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final step in category['steps'])
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.arrow_right, size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  step,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}