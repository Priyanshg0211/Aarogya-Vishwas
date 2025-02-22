import 'package:aarogya_vishwas/Feature/AI%20model/widget/ModelUI.dart';
import 'package:flutter/material.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    // Fade animation starts after 500ms
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    // Navigate to the next screen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()), 
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            flex: 7, 
            child: Center(
              child: AnimatedOpacity(
                duration: const Duration(seconds: 2),
                opacity: _opacity,
                child: Container(
                  height: MediaQuery.sizeOf(context).height * 0.6,
                  width: MediaQuery.sizeOf(context).width * 0.6,
                  child: Image.asset('assets/images/logo.png'),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1, 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, 
              children: [
                Text(
                  'A Personal Medical Assistant',
                  style: TextStyle(
                    fontFamily: 'Product Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
