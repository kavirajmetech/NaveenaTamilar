import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kynnovate/globals.dart';
import 'package:kynnovate/pages/authentication/splashscreen.dart';

class CollectDetails extends StatefulWidget {
  @override
  _CollectDetailsState createState() => _CollectDetailsState();
}

class _CollectDetailsState extends State<CollectDetails> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  String? _selectedState;
  String? _selectedDistrict;

  final List<String> _states = ['State 1', 'State 2', 'State 3'];
  final Map<String, List<String>> _districts = {
    'State 1': ['District 1A', 'District 1B'],
    'State 2': ['District 2A', 'District 2B'],
    'State 3': ['District 3A', 'District 3B'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Collect Details')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedState,
                onChanged: (newValue) {
                  setState(() {
                    _selectedState = newValue;
                    _selectedDistrict = null;
                  });
                },
                items: _states.map((state) {
                  return DropdownMenuItem<String>(
                    value: state,
                    child: Text(state),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'State',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDistrict,
                onChanged: (newValue) {
                  setState(() {
                    _selectedDistrict = newValue;
                  });
                },
                items: _selectedState != null
                    ? _districts[_selectedState]!.map((district) {
                        return DropdownMenuItem<String>(
                          value: district,
                          child: Text(district),
                        );
                      }).toList()
                    : [],
                decoration: InputDecoration(
                  labelText: 'District',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('User')
                      .doc(globalUserId)
                      .set({
                    'name': globalUsername,
                    'email': globalEmail ?? "",
                    'state': [_selectedState],
                    'district': [_selectedDistrict],
                    'likedcontent': [],
                    'likedauthors': [],
                    'likednewschannels': [],
                    'profileImageUrl': "",
                    'comments': [],
                    'subscriptions': []
                  });

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SplashScreen()),
                  );
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
