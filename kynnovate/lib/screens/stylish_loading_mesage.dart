import 'package:flutter/material.dart';

class StylishLoadingMessage extends StatefulWidget {
  @override
  _StylishLoadingMessageState createState() => _StylishLoadingMessageState();
}

class _StylishLoadingMessageState extends State<StylishLoadingMessage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _animation;
  String _dots = " .";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);
    _animation = ColorTween(
      begin: const Color.fromARGB(255, 39, 82, 176),   // Original color
      end: const Color.fromARGB(255, 8, 70, 225),  // Brighter color
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _startDotsAnimation();
  }

  void _startDotsAnimation() {
    Future.doWhile(() async {
      setState(() {
        if (_dots.length < 4) {
          _dots += ".";
        } else {
          _dots = " .";
        }
      });
      await Future.delayed(Duration(seconds: 1));
      return true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Text(
              "Personalizing Content$_dots",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _animation.value,  // Animate color instead of opacity
              ),
            );
          },
        ),
        const SizedBox(height: 25.0),
        const CircularProgressIndicator(),
      ],
    );
  }
}
