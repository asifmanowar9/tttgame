import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BackgroundGame extends FlameGame {
  final Random _random = Random();
  final _spawnInterval = 2.0; // Spawn a particle every 2 seconds
  double _timeSinceLastSpawn = 0.0;

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
  }

  @override
  void update(double dt) {
    super.update(dt);

    _timeSinceLastSpawn += dt;
    if (_timeSinceLastSpawn >= _spawnInterval) {
      _addParticle();
      _timeSinceLastSpawn = 0.0;
    }
  }

  void _addParticle() {
    final startPosition = Vector2(
      _random.nextDouble() * size.x,
      _random.nextDouble() * size.y,
    );

    final isX = _random.nextBool();
    final particleSize = _random.nextDouble() * 20 + 10;

    // Create and add the SymbolComponent directly instead of using ParticleSystemComponent
    add(
      SymbolComponent(
        isX: isX,
        size: particleSize,
        position: startPosition,
        endPosition: Vector2(
          startPosition.x + _random.nextDouble() * 100 - 50,
          startPosition.y + _random.nextDouble() * 100 - 50,
        ),
        lifespan: 5.0,
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
    // Fixed: Changed parameter name from 'gameSize' to 'size' to match the override
    super.onGameResize(size);
    this.size = size;
  }
}

// Replace MovingParticle with SymbolComponent which extends PositionComponent
class SymbolComponent extends PositionComponent {
  final bool isX;
  final double symbolSize; // Renamed from 'size' to avoid conflict
  final Vector2 endPosition;
  final double lifespan;

  late final Paint _paint;
  double _elapsedTime = 0.0;

  SymbolComponent({
    required this.isX,
    required double size, // Keep parameter name for backward compatibility
    required Vector2 position,
    required this.endPosition,
    required this.lifespan,
  }) : symbolSize = size, // Assign to the renamed field
       super(position: position);

  @override
  Future<void> onLoad() async {
    // Set the component size using the Vector2
    size = Vector2.all(symbolSize);

    _paint = Paint()
      ..color = Colors.white
          .withValues(
            red: 255,
            green: 255,
            blue: 255,
            alpha: 76,
          ) // Fixed: 0.3 * 255 = ~76
      ..style = isX ? PaintingStyle.stroke : PaintingStyle.fill
      ..strokeWidth = 2;
  }

  @override
  void render(Canvas canvas) {
    if (isX) {
      // Draw X
      canvas.drawLine(
        Offset(-symbolSize / 2, -symbolSize / 2),
        Offset(symbolSize / 2, symbolSize / 2),
        _paint,
      );
      canvas.drawLine(
        Offset(symbolSize / 2, -symbolSize / 2),
        Offset(-symbolSize / 2, symbolSize / 2),
        _paint,
      );
    } else {
      // Draw O
      canvas.drawCircle(Offset.zero, symbolSize / 2, _paint);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    _elapsedTime += dt;

    if (_elapsedTime >= lifespan) {
      removeFromParent();
      return;
    }

    // Calculate progress (0.0 to 1.0)
    final progress = _elapsedTime / lifespan;

    // Movement with easing
    final easeProgress = Curves.easeInOutCubic.transform(progress);
    position.x = lerpDouble(position.x, endPosition.x, easeProgress * dt * 2);
    position.y = lerpDouble(position.y, endPosition.y, easeProgress * dt * 2);

    // Fade out towards end
    final opacity =
        (0.3 * (1.0 - progress)) * 255; // Calculate alpha value (0-255)
    _paint.color = Colors.white.withValues(
      red: 255,
      green: 255,
      blue: 255,
      alpha: opacity,
    ); // Fixed: Using withValues instead of withOpacity
  }
}

// Helper function
double lerpDouble(double a, double b, double t) {
  return a + (b - a) * t;
}
