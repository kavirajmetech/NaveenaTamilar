import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kynnovate/globals.dart';
import 'package:kynnovate/pages/authentication/signin.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  void _logout(BuildContext context) {
    // Add your logout functionality here
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () async {
              await _auth.signOut();
              globalUserId = null;
              globalUsername = null;
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => SignInPage()),
              );
            },
            child: Text("Logout"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void _toggleTheme() {
    setState(() {
      globaltheme = globaltheme == 1 ? 0 : 1;
    });
    print('Theme changed to: ${globaltheme == 1 ? "Light" : "Dark"}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.person),
          onPressed: () {
            // Add functionality for the user icon if needed
          },
        ),
        title: Text('Home Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: _toggleTheme,
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome to the Home Page!'),
      ),
    );
  }
}
