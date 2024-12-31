import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

String? globalUserId;
String? globalUsername;
String? globalEmail;
int? globaltheme = 1;
Map<String, dynamic> globalOptions = {};
Map<String, dynamic> globalUserData = {};
bool globalloadedvariables = false;
bool globalloadedpreferences = false;
String? globalLanguageOption = 'ta';

class ThemeNotifier extends ChangeNotifier {
  int _theme = 1;

  int get theme => _theme;

  void changeTheme(int newTheme) {
    if (_theme != newTheme) {
      _theme = newTheme;
      notifyListeners();
    }
  }
}

ThemeNotifier themeNotifier = ThemeNotifier();

Future<void> fetchUserDetails() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String userId = user.uid;
      final DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('User').doc(userId).get();

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
