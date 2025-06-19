import 'package:flutter/material.dart';
import 'wave.dart';

class LiquidCustomProgressIndicator extends ProgressIndicator {
  final double? borderWidth;
  final Color? borderColor;
  final Axis direction;
  final CustomClipper<Path>? clipper;

  LiquidCustomProgressIndicator({
    Key? key,
    double value = 0.5,
    Color? backgroundColor,
    Animation<Color>? valueColor,
    this.borderWidth,
    this.borderColor,
    this.direction = Axis.vertical,
    this.clipper,
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
  State<StatefulWidget> createState() => _LiquidCustomProgressIndicatorState();
}

class _LiquidCustomProgressIndicatorState
    extends State<LiquidCustomProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: widget.clipper ?? _DefaultClipper(),
      child: CustomPaint(
        painter: _CustomPainter(
          color: widget._getBackgroundColor(context),
        ),
        foregroundPainter: _CustomBorderPainter(
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

class _DefaultClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _CustomPainter extends CustomPainter {
  final Color color;

  _CustomPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_CustomPainter oldDelegate) => color != oldDelegate.color;
}

class _CustomBorderPainter extends CustomPainter {
  final Color? color;
  final double? width;

  _CustomBorderPainter({this.color, this.width});

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
  bool shouldRepaint(_CustomBorderPainter oldDelegate) =>
      color != oldDelegate.color || width != oldDelegate.width;
} 