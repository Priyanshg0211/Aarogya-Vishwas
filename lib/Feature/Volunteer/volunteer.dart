import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VolunteerSupport extends StatelessWidget {
  // Pre-added demo data for volunteers (Indian context)
  final List<Map<String, dynamic>> volunteers = [
    {
      "name": "Ramesh Kumar",
      "phone": "+919876543210",
      "skills": "First Aid, Basic Medicine",
      "village": "Village A, Bihar",
    },
    {
      "name": "Sunita Devi",
      "phone": "+919876543211",
      "skills": "Maternal Health, Childcare",
      "village": "Village B, Uttar Pradesh",
    },
    {
      "name": "Arun Singh",
      "phone": "+919876543212",
      "skills": "Emergency Response, CPR",
      "village": "Village C, Rajasthan",
    },
    {
      "name": "Priya Sharma",
      "phone": "+919876543213",
      "skills": "Community Health, Nutrition",
      "village": "Village D, Maharashtra",
    },
    {
      "name": "Vijay Patel",
      "phone": "+919876543214",
      "skills": "First Aid, Disaster Management",
      "village": "Village E, Gujarat",
    },
    {
      "name": "Anjali Gupta",
      "phone": "+919876543215",
      "skills": "Health Education, Vaccination",
      "village": "Village F, Madhya Pradesh",
    },
    {
      "name": "Rajesh Yadav",
      "phone": "+919876543216",
      "skills": "First Aid, Wound Care",
      "village": "Village G, Haryana",
    },
    {
      "name": "Kavita Singh",
      "phone": "+919876543217",
      "skills": "Elderly Care, Chronic Disease Management",
      "village": "Village H, Punjab",
    },
    {
      "name": "Suresh Mehta",
      "phone": "+919876543218",
      "skills": "First Aid, Emergency Transport",
      "village": "Village I, Karnataka",
    },
    {
      "name": "Meena Kumari",
      "phone": "+919876543219",
      "skills": "Women's Health, Family Planning",
      "village": "Village J, Tamil Nadu",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Volunteer Support")),
      body: ListView.builder(
        itemCount: volunteers.length,
        itemBuilder: (context, index) {
          final volunteer = volunteers[index];
          return ListTile(
            title: Text(volunteer['name']),
            subtitle: Text("Skills: ${volunteer['skills']}"),
            trailing: IconButton(
              icon: Icon(Icons.call),
              onPressed: () => _callVolunteer(volunteer['phone']),
            ),
          );
        },
      ),
    );
  }

  void _callVolunteer(String phone) async {
    final url = 'tel:$phone';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}