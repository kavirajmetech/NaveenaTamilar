// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:kynnovate/globals.dart';
// import 'package:kynnovate/main.dart';
// import 'package:kynnovate/pages/authentication/signin.dart';
// import 'package:kynnovate/pages/user/userprofile.dart';
// import 'package:kynnovate/screens/news_list_screen.dart'; // Ensure you import your NewsListPage here

// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   void _logout(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text("Logout"),
//         content: Text("Are you sure you want to log out?"),
//         actions: [
//           TextButton(
//             onPressed: () async {
//               await _auth.signOut();
//               globalUserId = null;
//               globalUsername = null;
//               Navigator.of(context).pop();
//               Navigator.of(context).pushReplacement(
//                 MaterialPageRoute(builder: (context) => SignInPage()),
//               );
//             },
//             child: Text("Logout"),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text("Cancel"),
//           ),
//         ],
//       ),
//     );
//   }

//   void _toggleTheme() {
//     setState(() {
//       currentTheme = (currentTheme == 1) ? 0 : 1; // Toggle theme
//     });

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       print('Theme changed to: ${currentTheme == 1 ? "Light" : "Dark"}');
//       setState(() {});
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.person),
//           onPressed: () {
//             Navigator.of(context).push(
//               MaterialPageRoute(builder: (context) => Userprofile()),
//             );
//           },
//         ),
//         title: Text('Home Page'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.logout),
//             onPressed: () => _logout(context),
//           ),
//           IconButton(
//             icon: Icon(Icons.brightness_6),
//             onPressed: _toggleTheme,
//           ),
//         ],
//       ),
//       body: NewsListScreen(), // Use your NewsListPage widget here
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kynnovate/pages/authentication/signin.dart';
import 'package:kynnovate/pages/user/userprofile.dart';
import 'package:kynnovate/screens/news_list_screen.dart';
import 'package:kynnovate/screens/slideshow_screen.dart';

class HomePage extends StatefulWidget {
  final Function toggleTheme;

  HomePage({required this.toggleTheme, required SlideshowScreen slideshowScreen});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () async {
              await _auth.signOut();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.person),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => Userprofile()),
            );
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
            onPressed: () {
              widget.toggleTheme();
            },
          ),
        ],
      ),
      body: NewsListScreen(),
    );
  }
}