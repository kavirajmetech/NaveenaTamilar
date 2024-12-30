import 'package:flutter/material.dart';

class CollectDetails extends StatefulWidget {
  @override
  _CollectDetailsState createState() => _CollectDetailsState();
}

class _CollectDetailsState extends State<CollectDetails> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  String? _selectedState;
  String? _selectedDistrict;

  // Example lists for state and district
  final List<String> _states = [
    'State 1',
    'State 2',
    'State 3'
  ]; // Replace with actual data
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
              // First Name Field
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // Last Name Field
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // State Dropdown
              DropdownButtonFormField<String>(
                value: _selectedState,
                onChanged: (newValue) {
                  setState(() {
                    _selectedState = newValue;
                    _selectedDistrict =
                        null; // Reset district when state changes
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

              // District Dropdown
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

              // Submit Button
              ElevatedButton(
                onPressed: () {
                  // Collect all the details (e.g., from controllers and dropdowns)
                  final firstName = _firstNameController.text;
                  final lastName = _lastNameController.text;
                  final state = _selectedState;
                  final district = _selectedDistrict;

                  // Handle form submission
                  print('First Name: $firstName');
                  print('Last Name: $lastName');
                  print('State: $state');
                  print('District: $district');

                  // Navigate to the next page or perform other actions
                  // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NextPage()));
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
