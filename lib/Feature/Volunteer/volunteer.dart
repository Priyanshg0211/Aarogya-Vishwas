import 'package:aarogya_vishwas/UI/Homescreen/Homescreen.dart';
import 'package:aarogya_vishwas/localization/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VolunteerSupport extends StatelessWidget {
  // Pre-added demo data for volunteers with translation keys
  final List<Map<String, dynamic>> volunteers = [
    {
      "name": "volunteerName1",
      "phone": "+919876543210",
      "skills": "volunteerSkills1",
      "village": "volunteerVillage1",
    },
    {
      "name": "volunteerName2",
      "phone": "+919876543211",
      "skills": "volunteerSkills2",
      "village": "volunteerVillage2",
    },
    {
      "name": "volunteerName3",
      "phone": "+919876543212",
      "skills": "volunteerSkills3",
      "village": "volunteerVillage3",
    },
    {
      "name": "volunteerName4",
      "phone": "+919876543213",
      "skills": "volunteerSkills4",
      "village": "volunteerVillage4",
    },
    {
      "name": "volunteerName5",
      "phone": "+919876543214",
      "skills": "volunteerSkills5",
      "village": "volunteerVillage5",
    },
    {
      "name": "volunteerName6",
      "phone": "+919876543215",
      "skills": "volunteerSkills6",
      "village": "volunteerVillage6",
    },
    {
      "name": "volunteerName7",
      "phone": "+919876543216",
      "skills": "volunteerSkills7",
      "village": "volunteerVillage7",
    },
    {
      "name": "volunteerName8",
      "phone": "+919876543217",
      "skills": "volunteerSkills8",
      "village": "volunteerVillage8",
    },
    {
      "name": "volunteerName9",
      "phone": "+919876543218",
      "skills": "volunteerSkills9",
      "village": "volunteerVillage9",
    },
    {
      "name": "volunteerName10",
      "phone": "+919876543219",
      "skills": "volunteerSkills10",
      "village": "volunteerVillage10",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomeScreen()));
          },
        ),
        title: Text(AppLocalizations.of(context)!.translate('volunteerSupport2')),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Text(
              AppLocalizations.of(context)!.translate('volunteerSupportDesc'),
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue.shade900,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: volunteers.length,
              itemBuilder: (context, index) {
                final volunteer = volunteers[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(AppLocalizations.of(context)!
                          .translate(volunteer['name'])
                          .substring(0, 1)),
                    ),
                    title: Text(
                        AppLocalizations.of(context)!.translate(volunteer['name'])),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "${AppLocalizations.of(context)!.translate('skills')}: ${AppLocalizations.of(context)!.translate(volunteer['skills'])}"),
                        Text(
                            "${AppLocalizations.of(context)!.translate('location')}: ${AppLocalizations.of(context)!.translate(volunteer['village'])}"),
                      ],
                    ),
                    trailing: ElevatedButton.icon(
                      icon: Icon(Icons.call),
                      label: Text(
                          AppLocalizations.of(context)!.translate('callNow')),
                      onPressed: () => _callVolunteer(context, volunteer['phone']),
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _callVolunteer(BuildContext context, String phone) async {
    final url = 'tel:$phone';
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context)!.translate('callNotSupported')),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.translate('errorMakingCall')),
        ),
      );
    }
  }
}