import 'package:flutter/material.dart';
import 'wave.dart';

class LiquidLinearProgressIndicator extends ProgressIndicator {
  final double? borderWidth;
  final Color? borderColor;
  final Axis direction;
  final BorderRadius? borderRadius;

  LiquidLinearProgressIndicator({
    Key? key,
    double value = 0.5,
    Color? backgroundColor,
    Animation<Color>? valueColor,
    this.borderWidth,
    this.borderColor,
    this.direction = Axis.horizontal,
    this.borderRadius,
  }) : super(
          key: key,
          value: value,
          backgroundColor: backgroundColor,
          valueColor: valueColor,
        ) {
    if (borderWidth != null && borderColor == null ||
        borderColor != null && borderWidth == null) {
      throw ArgumentError("borderWidth and borderColor should both be set.");
    }
  }

  Color _getBackgroundColor(BuildContext context) =>
      backgroundColor ?? Theme.of(context).colorScheme.surface;

  Color _getValueColor(BuildContext context) =>
      valueColor?.value ?? Theme.of(context).colorScheme.secondary;

  @override
  State<StatefulWidget> createState() => _LiquidLinearProgressIndicatorState();
}

class _LiquidLinearProgressIndicatorState
    extends State<LiquidLinearProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: CustomPaint(
        painter: _LinearPainter(
          color: widget._getBackgroundColor(context),
        ),
        foregroundPainter: _LinearBorderPainter(
          color: widget.borderColor,
          width: widget.borderWidth,
        ),
        child: Stack(
          children: [
            Wave(
              value: widget.value ?? 0.0,
              color: widget._getValueColor(context),
              direction: widget.direction,
            ),
          ],
        ),
      ),
    );
  }
}

class _LinearPainter extends CustomPainter {
  final Color color;

  _LinearPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_LinearPainter oldDelegate) => color != oldDelegate.color;
}

class _LinearBorderPainter extends CustomPainter {
  final Color? color;
  final double? width;

  _LinearBorderPainter({this.color, this.width});

  @override
  void paint(Canvas canvas, Size size) {
    if (color == null || width == null) {
      return;
    }

    final borderPaint = Paint()
      ..color = color!
      ..style = PaintingStyle.stroke
      ..strokeWidth = width!;
    final newSize = Size(size.width - width!, size.height - width!);
    canvas.drawRect(
        Offset(width! / 2, width! / 2) & newSize, borderPaint);
  }

  @override
  bool shouldRepaint(_LinearBorderPainter oldDelegate) =>
      color != oldDelegate.color || width != oldDelegate.width;
} 