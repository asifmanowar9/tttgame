import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/particles.dart';
import 'package:flame/effects.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../screens/game_mode_screen.dart';

// Change to use TapCallbacks instead of mixing TapDetector and HasTappables
class TicTacToeGame extends FlameGame {
  final bool isAI;
  final String playerSymbol;
  final BuildContext context;

  // Game state
  late List<List<String>> board;
  late String currentPlayer;
  late String aiPlayer;
  String winner = '';
  int playerScore = 0;
  int opponentScore = 0;
  bool gameOver = false;
  bool firstPlayerStartsNext = false;

  // Game components
  late BoardComponent boardComponent;
  late ScoreComponent scoreComponent;
  late StatusComponent statusComponent;
  late ButtonsComponent buttonsComponent;

  // AI thinking simulation
  bool aiThinking = false;

  TicTacToeGame({
    required this.isAI,
    required this.playerSymbol,
    required this.context,
  });

  @override
  Future<void> onLoad() async {
    // Add gradient background
    add(
      GradientBackgroundComponent(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
        ),
      ),
    );

    // Initialize game state
    initializeGame();

    // Add game components
    scoreComponent = ScoreComponent(
      playerScore: playerScore,
      opponentScore: opponentScore,
      isAI: isAI,
    );
    add(scoreComponent);

    statusComponent = StatusComponent(
      currentPlayer: currentPlayer,
      playerSymbol: playerSymbol,
      isAI: isAI,
      gameOver: gameOver,
      winner: winner,
    );
    add(statusComponent);

    boardComponent = BoardComponent();
    add(boardComponent);

