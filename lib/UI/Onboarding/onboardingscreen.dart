import 'package:aarogya_vishwas/UI/authscreen/authscreen.dart';
import 'package:aarogya_vishwas/localization/app_localization.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class OnboardingScreen extends StatefulWidget {
  final Locale locale;
  final Function(Locale) onLocaleChange;

  const OnboardingScreen({
    super.key,
    required this.locale,
    required this.onLocaleChange,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentPage = 0;
  final PageController _pageController = PageController();
  Timer? _timer;

  final List<OnboardingContent> contents = [
    OnboardingContent(
      image: 'assets/images/img3.jpg',
      titleKey: 'title1',
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
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (currentPage < contents.length - 1) {
        currentPage++;
      } else {
        currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
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
    final localizedContents = contents.map((content) {
      return OnboardingContent(
        image: content.image,
        title: AppLocalizations.of(context)!.translate(content.titleKey),
        titleKey: content.titleKey,
      );
    }).toList();

    final getStartedText = AppLocalizations.of(context)!.translate('get_started');
    final termsText = AppLocalizations.of(context)!.translate('terms_and_conditions');
    final privacyPolicyText = AppLocalizations.of(context)!.translate('privacy_policy');
    final byContinuingText = AppLocalizations.of(context)!.translate('by_continuing');

    return Scaffold(
      body: SafeArea(
        child: Column(
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
                  return buildOnboardingPage(localizedContents[index], index);
                },
              ),
            ),
            buildPageIndicator(localizedContents.length),
            buildGetStartedButton(getStartedText),
            buildTermsAndConditions(byContinuingText, termsText, privacyPolicyText),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget buildOnboardingPage(OnboardingContent content, int index) {
    return Column(
      children: [
        // Image at the top
        Container(
          height: MediaQuery.of(context).size.height * 0.6,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Preload adjacent images
              if (index > 0)
                Opacity(
                  opacity: 0.0,
                  child: Image.asset(
                    contents[index - 1].image,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              if (index < contents.length - 1)
                Opacity(
                  opacity: 0.0,
                  child: Image.asset(
                    contents[index + 1].image,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              // Current image with fade transition
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: 1.0,
                child: Image.asset(
                  content.image,
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30), // Add some spacing between the image and text
        // Title text below the image
        AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: currentPage == index ? 1.0 : 0.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              content.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Product Sans',
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPageIndicator(int length) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          length,
          (index) => buildDot(index),
        ),
      ),
    );
  }

  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      margin: const EdgeInsets.only(right: 5),
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

  Widget buildGetStartedButton(String getStartedText) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AuthScreen(),
            ),
          );
        },
        child: Text(
          getStartedText,
          style: const TextStyle(
            fontFamily: 'Product Sans',
            fontSize: 19,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget buildTermsAndConditions(
    String byContinuingText,
    String termsText,
    String privacyPolicyText,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Text.rich(
        TextSpan(
          text: '$byContinuingText\n',
          style: const TextStyle(
            fontFamily: 'Product Sans Medium',
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
          children: [
            TextSpan(
              text: termsText,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.teal,
              ),
            ),
            const TextSpan(text: ' and '),
            TextSpan(
              text: privacyPolicyText,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.teal,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class OnboardingContent {
  final String image;
  final String titleKey;
  final String title;

  OnboardingContent({
    required this.image,
    required this.titleKey,
    this.title = '',
  });
}