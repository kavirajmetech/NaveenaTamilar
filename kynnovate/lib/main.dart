import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kynnovate/landingpage.dart';
import 'package:kynnovate/pages/authentication/signin.dart';
import 'package:kynnovate/pages/authentication/splashscreen.dart';
import 'package:kynnovate/pages/children/childrennews.dart';
import 'package:kynnovate/screens/news_details_screen.dart';
import 'package:kynnovate/screens/news_list_screen.dart';
import 'package:kynnovate/screens/slideshow_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int currentTheme = 1;

  void toggleTheme(int controll) {
    if (controll == 1) {
      setState(() {
        currentTheme = (currentTheme == 1) ? 0 : 1;
      });
    } else {
      setState(() {
        currentTheme = currentTheme;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: currentTheme == 1 ? ThemeData.light() : ThemeData.dark(),
      routes: {
        '/signin': (context) => SignInPage(),
      },
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen();
          }
          if (snapshot.hasData) {
            return HomePage(toggleTheme: toggleTheme);
            // return HomePage(toggleTheme: toggleTheme);
            // return KidsNewsPage();
            // return SlideshowScreen();
          } else {
            return SignInPage();
          }
        },
      ),
    );
  }
}
