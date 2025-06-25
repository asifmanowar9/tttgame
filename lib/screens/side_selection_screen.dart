import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../flame_game/background_game.dart';
import '../flame_game/tic_tac_toe_game.dart';
import '../theme/app_theme.dart';

class SideSelectionScreen extends StatefulWidget {
  final bool isAI;

  const SideSelectionScreen({super.key, required this.isAI});

  @override
  State<SideSelectionScreen> createState() => _SideSelectionScreenState();
}

class _SideSelectionScreenState extends State<SideSelectionScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedSide;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Flame game for particles
          GameWidget(game: BackgroundGame()),

          // UI Layer
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Choose your side',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  const SizedBox(height: 60),

                  // Symbols selection row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // X selection
                      _buildSymbolSelection(
                        isX: true,
                        isSelected: _selectedSide == 'X',
                      ),

                      const SizedBox(width: 40),

                      // O selection
                      _buildSymbolSelection(
                        isX: false,
                        isSelected: _selectedSide == 'O',
                      ),
                    ],
                  ),

                  const SizedBox(height: 60),

                  // Start game button
                  SizedBox(
                    width: 220,
                    child: ElevatedButton(
                      onPressed: _selectedSide != null
                          ? () => _startGame(context)
                          : null,
                      child: const Text('Start Game'),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Back button
                  TextButton.icon(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: const Text(
                      'Back',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymbolSelection({required bool isX, required bool isSelected}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSide = isX ? 'X' : 'O';
        });

        // Play animation
        if (isSelected) {
          _animationController.reverse();
        } else {
          _animationController.forward();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        width: isSelected ? 100 : 80,
        height: isSelected ? 100 : 80,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withAlpha(100),
          borderRadius: BorderRadius.circular(isX ? 16 : 50),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(
                      red: 0,
                      green: 0,
                      blue: 0,
                      alpha: 51, // 0.2 * 255 = ~51
                    ),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isX
              ? _buildCross(
                  size: isSelected ? 70 : 50,
                  thickness: isSelected ? 15 : 10,
                  color: AppTheme.primaryColor,
                )
              : Container(
                  width: isSelected ? 70 : 50,
                  height: isSelected ? 70 : 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryColor,
                      width: isSelected ? 15 : 10,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildCross({
    required double size,
    required double thickness,
    required Color color,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(
            top: (size - thickness) / 2,
            child: Transform.rotate(
              angle: 45 * 3.14159 / 180,
              child: Container(width: size, height: thickness, color: color),
            ),
          ),
          Positioned(
            top: (size - thickness) / 2,
            child: Transform.rotate(
              angle: -45 * 3.14159 / 180,
              child: Container(width: size, height: thickness, color: color),
            ),
          ),
        ],
      ),
    );
  }

  void _startGame(BuildContext context) {
    // Default to X if somehow nothing is selected
    final playerSymbol = _selectedSide ?? 'X';

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            GameScreen(isAI: widget.isAI, playerSymbol: playerSymbol),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  final bool isAI;
  final String playerSymbol;

  const GameScreen({super.key, required this.isAI, required this.playerSymbol});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: TicTacToeGame(
          isAI: isAI,
          playerSymbol: playerSymbol,
          context: context,
        ),
      ),
    );
  }
}
