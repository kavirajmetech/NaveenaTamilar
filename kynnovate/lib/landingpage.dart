import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kynnovate/config.dart';
import 'package:kynnovate/globals.dart';
import 'package:kynnovate/pages/Events/event_page.dart';
import 'package:kynnovate/pages/authentication/signin.dart';
import 'package:kynnovate/pages/children/childrennews.dart';
import 'package:kynnovate/pages/exams/exams.dart';
import 'package:kynnovate/pages/fmpage/fmpage.dart';
import 'package:kynnovate/pages/user/userprofile.dart';
import 'package:kynnovate/screens/meme_page.dart';
import 'package:kynnovate/screens/news_list_screen.dart';
import 'package:kynnovate/screens/slideshow_screen.dart';


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
    KidsNewsPage(),
    Exams(),
    SlideshowScreen(),
    MemePage(),
    EventPage(), // Profile
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
        globalLanguageOption=language;
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
          // IconButton(
          //   icon: const Icon(Icons.replay_outlined),
          //   onPressed: () => widget.toggleTheme(0),
          // ),
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
      // bottomNavigationBar: BottomNavigationBar(
      //   items: [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: home[globalLanguageOption] ?? 'Home',
      //       backgroundColor: Colors.blueGrey,
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.child_care),
      //       label: children[globalLanguageOption] ?? 'Children',
      //       backgroundColor: Colors.blueGrey,
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.book),
      //       label: 'Preparation',
      //       backgroundColor: Colors.blueGrey,
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.video_call),
      //       label: shorts[globalLanguageOption] ?? 'Shorts',
      //       backgroundColor: Colors.blueGrey,
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.emoji_emotions),
      //       label: memes[globalLanguageOption] ?? 'Memes',
      //       backgroundColor: Colors.blueGrey,
      //     ),
      //   ],
      //   currentIndex: _selectedIndex,
      //   selectedItemColor: Color.fromARGB(255, 72, 52, 185),
      //   unselectedItemColor: const Color.fromARGB(255, 91, 91, 91),
      //   onTap: _onBottomNavItemTapped,
      //   showSelectedLabels: true,
      //   showUnselectedLabels: true,
      //   type: BottomNavigationBarType.fixed,
      // ),
      // Your pages
      bottomNavigationBar: ScrollableBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onBottomNavItemTapped,
      ),
    );
  }
}

class ScrollableBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  ScrollableBottomNavBar({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home, 'label': home[globalLanguageOption] ?? "Home"},
      {
        'icon': Icons.child_care,
        'label': children[globalLanguageOption] ?? "Children"
      },
      {
        'icon': Icons.book,
        'label': preparation[globalLanguageOption] ?? "Preparation"
      },
      {
        'icon': Icons.video_call,
        'label': shorts[globalLanguageOption] ?? "Shorts"
      },
      {
        'icon': Icons.emoji_emotions,
        'label': memes[globalLanguageOption] ?? "Memes"
      },
      {'icon': Icons.event, 'label': events[globalLanguageOption] ?? "Events"},
    ];
    return Container(
      color: Colors.white, // Set the overall background color to white
      height: 60,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return GestureDetector(
              onTap: () => onItemTapped(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.white, // Background stays white for all items
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item['icon'] as IconData?,
                      color: index == selectedIndex
                          ? Color.fromARGB(
                              255, 72, 52, 185) // Blue for selected item
                          : Color.fromARGB(
                              255, 91, 91, 91), // Gray for unselected items
                    ),
                    Text(
                      item['label']! as String,
                      style: TextStyle(
                        color: index == selectedIndex
                            ? Color.fromARGB(
                                255, 72, 52, 185) // Blue for selected text
                            : Color.fromARGB(
                                255, 91, 91, 91), // Gray for unselected text
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