    buttonsComponent = ButtonsComponent(
      onRestart: resetGame,
      onExit: () {
        // Replace pushAndRemoveUntil with pushReplacement to preserve navigation stack
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const GameModeScreen()),
        );
      },
    );
    add(buttonsComponent);

    // Wait for initial frame to ensure components are properly sized
    await Future.delayed(Duration.zero);

    // If AI starts first
    if (isAI && currentPlayer == aiPlayer) {
      aiThinking = true;
      await Future.delayed(const Duration(milliseconds: 1000));
      makeAIMove();
    }
  }

  void initializeGame() {
    // Initialize 3x3 board
    board = List.generate(3, (_) => List.filled(3, ''));

    // Set current player based on who should go first this round
    currentPlayer = firstPlayerStartsNext ? 'O' : 'X';
    aiPlayer = playerSymbol == 'X' ? 'O' : 'X';
    winner = '';
    gameOver = false;
    aiThinking = false;
  }

  void makeMove(int row, int col) {
    if (board[row][col] != '' || gameOver || aiThinking) {
      return;
    }

    // Apply move with animation
    boardComponent.placeSymbol(row, col, currentPlayer);
    HapticFeedback.lightImpact();

    board[row][col] = currentPlayer;

    // Check for winner
    if (checkWinner(currentPlayer)) {
      winner = currentPlayer;
      gameOver = true;

      if (winner == playerSymbol) {
        playerScore++;
      } else {
        opponentScore++;
      }

      statusComponent.updateState(
        currentPlayer: currentPlayer,
        gameOver: gameOver,
        winner: winner,
      );

      scoreComponent.updateScore(playerScore, opponentScore);
      boardComponent.highlightWin(getWinningLine());
      return;
    }

    // Check for draw
    if (isBoardFull()) {
      gameOver = true;
      winner = 'Draw';
      statusComponent.updateState(
        currentPlayer: currentPlayer,
        gameOver: gameOver,
        winner: winner,
      );

      // Toggle who goes first for the next game (same as in resetGame)
      firstPlayerStartsNext = !firstPlayerStartsNext;

      // Add auto-reset on draw without updating score
      Future.delayed(const Duration(milliseconds: 1200), () {
        boardComponent.resetBoard();
        initializeGame();
        statusComponent.updateState(
          currentPlayer: currentPlayer,
          gameOver: false,
          winner: '',
        );

        // If AI should start first in the new game, make AI move
        if (isAI && currentPlayer == aiPlayer) {
          aiThinking = true;
          Future.delayed(const Duration(milliseconds: 500), () {
            makeAIMove();
          });
        }
      });
      return;
    }

    // Switch player
    currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
    statusComponent.updateState(currentPlayer: currentPlayer);

    // AI's turn
    if (isAI && currentPlayer == aiPlayer && !gameOver) {
      aiThinking = true;
      Future.delayed(const Duration(milliseconds: 800), () {
        makeAIMove();
      });
    }
  }

  void makeAIMove() {
    if (gameOver) return;
    aiThinking = true;

    // Add a small delay to fix potential positioning issues
    Future.delayed(const Duration(milliseconds: 200), () {
      // Simple AI: Look for winning move
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (board[i][j] == '') {
            board[i][j] = aiPlayer;
            if (checkWinner(aiPlayer)) {
              boardComponent.placeSymbol(i, j, aiPlayer);
              winner = aiPlayer;
              gameOver = true;
              opponentScore++;
              scoreComponent.updateScore(playerScore, opponentScore);
              statusComponent.updateState(
                currentPlayer: aiPlayer,
                gameOver: gameOver,
                winner: winner,
              );
              boardComponent.highlightWin(getWinningLine());
              aiThinking = false;
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
            board[i][j] = playerSymbol;
            if (checkWinner(playerSymbol)) {
              board[i][j] = aiPlayer;
              boardComponent.placeSymbol(i, j, aiPlayer);
              currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
              statusComponent.updateState(currentPlayer: currentPlayer);
              aiThinking = false;
              return;
            }
            board[i][j] = '';
          }
        }
      }

      // Take center if available
      if (board[1][1] == '') {
        board[1][1] = aiPlayer;
        boardComponent.placeSymbol(1, 1, aiPlayer);
        currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
        statusComponent.updateState(currentPlayer: currentPlayer);
        aiThinking = false;
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
        board[move[0]][move[1]] = aiPlayer;
        boardComponent.placeSymbol(move[0], move[1], aiPlayer);

        if (checkWinner(aiPlayer)) {
          winner = aiPlayer;
          gameOver = true;
          opponentScore++;
          scoreComponent.updateScore(playerScore, opponentScore);
          statusComponent.updateState(
            currentPlayer: aiPlayer,
            gameOver: gameOver,
            winner: winner,
          );
          boardComponent.highlightWin(getWinningLine());
          aiThinking = false;
          return;
        }

        if (isBoardFull()) {
          gameOver = true;
          winner = 'Draw';
          statusComponent.updateState(
            currentPlayer: currentPlayer,
            gameOver: gameOver,
            winner: winner,
          );

          // Toggle who goes first for the next game (same as in resetGame)
          firstPlayerStartsNext = !firstPlayerStartsNext;

          // Add auto-reset on draw without updating score
          Future.delayed(const Duration(milliseconds: 1200), () {
            boardComponent.resetBoard();
            initializeGame();
            statusComponent.updateState(
              currentPlayer: currentPlayer,
              gameOver: false,
              winner: '',
            );

            // If AI should start first in the new game, make AI move
            if (isAI && currentPlayer == aiPlayer) {
              aiThinking = true;
              Future.delayed(const Duration(milliseconds: 500), () {
                makeAIMove();
              });
            }
          });
          aiThinking = false;
          return;
        }

        currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
        statusComponent.updateState(currentPlayer: currentPlayer);
      }

      aiThinking = false;
    });
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

  List<List<int>> getWinningLine() {
    for (int i = 0; i < 3; i++) {
      // Fix missing bracket and correctly check rows
      if (board[i][0] != '' &&
          board[i][0] == board[i][1] &&
          board[i][1] == board[i][2]) {
        return [
          [i, 0],
          [i, 1],
          [i, 2],
        ];
      }

      // Check columns
      if (board[0][i] != '' &&
          board[0][i] == board[1][i] &&
          board[1][i] == board[2][i]) {
        return [
          [0, i],
          [1, i],
          [2, i],
        ];
      }
    }

    // Rest of the method remains unchanged
    if (board[0][0] != '' &&
        board[0][0] == board[1][1] &&
        board[1][1] == board[2][2]) {
      return [
        [0, 0],
        [1, 1],
        [2, 2],
      ];
    }

    if (board[0][2] != '' &&
        board[0][2] == board[1][1] &&
        board[1][1] == board[2][0]) {
      return [
        [0, 2],
        [1, 1],
        [2, 0],
      ];
    }

    return [];
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
    // Toggle who goes first for the next game
    firstPlayerStartsNext = !firstPlayerStartsNext;

    // Reset the game state and board
    initializeGame();
    boardComponent.resetBoard();

    // Update UI components
    statusComponent.updateState(
      currentPlayer: currentPlayer,
      gameOver: gameOver,
      winner: winner,
    );

    // If AI starts first in the new game, give components time to update
    if (isAI && currentPlayer == aiPlayer) {
      aiThinking = true;
      // Use a slightly longer delay to ensure everything is ready
      Future.delayed(const Duration(milliseconds: 1200), () {
        makeAIMove();
      });
    }
  }

  // Replace onTapDown with a tap handler on the board component
  void handleBoardTap(Vector2 position) {
    // Only handle taps if it's the player's turn, not AI thinking, and game not over
    if (!gameOver &&
        !aiThinking &&
        (isAI ? currentPlayer == playerSymbol : true)) {
      final cellSize = boardComponent.cellSize;
      // Calculate board position
      final boardPosition = position - boardComponent.position;

      final col = (boardPosition.x / cellSize).floor();
      final row = (boardPosition.y / cellSize).floor();

      if (row >= 0 && row < 3 && col >= 0 && col < 3) {
        makeMove(row, col);
      }
    }
  }
}

