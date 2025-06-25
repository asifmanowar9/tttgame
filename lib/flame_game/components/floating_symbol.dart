import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class FloatingSymbol extends PositionComponent {
  final bool isX;
  final double symbolSize; // Renamed from 'size' to avoid conflict
  final double speed;
  late final Paint _paint;
  late Vector2 _velocity;
  final Random _random = Random();

  FloatingSymbol({
    required this.isX,
    required this.symbolSize, // Renamed parameter
    required Vector2 position,
    required this.speed,
  }) : super(position: position);

  @override
  Future<void> onLoad() async {
    // Set the component size using the Vector2
    size = Vector2.all(symbolSize);

    // Fixed: Replace withOpacity with withValues
    _paint = Paint()
      ..color = Colors.white
          .withValues(
            red: 255,
            green: 255,
            blue: 255,
            alpha: 51,
          ) // 0.2 * 255 = ~51
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Random direction
    final angle = _random.nextDouble() * 2 * pi;
    _velocity = Vector2(cos(angle), sin(angle)) * speed;
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.add(_velocity * dt);

    // Bounce off edges
    final game = findGame()!;
    if (position.x < 0 || position.x > game.size.x) {
      _velocity.x = -_velocity.x;
    }
    if (position.y < 0 || position.y > game.size.y) {
      _velocity.y = -_velocity.y;
    }

    // Keep within bounds
    position.x = position.x.clamp(0, game.size.x);
    position.y = position.y.clamp(0, game.size.y);
  }

  @override
  void render(Canvas canvas) {
    // Instead of using canvas.save(), use the anchor property correctly
    // The anchor is already set to center in the constructor, so we draw relative to center

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
}
