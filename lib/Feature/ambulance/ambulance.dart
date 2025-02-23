import 'package:aarogya_vishwas/UI/Homescreen/Homescreen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // For making calls and sending messages

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emergency Connect - India',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: EmergencyConnectPage(),
    );
  }
}

class EmergencyConnectPage extends StatelessWidget {
  // Sample data for ambulances in India
  final List<Map<String, String>> ambulances = [
    {
      'name': 'GVK EMRI Ambulance',
      'phone': '108',
      'location': 'Pan-India',
    },
    {
      'name': 'Centralized Ambulance Service',
      'phone': '102',
      'location': 'Pan-India',
    },
    {
      'name': 'Private Ambulance Service - Delhi',
      'phone': '+919876543210',
      'location': 'Delhi, India',
    },
  ];

  // Sample data for hospitals in India
  final List<Map<String, String>> hospitals = [
    {
      'name': 'AIIMS Hospital',
      'phone': '+911126584567',
      'location': 'New Delhi, India',
    },
    {
      'name': 'Apollo Hospitals',
      'phone': '+914442289000',
      'location': 'Chennai, India',
    },
    {
      'name': 'Fortis Hospital',
      'phone': '+914033471717',
      'location': 'Bengaluru, India',
    },
  ];

  // Function to make a phone call
  void _makeCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Function to send a message with a pre-filled emergency text
  void _sendMessage(String phoneNumber) async {
    final message =
        'Emergency! I need immediate assistance. Please send help to my location.';
    final url = 'sms:$phoneNumber?body=$message';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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
        title: Text('Emergency Connect - India'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ambulance Services',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ...ambulances.map((ambulance) => _buildContactCard(
                    name: ambulance['name']!,
                    phone: ambulance['phone']!,
                    location: ambulance['location']!,
                  )).toList(),
              SizedBox(height: 20),
              Text(
                'Nearby Hospitals',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ...hospitals.map((hospital) => _buildContactCard(
                    name: hospital['name']!,
                    phone: hospital['phone']!,
                    location: hospital['location']!,
                  )).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required String name,
    required String phone,
    required String location,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              'Location: $location',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _makeCall(phone),
                  child: Text('Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _sendMessage(phone),
                  child: Text('Message'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}