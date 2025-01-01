import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kynnovate/globals.dart';

import 'package:flutter/material.dart';

class AddItemDialog extends StatefulWidget {
  final String title;
  final String keyName;
  final List<String> initialOptions;
  final Function(String) onAddItem;

  const AddItemDialog({
    Key? key,
    required this.title,
    required this.keyName,
    required this.initialOptions,
    required this.onAddItem,
  }) : super(key: key);

  @override
  _AddItemDialogState createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  late List<String> filteredOptions;
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    filteredOptions = List.from(widget.initialOptions);
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterOptions(String query) {
    setState(() {
      filteredOptions = widget.initialOptions
          .where((option) => option.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _addItem(String item) {
    widget.onAddItem(item);
    setState(() {
      filteredOptions.remove(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$item added!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New ${widget.title}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Search',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: _filterOptions,
          ),
          SizedBox(height: 10),
          filteredOptions.isNotEmpty
              ? SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredOptions.length,
                    itemBuilder: (context, index) {
                      String option = filteredOptions[index];
                      return ListTile(
                        title: Text(option),
                        trailing: IconButton(
                          icon: Icon(Icons.add, color: Colors.green),
                          onPressed: () => _addItem(option),
                        ),
                      );
                    },
                  ),
                )
              : Text("No options available."),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Cancel"),
        ),
      ],
    );
  }
}

class _DropdownContent extends StatefulWidget {
  final String title;
  final List<dynamic> items;
  final String keyName;
  final Function(dynamic item) onItemRemoved;
  final VoidCallback onAddItem;

  const _DropdownContent({
    required this.title,
    required this.items,
    required this.keyName,
    required this.onItemRemoved,
    required this.onAddItem,
  });

  @override
  __DropdownContentState createState() => __DropdownContentState();
}

class __DropdownContentState extends State<_DropdownContent> {
  late List<dynamic> filteredItems;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredItems = List.from(widget.items);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            labelText: 'Search...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: (query) {
            setState(() {
              filteredItems = widget.items
                  .where((item) =>
                      item.toLowerCase().contains(query.toLowerCase()))
                  .toList();
            });
          },
        ),
        filteredItems.isNotEmpty
            ? SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(filteredItems[index].toString()),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          widget.onItemRemoved(filteredItems[index]);
                          setState(() {
                            filteredItems.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
              )
            : Text('No items available'),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Close"),
        ),
        TextButton(
          onPressed: widget.onAddItem,
          child: Text("Add preferences"),
        ),
      ],
    );
  }
}

class Userprofile extends StatefulWidget {
  @override
  _UserprofileState createState() => _UserprofileState();
}

class _UserprofileState extends State<Userprofile> {
  late List<dynamic> filteredItems;
  @override
  void initState() {
    super.initState();
    if (!globalloadedpreferences) {
      _fetchUserPreferences();
    }
    if (!globalloadedvariables) {
      _fetchUserDetails();
    }
  }

