import 'package:aarogya_vishwas/UI/Homescreen/Homescreen.dart';
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

  // Language options
  final Map<String, String> languages = {
    'en': 'English',
    'hi': 'Hindi',
    'ta': 'Tamil',
    'bn': 'Bengali',
  };

  // Sample first aid categories and instructions in multiple languages
  final Map<String, Map<String, List<String>>> firstAidCategories = {
    'en': {
      'Heart Attack': [
        'Call emergency services immediately.',
        'Help the person sit down and rest.',
        'If the person is conscious, give them an aspirin to chew.',
        'Perform CPR if the person becomes unresponsive.',
      ],
      'Burn Injuries': [
        'Cool the burn under running water for 10-15 minutes.',
        'Cover the burn with a sterile dressing.',
        'Do not apply ice or creams.',
        'Seek medical help if the burn is severe.',
      ],
      'Snake Bites': [
        'Keep the person calm and still.',
        'Do not cut the wound or try to suck out the venom.',
        'Immobilize the affected limb and keep it at heart level.',
        'Take the person to a hospital immediately.',
      ],
      'Choking': [
        'Encourage the person to cough to clear the blockage.',
        'Perform the Heimlich maneuver if the person cannot breathe.',
        'Call emergency services if the blockage is not cleared.',
        'Monitor the person until help arrives.',
      ],
      'Fractures': [
        'Immobilize the injured area using a splint or sling.',
        'Apply ice to reduce swelling.',
        'Do not attempt to realign the bone.',
        'Seek medical attention immediately.',
      ],
    },
    'hi': {
      'हार्ट अटैक': [
        'तुरंत आपातकालीन सेवाओं को कॉल करें।',
        'व्यक्ति को बैठने और आराम करने में मदद करें।',
        'यदि व्यक्ति होश में है, तो उन्हें चबाने के लिए एस्पिरिन दें।',
        'यदि व्यक्ति बेहोश हो जाए, तो सीपीआर करें।',
      ],
      'जलने की चोट': [
        'जले हुए स्थान को 10-15 मिनट तक बहते पानी के नीचे ठंडा करें।',
        'जले हुए स्थान को स्टराइल ड्रेसिंग से ढकें।',
        'बर्फ या क्रीम न लगाएं।',
        'यदि जलन गंभीर है, तो चिकित्सकीय सहायता लें।',
      ],
      'सांप का काटना': [
        'व्यक्ति को शांत और स्थिर रखें।',
        'घाव को काटें नहीं या जहर निकालने की कोशिश न करें।',
        'प्रभावित अंग को स्थिर करें और इसे हृदय स्तर पर रखें।',
        'व्यक्ति को तुरंत अस्पताल ले जाएं।',
      ],
      'दम घुटना': [
        'व्यक्ति को खांसने के लिए प्रोत्साहित करें।',
        'यदि व्यक्ति सांस नहीं ले सकता है, तो हाइमलिक मैन्युवर करें।',
        'यदि रुकावट दूर नहीं होती है, तो आपातकालीन सेवाओं को कॉल करें।',
        'मदद आने तक व्यक्ति की निगरानी करें।',
      ],
      'फ्रैक्चर': [
        'चोटग्रस्त क्षेत्र को स्प्लिंट या स्लिंग से स्थिर करें।',
        'सूजन कम करने के लिए बर्फ लगाएं।',
        'हड्डी को सीधा करने की कोशिश न करें।',
        'तुरंत चिकित्सकीय सहायता लें।',
      ],
    },
    'ta': {
      'இதய அடைப்பு': [
        'உடனடியாக அவசர சேவைகளை அழைக்கவும்.',
        'நபரை உட்கார வைத்து ஓய்வெடுக்க உதவுங்கள்.',
        'நபர் உணர்வுடன் இருந்தால், அவர்களுக்கு அஸ்பிரின் மாத்திரை கொடுங்கள்.',
        'நபர் உணர்விழந்தால், சிபிஆர் செய்யுங்கள்.',
      ],
      'தீக்காயங்கள்': [
        '10-15 நிமிடங்களுக்கு தண்ணீரில் குளிர்விக்கவும்.',
        'தீக்காயத்தை மருத்துவ துணியால் மூடவும்.',
        'பனிக்கட்டி அல்லது கிரீம்களை பயன்படுத்த வேண்டாம்.',
        'தீக்காயம் கடுமையானால் மருத்துவ உதவி பெறவும்.',
      ],
      'பாம்பு கடி': [
        'நபரை அமைதியாகவும் நிலையாகவும் வைத்திருங்கள்.',
        'காயத்தை வெட்டவோ அல்லது விஷத்தை உறிஞ்சவோ செய்யாதீர்கள்.',
        'பாதிக்கப்பட்ட பகுதியை நிலையாக வைத்து இதய மட்டத்தில் வைக்கவும்.',
        'நபரை உடனடியாக மருத்துவமனைக்கு அழைத்துச் செல்லுங்கள்.',
      ],
      'மூச்சுத் திணறல்': [
        'நபரை இரும வைத்து தடையை அகற்ற உதவுங்கள்.',
        'நபர் மூச்சுவிட முடியாவிட்டால் ஹைம்லிக் முறையை பின்பற்றுங்கள்.',
        'தடை அகலவில்லை என்றால் அவசர சேவைகளை அழைக்கவும்.',
        'உதவி வரும் வரை நபரை கண்காணிக்கவும்.',
      ],
      'எலும்பு முறிவு': [
        'பாதிக்கப்பட்ட பகுதியை ஸ்ப்ளிண்ட் அல்லது ஸ்லிங் மூலம் நிலையாக வைக்கவும்.',
        'வீக்கத்தை குறைக்க பனிக்கட்டி வைக்கவும்.',
        'எலும்பை நேராக்க முயற்சிக்காதீர்கள்.',
        'உடனடியாக மருத்துவ உதவி பெறவும்.',
      ],
    },
    'bn': {
      'হার্ট অ্যাটাক': [
        'তাত্ক্ষণিকভাবে জরুরি পরিষেবাগুলিতে কল করুন।',
        'ব্যক্তিকে বসতে এবং বিশ্রাম নিতে সাহায্য করুন।',
        'ব্যক্তি সচেতন থাকলে, তাদের অ্যাসপিরিন চিবাতে দিন।',
        'ব্যক্তি অচেতন হয়ে গেলে সিপিআর করুন।',
      ],
      'পোড়া': [
        '10-15 মিনিটের জন্য চলমান জলের নীচে পোড়া ঠান্ডা করুন।',
        'পোড়া স্থানটি একটি স্টেরাইল ড্রেসিং দিয়ে ঢেকে দিন।',
        'বরফ বা ক্রিম প্রয়োগ করবেন না।',
        'পোড়া গুরুতর হলে চিকিৎসা সহায়তা নিন।',
      ],
      'সাপের কামড়': [
        'ব্যক্তিকে শান্ত এবং স্থির রাখুন।',
        'ক্ষত কাটবেন না বা বিষ বের করার চেষ্টা করবেন না।',
        'আক্রান্ত অঙ্গটি স্থির করুন এবং হৃদয় স্তরে রাখুন।',
        'ব্যক্তিকে অবিলম্বে হাসপাতালে নিয়ে যান।',
      ],
      'শ্বাসরোধ': [
        'ব্যক্তিকে কাশতে উত্সাহিত করুন।',
        'ব্যক্তি শ্বাস নিতে না পারলে হেইমলিক ম্যানুভার করুন।',
        'বাধা দূর না হলে জরুরি পরিষেবাগুলিতে কল করুন।',
        'সাহায্য না আসা পর্যন্ত ব্যক্তির উপর নজর রাখুন।',
      ],
      'হাড় ভাঙা': [
        'আক্রান্ত স্থানটি স্প্লিন্ট বা স্লিং দিয়ে স্থির করুন।',
        'ফোলা কমাতে বরফ প্রয়োগ করুন।',
        'হাড় সোজা করার চেষ্টা করবেন না।',
        'তাত্ক্ষণিকভাবে চিকিৎসা সহায়তা নিন।',
      ],
    },
  };

  @override
  void initState() {
    super.initState();
    initializeTts();
  }

  Future<void> initializeTts() async {
    try {
      // First, check if TTS is available
      var available = await flutterTts.isLanguageAvailable(selectedLanguage);

      if (available) {
        // Configure TTS settings
        await Future.wait([
          flutterTts.setLanguage(selectedLanguage),
          flutterTts.setSpeechRate(0.5),
          flutterTts.setVolume(1.0),
          flutterTts.setPitch(1.0),
        ]);

        // Add error and completion handlers
        flutterTts.setErrorHandler((msg) {
          print("TTS error: $msg");
          setState(() {
            isTtsInitialized = false;
          });
        });

        flutterTts.setStartHandler(() {
          print("TTS started");
        });

        flutterTts.setCompletionHandler(() {
          print("TTS completed");
        });

        setState(() {
          isTtsInitialized = true;
        });
        print('TTS initialized successfully for language: $selectedLanguage');
      } else {
        print('Language $selectedLanguage not available');
        // Try falling back to English if selected language is not available
        if (selectedLanguage != 'en') {
          print('Falling back to English');
          setState(() {
            selectedLanguage = 'en';
          });
          await initializeTts(); // Recursively try with English
        } else {
          setState(() {
            isTtsInitialized = false;
          });
          throw Exception('TTS not available for any language');
        }
      }
    } catch (e) {
      print('TTS initialization failed: $e');
      setState(() {
        isTtsInitialized = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Failed to initialize text-to-speech. Please check your device settings.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> speakInstructions(String text) async {
    if (!isTtsInitialized) {
      await initializeTts(); // Try to reinitialize if not initialized
      if (!isTtsInitialized) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Text-to-speech is not available. Please check your device settings.'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
    }

    try {
      var result = await flutterTts.speak(text);
      if (result != 1) {
        throw Exception('Failed to speak');
      }
    } catch (e) {
      print('Speech failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to speak. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void changeLanguage(String? language) async {
    if (language != null && language != selectedLanguage) {
      setState(() {
        selectedLanguage = language;
        isTtsInitialized = false;
      });

      // Stop any ongoing speech
      await flutterTts.stop();

      // Initialize TTS with new language
      await initializeTts();
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> speakCategoryInstructions(
      String title, List<String> steps) async {
    String fullInstructions =
        "What to do in case of $title? ${steps.join('. ')}";
    await speakInstructions(fullInstructions);
  }

  Future<void> callEmergency() async {
    const emergencyNumber =
        'tel:102'; // Replace with your country's emergency number
    if (await canLaunch(emergencyNumber)) {
      await launch(emergencyNumber);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not call emergency services')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        firstAidCategories[selectedLanguage] ?? firstAidCategories['en']!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ), // Back icon
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeScreen())); // Navigate back
          },
        ),
        title: Text(
          'Offline First Aid Guide',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.emergency,
              color: Colors.white,
            ),
            onPressed: callEmergency, // Emergency SOS button
          ),
          DropdownButton<String>(
            dropdownColor: Colors.teal,
            value: selectedLanguage,
            onChanged: changeLanguage,
            items: languages.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(
                  entry.value,
                  style: TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories.entries.elementAt(index);
          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ExpansionTile(
              title: Text(
                category.key,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              trailing: IconButton(
                icon: Icon(Icons.volume_up),
                onPressed: () =>
                    speakCategoryInstructions(category.key, category.value),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final step in category.value)
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
