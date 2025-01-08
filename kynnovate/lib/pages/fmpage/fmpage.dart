import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:kynnovate/Models/news_item.dart';
import 'package:kynnovate/globals.dart';

class FMpage extends StatefulWidget {
  @override
  _FMpage createState() => _FMpage();
}

class _FMpage extends State<FMpage> {
  late Future<List<NewsItem>> newsItems;
  final FlutterTts flutterTts = FlutterTts();
  int? currentlyReadingIndex;
  bool isReadAloudMode = false;

  double _volume = 1.0;
  double _pitch = 1.0;
  double _rate = 0.5;

  @override
  void initState() {
    super.initState();
    if (!globalloadednewsitem) {
      globalrefreshNews();
      globalloadednewsitem = true;
    }
    newsItems = globalfutureNewsItems;

    flutterTts.setCompletionHandler(() {
      if (isReadAloudMode) {
        _readNextNewsItem();
      } else {
        setState(() {
          currentlyReadingIndex = null;
        });
      }
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  void toggleReadAloudMode() {
    setState(() {
      isReadAloudMode = !isReadAloudMode;
      currentlyReadingIndex = isReadAloudMode ? 0 : null;
    });

    if (isReadAloudMode) {
      _readNextNewsItem();
    } else {
      flutterTts.stop();
    }
  }

  Future<void> _readNextNewsItem() async {
    if (!isReadAloudMode) return;

    final snapshot = await newsItems;
    if (currentlyReadingIndex! < snapshot.length) {
      final newsItem = snapshot[currentlyReadingIndex!];
      setState(() {
        currentlyReadingIndex = currentlyReadingIndex;
      });

      await flutterTts.setVolume(_volume);
      await flutterTts.setPitch(_pitch);
      await flutterTts.setSpeechRate(_rate);
      await flutterTts.speak("${newsItem.title}. ${newsItem.description}");

      setState(() {
        currentlyReadingIndex = currentlyReadingIndex! + 1;
      });
    } else {
      setState(() {
        isReadAloudMode = false;
        currentlyReadingIndex = null;
      });
    }
  }

  Future<void> readNewsItem(int index, String text) async {
    setState(() {
      currentlyReadingIndex = index;
      isReadAloudMode = false;
    });

    await flutterTts.setVolume(_volume);
    await flutterTts.setPitch(_pitch);
    await flutterTts.setSpeechRate(_rate);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FM News"),
        backgroundColor: Colors.blueGrey,
        actions: [
          ElevatedButton.icon(
            onPressed: toggleReadAloudMode,
            icon: Icon(isReadAloudMode ? Icons.stop : Icons.play_arrow),
            label: Text(isReadAloudMode ? "Stop" : "Start"),
            style: ElevatedButton.styleFrom(
              backgroundColor: isReadAloudMode
                  ? const Color.fromARGB(255, 190, 101, 95)
                  : Colors.green,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Text("Volume"),
                    Expanded(
                      child: Slider(
                        value: _volume,
                        min: 0.0,
                        max: 1.0,
                        onChanged: (value) {
                          setState(() {
                            _volume = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text("Pitch"),
                    Expanded(
                      child: Slider(
                        value: _pitch,
                        min: 0.5,
                        max: 2.0,
                        onChanged: (value) {
                          setState(() {
                            _pitch = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text("Rate"),
                    Expanded(
                      child: Slider(
                        value: _rate,
                        min: 0.1,
                        max: 1.0,
                        onChanged: (value) {
                          setState(() {
                            _rate = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<NewsItem>>(
              future: newsItems,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text("Error loading news: ${snapshot.error}"),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text("No news available."),
                  );
                }

                final items = snapshot.data!;
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final newsItem = items[index];
                    final isReading = currentlyReadingIndex == index;

                    return GestureDetector(
                      onTap: () => readNewsItem(
                          index, "${newsItem.title}. ${newsItem.description}"),
                      child: Card(
                        color: isReading
                            ? Colors.lightBlue.shade100
                            : Colors.white,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                newsItem.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isReading ? Colors.blue : Colors.black,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                newsItem.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isReading
                                      ? Colors.blueGrey
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