// Update BoardComponent to handle taps directly
class BoardComponent extends PositionComponent with TapCallbacks {
  static const double relativeSize = 0.8; // Board takes 80% of screen width
  double cellSize =
      100; // Initialize with a default value instead of using 'late'
  final Paint _boardPaint = Paint()
    ..color = AppTheme.boardColor
    ..style = PaintingStyle.fill;

  final Paint _gridPaint = Paint()
    ..color = Colors.white.withValues(
      red: 255,
      green: 255,
      blue: 255,
      alpha: 76,
    )
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  final List<List<SymbolComponent?>> symbols = List.generate(
    3,
    (_) => List.filled(3, null),
  );

  @override
  bool onTapDown(TapDownEvent event) {
    final game = findGame()!;
    game.handleBoardTap(event.canvasPosition);
    return true;
  }

  @override
  TicTacToeGame? findGame() {
    Component? component = parent;
    while (component != null) {
      if (component is TicTacToeGame) {
        return component;
      }
      component = component.parent;
    }
    return null;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    // Calculate board size based on screen width
    final boardSize = size.x * relativeSize;
    cellSize = boardSize / 3;
    this.size = Vector2(boardSize, boardSize);

    // Center the board horizontally and position it vertically
    position = Vector2(
      (size.x - this.size.x) / 2,
      size.y * 0.35, // Position at 40% from top
    );
  }

