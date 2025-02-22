import 'package:aarogya_vishwas/Homescreen/Homescreen.dart';
import 'package:aarogya_vishwas/localization/app_localization.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentPage = 0;
  final PageController _pageController = PageController();
  Timer? _timer;

  // Define the list of onboarding content without localization
  final List<OnboardingContent> contents = [
    OnboardingContent(
      image: 'assets/images/img3.jpg',
      titleKey: 'title1', // Use keys instead of localized strings
    ),
    OnboardingContent(
      image: 'assets/images/img2.jpg',
      titleKey: 'title2',
    ),
    OnboardingContent(
      image: 'assets/images/img1.jpg',
      titleKey: 'title3',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Start auto-scrolling with longer interval
    _timer = Timer.periodic(Duration(seconds: 2), (Timer timer) {
      if (currentPage < contents.length - 1) {
        currentPage++;
      } else {
        currentPage = 0;
      }

      _pageController.animateToPage(
        currentPage,
        duration: Duration(milliseconds: 800), // Increased duration
        curve: Curves.easeInOutCubic, // Smoother curve
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Localize the titles inside the build method
    final localizedContents = contents.map((content) {
      return OnboardingContent(
        image: content.image,
        title: AppLocalizations.of(context)!.translate(content.titleKey), titleKey: '', // Localize here
      );
    }).toList();

    // Localized texts
    final getStartedText = AppLocalizations.of(context)!.translate('get_started');
    final termsText = AppLocalizations.of(context)!.translate('terms_and_conditions');
    final privacyPolicyText = AppLocalizations.of(context)!.translate('privacy_policy');
    final byContinuingText = AppLocalizations.of(context)!.translate('by_continuing');

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              itemCount: localizedContents.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Container(
                      height: MediaQuery.sizeOf(context).height * 0.6,
                      width: MediaQuery.sizeOf(context).width,
                      child: Stack(
                        fit: StackFit.expand, // Make stack fill container
                        children: [
                          // Preload adjacent images
                          if (index > 0)
                            Opacity(
                              opacity: 0.0,
                              child: Image.asset(
                                localizedContents[index - 1].image,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          if (index < localizedContents.length - 1)
                            Opacity(
                              opacity: 0.0,
                              child: Image.asset(
                                localizedContents[index + 1].image,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          // Current image with fade transition
                          AnimatedOpacity(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            opacity: 1.0,
                            child: Image.asset(
                              localizedContents[index].image,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              gaplessPlayback: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    AnimatedOpacity(
                      duration: Duration(milliseconds: 500), // Increased duration
                      opacity: currentPage == index ? 1.0 : 0.0,
                      curve: Curves.easeInOut,
                      child: Text(
                        localizedContents[index].title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Product Sans',
                          fontSize: 21,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                localizedContents.length,
                (index) => buildDot(index),
              ),
            ),
          ),
          Container(
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
              onPressed: () {
                // Directly navigate to login screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    getStartedText, // Localized "Get Started" text
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
          SizedBox(height: 35),
          Padding(
            padding: EdgeInsets.only(bottom: 30),
            child: Text.rich(
              TextSpan(
                text: '$byContinuingText\n', // Localized "By continuing" text
                style: TextStyle(
                  fontFamily: 'Product Sans Medium',
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text: termsText, // Localized "T&Cs" text
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.teal,
                    ),
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: privacyPolicyText, // Localized "Privacy Policy" text
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  AnimatedContainer buildDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500), // Increased duration
      curve: Curves.easeInOutCubic, // Smoother curve
      margin: EdgeInsets.only(right: 5),
      height: 8,
      width: currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: currentPage == index
            ? Colors.teal
            : Colors.teal.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class OnboardingContent {
  final String image;
  final String titleKey; // Use a key for localization
  String title; // Localized title

  OnboardingContent({
    required this.image,
    required this.titleKey,
    this.title = '', // Default value, will be overridden
  });
}