import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Aarogya Vishwas',
          style: TextStyle(fontFamily: 'Product Sans Medium', fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal, // A calming and professional color
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFeatureCard(
              icon: Icons.summarize,
              title: 'GenAI Powered Report Summarization',
              description:
                  'Upload medical reports and get an easy-to-understand summary in your preferred language.',
              onTap: () {},
            ),
            SizedBox(height: 16.0),
            _buildFeatureCard(
              icon: Icons.medical_services,
              title: 'Medical Record Storage',
              description:
                  'Securely save and access your medical reports anytime.',
              onTap: () {
                // Navigate to the medical record storage screen
              },
            ),
            SizedBox(height: 16.0),
            _buildFeatureCard(
              icon: Icons.assignment_turned_in,
              title: 'Government Scheme Eligibility Checker',
              description:
                  'Check if you qualify for healthcare schemes provided by the government.',
              onTap: () {
                // Navigate to the eligibility checker screen
              },
            ),
            SizedBox(height: 16.0),
            _buildFeatureCard(
              icon: Icons.local_hospital,
              title: 'Hospital & Ambulance Locator',
              description:
                  'Find nearby hospitals and emergency services with direct call functionality.',
              onTap: () {
                // Navigate to the hospital locator screen
              },
            ),
            SizedBox(height: 16.0),
            _buildFeatureCard(
              icon: Icons.medical_information,
              title: 'Offline First Aid Guide',
              description:
                  'Access preloaded life-saving instructions for emergencies like burns, fractures, heart attacks, and more.',
              onTap: () {
                // Navigate to the first aid guide screen
              },
            ),
            SizedBox(height: 16.0),
            _buildFeatureCard(
              icon: Icons.people,
              title: 'Volunteer Support System',
              description:
                  'Seek help from trained community health volunteers.',
              onTap: () {
                // Navigate to the volunteer support screen
              },
            ),
            SizedBox(height: 16.0),
            _buildFeatureCard(
              icon: Icons.location_on,
              title: 'Local Volunteer Connection',
              description:
                  'Locate and contact healthcare volunteers from your village or nearby areas for immediate assistance.',
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
                title,
                style: TextStyle(
                  fontFamily: 'Product Sans Medium',
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                description,
                style: TextStyle(
                    fontFamily: 'Product Sans Medium',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
