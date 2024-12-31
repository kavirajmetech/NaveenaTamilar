import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kynnovate/config.dart';
import 'package:kynnovate/globals.dart';
import 'package:kynnovate/pages/authentication/signin.dart';
import 'package:kynnovate/pages/children/childrennews.dart';
import 'package:kynnovate/pages/user/userprofile.dart';
import 'package:kynnovate/screens/news_list_screen.dart';

String globalLanguageOption = 'English'; // Default global language option

class HomePage extends StatefulWidget {
  final Function toggleTheme;

  const HomePage({Key? key, required this.toggleTheme}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedIndex = 0;

  // Define the pages for the BottomNavigationBar
  final List<Widget> _pages = [
    NewsListScreen(), // Home
    KidsNewsPage(), // Replace with your Search Page
    Center(child: Text("Favorites Page")),
    Center(child: Text("Favorites Page")), // Replace with your Favorites Page
    Userprofile(), // Profile
  ];

  Future<void> _logout(BuildContext context) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirmation == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        await _auth.signOut();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => SignInPage()),
        );
      } catch (e) {
        Navigator.of(context).pop(); // Remove loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to log out: $e")),
        );
      }
    }
  }

  void _selectLanguage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Language"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _languageOptionTile("தமிழ் (Tamil)", "ta"),
              _languageOptionTile("English", "en"),
              _languageOptionTile("తెలుగు (Telugu)", "te"),
              _languageOptionTile("മലയാളം (Malayalam)", "ml"),
              _languageOptionTile("ಕನ್ನಡ (Kannada)", "kn"),
              _languageOptionTile("हिन्दी (Hindi)", 'hi')
            ],
          ),
        ),
      ),
    );
  }

  Widget _languageOptionTile(String displayName, String language) {
    return ListTile(
      title: Text(displayName),
      onTap: () {
        setState(() {
          globalLanguageOption = language;
        });
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Language changed to $displayName")),
        );
      },
    );
  }

  void _onBottomNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => Userprofile()),
            );
          },
        ),
        title: Text(homePage[globalLanguageOption] ?? 'Home Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.replay_outlined),
            onPressed: () => widget.toggleTheme(0),
          ),
          IconButton(
            icon: const Icon(Icons.translate),
            onPressed: () => _selectLanguage(context),
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () => widget.toggleTheme(1),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.blueGrey,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.child_care),
            label: 'Children',
            backgroundColor: Colors.blueGrey,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
            backgroundColor: Colors.blueGrey,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.short_text),
            label: 'Shorts',
            backgroundColor: Colors.blueGrey,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Preparation',
            backgroundColor: Colors.blueGrey,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromARGB(255, 72, 52, 185),
        unselectedItemColor: const Color.fromARGB(255, 91, 91, 91),
        onTap: _onBottomNavItemTapped,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