  @override
  void render(Canvas canvas) {
    // Draw board background
    final boardRect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect, const Radius.circular(10)),
      _boardPaint,
    );

    // Draw grid lines
    for (int i = 1; i < 3; i++) {
      // Vertical lines
      canvas.drawLine(
        Offset(i * cellSize, 0),
        Offset(i * cellSize, size.y),
        _gridPaint,
      );

      // Horizontal lines
      canvas.drawLine(
        Offset(0, i * cellSize),
        Offset(size.x, i * cellSize),
        _gridPaint,
      );
    }
  }

  void placeSymbol(int row, int col, String symbol) {
    // Remove existing symbol if any
    if (symbols[row][col] != null) {
      symbols[row][col]!.removeFromParent();
    }

    // Calculate position for the symbol
    final symbolPosition = Vector2(
      col * cellSize + cellSize / 2, // Center horizontally
      row * cellSize +
          cellSize / 2, // Center vertically - ensure this is correct
    );

    // Create and add the new symbol
    final symbolComponent = SymbolComponent(
      symbol: symbol,
      size: cellSize * 0.8,
    );

    // Important: Set the anchor to center BEFORE setting position
    symbolComponent.anchor = Anchor.center;
    symbolComponent.position = symbolPosition;

    // Add with animation
    symbolComponent.scale = Vector2.zero();
    symbolComponent.add(
      ScaleEffect.to(
        Vector2.all(1.0),
        EffectController(duration: 0.3, curve: Curves.elasticOut),
      ),
    );

    symbols[row][col] = symbolComponent;
    add(symbolComponent);

    // Add particle effects at the correct position
    add(
      ParticleSystemComponent(
        position: symbolPosition,
        particle: Particle.generate(
          count: 20,
          lifespan: 0.8,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, 50),
            speed: Vector2(
              Random().nextDouble() * 100 - 50,
              Random().nextDouble() * -50 - 50,
            ),
            position: Vector2.zero(),
            child: CircleParticle(
              radius: Random().nextDouble() * 3 + 1,
              paint: Paint()
                ..color = symbol == 'X'
                    ? Colors.white.withValues(
                        red: 255,
                        green: 255,
                        blue: 255,
                        alpha: 76,
                      )
                    : AppTheme.oColor.withValues(
                        red: 255,
                        green: 255,
                        blue: 255,
                        alpha: 76,
                      ),
            ),
          ),
        ),
      ),
    );
  }

  void highlightWin(List<List<int>> winningLine) {
    // Highlight winning cells with animation
    for (final cell in winningLine) {
      final row = cell[0];
      final col = cell[1];

      if (symbols[row][col] != null) {
        symbols[row][col]!.add(
          SequenceEffect([
            ScaleEffect.to(
              Vector2.all(1.2),
              EffectController(duration: 0.3, curve: Curves.easeOut),
            ),
            ScaleEffect.to(
              Vector2.all(1.0),
              EffectController(duration: 0.3, curve: Curves.easeIn),
            ),
          ], infinite: true),
        );
      }
    }
  }

  void resetBoard() {
    // Clear all symbols
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (symbols[i][j] != null) {
          final symbolToRemove = symbols[i][j]!;
          symbolToRemove.add(
            ScaleEffect.to(
              Vector2.zero(),
              EffectController(duration: 0.2, curve: Curves.easeIn),
              onComplete: () {
                // Store this in a local variable to avoid the null check issue
                symbolToRemove.removeFromParent();
              },
            ),
          );
          symbols[i][j] = null;
        }
      }
    }
  }

  @override
  Rect toRect() {
    return Rect.fromLTWH(position.x, position.y, size.x, size.y);
  }

  @override
  double get width => size.x;

  @override
  double get height => size.y;
}

class GradientBackgroundComponent extends PositionComponent {
  final LinearGradient gradient;

  GradientBackgroundComponent({required this.gradient});

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }
}

class SymbolComponent extends PositionComponent with HasGameReference {
  final String symbol;
  final double symbolSize;
  late final Paint _paint;

  SymbolComponent({required this.symbol, required double size})
    : symbolSize = size,
      super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2(symbolSize, symbolSize);

    _paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = symbolSize / 10;
  }

  @override
  void render(Canvas canvas) {
    if (symbol == 'X') {
      // Draw X with proper centering
      final margin = symbolSize / 8;

      // Save and translate canvas to center the drawing operations
      canvas.save();
      canvas.translate(symbolSize / 2, symbolSize / 2);

      canvas.drawLine(
        Offset(-symbolSize / 2 + margin, -symbolSize / 2 + margin),
        Offset(symbolSize / 2 - margin, symbolSize / 2 - margin),
        _paint,
      );
      canvas.drawLine(
        Offset(symbolSize / 2 - margin, -symbolSize / 2 + margin),
        Offset(-symbolSize / 2 + margin, symbolSize / 2 - margin),
        _paint,
      );

      canvas.restore();
    } else {
      // Draw O centered perfectly
      canvas.save();
      canvas.translate(symbolSize / 2, symbolSize / 2);

      canvas.drawCircle(
        Offset.zero,
        symbolSize * 0.35, // Make circle slightly smaller for better appearance
        _paint,
      );

      canvas.restore();
    }
  }
}

class ScoreComponent extends PositionComponent with HasGameReference {
  int playerScore;
  int opponentScore;
  final bool isAI;
  late TextComponent scoreText;
  late TextComponent playerLabel;
  late TextComponent opponentLabel;
  late RectangleComponent scoreBackground;

  ScoreComponent({
    required this.playerScore,
    required this.opponentScore,
    required this.isAI,
  });

