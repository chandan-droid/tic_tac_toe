import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import 'line_painter.dart';

class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({super.key});

  @override
  _TicTacToeGameState createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  List<String> board = List.filled(9, '');
  bool xTurn = true;
  String message = '';
  List<int> winningCells = [];

  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
  }

  void onTap(int index) {
    if (board[index] != '' || message.isNotEmpty) return;

    setState(() {
      board[index] = xTurn ? 'X' : 'O';
      xTurn = !xTurn;
      checkWinner();
    });
  }

  void checkWinner() {
    const winPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var pattern in winPatterns) {
      if (board[pattern[0]] != '' &&
          board[pattern[0]] == board[pattern[1]] &&
          board[pattern[1]] == board[pattern[2]]) {
        setState(() {
          message = '${board[pattern[0]]} wins!';
          winningCells = pattern;
        });

        Future.delayed(const Duration(milliseconds: 500), () {
          showWinPopup(context, board[pattern[0]]);
          _confettiController.play();
        });

        return;
      }
    }
    if (!board.contains('')) {
      setState(() {
        message = 'Draw!';
      });
    }
  }

  void resetGame() {
    setState(() {
      board = List.filled(9, '');
      xTurn = true;
      message = '';
      winningCells = [];
    });
    _confettiController.stop();
  }

  void showWinPopup(BuildContext context, String winner) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Stack(
          children: [
            AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text("Game Over"),
              content: Text(
                "$winner wins the game!",
                style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
              ),
              actions: [
                OutlinedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    resetGame();
                  },
                  child: const Text("Restart"),
                ),
              ],
            ),
            Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.red,
                  Colors.blue,
                  Colors.green,
                  Colors.orange,
                  Colors.purple,
                  Colors.yellow,
                  Colors.white
                ],
                emissionFrequency: 0.05,
                numberOfParticles: 40,
                gravity: 0.4,
              ),
            ),
          ],
        );
      },
    );
  }

  Offset getCellOffset(int index, double width, double height) {
    int row = index ~/ 3;
    int col = index % 3;
    double gap = 10;

    double cellWidth = (width - 2 * gap) / 3;
    double cellHeight = (height - 2 * gap) / 3;

    double x = col * (cellWidth + gap) + cellWidth / 2;
    double y = row * (cellHeight + gap) + cellHeight / 2;

    return Offset(x, y);
  }


  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double gridSize = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFB2FEFA), Color(0xFF0ED2F7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    message.isEmpty ? "${xTurn ? 'X' : 'O'}'s Turn" : message,
                    style: const TextStyle(fontSize: 28, color: Colors.black87, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: gridSize,
                    height: gridSize*1.5,
                    child: Stack(
                      children: [
                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 9,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: () => onTap(index),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.white.withOpacity(0.25), Colors.white54],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.black26, width: 1.5),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    spreadRadius: 1,
                                    blurRadius: 8,
                                    offset: Offset(2, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  board[index],
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: board[index] == 'X' ? Colors.redAccent : Colors.blueAccent,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (winningCells.isNotEmpty)
                          CustomPaint(
                            painter: LinePainter(
                              start: getCellOffset(winningCells[0], gridSize, gridSize*1.2 ),
                              end: getCellOffset(winningCells[2], gridSize, gridSize*1.2 ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  OutlinedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    onPressed: resetGame,
                    child: const Text(
                      'Reset Game',
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                    ),
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

