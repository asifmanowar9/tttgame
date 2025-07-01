import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../flame_game/background_game.dart';
// import '../theme/app_theme.dart';
import 'side_selection_screen.dart';

class GameModeScreen extends StatelessWidget {
  const GameModeScreen({super.key});

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
                    'Choose a play mode',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  const SizedBox(height: 60),

                  // With AI button
                  _buildModeButton(
                    context: context,
                    icon: Icons.computer,
                    label: 'Play with AI',
                    isAI: true,
                  ),

                  const SizedBox(height: 20),

                  // With friend button
                  _buildModeButton(
                    context: context,
                    icon: Icons.people,
                    label: 'Play with Friend',
                    isAI: false,
                  ),

                  const SizedBox(height: 40),

                  // Back button
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 30,
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

  Widget _buildModeButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isAI,
  }) {
    return SizedBox(
      width: 240,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 24),
        label: Text(label),
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  SideSelectionScreen(isAI: isAI),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOutCubic;

                    var tween = Tween(
                      begin: begin,
                      end: end,
                    ).chain(CurveTween(curve: curve));

                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        },
      ),
    );
  }
}
