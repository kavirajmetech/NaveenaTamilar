import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';

class KidsNewsPage extends StatefulWidget {
  @override
  _KidsNewsPageState createState() => _KidsNewsPageState();
}

class _KidsNewsPageState extends State<KidsNewsPage> {
  final String cartoonImage = 'assets/cartoon.png'; // Your cartoon image
  final List<Map<String, String>> newsItems = [
    {
      "title": "The Moon and Its Mysteries!",
      "content":
          "Scientists have discovered new secrets about the moon. It has ice in its craters!"
    },
    {
      "title": "The Ocean Depths!",
      "content":
          "Scientists are exploring the deepest parts of the ocean. They found new species living there!"
    }
  ];

  int _currentNewsIndex = 0;
  bool _showQuestion = false;
  bool _showRewards = false;
  double _timeLeft = 0.0;
  late Timer _questionTimer;
  late Timer _readAloudTimer;
  String _question = '';
  List<String> _options = [];
  String _correctAnswer = '';

  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _questionTimer.cancel();
    _readAloudTimer.cancel();
    _flutterTts.stop();
    super.dispose();
  }

  void _startTimer() {
    _timeLeft = 30.0; // Set the initial time to 30 seconds
    _questionTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft -= 1;
        });
      } else {
        timer.cancel();
        _fetchQuestionFromGemini();
      }
    });
  }

  Future<void> _fetchQuestionFromGemini() async {
    final apiKey = 'YOUR_API_KEY'; // Your Gemini API key
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'contents': [
            {
              'parts': [
                {
                  'text':
                      'Scientists have discovered new secrets about the moon. It has ice in its craters!, return me a json of question with options and answer based on the news'
                }
              ]
            }
          ]
        }),
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          // Assuming the response contains `question`, `options`, and `answer`
          _question = responseData['contents'][0]['parts'][0]['text'];
          _options = List<String>.from(
              responseData['contents'][0]['parts'][0]['options']);
          _correctAnswer = responseData['contents'][0]['parts'][0]['answer'];
          _showQuestion = true;
        });
      } else {
        print("Failed to load question: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching question: $e");
    }
  }

  void _readAloud(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);

    int contentLength = text.length;
    int timeForReading = (contentLength / 10).round();
    _startReadAloudTimer(timeForReading);
  }

  void _startReadAloudTimer(int timeForReading) {
    _readAloudTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft -= 1;
        });
      } else {
        timer.cancel();
      }
    });

    setState(() {
      _timeLeft = timeForReading.toDouble();
    });
  }

  void _displayRewards() {
    setState(() {
      _showRewards = true;
    });
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _showRewards = false;
        _loadNextQuestion();
      });
    });
  }

  void _checkAnswer(String selectedAnswer) {
    if (selectedAnswer == _correctAnswer) {
      _displayRewards();
    }
  }

  void _loadNextQuestion() {
    if (_currentNewsIndex < newsItems.length - 1) {
      setState(() {
        _currentNewsIndex++;
        _showQuestion = false;
        _timeLeft = 30.0; // Reset time for the next news item
        _startTimer();
      });
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Congratulations!"),
          content: Text("You've completed all the questions!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kids News"),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Image.asset(
                cartoonImage,
                height: 150,
              ),
            ),
            SizedBox(height: 20),
            if (!_showQuestion)
              Center(
                child: CircularProgressIndicator(
                  value: _timeLeft / 60,
                  strokeWidth: 6,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            SizedBox(height: 20),
            if (!_showQuestion)
              Text(
                newsItems[_currentNewsIndex]['title']!,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
            SizedBox(height: 10),
            if (!_showQuestion)
              Text(
                newsItems[_currentNewsIndex]['content']!,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.justify,
              ),
            SizedBox(height: 20),
            if (!_showQuestion)
              ElevatedButton.icon(
                onPressed: () =>
                    _readAloud(newsItems[_currentNewsIndex]['content']!),
                icon: Icon(Icons.record_voice_over),
                label: Text("Read Aloud"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                ),
              ),
            if (_showQuestion) ...[
              Divider(height: 30, color: Colors.grey),
              Text(
                _question,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 10),
              for (var option in _options) ...[
                ElevatedButton(
                  onPressed: () => _checkAnswer(option),
                  child: Text(option),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
              ]
            ],
            if (_showRewards)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.orange,
                      size: 50,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Congrats! You got a reward!",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 10),
                    Icon(
                      Icons.fireplace,
                      color: Colors.red,
                      size: 50,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
