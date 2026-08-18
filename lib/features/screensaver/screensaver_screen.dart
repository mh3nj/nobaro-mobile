import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/ascii_art.dart';
import '../../core/utils/sound_manager.dart';

class ScreensaverScreen extends StatefulWidget {
  const ScreensaverScreen({super.key});

  @override
  State<ScreensaverScreen> createState() => _ScreensaverScreenState();
}

class _ScreensaverScreenState extends State<ScreensaverScreen> {
  double _x = 0;
  double _y = 0;
  double _dx = 2;
  double _dy = 2;
  late Timer _timer;
  final Random _random = Random();
  Color _color = Colors.yellow;

  @override
  void initState() {
    super.initState();
    SoundManager.playGorilla();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      _move();
    });
  }

  void _move() {
    final size = MediaQuery.of(context).size;
    setState(() {
      _x += _dx;
      _y += _dy;

      if (_x <= 0 || _x > size.width - 200) {
        _dx = -_dx;
        _changeColor();
      }
      if (_y <= 0 || _y > size.height - 100) {
        _dy = -_dy;
        _changeColor();
      }
    });
  }

  void _changeColor() {
    final colors = [Colors.yellow, Colors.cyanAccent, Colors.greenAccent, Colors.pinkAccent, Colors.white];
    _color = colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Stack(
          children: [
            Positioned(
              left: _x,
              top: _y,
              child: Text(
                AsciiArt.logoSmall,
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 8,
                  color: _color,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
