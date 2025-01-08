import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kynnovate/Models/news_item.dart';
import 'package:kynnovate/config.dart';
import 'package:kynnovate/globals.dart';
import 'package:kynnovate/pages/fmpage/fmpage.dart';
import 'package:kynnovate/screens/search_screen.dart';
import 'package:kynnovate/screens/stylish_loading_mesage.dart';
import 'package:translator/translator.dart';
import 'package:xml/xml.dart' as xml;
import 'category_page.dart';
import 'channel_page.dart';
import 'latest_news_page.dart';
import 'location_page.dart';
import 'news_details_screen.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'saved_page.dart';
import 'todays_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewsListScreen extends StatefulWidget {
  @override
  _NewsListScreenState createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen>
    with TickerProviderStateMixin {
  String expandedSection = '';
  List<String> words = [];
  late Future<List<NewsItem>> futureNewsItems;
  late Future<List<NewsItem>> tamNewsItems;
  late Future<List<NewsItem>> engNewsItems;
  late Future<List<NewsItem>> latestItems;
  late Future<List<NewsItem>> allFutureNewsItems;
  late Future<List<NewsItem>> latestAllNewsItems;
  late Future<List<NewsItem>> latestTamNewsItems;
  late Future<List<NewsItem>> latestEngNewsItems;
  late Timer _timer;
  bool isLoading = true;
  final translator = GoogleTranslator();
  String errorMessage = '';
  late ScrollController
      _scrollController; // Scroll controller for auto-scrolling

  // Fetch data method
  Future<List<NewsItem>> fetchRssFeed(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.body);
        final items = document.findAllElements('item');
        return items.map((element) => NewsItem.fromXml(element)).toList();
      } else {
        print(
            'Failed to load RSS feed from $url (Status Code: ${response.statusCode})');
        return [];
      }
    } catch (e) {
      print('Error fetching RSS feed from $url: $e');
      return [];
    }
  }

  // Fetch multiple RSS feeds
  Future<List<NewsItem>> fetchMultipleRssFeeds(List<String> urls) async {
    List<NewsItem> allNewsItems = [];
    List<String> failedUrls = [];

    final translator = GoogleTranslator();
    for (String url in urls) {
      try {
        final newsItems = await fetchRssFeed(url);
        if (newsItems.isNotEmpty) {
          allNewsItems.addAll(newsItems.take(20));
          //allNewsItems.addAll(newsItems);
        } else {
          failedUrls.add(url);
        }
      } catch (e) {
        failedUrls.add(url);
        print('Error fetching from $url: $e');
      }
    }

    if (allNewsItems.isEmpty && failedUrls.isNotEmpty) {
      throw Exception('Failed to fetch news from any source');
    }

    return allNewsItems;
  }

  // Refresh method to reload data
  Future<void> _refreshNews() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      latestItems = fetchMultipleRssFeeds([
        "https://feeds.feedburner.com/Hindu_Tamil_tamilnadu",
        "https://www.dinakaran.com/feed/",
        "https://feeds.nbcnews.com/nbcnews/public/news"
      ]);
      latestTamNewsItems = fetchMultipleRssFeeds([
        "https://feeds.feedburner.com/Hindu_Tamil_tamilnadu",
        "https://www.dinakaran.com/feed/"
      ]);
      latestEngNewsItems = fetchMultipleRssFeeds(
          ["https://feeds.nbcnews.com/nbcnews/public/news"]);
      futureNewsItems = fetchMultipleRssFeeds([
        "https://www.dinakaran.com/feed/",
        "https://feeds.bbci.co.uk/news/world/rss.xml",
        "https://feeds.feedburner.com/Hindu_Tamil_tamilnadu",
      ]);
      tamNewsItems = fetchMultipleRssFeeds([
        "https://www.dinakaran.com/feed/",
        'https://feeds.feedburner.com/Hindu_Tamil_tamilnadu',
      ]);
      engNewsItems = fetchMultipleRssFeeds([
        'https://feeds.bbci.co.uk/news/world/rss.xml',
        'https://feeds.nbcnews.com/nbcnews/public/news'
      ]);
      allFutureNewsItems = futureNewsItems;
      latestAllNewsItems = latestItems;
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to refresh news. Please try again later.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshNews();
    _scrollController = ScrollController();

    // Set up the timer for automatic scrolling
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_scrollController.hasClients) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.position.pixels;

        // If the scroll position has reached the maximum, reset to the beginning
        if (currentScroll == maxScroll) {
          _scrollController.jumpTo(0);
        } else {
          // Scroll by a certain amount to the right
          _scrollController.animateTo(
            currentScroll + 360.0,
            duration: Duration(seconds: 1),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose(); // Dispose of the scroll controller
    super.dispose();
  }

  void _signOut() {
    Navigator.pushReplacementNamed(context, '/signin');
    // You can also clear authentication data if necessary (e.g. FirebaseAuth.signOut)
    print('User signed out');
  }

  Future<List<String>> fetchWords(String username) async {
    try {
      // QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      //     .collection('User')
      //     .where('name', isEqualTo: username)
      //     .limit(1)
      //     .get();
      //
      // if (querySnapshot.docs.isNotEmpty) {
      //   final docData = querySnapshot.docs.first.data() as Map<String, dynamic>;

      DocumentSnapshot docData = await FirebaseFirestore.instance.collection('User').doc(globalUserId).get();

        return List<String>.from(docData['words'] ?? []);
      // }
    } catch (e) {
      print("Error fetching words: $e");
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: errorMessage.isNotEmpty
          ? _buildErrorWidget()
          : RefreshIndicator(
              onRefresh: _refreshNews,
              child: ListView(
                children: [
                  _buildLanguageSelection(),
                  _buildSectionHeader('Latest'),
                  _buildLatestNews(),
                  _buildSectionHeader('Filter'),
                  _buildButtonsRow(),
                  _buildSectionHeader('Today\'s'),
                  _buildAllNews(),
                ],
              ),
            ),
    );
  }

  Widget _buildButtonsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildIconButton(
          icon: Icons.radio,
          label: 'FM',
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => FMpage()));
            print('FM tapped');
          },
        ),
        _buildIconButton(
          icon: Icons.live_tv,
          label: 'Channels',
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChannelPage(channel: 'Dhinakaran')));
            print('Channels tapped');
          },
        ),
        _buildIconButton(
          icon: Icons.category,
          label: 'Categories',
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CategoryPage(category: 'Politics')));
            print('Categories tapped');
          },
        ),
        _buildIconButton(
          icon: Icons.location_on,
          label: 'Locations',
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        LocationPage(locationTag: 'Chennai')));
            print('Locations tapped');
          },
        ),
        _buildIconButton(
          icon: Icons.save_alt_outlined,
          label: 'Saved',
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => SavedPage()));
            print('Saved tapped');
          },
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200], // Background color for the icon
            ),
            child: Icon(icon, size: 30, color: Colors.black), // Icon display
          ),
          SizedBox(height: 8), // Space between icon and label
          Text(
            label,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  // Error widget
  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            // errorMessage,
            'Upgrade Pro',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshNews,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsItem(NewsItem item) {
    double boxWidth = 350; // Adjust this to change the width of the box

    return GestureDetector(
      onTap: () {
        // Navigate to NewsDetailScreen and pass the NewsItem
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetailScreen(newsItem: item),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Image.network(
              item.imageUrl,
              width: boxWidth,
              height: 250,
              fit: BoxFit.cover, // Ensure the image covers the container
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  height: 250,
                  width: boxWidth,
                  child: const Icon(Icons.image_not_supported),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[200],
                  height: 250,
                  width: boxWidth,
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
            ),
            // Text overlay with gradient background at the bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(8.0),
                width: boxWidth, // Ensure overlay matches width of the image
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent, // Transparent at the top
                      Colors.grey.withOpacity(0.7), // Greyish at the bottom
                    ],
                  ),
                ),
                child:


                FutureBuilder<String>(
                  future: translator
                      .translate(

                      item.title.length > 50
                             ? "${item.title.substring(0, 50)}..." // Truncate text after 2 lines
                             : item.title
                      ,
                      to: globalLanguageOption)
                      .then((value) => value.toString()),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Text(
                        "Loading translation...",
                        style: TextStyle(color: Colors.white),
                      );
                    }
                    if (snapshot.hasError) {
                      return const Text(
                        "Error translating...",
                        style: TextStyle(color: Colors.red),
                      );
                    }
                    return Text(
                      snapshot.data ?? "",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),

                // Text(
                //   item.title.length > 50
                //       ? "${item.title.substring(0, 50)}..." // Truncate text after 2 lines
                //       : item.title,
                //   style: const TextStyle(
                //     color: Colors.white,
                //     fontWeight: FontWeight.bold,
                //     fontSize: 16.0,
                //     overflow: TextOverflow.ellipsis,
                //   ),
                //   maxLines: 2, // Limit the text to 2 lines
                //   softWrap:
                //       true, // Ensure it wraps to the next line if necessary
                // ),


              ),
            ),
          ],
        ),
      ),
    );
  }