  Future<void> _fetchUserDetails() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final String userId = user.uid;
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('User')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          globalUserData = userDoc.data() as Map<String, dynamic>;
          globalloadedvariables = true;
        } else {
          print("No user data found in Firestore.");
        }
      } else {
        print("No user signed in.");
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  Future<void> _fetchUserPreferences() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Preferences')
            .doc('preferences')
            .get();

        if (userDoc.exists) {
          setState(() {
            globalOptions = userDoc.data() as Map<String, dynamic>;
            globalloadedpreferences = true;
          });
          print('feteched preferences successfully');
        } else {
          print("No preference data found in Firestore.");
        }
      } else {
        print("No user signed in.");
      }
    } catch (e) {
      print("Error fetching preferences details: $e");
    }
  }

  void _showDropdownPopup(String title, List<dynamic> items, String key) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: _DropdownContent(
            title: title,
            items: items,
            keyName: key,
            onItemRemoved: (item) {
              _removeItemFromList(key, item);
            },
            onAddItem: () {
              _showAddItemDialog(title, key);
            },
          ),
        );
      },
    );
  }

  void _showAddItemDialog(String title, String key) {
    List<String> initialOptions =
        (globalOptions['options_${key}'] as List<dynamic>)
            .cast<String>()
            .where((item) => !(globalUserData[key]?.contains(item) ?? false))
            .toList();
    showDialog(
      context: context,
      builder: (context) {
        return AddItemDialog(
          title: title,
          keyName: key,
          initialOptions: initialOptions,
          onAddItem: (String item) {
            setState(() {
              globalUserData[key]?.add(item);
              globalOptions['options_${key}']?.remove(item);
            });
            _addupdateDatabase(key, item);
          },
        );
      },
    );
  }

  Future<void> _addupdateDatabase(String key, String item) async {
    // // Replace this with actual database logic.
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final String userId = user.uid;
        List<dynamic> updatedList = globalUserData[key] ?? [];
        await FirebaseFirestore.instance
            .collection('User')
            .doc(userId)
            .update({key: updatedList});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$item added successfully')),
        );
      }
    } catch (e) {
      print("Error removing item: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove $item')),
      );
    }
    // await Future.delayed(Duration(milliseconds: 500)); // Simulating DB delay.
    print('Database updated: $key -> $item');
  }

  Future<void> _removeItemFromList(String key, String item) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final String userId = user.uid;
        List<dynamic> updatedList = globalUserData[key] ?? [];
        updatedList.remove(item);

        await FirebaseFirestore.instance
            .collection('User')
            .doc(userId)
            .update({key: updatedList});

        setState(() {
          globalUserData[key] = updatedList;
        });

        // Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$item removed successfully')),
        );
      }
    } catch (e) {
      print("Error removing item: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove $item')),
      );
    }
  }

  Future<void> _addItemToList(String key, String newItem) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final String userId = user.uid;

        List<dynamic> updatedList = globalUserData[key] ?? [];
        updatedList.add(newItem);
        await FirebaseFirestore.instance
            .collection('User')
            .doc(userId)
            .update({key: updatedList});

        setState(() {
          globalUserData[key] = updatedList;
        });

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$newItem added successfully')),
        );
      }
    } catch (e) {
      print("Error adding item: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add $newItem')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Profile"),
        backgroundColor: Colors.teal,
      ),
      body: globalloadedvariables
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        globalUserData['profileImageUrl'] != null &&
                                globalUserData['profileImageUrl'].isNotEmpty
                            ? NetworkImage(globalUserData['profileImageUrl'])
                            : AssetImage('assets/default_user.png')
                                as ImageProvider,
                    backgroundColor: Colors.grey[200],
                  ),
                  SizedBox(height: 20),
                  // User Name
                  Text(
                    globalUserData['name'] ?? 'Unknown User',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(height: 5),
                  // Email
                  Text(
                    globalUserData['email'] ?? 'Not Available',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  Divider(thickness: 1, height: 30, color: Colors.teal[200]),
                  // Details Section
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.start,
                    children: [
                      _buildInfoCard(
                        icon: Icons.location_city,
                        color: Colors.orange,
                        label: 'States',
                        value: (globalUserData['state'] is List
                            ? (globalUserData['state'] as List).join(', ')
                            : globalUserData['state'] ?? 'Not Available'),
                        onTap: () {
                          _showDropdownPopup(
                              'States', globalUserData['state'] ?? [], 'state');
                        },
                      ),
                      _buildInfoCard(
                        icon: Icons.map,
                        color: Colors.green,
                        label: 'Districts',
                        value: (globalUserData['district'] is List
                            ? (globalUserData['district'] as List).join(', ')
                            : globalUserData['district'] ?? 'Not Available'),
                        onTap: () {
                          _showDropdownPopup('Districts',
                              globalUserData['district'] ?? [], 'district');
                        },
                      ),
                      _buildInfoCard(
                        icon: Icons.comment,
                        color: Colors.indigo,
                        label: 'Comments',
                        value: (globalUserData['comments'] is List
                            ? (globalUserData['comments'] as List).join(', ')
                            : globalUserData['comments'] ?? 'No Comments'),
                        onTap: () {
                          _showDropdownPopup('Comments',
                              globalUserData['comments'] ?? [], 'comments');
                        },
                      ),
                      _buildInfoCard(
                        icon: Icons.subscriptions,
                        color: Colors.cyan,
                        label: 'Subscriptions',
                        value: (globalUserData['subscription'] is List
                            ? (globalUserData['subscription'] as List)
                                .join(', ')
                            : globalUserData['subscription'] ??
                                'No Subscriptions'),
                        onTap: () {
                          _showDropdownPopup(
                              'Subscriptions',
                              globalUserData['subscriptions'] ?? [],
                              'subscriptions');
                        },
                      ),
                      _buildInfoCard(
                        icon: Icons.thumb_up_alt_rounded,
                        color: Colors.blue,
                        label: 'Liked Content',
                        value: (globalUserData['likedcontent'] is List
                            ? (globalUserData['likedcontent'] as List)
                                .join(', ')
                            : globalUserData['likedcontent'] ?? 'No Likes'),
                        onTap: () {
                          _showDropdownPopup(
                              'Liked Content',
                              globalUserData['likedcontent'] ?? [],
                              'likedcontent');
                        },
                      ),
                      _buildInfoCard(
                        icon: Icons.person,
                        color: Colors.purple,
                        label: 'Liked Authors',
                        value: (globalUserData['likedauthors'] is List
                            ? (globalUserData['likedauthors'] as List)
                                .join(', ')
                            : globalUserData['likedauthors'] ?? 'No Authors'),
                        onTap: () {
                          _showDropdownPopup(
                              'Liked Authors',
                              globalUserData['likedauthors'] ?? [],
                              'likedauthors');
                        },
                      ),
                      _buildInfoCard(
                        icon: Icons.tv,
                        color: Colors.red,
                        label: 'Liked Channels',
                        value: (globalUserData['likednewschannels'] is List
                            ? (globalUserData['likednewschannels'] as List)
                                .join(', ')
                            : globalUserData['likednewschannels'] ??
                                'No Channels'),
                        onTap: () {
                          _showDropdownPopup(
                              'Liked Channels',
                              globalUserData['likednewschannels'] ?? [],
                              'likednewschannels');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: color.withOpacity(0.3),
                  child: Icon(icon, color: color, size: 20),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            // Text(
            //   value,
            //   style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            //   maxLines: 3,
            //   overflow: TextOverflow.ellipsis,
            // ),
          ],
        ),
      ),
    );
  }
}
