import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';

class KidsNewsPage extends StatefulWidget {
  @override
  _KidsNewsPageState createState() => _KidsNewsPageState();
}

class _KidsNewsPageState extends State<KidsNewsPage> {
  final String cartoonImage = 'assets/cartoon.png';
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
  double _timeLeft = 30.0;
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
    _flutterTts.stop();
    super.dispose();
  }

  void _startTimer() {
    _timeLeft = 5.0;
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
    final apiKey = 'AIzaSyBHbQhbhN55b1RR00vbUfgeoVoAZgAuj6s';
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
                      '${newsItems[_currentNewsIndex]['content']}, for this news, Return a question , options and the correct answer, please return in the form of "question text":"option a":"option b":"option c":"option d":"answer".'
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['candidates'] != null &&
            responseData['candidates'] is List &&
            responseData['candidates'].isNotEmpty) {
          final textContent = responseData['candidates'][0]['content']['parts']
              [0]['text'] as String;

          // Parse the response string
          final components = textContent.split('":"');
          if (components.length >= 7) {
            setState(() {
              // _question = components[0].replaceAll('"', '').trim();
              // _options = [
              //   components[1].replaceAll('"', '').trim(),
              //   components[2].replaceAll('"', '').trim(),
              //   components[3].replaceAll('"', '').trim(),
              //   components[4].replaceAll('"', '').trim()
              // ];
              // _correctAnswer = components[5].replaceAll('"', '').trim();
              _question =
                  'What have scientists recently discovered about the moon?';
              _options = [
                'It has trees in its craters.',
                'It has ice in its craters.',
                'It has water on its surface.',
                'It has gold deposits.'
              ];
              _correctAnswer = 'B';
              _showQuestion = true;
            });
          } else {
            print("Unexpected response format. Length: ${components.length}");
          }
        } else {
          print("Invalid response structure: $responseData");
        }
      } else {
        print('Error: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print("Error fetching question: $e");
    }
  }

  void _readAloud(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  void _displayRewards() {
    setState(() {
      _showRewards = true;
    });
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _showRewards = false;
        _loadNextNewsOrReset();
      });
    });
  }

  void _checkAnswer(int selectedAnswer) {
    int correctAnswer =
        _correctAnswer.toUpperCase().codeUnitAt(0) - 'A'.codeUnitAt(0) + 1;
    if (selectedAnswer == correctAnswer) {
      _displayRewards();
    } else {
      print("Incorrect Answer: $selectedAnswer");
    }
  }

  void _loadNextNewsOrReset() {
    if (_currentNewsIndex < newsItems.length - 1) {
      setState(() {
        _currentNewsIndex++;
        _showQuestion = false;
        _timeLeft = 30.0;
        _startTimer();
      });
    } else {
      setState(() {
        _currentNewsIndex = 0;
        _showQuestion = false;
        _timeLeft = 30.0;
        _startTimer();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kids News"),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                Column(
                  children: [
                    CircularProgressIndicator(
                      value: _timeLeft / 30,
                      strokeWidth: 6,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    SizedBox(height: 20),
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
                    Text(
                      newsItems[_currentNewsIndex]['content']!,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    SizedBox(height: 20),
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
                  ],
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
                for (var entry in _options.asMap().entries)
                  ElevatedButton(
                    onPressed: () => _checkAnswer(entry.key),
                    child: Text(entry.value),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
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
      ),
    );
  }
}
