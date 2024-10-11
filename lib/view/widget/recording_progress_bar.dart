import 'package:flutter/material.dart';
import 'dart:async';

class RecordingProgressBar extends StatefulWidget {
  const RecordingProgressBar({super.key});

  @override
  RecordingProgressBarState createState() => RecordingProgressBarState();
}

class RecordingProgressBarState extends State<RecordingProgressBar> {
  bool _isVisible = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startBlinking();
  }

  void _startBlinking() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _isVisible = !_isVisible;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        width: double.infinity,
        height: 30,
        color: Colors.red,
        child: const Center(
          child: Text(
            '録画中',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
