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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Profile"),
      ),
      body: globalloadedvariables
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Name: ${globalUserData['name'] ?? 'Not Available'}",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Email: ${globalUserData['email'] ?? 'Not Available'}",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Likes: ${(globalUserData['likes'] as List?)?.join(', ') ?? 'No Likes'}",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Favourites: ${(globalUserData['favourites'] as List?)?.join(', ') ?? 'No Favourites'}",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Profile Image URL: ${globalUserData['profileImageUrl'] ?? 'Not Available'}",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Contributions: ${(globalUserData['contributions'] as List?)?.join(', ') ?? 'No Contributions'}",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Verifications: ${(globalUserData['verifications'] as List?)?.join(', ') ?? 'No Verifications'}",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Discussions: ${(globalUserData['discussions'] as List?)?.join(', ') ?? 'No Discussions'}",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
