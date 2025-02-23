import 'package:aarogya_vishwas/UI/Homescreen/Homescreen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../localization/app_localization.dart';

class GovernmentSchemesPage extends StatefulWidget {
  @override
  _GovernmentSchemesPageState createState() => _GovernmentSchemesPageState();
}

class _GovernmentSchemesPageState extends State<GovernmentSchemesPage> {
  final List<Map<String, dynamic>> schemes = [
    {
      'title': 'ayushmanBharat',
      'description': 'ayushmanBharatDesc',
      'eligibility': 'bplFamilies',
      'image':
          'https://www.india.gov.in/sites/upload_files/npi/files/ayushman_bharat.jpg',
      'link': 'https://www.pmjay.gov.in/',
      'category': 'healthCategory',
    },
    {
      'title': 'nationalHealth',
      'description': 'nationalHealthDesc',
      'eligibility': 'allCitizens',
      'image': 'https://www.nhm.gov.in/images/nhm_logo.png',
      'link': 'https://nhm.gov.in/',
      'category': 'healthCategory',
    },
    {
      'title': 'matruVandana',
      'description': 'matruVandanaDesc',
      'eligibility': 'pregnantWomen',
      'image': 'https://www.pmmvy.gov.in/images/logo.png',
      'link': 'https://pmmvy.gov.in/',
      'category': 'womenCategory',
    },
    {
      'title': 'jananiShishu',
      'description': 'jananiShishuDesc',
      'eligibility': 'pregnantAndNewborn',
      'image': 'https://www.nhp.gov.in/sites/default/files/jssk_logo.png',
      'link': 'https://www.nhp.gov.in/janani-shishu-suraksha-karyakram-jssk_pg',
      'category': 'womenCategory',
    },
    {
      'title': 'balSwasthya',
      'description': 'balSwasthyaDesc',
      'eligibility': 'children018',
      'image': 'https://www.nhm.gov.in/images/rbsk_logo.png',
      'link': 'https://nhm.gov.in/rbsk/',
      'category': 'childrenCategory',
    },
    {
      'title': 'missionIndradhanush',
      'description': 'missionIndradhanushDesc',
      'eligibility': 'childrenAndPregnant',
      'image':
          'https://www.nhp.gov.in/sites/default/files/mission_indradhanush_logo.png',
      'link': 'https://www.nhp.gov.in/mission-indradhanush_pg',
      'category': 'childrenCategory',
    },
    {
      'title': 'surakshitMatritva',
      'description': 'surakshitMatritvaDesc',
      'eligibility': 'pregnantWomenOnly',
      'image': 'https://www.nhp.gov.in/sites/default/files/pmsma_logo.png',
      'link': 'https://www.nhp.gov.in/pmsma_pg',
      'category': 'womenCategory',
    },
    {
      'title': 'nutritionMission',
      'description': 'nutritionMissionDesc',
      'eligibility': 'nutritionBeneficiaries',
      'image':
          'https://www.nhp.gov.in/sites/default/files/poshan_abhiyaan_logo.png',
      'link': 'https://www.nhp.gov.in/poshan-abhiyaan_pg',
      'category': 'childrenCategory',
    },
    {
      'title': 'pmjay',
      'description': 'pmjayDesc',
      'eligibility': 'bplFamilies',
      'image': 'assets/images/government-of-india.jpg',
      'link': 'https://www.pmjay.gov.in/',
      'category': 'healthCategory',
    },
  ];

  String searchQuery = '';
  String selectedCategory = 'allCategories';

  List<Map<String, dynamic>> get filteredSchemes {
    List<Map<String, dynamic>> filtered = schemes
        .where((scheme) =>
            AppLocalizations.of(context)!.translate(scheme['title'])
                .toLowerCase()
                .contains(searchQuery.toLowerCase()))
        .toList();

    if (selectedCategory != 'allCategories') {
      filtered = filtered
          .where((scheme) => scheme['category'] == selectedCategory)
          .toList();
    }

    return filtered;
  }

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
        title: Text(
          AppLocalizations.of(context)!.translate('governmentSchemes'),
          style: TextStyle(
            fontFamily: 'Product Sans Medium',
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showSearch(
                context: context,
                delegate: SchemeSearchDelegate(schemes, context),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: DropdownButton<String>(
                value: selectedCategory,
                items: [
                  'allCategories',
                  'healthCategory',
                  'womenCategory',
                  'childrenCategory',
                ].map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(
                      AppLocalizations.of(context)!.translate(category),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue!;
                  });
                },
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue.shade800,
                ),
                dropdownColor: Colors.white,
                icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade800),
                underline: Container(
                  height: 2,
                  color: Colors.blue.shade800,
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await Future.delayed(Duration(seconds: 2));
                  setState(() {});
                },
                child: ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: filteredSchemes.length,
                  itemBuilder: (context, index) {
                    final scheme = filteredSchemes[index];
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            scheme['image'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/government-of-india.jpg',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                        title: Text(
                          AppLocalizations.of(context)!.translate(scheme['title']),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!
                                  .translate(scheme['description']),
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${AppLocalizations.of(context)!.translate("eligibilityLabel")}: ${AppLocalizations.of(context)!.translate(scheme["eligibility"])}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.arrow_forward,
                              color: Colors.blue.shade800),
                          onPressed: () async {
                            if (await canLaunch(scheme['link'])) {
                              await launch(scheme['link']);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(AppLocalizations.of(context)!
                                        .translate('couldNotOpenLink'))),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SchemeSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> schemes;
  final BuildContext context;

  SchemeSearchDelegate(this.schemes, this.context);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, query);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = schemes
        .where((scheme) =>
            AppLocalizations.of(context)!
                .translate(scheme['title'])
                .toLowerCase()
                .contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final scheme = results[index];
        return ListTile(
          title: Text(AppLocalizations.of(context)!.translate(scheme['title'])),
          onTap: () {
            close(context, scheme['title']);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = schemes
        .where((scheme) =>
            AppLocalizations.of(context)!
                .translate(scheme['title'])
                .toLowerCase()
                .contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final scheme = suggestions[index];
        return ListTile(
          title: Text(AppLocalizations.of(context)!.translate(scheme['title'])),
          onTap: () {
            query = AppLocalizations.of(context)!.translate(scheme['title']);
          },
        );
      },
    );
  }
}