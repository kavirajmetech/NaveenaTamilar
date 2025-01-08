import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kynnovate/globals.dart';

class EventPage extends StatefulWidget {
  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  final List<Map<String, String>> _events = [];
  int index = 0;
  List<String> images = [
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSIsZe6PUzjXtzYhjth8hqBwnvupdUtqEeu3w&s",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQC5MO4cPTMP3Ezp_zZxP6zcVfC5nbtCPDQQw&s",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTDMhwfsCosZjaDi0MXW_9i5zJZEPcGOy8Iwg&s",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRzGPBoxnTAMZSHnr8rVc6C1XdQ57boULlbrg&s",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT6bPlmx9sEzttZCQ_C9LGLxv0XU_RF7qRZHw&s",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQWcrnBeaURxN8n03SKoCwwDTAoTahBel0Q0w&s",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTPojxJ4l3rafdxqdDKdDR-guUM4gfY-1psKQ&s",
  ];

  Future<void> _fetchEvents() async {
    print('entered');
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Events').get();

      final List<Map<String, String>> fetchedEvents =
          querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data.map((key, value) => MapEntry(key, value.toString()));
      }).toList();

      setState(() {
        _events.clear();
        _events.addAll(fetchedEvents);
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch events: $error')),
      );
    }
  }

  void _addEvent(Map<String, String> eventDetails) async {
    try {
      print('entered');
      print(eventDetails);
      DocumentReference eventDocRef = await FirebaseFirestore.instance
          .collection('Events')
          .add(eventDetails);

      String eventDocId = eventDocRef.id;
      print(eventDocId);
      await FirebaseFirestore.instance
          .collection('User')
          .doc(globalUserId)
          .update({
        "events": FieldValue.arrayUnion([eventDocId])
      });
      setState(() {
        _events.add(eventDetails);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event added successfully!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add event: $error')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events for you'),
        backgroundColor: Colors.blue,
      ),
      body: _events.isEmpty
          ? Center(
              child: Text(
                'No events available. Tap + to add a new event!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: _events.length,
              itemBuilder: (context, index) {
                return _buildEventTile(_events[index]);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventPanel(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showAddEventPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddEvent(
          onEventAdded: (eventDetails) => _addEvent(eventDetails),
        );
      },
    );
  }

  Widget _buildEventTile(Map<String, String> event) {
    index = (index + 1) % images.length;
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 5,
      child: ListTile(
        contentPadding: EdgeInsets.all(10),
        leading: index % 2 == 0
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  images[index],
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.image, size: 60, color: Colors.grey);
                  },
                ),
              )
            : null,
        trailing: index % 2 != 0
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  images[index],
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.image, size: 60, color: Colors.grey);
                  },
                ),
              )
            : null,
        title: Text(
          event['title']!,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event['description']!, style: TextStyle(fontSize: 14)),
            SizedBox(height: 4),
            Text(
              'Date: ${event['date']}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        onTap: () {
          index = (index + 1) % images.length;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EventDetails(event: event, image: images[index]),
            ),
          );
        },
      ),
    );
  }
}

class EventDetails extends StatelessWidget {
  final Map<String, String> event;
  final String image;

  EventDetails({required this.event, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          event['title']!,
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: Image.network(
                image,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event title
                  Text(
                    event['title']!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    event['description']!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Event details
                  _buildDetailRow(Icons.calendar_today, 'Date', event['date']!),
                  _buildDetailRow(
                      Icons.description, 'Summary', event['summary'] ?? 'N/A'),
                  _buildDetailRow(
                      Icons.phone, 'Contact', event['contact'] ?? 'N/A'),
                  _buildDetailRow(
                      Icons.email, 'Email', event['email'] ?? 'N/A'),
                  _buildDetailRow(
                      Icons.location_on, 'Address', event['address'] ?? 'N/A'),
                  _buildDetailRow(Icons.person, 'Coordinator',
                      event['coordinator'] ?? 'N/A'),
                  _buildDetailRow(Icons.business, 'Organization',
                      event['organization'] ?? 'N/A'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.blueGrey),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AddEvent extends StatefulWidget {
  final Function(Map<String, String>) onEventAdded;

  AddEvent({required this.onEventAdded});

  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _registrationlinkcontroller =
      TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _coordinatorController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();
  DateTime? _selectedDate;
  DateTime? _registrationStartDate;
  DateTime? _registrationEndDate;
  String _selectedRecurrence = 'None';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedDate = DateTime.now();
    _registrationStartDate = DateTime.now();
    _registrationEndDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(_organizationController, "Organization Name"),
              _buildTextField(_titleController, 'Event Title'),
              _buildTextField(_descriptionController, 'Event Description'),
              _buildTextField(_addressController, 'Venue'),
              _buildTextField(_registrationlinkcontroller,
                  'Registration Form Link if Required'),
              _buildTextField(_coordinatorController, 'Coordinator Name'),
              _buildTextField(_emailController, 'Email Address',
                  keyboardType: TextInputType.emailAddress),
              _buildTextField(_contactController, 'Contact Number',
                  keyboardType: TextInputType.phone),
              _buildRecurrenceDropdown(),
              Row(
                children: [
                  const Text("Event Date"),
                  _buildDatePickerButton(_selectedDate!),
                ],
              ),
              Row(
                children: [
                  const Text("Registration Start Date"),
                  _buildDatePickerButton(_registrationStartDate!),
                ],
              ),
              Row(
                children: [
                  const Text("Registration End Date"),
                  _buildDatePickerButton(_registrationEndDate!),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleAddEvent,
                child: Text('Add Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerButton(DateTime object) {
    return TextButton(
      onPressed: _selectDate,
      child: Text(_selectedDate == null
          ? 'Select Date'
          : 'Date: ${DateFormat.yMd().format(object!)}'),
    );
  }

  Widget _buildRecurrenceDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _selectedRecurrence,
        items: <String>['None', 'Daily', 'Weekly', 'Monthly']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedRecurrence = value ?? 'None';
          });
        },
        decoration: InputDecoration(
          labelText: 'Recurrence',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleAddEvent() {
    print('got the data');
    if (_formIsValid()) {
      print("heheheggg");
      widget.onEventAdded({
        'Organization': _organizationController.text,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'registrationlink': _registrationlinkcontroller.text,
        'contact': _contactController.text,
        'email': _emailController.text,
        'address': _addressController.text,
        'coordinator': _coordinatorController.text,
        'date': DateFormat.yMd().format(_selectedDate!),
        'recurrence': _selectedRecurrence,
        'regstartdate': DateFormat.yMd().format(_registrationStartDate!),
        'regenddate': DateFormat.yMd().format(_registrationEndDate!),
      });
      Navigator.of(context).pop();
    }
  }

  bool _formIsValid() {
    print('heheheeh');
    bool b = _titleController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _contactController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _coordinatorController.text.isNotEmpty &&
        _organizationController.text.isNotEmpty;
    print(b);
    return b;
  }
}
