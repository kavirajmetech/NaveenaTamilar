import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kynnovate/globals.dart';

class Userprofile extends StatefulWidget {
  @override
  _UserprofileState createState() => _UserprofileState();
}

class _UserprofileState extends State<Userprofile> {
  @override
  void initState() {
    super.initState();
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
          setState(() {
            globalUserData = userDoc.data() as Map<String, dynamic>;
            globalloadedvariables = true;
          });
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
    TextEditingController searchController = TextEditingController();
    List<dynamic> filteredItems = List.from(items);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search Bar
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Search...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (query) {
                  setState(() {
                    filteredItems = items
                        .where((item) => item
                            .toString()
                            .toLowerCase()
                            .contains(query.toLowerCase()))
                        .toList();
                  });
                },
              ),
              // Display items
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
                                _removeItemFromList(key, filteredItems[index]);
                              },
                            ),
                          );
                        },
                      ),
                    )
                  : Text('No items available'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
            TextButton(
              onPressed: () {
                // Add new item functionality
                _showAddItemDialog(title, key);
              },
              child: Text("Add preferences"),
            ),
          ],
        );
      },
    );
  }

// Function to handle the addition of new item to the corresponding list
  void _showAddItemDialog(String title, String key) {
    TextEditingController newItemController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New $title'),
          content: TextField(
            controller: newItemController,
            decoration: InputDecoration(
              labelText: 'New Item',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                String newItem = newItemController.text.trim();
                if (newItem.isNotEmpty) {
                  setState(() {
                    globalUserData[title].add(newItem);
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
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

        Navigator.of(context).pop(); // Close the popup
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

        // Fetch the current list from globalUserData
        List<dynamic> updatedList = globalUserData[key] ?? [];

        // Add the new item to the list
        updatedList.add(newItem);

        // Update the list in Firebase
        await FirebaseFirestore.instance
            .collection('User')
            .doc(userId)
            .update({key: updatedList});

        // Update the local data as well
        setState(() {
          globalUserData[key] = updatedList;
        });

        Navigator.of(context).pop(); // Close the popup
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
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
