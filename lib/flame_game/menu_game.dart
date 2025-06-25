import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'components/floating_symbol.dart';

class MenuGame extends FlameGame {
  final Random _random = Random();

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

    // Add floating symbols
    for (var i = 0; i < 10; i++) {
      await addFloatingSymbol();
    }
  }

  Future<void> addFloatingSymbol() async {
    final isX = _random.nextBool();
    final size = _random.nextDouble() * 30 + 20;
    final position = Vector2(
      _random.nextDouble() * size,
      _random.nextDouble() * size,
    );
    final speed = _random.nextDouble() * 50 + 20;

    await add(
      FloatingSymbol(
        isX: isX,
        symbolSize: size,
        position: position,
        speed: speed,
      ),
    );
  }
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
