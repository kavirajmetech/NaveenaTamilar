import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kynnovate/landingpage.dart';
import 'package:kynnovate/pages/exams/examcategory.dart';
import 'package:kynnovate/pages/exams/examcategorynews.dart';

class Exams extends StatefulWidget {
  @override
  _Exams createState() => _Exams();
}

class _Exams extends State<Exams> {
  final Map<String, String> map = {
    "UPSC Civil Services": "UPSC",
    "Banking Exams (IBPS, SBI, RBI)": "Economics",
    "Railway Exams (RRB)": "Politics",
    "Insurance Exams (LIC, NIACL)": "Economics",
    "General Knowledge": "Examination",
    "Current Affairs": "CA",
    "Science and Technology": "Technology",
    "History and Culture": "Education",
  };

  final List<String> examCategories = [
    "UPSC Civil Services",
    "Banking Exams (IBPS, SBI, RBI)",
    "Railway Exams (RRB)",
    "Insurance Exams (LIC, NIACL)",
    "General Knowledge",
    "Current Affairs",
    "Science and Technology",
    "History and Culture",
  ];

  List<String> filteredCategories = [];
  String selectedCategory = "";

  @override
  void initState() {
    super.initState();
    filteredCategories = examCategories; // Initially show all categories
  }

  void filterCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCategories = examCategories;
      } else {
        filteredCategories = examCategories
            .where((category) =>
                category.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: (query) => filterCategories(query),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                hintText: "Search exams...",
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Dynamic GridView
          Expanded(
            child: Container(
              child: GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      MediaQuery.of(context).size.width > 600 ? 2 : 1,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 3 / 2,
                ),
                itemCount: filteredCategories.length,
                itemBuilder: (context, index) {
                  final category = filteredCategories[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                      });
                      if (map[selectedCategory] == 'UPSC' ||
                          map[selectedCategory] == "CA") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ExamCategory(category: map[selectedCategory]!),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Examcategorynews(
                                  category: map[selectedCategory]!,
                                  fullcategory: selectedCategory!)),
                        );
                      }
                    },
                    child: AnimatedCard(category: category),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedCard extends StatelessWidget {
  final String category;

  AnimatedCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 117, 139, 218),
            const Color.fromARGB(255, 208, 125, 125)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 40, color: Colors.white),
            SizedBox(height: 8),
            Text(
              category,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
