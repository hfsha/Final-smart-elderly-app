import 'dart:math' as math;
import 'package:flutter/material.dart';

class Wave extends StatefulWidget {
  final double value;
  final Color color;
  final Axis direction;

  const Wave({
    Key? key,
    required this.value,
    required this.color,
    this.direction = Axis.vertical,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WaveState();
}

class _WaveState extends State<Wave> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 2 * math.pi).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _WavePainter(
            animation: _animation.value,
            value: widget.value,
            color: widget.color,
            direction: widget.direction,
          ),
          child: Container(),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final double animation;
  final double value;
  final Color color;
  final Axis direction;

  _WavePainter({
    required this.animation,
    required this.value,
    required this.color,
    required this.direction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final height = size.height;
    final width = size.width;
    final mid = direction == Axis.vertical ? height * (1 - value) : width * value;
    final waveHeight = height * 0.05;
    final waveWidth = width * 0.1;

    if (direction == Axis.vertical) {
      path.moveTo(0, height);
      for (double i = 0; i <= width; i++) {
        path.lineTo(
          i,
          mid + math.sin((i / waveWidth) + animation) * waveHeight,
        );
      }
      path.lineTo(width, height);
      path.close();
    } else {
      path.moveTo(width, 0);
      for (double i = 0; i <= height; i++) {
        path.lineTo(
          mid + math.sin((i / waveHeight) + animation) * waveWidth,
          i,
        );
      }
      path.lineTo(width, height);
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) =>
      animation != oldDelegate.animation ||
      value != oldDelegate.value ||
      color != oldDelegate.color ||
      direction != oldDelegate.direction;
} 