  @override
  Future<void> onLoad() async {
    // Add a more visible background for the score
    scoreBackground = RectangleComponent(
      size: Vector2(300, 50), // Made it slightly larger
      position: Vector2(-150, -25),
      paint: Paint()
        ..color = Colors.black.withOpacity(0.3), // More visible background
      cornerRadius: 25,
    );
    add(scoreBackground);

    playerLabel = TextComponent(
      text: 'You',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20, // Increased font size
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black54),
          ],
        ),
      ),
      anchor: Anchor.center,
    );
    add(playerLabel);

    scoreText = TextComponent(
      text: '$playerScore - $opponentScore',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28, // Increased font size
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black54),
          ],
        ),
      ),
      anchor: Anchor.center,
    );
    add(scoreText);

    opponentLabel = TextComponent(
      text: isAI ? 'AI' : 'Friend',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20, // Increased font size
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black54),
          ],
        ),
      ),
      anchor: Anchor.center,
    );
    add(opponentLabel);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    position = Vector2(size.x / 2, size.y * 0.15);

    // Position the components
    playerLabel.position = Vector2(-120, 0);
    scoreText.position = Vector2(0, 0);
    opponentLabel.position = Vector2(120, 0);
  }

  void updateScore(int player, int opponent) {
    playerScore = player;
    opponentScore = opponent;
    scoreText.text = '$playerScore - $opponentScore';

    // Add a scale effect to the background instead of color effect
    scoreBackground.add(
      SequenceEffect([
        ScaleEffect.to(
          Vector2.all(1.1),
          EffectController(duration: 0.3, curve: Curves.easeOut),
        ),
        ScaleEffect.to(
          Vector2.all(1.0),
          EffectController(duration: 0.3, curve: Curves.easeIn),
        ),
      ]),
    );

    // Add pulsating animation to the score
    scoreText.add(
      SequenceEffect([
        ScaleEffect.to(
          Vector2.all(1.3),
          EffectController(duration: 0.2, curve: Curves.easeOut),
        ),
        ScaleEffect.to(
          Vector2.all(1.0),
          EffectController(duration: 0.2, curve: Curves.easeIn),
        ),
      ]),
    );
  }
}

class StatusComponent extends TextComponent with HasGameReference {
  String currentPlayer;
  final String playerSymbol;
  final bool isAI;
  bool gameOver;
  String winner;

  StatusComponent({
    required this.currentPlayer,
    required this.playerSymbol,
    required this.isAI,
    required this.gameOver,
    required this.winner,
  }) : super(
         text: '',
         textRenderer: TextPaint(
           style: const TextStyle(
             color: Colors.white,
             fontSize: 18,
             fontWeight: FontWeight.bold,
           ),
         ),
         anchor: Anchor.center,
       );