// Build latest news widget
  Widget _buildLatestNews() {
    return FutureBuilder<List<NewsItem>>(
      future: latestItems,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return _buildSectionError('Latest News');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptySection('Latest News');
        }

        final now = DateTime.now();
        final List<NewsItem> allItems = snapshot.data!;

        final List<NewsItem> filteredItems = allItems.where((newsItem) {
          try {
            // Parse the newsItem's date
            return true;
            final DateTime newsDate =
                DateFormat('yyyy-MM-dd HH:mm:ss').parse(newsItem.date);

            final bool isWithinLast3Hours =
                now.difference(newsDate).inHours <= 6;
            final bool isSameDay = now.year == newsDate.year &&
                now.month == newsDate.month &&
                now.day == newsDate.day;

            return isSameDay;
            //return true;
          } catch (e) {
            // If parsing fails, exclude the item
            print('Error parsing date: ${newsItem.date}, error: $e');
            return false;
          }
        }).toList();

        if (filteredItems.isEmpty) {
          return _buildEmptySection('Today\'s Latest news yet to be updated.');
        }

        return SizedBox(
          height: 250, // Keep the height fixed
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              return _buildNewsItem(filteredItems[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildLanguageSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
// Search Button
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 0, 112, 248),
            padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8), // Adjusted padding for better height
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // Rounded corners
            ),
            elevation: 5, // Shadow/elevation
          ),
          child: const Row(
            mainAxisSize: MainAxisSize
                .min, // Ensures the button size is based on the content
            children: [
              Icon(
                Icons.search,
                size: 18, // Small size for the icon
                color: Colors.white, // Icon color
              ),
              SizedBox(width: 8), // Spacing between the icon and the text
              Text(
                'Search',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8), // Adjusted spacing for consistency

        // All News Button
        ElevatedButton(
          onPressed: () {
            setState(() {
              futureNewsItems = allFutureNewsItems; // Show All news
              latestItems = latestAllNewsItems; // Show All news
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: futureNewsItems == allFutureNewsItems
                ? Colors.blue
                : Colors.grey[
                    400], // Selected language - blue, non-selected - faded blue
            padding: const EdgeInsets.symmetric(
                horizontal: 0,
                vertical: 8), // Adjusted padding for better height
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // Rounded corners
            ),
            elevation: 5, // Shadow/elevation
          ),
          child: const Text(
            'All',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(width: 8), // Adjusted spacing for consistency

        // Tamil News Button
        ElevatedButton(
          onPressed: () {
            setState(() {
              futureNewsItems = tamNewsItems; // Show Tamil news
              latestItems = latestTamNewsItems; // Show Tamil news
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: futureNewsItems == tamNewsItems
                ? Colors.blue
                : Colors.grey[
                    400], // Selected language - blue, non-selected - faded blue
            padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 8), // Adjusted padding for better height
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // Rounded corners
            ),
            elevation: 5, // Shadow/elevation
          ),
          child: const Text(
            'Tamil News',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(width: 8), // Adjusted spacing for consistency

        // English News Button
        ElevatedButton(
          onPressed: () {
            setState(() {
              futureNewsItems = engNewsItems; // Show English news
              latestItems = latestEngNewsItems; // Show English news
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: futureNewsItems == engNewsItems
                ? Colors.blue
                : Colors.grey[
                    400], // Selected language - blue, non-selected - faded blue
            padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 8), // Adjusted padding for better height
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // Rounded corners
            ),
            elevation: 5, // Shadow/elevation
          ),
          child: const Text(
            'English News',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildAllNews() {
    return FutureBuilder<List<NewsItem>>(
      future: futureNewsItems,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return StylishLoadingMessage();
          // return const Column(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     CircularProgressIndicator(),
          //     Padding(
          //       padding: EdgeInsets.all(16.0),
          //       child: Text(
          //         "Personalizing Content...",
          //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          //       ),
          //     ),
          //   ],
          // );
        } else if (snapshot.hasError) {
          return _buildSectionError('Today\'s');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptySection('Today\'s');
        }

        // Get today's date
        final now = DateTime.now();
        final String todayString = DateFormat('yyyy-MM-dd').format(now);

        // Filter items to include only those from today
        final List<NewsItem> filteredItems = snapshot.data!.where((newsItem) {
          return true;
          try {
            // Parse the newsItem's date
            final DateTime newsDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(
                newsItem
                    .simpleDate); // Assuming 'date' is in 'yyyy-MM-dd HH:mm:ss' format
            // Check if the news is from today
            return now.year == newsDate.year &&
                now.month == newsDate.month &&
                now.day == newsDate.day;
          } catch (e) {
            // If parsing fails, exclude the item
            print('Error parsing date: ${newsItem.simpleDate}, error: $e');
            return false;
          }
        }).toList();

        if (filteredItems.isEmpty) {
          return _buildEmptySection('Today\'s news yet to be updated.');
        }

        // Fetch the list of words to check against (this is an async call)
        return FutureBuilder<List<String>>(
          future: fetchWords(globalUsername ?? ""),
          builder: (context, wordsSnapshot) {
            if (wordsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (wordsSnapshot.hasError) {
              return const Center(child: Text("Error loading keywords"));
            } else if (!wordsSnapshot.hasData || wordsSnapshot.data!.isEmpty) {
              return _buildNewsList(
                  filteredItems); // No words found, render news without "Recommended"
            }

            final words = wordsSnapshot.data!;

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final newsItem = filteredItems[index];
                final containsKeywords = words.any((word) =>
                    newsItem.title.contains(word) ||
                    newsItem.description.contains(word));

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (containsKeywords) // Add "Recommended" row if keywords match
                        Container(
                          width: double
                              .infinity, // Ensure the container spans the card width
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue[400],
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(
                                  15), // Round the top-left corner
                              topRight: Radius.circular(
                                  15), // Round the top-right corner
                            ),
                          ),
                          child: const Text(
                            "Recommended",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ListTile(
                        leading: SizedBox(
                          width: 100,
                          child: _buildNewsImage(newsItem.imageUrl, 60.0),
                        ),
                        title: FutureBuilder<String>(
                          future: translator
                              .translate(newsItem.title,
                                  to: globalLanguageOption)
                              .then((value) => value.toString()),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text(
                                "Loading translation...",
                                style: TextStyle(color: Colors.black87),
                              );
                            }
                            if (snapshot.hasError) {
                              return const Text(
                                "Error translating...",
                                style: TextStyle(color: Colors.red),
                              );
                            }
                            return Text(
                              snapshot.data ?? "",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                        subtitle: Text(
                          newsItem.date,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NewsDetailScreen(newsItem: newsItem),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSectionError(String section) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.orange),
          const SizedBox(height: 8),
          Text(
            'Upgrade PRO to Load Section',
            style: const TextStyle(color: Colors.red),
          ),
          TextButton(
            onPressed: _refreshNews,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySection(String section) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(Icons.inbox, color: Colors.grey),
          const SizedBox(height: 8),
          Text('$section'),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: () {
              if (title == 'Latest') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LatestNewsPage()));
              } else if (title == 'Today\'s') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TodaysPage()));
              }
            },
            child: Text(
              title == 'Latest'
                  ? latest[globalLanguageOption] ?? 'Latest'
                  : title == 'Filter'
                      ? filter[globalLanguageOption] ?? 'Filter'
                      : seeall[globalLanguageOption] ?? 'See All',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsImage(String imageUrl, double height) {
    return imageUrl.isNotEmpty
        ? Image.network(
            imageUrl,
            width: double.infinity,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: height,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: height,
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              );
            },
          )
        : Container(
            height: height,
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported),
          );
  }

  Widget _buildNewsList(List<NewsItem> newsItems) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: newsItems.length,
      itemBuilder: (context, index) {
        final newsItem = newsItems[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: ListTile(
            leading: SizedBox(
              width: 100,
              child: _buildNewsImage(newsItem.imageUrl, 60.0),
            ),
            title: Text(
              newsItem.title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              newsItem.date,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsDetailScreen(newsItem: newsItem),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
