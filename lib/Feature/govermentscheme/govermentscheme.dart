import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GovernmentSchemesPage extends StatefulWidget {
  @override
  _GovernmentSchemesPageState createState() => _GovernmentSchemesPageState();
}

class _GovernmentSchemesPageState extends State<GovernmentSchemesPage> {
  final List<Map<String, dynamic>> schemes = [
    {
      'title': 'Ayushman Bharat Yojana',
      'description':
          'Provides health coverage of up to ₹5 lakh per family per year for secondary and tertiary care hospitalization.',
      'eligibility': 'Families living below the poverty line.',
      'image':
          'https://www.india.gov.in/sites/upload_files/npi/files/ayushman_bharat.jpg',
      'link': 'https://www.pmjay.gov.in/',
      'category': 'Health',
    },
    {
      'title': 'National Health Mission',
      'description':
          'Aims to provide accessible, affordable, and quality healthcare to rural and urban populations.',
      'eligibility': 'All citizens, especially women and children.',
      'image': 'https://www.nhm.gov.in/images/nhm_logo.png',
      'link': 'https://nhm.gov.in/',
      'category': 'Health',
    },
    {
      'title': 'Pradhan Mantri Matru Vandana Yojana',
      'description':
          'Provides financial assistance to pregnant and lactating women for their first living child.',
      'eligibility': 'Pregnant women and lactating mothers.',
      'image': 'https://www.pmmvy.gov.in/images/logo.png',
      'link': 'https://pmmvy.gov.in/',
      'category': 'Women',
    },
    {
      'title': 'Janani Shishu Suraksha Karyakram',
      'description':
          'Ensures free and cashless delivery, C-section, and postnatal care for pregnant women and sick newborns.',
      'eligibility': 'All pregnant women and sick newborns.',
      'image': 'https://www.nhp.gov.in/sites/default/files/jssk_logo.png',
      'link': 'https://www.nhp.gov.in/janani-shishu-suraksha-karyakram-jssk_pg',
      'category': 'Women',
    },
    {
      'title': 'Rashtriya Bal Swasthya Karyakram',
      'description':
          'Provides comprehensive healthcare services for children, including early detection of diseases.',
      'eligibility': 'Children aged 0-18 years.',
      'image': 'https://www.nhm.gov.in/images/rbsk_logo.png',
      'link': 'https://nhm.gov.in/rbsk/',
      'category': 'Children',
    },
    {
      'title': 'Mission Indradhanush',
      'description':
          'Aims to immunize children and pregnant women against vaccine-preventable diseases.',
      'eligibility': 'Children and pregnant women.',
      'image': 'https://www.nhp.gov.in/sites/default/files/mission_indradhanush_logo.png',
      'link': 'https://www.nhp.gov.in/mission-indradhanush_pg',
      'category': 'Children',
    },
    {
      'title': 'Pradhan Mantri Surakshit Matritva Abhiyan',
      'description':
          'Provides free antenatal services to pregnant women on the 9th of every month.',
      'eligibility': 'Pregnant women.',
      'image': 'https://www.nhp.gov.in/sites/default/files/pmsma_logo.png',
      'link': 'https://www.nhp.gov.in/pmsma_pg',
      'category': 'Women',
    },
    {
      'title': 'National Nutrition Mission (Poshan Abhiyaan)',
      'description':
          'Aims to improve nutritional outcomes for children, pregnant women, and lactating mothers.',
      'eligibility': 'Children, pregnant women, and lactating mothers.',
      'image': 'https://www.nhp.gov.in/sites/default/files/poshan_abhiyaan_logo.png',
      'link': 'https://www.nhp.gov.in/poshan-abhiyaan_pg',
      'category': 'Children',
    },
    {
      'title': 'Pradhan Mantri Jan Arogya Yojana (PM-JAY)',
      'description':
          'Provides health insurance coverage of up to ₹5 lakh per family per year for secondary and tertiary care hospitalization.',
      'eligibility': 'Families living below the poverty line.',
      'image': 'https://www.pmjay.gov.in/sites/default/files/pmjay_logo.png',
      'link': 'https://www.pmjay.gov.in/',
      'category': 'Health',
    },
  ];

  String searchQuery = '';
  String selectedCategory = 'All';

  List<Map<String, dynamic>> get filteredSchemes {
    List<Map<String, dynamic>> filtered = schemes
        .where((scheme) =>
            scheme['title'].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    if (selectedCategory != 'All') {
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
        title: Text('Government Health Schemes'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: SchemeSearchDelegate(schemes),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: DropdownButton<String>(
              value: selectedCategory,
              items: [
                'All',
                'Health',
                'Women',
                'Children',
              ].map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue!;
                });
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                // Simulate fetching new data
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
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CachedNetworkImage(
                        imageUrl: scheme['image'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                      title: Text(scheme['title']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(scheme['description']),
                          SizedBox(height: 4),
                          Text(
                            'Eligibility: ${scheme['eligibility']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.arrow_forward),
                        onPressed: () async {
                          if (await canLaunch(scheme['link'])) {
                            await launch(scheme['link']);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Could not open link')),
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
    );
  }
}

class SchemeSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> schemes;

  SchemeSearchDelegate(this.schemes);

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
        close(context, query); // Pass the current query as the result
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = schemes
        .where((scheme) =>
            scheme['title'].toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final scheme = results[index];
        return ListTile(
          title: Text(scheme['title']),
          onTap: () {
            close(context, scheme['title']); // Pass the selected scheme title
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = schemes
        .where((scheme) =>
            scheme['title'].toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final scheme = suggestions[index];
        return ListTile(
          title: Text(scheme['title']),
          onTap: () {
            query = scheme['title'];
          },
        );
      },
    );
  }
}