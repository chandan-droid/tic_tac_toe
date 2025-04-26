import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

import 'home_page.dart';
import 'line_painter.dart';

void main() => runApp(TicTacToeApp());

class TicTacToeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TicTacToeGame(),
      debugShowCheckedModeBanner: false,
    );
  }
}

