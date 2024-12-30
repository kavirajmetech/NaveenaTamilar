// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'splashscreen.dart';

// class SignUpPage extends StatefulWidget {
//   @override
//   _SignUpPageState createState() => _SignUpPageState();
// }

// class _SignUpPageState extends State<SignUpPage> {
//   final TextEditingController _firstNameController = TextEditingController();
//   final TextEditingController _lastNameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   @override
//   Widget build(BuildContext context) {
//     final mediaQuery = MediaQuery.of(context);
//     final width = mediaQuery.size.width;
//     final height = mediaQuery.size.height;

//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       body: Stack(
//         children: [
//           Container(
//             width: width,
//             height: height,
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage('assets/signup.png'),
//                 fit: BoxFit.cover,
//               ),
//             ),
//             child: Container(
//               color: Colors.black.withOpacity(0.1),
//             ),
//           ),
//           SingleChildScrollView(
//             child: Padding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: width * 0.1,
//                 vertical: height * 0.1,
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   SizedBox(height: height * 0.05),
//                   const Text(
//                     'Sign up',
//                     style: TextStyle(
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                       shadows: [
//                         Shadow(
//                           blurRadius: 10.0,
//                           offset: Offset(5, 5),
//                         ),
//                       ],
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 10),
//                   const Text(
//                     'Create your new account',
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.white70,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 40),

//                   // First Name and Last Name Row
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.9),
//                             borderRadius: BorderRadius.circular(12.0),
//                           ),
//                           child: TextField(
//                             controller: _firstNameController,
//                             decoration: InputDecoration(
//                               labelText: 'First name',
//                               border: InputBorder.none,
//                               contentPadding: EdgeInsets.symmetric(
//                                   horizontal: 16.0, vertical: 14.0),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.9),
//                             borderRadius: BorderRadius.circular(12.0),
//                           ),
//                           child: TextField(
//                             controller: _lastNameController,
//                             decoration: InputDecoration(
//                               labelText: 'Last name',
//                               border: InputBorder.none,
//                               contentPadding: EdgeInsets.symmetric(
//                                   horizontal: 16.0, vertical: 14.0),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),

//                   // Email Field
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.9),
//                       borderRadius: BorderRadius.circular(12.0),
//                     ),
//                     child: TextField(
//                       controller: _emailController,
//                       decoration: InputDecoration(
//                         labelText: 'Email',
//                         border: InputBorder.none,
//                         contentPadding: EdgeInsets.symmetric(
//                             horizontal: 16.0, vertical: 14.0),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   // Password Field
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.9),
//                       borderRadius: BorderRadius.circular(12.0),
//                     ),
//                     child: TextField(
//                       controller: _passwordController,
//                       obscureText: true,
//                       decoration: InputDecoration(
//                         labelText: 'Password',
//                         border: InputBorder.none,
//                         contentPadding: EdgeInsets.symmetric(
//                             horizontal: 16.0, vertical: 14.0),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                   // Sign Up Button
//                   ElevatedButton(
//                     onPressed: () async {
//                       try {
//                         final email = _emailController.text.trim();
//                         final password = _passwordController.text.trim();
//                         final firstName = _firstNameController.text.trim();
//                         final lastName = _lastNameController.text.trim();

//                         UserCredential userCredential =
//                             await _auth.createUserWithEmailAndPassword(
//                           email: email,
//                           password: password,
//                         );

//                         final String userId = userCredential.user!.uid;

//                         // Insert data into User collection
//                         // await FirebaseFirestore.instance
//                         //     .collection('User')
//                         //     .doc(userId)
//                         //     .set({
//                         //   'firstName': firstName,
//                         //   'lastName': lastName,
//                         //   'email': email,
//                         // });
//                         // Insert data into UserData collection

//                         try {
//                           await FirebaseFirestore.instance
//                               .collection('User')
//                               .doc(userId)
//                               .set({
//                             'name': "$firstName $lastName",
//                             'email': email,
//                             'likes': [],
//                             'favourites': [],
//                             'profileImageUrl': "",
//                             'contributions': [],
//                             'verifications': [],
//                             'discussions': []
//                           });
//                           print(
//                               "Data successfully saved to 'User' collection for userId: $userId");
//                         } catch (e) {
//                           print("Error saving to 'User' collection: $e");
//                         }

//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => SplashScreen()),
//                         );
//                       } catch (e) {
//                         // Handle errors
//                         showDialog(
//                           context: context,
//                           barrierDismissible: false,
//                           builder: (BuildContext context) {
//                             return AlertDialog(
//                               backgroundColor: Colors.transparent,
//                               elevation: 0,
//                               content: Text(
//                                 e.toString(),
//                                 style: TextStyle(color: Colors.red),
//                               ),
//                             );
//                           },
//                         );
//                         print('Error signing up: $e');
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 15.0),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12.0),
//                       ),
//                       backgroundColor: const Color.fromARGB(255, 83, 100, 147),
//                     ),
//                     child: const Text(
//                       'Sign up',
//                       style: TextStyle(fontSize: 18, color: Colors.white),
//                     ),
//                   ),
//                   SizedBox(height: mediaQuery.viewInsets.bottom),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'splashscreen.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in process
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user != null) {
        final String userId = user.uid;
        final String? name = user.displayName;
        final String? email = user.email;

        // Save user details to Firestore
        await FirebaseFirestore.instance.collection('User').doc(userId).set({
          'name': name ?? "Anonymous",
          'email': email ?? "",
          'likes': [],
          'favourites': [],
          'profileImageUrl': user.photoURL ?? "",
          'contributions': [],
          'verifications': [],
          'discussions': [],
        });

        print("User signed in with Google: $name ($email)");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SplashScreen()),
        );
      }
    } catch (e) {
      print("Error signing in with Google: $e");
      _showErrorDialog("Error signing in with Google: $e");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Text(
            message,
            style: const TextStyle(color: Colors.red),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final height = mediaQuery.size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            width: width,
            height: height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/signup.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.1,
                vertical: height * 0.1,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: height * 0.05),
                  const Text(
                    'Sign up',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          offset: Offset(5, 5),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Create your new account',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Existing Sign Up Fields

                  const SizedBox(height: 30),

                  // Continue with Google Button
                  ElevatedButton.icon(
                    onPressed: _signInWithGoogle,
                    icon: const Icon(Icons.g_mobiledata, size: 24),
                    label: const Text(
                      'Continue with Google',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      backgroundColor: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
