import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kynnovate/landingpage.dart';
import 'package:kynnovate/pages/authentication/signin.dart';
import '../../globals.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    print("Initializing app...");

    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        if (mounted) {
          Future.delayed(Duration(seconds: 1), () {
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage(
                          toggleTheme: () {},
                        )),
              );
            }
          });
        }
      } else {
        if (mounted) {
          Future.delayed(Duration(seconds: 1), () {
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignInPage()),
              );
            }
          });
        }
      }
    });
  }

  Future<void> _fetchUserData(String userId) async {
    if (globalUserId == null || globalUsername == null) {
      try {
        final FirebaseAuth _auth = FirebaseAuth.instance;
        User? user = _auth.currentUser;
        if (user != null) {
          globalUserId = user.uid;
          globalUsername = user.displayName ?? 'User';
          print("Fetched user data: $globalUsername ($globalUserId)");
        } else {
          print("User details are not available.");
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/splashscreen.png',
              height: 100,
            ),
            SizedBox(height: 20),
            Text(
              "Loading...",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}