  @override
  Future<void> onLoad() async {
    updateState(
      currentPlayer: currentPlayer,
      gameOver: gameOver,
      winner: winner,
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    position = Vector2(size.x / 2, size.y * 0.3);
  }

  void updateState({String? currentPlayer, bool? gameOver, String? winner}) {
    this.currentPlayer = currentPlayer ?? this.currentPlayer;
    this.gameOver = gameOver ?? this.gameOver;
    this.winner = winner ?? this.winner;

    if (this.gameOver) {
      if (this.winner != 'Draw') {
        text = this.winner == playerSymbol ? 'You Win!' : 'You Lose!';
      } else {
        text = "It's a Draw!";
      }
    } else {
      text = this.currentPlayer == playerSymbol
          ? 'Your Turn'
          : isAI
          ? "AI is thinking..."
          : "Opponent's Turn ";
    }

    // Add animation when text changes
    add(
      SequenceEffect([
        ScaleEffect.to(
          Vector2.all(1.2),
          EffectController(duration: 0.2, curve: Curves.easeOut),
        ),
        ScaleEffect.to(
          Vector2.all(1.0),
          EffectController(duration: 0.2, curve: Curves.easeIn),
        ),
      ]),
    );
  }
}

class ButtonsComponent extends PositionComponent
    with HasGameReference, TapCallbacks {
  final VoidCallback onRestart;
  final VoidCallback onExit;
  late ButtonComponent restartButton;
  late ButtonComponent exitButton;

  ButtonsComponent({required this.onRestart, required this.onExit});

  @override
  Future<void> onLoad() async {
    // Create more stylish Restart button
    restartButton = ButtonComponent(
      text: 'Restart',
      onPressed: onRestart,
      width: 140,
      height: 55,
      color: Colors.white,
      textColor: AppTheme.primaryColor,
      borderRadius: 25,
      shadowOffset: 4,
    );
    add(restartButton);

    // Create more stylish Exit button
    exitButton = ButtonComponent(
      text: 'Exit',
      onPressed: onExit,
      width: 140,
      height: 55,
      color: Colors.white,
      textColor: AppTheme.primaryColor,
      borderRadius: 25,
      shadowOffset: 4,
    );
    add(exitButton);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Position buttons at 90% of screen height
    position = Vector2(size.x / 2, size.y * 0.9);

    // Adjust button positions to be more centered and visible
    // Reduce the spacing and move them slightly right
    restartButton.position = Vector2(-25, 0); // Changed from -100 to -25
    exitButton.position = Vector2(160, 0); // Changed from 100 to 160
  }
}

class ButtonComponent extends PositionComponent
    with HasGameReference, TapCallbacks {
  final String text;
  final VoidCallback onPressed;
  @override
  final double width;
  @override
  final double height;
  final Color color;
  final Color textColor;
  final double borderRadius;
  final double shadowOffset;
  late final TextComponent textComponent;
  bool isPressed = false;

  ButtonComponent({
    required this.text,
    required this.onPressed,
    this.width = 140,
    this.height = 55,
    this.color = Colors.white,
    this.textColor = AppTheme.primaryColor,
    this.borderRadius = 25,
    this.shadowOffset = 4,
  }) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    size = Vector2(width, height);

    textComponent = TextComponent(
      text: text,
      textRenderer: TextPaint(
        style: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
    );
    add(textComponent);
  }

  @override
  void render(Canvas canvas) {
    // Draw shadow first
    if (!isPressed) {
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 40)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-width / 2, -height / 2 + shadowOffset, width, height),
          Radius.circular(borderRadius),
        ),
        shadowPaint,
      );
    }

    // Draw button
    final buttonPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          -width / 2,
          -height / 2 + (isPressed ? 2 : 0),
          width,
          height,
        ),
        Radius.circular(borderRadius),
      ),
      buttonPaint,
    );

    // Add a subtle border
    final borderPaint = Paint()
      ..color = AppTheme.primaryColor.withValues(
        red: AppTheme.primaryColor.red.toDouble(),
        green: AppTheme.primaryColor.green.toDouble(),
        blue: AppTheme.primaryColor.blue.toDouble(),
        alpha: 50,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          -width / 2,
          -height / 2 + (isPressed ? 2 : 0),
          width,
          height,
        ),
        Radius.circular(borderRadius),
      ),
      borderPaint,
    );
  }

  // Ensure the hitbox is properly sized
  @override
  void onMount() {
    super.onMount();
    // Ensure the component has a properly sized hitbox
    final hitbox = RectangleHitbox(
      size: Vector2(width, height),
      position: Vector2(-width / 2, -height / 2),
    );
    add(hitbox);
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    // Implement a more reliable check for taps
    final localX = point.x;
    final localY = point.y;
    return localX >= -width / 2 &&
        localX <= width / 2 &&
        localY >= -height / 2 &&
        localY <= height / 2;
  }

  @override
  bool onTapDown(TapDownEvent event) {
    isPressed = true;
    scale = Vector2.all(0.95);
    return true;
  }

  @override
  bool onTapUp(TapUpEvent event) {
    isPressed = false;
    scale = Vector2.all(1.0);
    onPressed();
    return true;
  }

  @override
  bool onTapCancel(TapCancelEvent event) {
    isPressed = false;
    scale = Vector2.all(1.0);
    return true;
  }
}

class RectangleComponent extends PositionComponent {
  final Paint paint;
  final double cornerRadius;

  RectangleComponent({
    required Vector2 position,
    required Vector2 size,
    required this.paint,
    this.cornerRadius = 0,
  }) : super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Radius.circular(cornerRadius),
      ),
      paint,
    );
  }
}
