import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kynnovate/pages/authentication/form.dart';
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

  String _selectedState = "Select State";
  String _selectedDistrict = "Select District";
  List<String> states = [
    "Select State",
    "Andhra Pradesh",
    "Arunachal Pradesh",
    "Assam",
    "Bihar",
    "Chhattisgarh",
    "Goa",
    "Gujarat",
    "Haryana",
    "Himachal Pradesh",
    "Jharkhand",
    "Karnataka",
    "Kerala",
    "Madhya Pradesh",
    "Maharashtra",
    "Manipur",
    "Meghalaya",
    "Mizoram",
    "Nagaland",
    "Odisha",
    "Punjab",
    "Rajasthan",
    "Sikkim",
    "Tamil Nadu",
    "Telangana",
    "Tripura",
    "Uttar Pradesh",
    "Uttarakhand",
    "West Bengal",
    "Andaman and Nicobar Islands",
    "Chandigarh",
    "Dadra and Nagar Haveli and Daman and Diu",
    "Delhi",
    "Jammu and Kashmir",
    "Ladakh",
    "Lakshadweep",
    "Puducherry"
  ];
  List<String> districts = [
    "Select District",
    "Ariyalur",
    "Chengalpattu",
    "Chennai",
    "Coimbatore",
    "Cuddalore",
    "Dharmapuri",
    "Dindigul",
    "Erode",
    "Kallakurichi",
    "Kanchipuram",
    "Kanyakumari",
    "Karur",
    "Krishnagiri",
    "Madurai",
    "Mayiladuthurai",
    "Nagapattinam",
    "Namakkal",
    "Nilgiris",
    "Perambalur",
    "Pudukkottai",
    "Ramanathapuram",
    "Ranipet",
    "Salem",
    "Sivaganga",
    "Tenkasi",
    "Thanjavur",
    "Theni",
    "Thiruvallur",
    "Thiruvarur",
    "Thoothukudi",
    "Tiruchirappalli",
    "Tirunelveli",
    "Tirupattur",
    "Tiruppur",
    "Tiruvannamalai",
    "Vellore",
    "Viluppuram",
    "Virudhunagar"
  ];
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // User canceled sign-in

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        await _saveUserToFirestore(user.uid, user.displayName ?? "Google User",
            user.email ?? "", "Google Sign-In");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SplashScreen()),
        );
      }
    } catch (e) {
      _showErrorDialog("Error: ${e.toString()}");
    }
  }

  Future<void> _saveUserToFirestore(
      String uid, String name, String email, String authMethod) async {
    final userDoc = FirebaseFirestore.instance.collection('User').doc(uid);
    final userExists = await userDoc.get();
    if (!userExists.exists) {
      await userDoc.set({
        'name': name,
        'email': email,
        'authMethod': authMethod,
        'state': _selectedState,
        'district': _selectedDistrict,
        'likedcontent': [],
        'likedauthors': [],
        'likednewschannels': [],
        'profileImageUrl': "",
        'comments': [],
        'subscriptions': [],
        'Events': [],
        'EventsRegistered': [],
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Error"),
          content: Text(message, style: const TextStyle(color: Colors.red)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _signUpWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        _selectedState == "Select State" ||
        _selectedDistrict == "Select District") {
      _showErrorDialog("Please fill in all the fields.");
      return;
    }

    if (!RegExp(r"^[a-zA-Z0-9.+_-]+@[a-zA-Z0-9._-]+\.[a-zA-Z]+$")
        .hasMatch(email)) {
      _showErrorDialog("Invalid email format.");
      return;
    }

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _saveUserToFirestore(userCredential.user!.uid,
          "$firstName $lastName", email, "Email/Password");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SplashScreen()),
      );
    } catch (e) {
      _showErrorDialog("Sign-up failed. Error: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final height = mediaQuery.size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
            child: Container(color: Colors.black.withOpacity(0.1)),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.1,
                vertical: height * 0.1,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Sign up',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(_firstNameController, "First Name"),
                  const SizedBox(height: 20),
                  _buildTextField(_lastNameController, "Last Name"),
                  const SizedBox(height: 20),
                  _buildTextField(_emailController, "Email"),
                  const SizedBox(height: 20),
                  _buildTextField(_passwordController, "Password",
                      obscureText: true),
                  const SizedBox(height: 20),
                  _buildDropdown("Select State", states, _selectedState,
                      (newValue) => setState(() => _selectedState = newValue)),
                  const SizedBox(height: 20),
                  _buildDropdown(
                      "Select District",
                      districts,
                      _selectedDistrict,
                      (newValue) =>
                          setState(() => _selectedDistrict = newValue)),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _signUpWithEmail,
                    child:
                        const Text("Sign up", style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _signInWithGoogle,
                    icon: const Icon(Icons.g_mobiledata),
                    label: const Text("Continue with Google"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
      ),
    );
  }

  Widget _buildDropdown(String hint, List<String> items, String selectedValue,
      ValueChanged<String> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: DropdownButton<String>(
        value: selectedValue,
        isExpanded: true,
        onChanged: (value) => onChanged(value!),
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}
