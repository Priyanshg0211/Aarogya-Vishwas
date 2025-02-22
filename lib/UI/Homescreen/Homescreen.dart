import 'package:aarogya_vishwas/Feature/AI%20model/widget/ModelUI.dart';
import 'package:aarogya_vishwas/UI/Profile/Profilepage.dart';
import 'package:aarogya_vishwas/localization/app_localization.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.translate('appTitle'),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          // Profile Icon to change language
          IconButton(
            icon: Icon(Icons.person, color: Colors.white), // Profile icon
            onPressed: () {
              // Navigate to the LanguageSelectionScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Profilepage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFeatureCard(
              context: context,
              icon: Icons.summarize,
              title: 'reportSummarization',
              description: 'reportDescription',
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => HomePage()));
              },
            ),
            SizedBox(height: 16.0),
            _buildFeatureCard(
              context: context,
              icon: Icons.medical_services,
              title: 'medicalRecordStorage',
              description: 'medicalRecordDescription',
              onTap: () {
                // Navigate to the medical record storage screen
              },
            ),
            SizedBox(height: 16.0),
            _buildFeatureCard(
              context: context,
              icon: Icons.assignment_turned_in,
              title: 'schemeChecker',
              description: 'schemeDescription',
              onTap: () {
                // Navigate to the eligibility checker screen
              },
            ),
            SizedBox(height: 16.0),
            _buildFeatureCard(
              context: context,
              icon: Icons.local_hospital,
              title: 'hospitalLocator',
              description: 'hospitalDescription',
              onTap: () {
                // Navigate to the hospital locator screen
              },
            ),
            SizedBox(height: 16.0),
            _buildFeatureCard(
              context: context,
              icon: Icons.medical_information,
              title: 'firstAidGuide',
              description: 'firstAidDescription',
              onTap: () {
                // Navigate to the first aid guide screen
              },
            ),
            SizedBox(height: 16.0),
            _buildFeatureCard(
              context: context,
              icon: Icons.people,
              title: 'volunteerSupport',
              description: 'volunteerDescription',
              onTap: () {
                // Navigate to the volunteer support screen
              },
            ),
            SizedBox(height: 16.0),
            _buildFeatureCard(
              context: context,
              icon: Icons.location_on,
              title: 'localVolunteer',
              description: 'localVolunteerDescription',
              onTap: () {
                // Navigate to the local volunteer connection screen
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 40.0, color: Colors.teal),
              SizedBox(height: 8.0),
              Text(
                AppLocalizations.of(context)!.translate(title),
                style: TextStyle(
                  fontFamily: 'Product Sans Medium',
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                AppLocalizations.of(context)!.translate(description),
                style: TextStyle(
                  fontFamily: 'Product Sans Medium',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
