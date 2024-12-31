import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kynnovate/Models/news_item.dart';
import 'news_details_screen.dart';  // Assuming you have a detail screen


class LocationPage extends StatelessWidget {
  final String locationTag;

  LocationPage({required this.locationTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location: $locationTag'),
      ),
      body: Center(
        child: Text('News for $locationTag'),
      ),
    );
  }
}

// class _LocationPageState extends State<LocationPage> {
//   String selectedLocation = "Chennai"; // Default location
//   late Future<List<NewsItem>> locationNewsItems;

//   @override
//   void initState() {
//     super.initState();
//     _loadLocationNews(selectedLocation);
//   }

//   // Load news based on location
//   Future<void> _loadLocationNews(String location) async {
//     final response = await http.get(Uri.parse('assets/rssList.json'));
//     final data = json.decode(response.body);
//     final locationUrls = data['categories']['Regional'][location];
//     locationNewsItems = fetchRssFeed(locationUrls);
//     setState(() {});
//   }

//     List<NewsItem> parseRss(String xmlContent) {
//     // Your XML parsing logic here
//     // Returning an empty list for simplicity
//     return [];
//   }

//   // Fetch RSS feed
//   Future<List<NewsItem>> fetchRssFeed(List<String> urls) async {
//     List<NewsItem> allNewsItems = [];
//     for (String url in urls) {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         // Parse the XML response here
//         allNewsItems.addAll(parseRss(response.body));
//       }
//     }
//     return allNewsItems;
//   }



//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Location: $selectedLocation')),
//       body: Column(
//         children: [
//           // Dropdown to select location
//           DropdownButton<String>(
//             value: selectedLocation,
//             onChanged: (String? newValue) {
//               if (newValue != null) {
//                 setState(() {
//                   selectedLocation = newValue;
//                 });
//                 _loadLocationNews(newValue);
//               }
//             },
//             items: <String>[
//               'Chennai', 'Cuddalore', 'Thiruvannamalai', 'Sivakasi', 'Pondicherry'
//             ].map<DropdownMenuItem<String>>((String value) {
//               return DropdownMenuItem<String>(
//                 value: value,
//                 child: Text(value),
//               );
//             }).toList(),
//           ),
//           // News list based on location
//           Expanded(
//             child: FutureBuilder<List<NewsItem>>(
//               future: locationNewsItems,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 }
//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error loading news'));
//                 }
//                 final items = snapshot.data ?? [];
//                 return ListView.builder(
//                   itemCount: items.length,
//                   itemBuilder: (context, index) {
//                     return GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => NewsDetailScreen(newsItem: items[index]),
//                           ),
//                         );
//                       },
//                       child: Card(
//                         child: Column(
//                           children: [
//                             Image.network(items[index].imageUrl),
//                             Text(items[index].title),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
