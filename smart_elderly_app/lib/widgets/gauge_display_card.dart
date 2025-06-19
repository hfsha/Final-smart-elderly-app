import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

//GaugeDisplayCard is a widget that displays a radial gauge with a label, current value, and unit.
class GaugeDisplayCard extends StatelessWidget {
  final String label;
  final double currentValue;
  final String unit;
  final double minValue;
  final double maxValue;

  const GaugeDisplayCard({
    super.key,
    required this.label,
    required this.currentValue,
    required this.unit,
    required this.minValue,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.10),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 110,
                child: SfRadialGauge(
                  axes: <RadialAxis>[
                    RadialAxis(
                      minimum: minValue,
                      maximum: maxValue,
                      startAngle: 180,
                      endAngle: 0,
                      showTicks: false,
                      showLabels: false,
                      axisLineStyle: AxisLineStyle(
                        thickness: 0.20,
                        thicknessUnit: GaugeSizeUnit.factor,
                        cornerStyle: CornerStyle.bothCurve,
                        gradient: SweepGradient(
                          colors: const [
                            Color(0xFFFFB300), // yellow
                            Color(0xFFFF5252), // red
                            Color(0xFFAB47BC), // purple
                            Color(0xFF42A5F5), // blue
                            Color(0xFF00E5FF), // cyan
                          ],
                          stops: const [0.0, 0.3, 0.6, 0.8, 1.0],
                        ),
                      ),
                      pointers: <GaugePointer>[
                        NeedlePointer(
                          value: currentValue,
                          needleColor: Colors.white,
                          needleLength: 0.8,
                          lengthUnit: GaugeSizeUnit.factor,
                          needleStartWidth: 0,
                          needleEndWidth: 6,
                          knobStyle: KnobStyle(
                            color: Colors.white.withOpacity(0.7),
                            borderColor: Colors.blueAccent.withOpacity(0.5),
                            borderWidth: 2,
                            sizeUnit: GaugeSizeUnit.factor,
                            knobRadius: 0.09,
                          ),
                          tailStyle: TailStyle(
                            length: 0.18,
                            width: 6,
                            color: Colors.blueAccent.withOpacity(0.5),
                            lengthUnit: GaugeSizeUnit.factor,
                          ),
                          enableAnimation: true,
                          animationType: AnimationType.easeOutBack,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF42A5F5), Color(0xFFAB47BC)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ],
                      annotations: const <GaugeAnnotation>[], // No annotation here
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.10),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 1.2,
                    ),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        currentValue.toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: Colors.black,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        unit,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 19,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
