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

  void _showDropdownPopup(String title, List<dynamic> items, String key) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: items.isNotEmpty
              ? SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(items[index]),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _removeItemFromList(key, items[index]);
                          },
                        ),
                      );
                    },
                  ),
                )
              : Text('No items available'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Close"),
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
                        label: 'State',
                        value: globalUserData['state'] ?? 'Not Available',
                      ),
                      _buildInfoCard(
                        icon: Icons.map,
                        color: Colors.green,
                        label: 'District',
                        value: globalUserData['district'] ?? 'Not Available',
                      ),
                      _buildInfoCard(
                        icon: Icons.comment,
                        color: Colors.indigo,
                        label: 'Comments',
                        value:
                            (globalUserData['comments'] as List?)?.join(', ') ??
                                'No Comments',
                      ),
                      _buildInfoCard(
                        icon: Icons.subscriptions,
                        color: Colors.cyan,
                        label: 'Subscriptions',
                        value: (globalUserData['subscription'] as List?)
                                ?.join(', ') ??
                            'No Subscriptions',
                      ),
                      _buildInfoCard(
                        icon: Icons.thumb_up_alt_rounded,
                        color: Colors.blue,
                        label: 'Liked Content',
                        value: (globalUserData['likedcontent'] as List?)
                                ?.join(', ') ??
                            'No Likes',
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
                        value: (globalUserData['likedauthors'] as List?)
                                ?.join(', ') ??
                            'No Authors',
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
                        value: (globalUserData['likednewschannels'] as List?)
                                ?.join(', ') ??
                            'No Channels',
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
