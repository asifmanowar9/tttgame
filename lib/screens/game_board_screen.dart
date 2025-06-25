import 'package:flutter/material.dart';
import 'dart:math';
import '../theme/app_theme.dart';
import 'game_mode_screen.dart';

class GameBoardScreen extends StatefulWidget {
  final bool isAI;
  final String playerSymbol;

  const GameBoardScreen({
    super.key,
    required this.isAI,
    required this.playerSymbol,
  });

  @override
  State<GameBoardScreen> createState() => _GameBoardScreenState();
}

class _GameBoardScreenState extends State<GameBoardScreen> {
  late List<List<String>> board;
  late String currentPlayer;
  late String aiPlayer;
  late String winner;
  int playerScore = 0;
  int opponentScore = 0;
  bool gameOver = false;
  bool firstPlayerStartsNext = false; // Track who starts first

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  void initializeGame() {
    // Initialize 3x3 board
    board = List.generate(3, (_) => List.filled(3, ''));

    // Set current player based on who should go first this round
    currentPlayer = firstPlayerStartsNext ? 'O' : 'X';
    aiPlayer = widget.playerSymbol == 'X' ? 'O' : 'X';
    winner = '';
    gameOver = false;

    // If AI goes first in this round, make a move
    if (widget.isAI && currentPlayer == aiPlayer) {
      makeAIMove();
    }
  }

  void makeMove(int row, int col) {
    if (board[row][col] != '' || gameOver) {
      return;
    }

    setState(() {
      board[row][col] = currentPlayer;

      // Check for winner
      if (checkWinner(currentPlayer)) {
        winner = currentPlayer;
        gameOver = true;

        if (winner == widget.playerSymbol) {
          playerScore++;
        } else {
          opponentScore++;
        }
        return;
      }

      // Check for draw
      if (isBoardFull()) {
        gameOver = true;
        winner = 'Draw';
        return;
      }

      // Switch player
      currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
    });

    // Move this outside setState
    if (widget.isAI && currentPlayer == aiPlayer && !gameOver) {
      Future.delayed(const Duration(milliseconds: 500), () {
        makeAIMove();
      });
    }
  }

  void makeAIMove() {
    if (gameOver) return;

    // Simple AI: Look for winning move
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == '') {
          board[i][j] = aiPlayer;
          if (checkWinner(aiPlayer)) {
            setState(() {
              winner = aiPlayer;
              gameOver = true;
              opponentScore++;
            });
            return;
          }
          board[i][j] = '';
        }
      }
    }

    // Block player's winning move
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == '') {
          board[i][j] = widget.playerSymbol;
          if (checkWinner(widget.playerSymbol)) {
            board[i][j] = aiPlayer;
            setState(() {});
            currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
            return;
          }
          board[i][j] = '';
        }
      }
    }

    // Take center if available
    if (board[1][1] == '') {
      board[1][1] = aiPlayer;
      setState(() {});
      currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
      return;
    }

    // Take a random available move
    List<List<int>> availableMoves = [];
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == '') {
          availableMoves.add([i, j]);
        }
      }
    }

    if (availableMoves.isNotEmpty) {
      final random = Random();
      final move = availableMoves[random.nextInt(availableMoves.length)];
      setState(() {
        board[move[0]][move[1]] = aiPlayer;

        if (checkWinner(aiPlayer)) {
          winner = aiPlayer;
          gameOver = true;
          opponentScore++;
          return;
        }

        if (isBoardFull()) {
          gameOver = true;
          winner = 'Draw';
          return;
        }

        currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
      });
    }
  }

  bool checkWinner(String player) {
    // Check rows
    for (int i = 0; i < 3; i++) {
      if (board[i][0] == player &&
          board[i][1] == player &&
          board[i][2] == player) {
        return true;
      }
    }

    // Check columns
    for (int i = 0; i < 3; i++) {
      if (board[0][i] == player &&
          board[1][i] == player &&
          board[2][i] == player) {
        return true;
      }
    }

    // Check diagonals
    if (board[0][0] == player &&
        board[1][1] == player &&
        board[2][2] == player) {
      return true;
    }
    if (board[0][2] == player &&
        board[1][1] == player &&
        board[2][0] == player) {
      return true;
    }

    return false;
  }

  bool isBoardFull() {
    for (var row in board) {
      for (var cell in row) {
        if (cell == '') {
          return false;
        }
      }
    }
    return true;
  }

  void resetGame() {
    setState(() {
      // Toggle who goes first for the next game
      firstPlayerStartsNext = !firstPlayerStartsNext;
      initializeGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Add this to your build method in GameBoardScreen before the score display
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    gameOver 
                        ? (winner != 'Draw' 
                            ? (winner == widget.playerSymbol ? 'You Win!' : 'You Lose!') 
                            : "It's a Draw!")
                        : currentPlayer == widget.playerSymbol 
                            ? 'Your Turn' 
                            : widget.isAI 
                                ? "AI is thinking..." 
                                : "Opponent's Turn",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Score board
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'You',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        // Replace this line
                        color: Colors.white.withValues(red: 255, green: 255, blue: 255, alpha: 0.2),
                        // Alternative method if withValues still has issues
                        // color: Colors.white.withOpacity(0.2), // This works but is deprecated
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$playerScore - $opponentScore',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      widget.isAI ? 'AI' : 'Friend',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Game board
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                        ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      final row = index ~/ 3;
                      final col = index % 3;

                      return GestureDetector(
                        onTap: () {
                          if (!gameOver &&
                              (widget.isAI
                                  ? currentPlayer == widget.playerSymbol
                                  : true)) {
                            makeMove(row, col);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(child: _buildSymbol(board[row][col])),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),

                // Game control buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: resetGame,
                        child: const Text('Restart'),
                      ),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const GameModeScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text('End game'),
                      ),
                    ),
                  ],
                ),

                // Game status text
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    gameOver 
                      ? (winner != 'Draw' 
                        ? (winner == widget.playerSymbol ? 'You Win!' : 'You Lose!') 
                        : "It's a Draw!")
                      : (currentPlayer == widget.playerSymbol ? 'Your Turn' : "Opponent's Turn"),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSymbol(String symbol) {
    if (symbol == 'O') {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.primaryColor, width: 8),
        ),
      );
    } else if (symbol == 'X') {
      return SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          children: [
            Positioned(
              top: 17,
              child: Transform.rotate(
                angle: 45 * 3.14159 / 180,
                child: Container(
                  width: 40,
                  height: 8,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            Positioned(
              top: 17,
              child: Transform.rotate(
                angle: -45 * 3.14159 / 180,
                child: Container(
                  width: 40,
                  height: 8,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Container();
  }
}
