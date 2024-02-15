import 'package:example/helpers.dart';
import 'package:flutter/material.dart';

import 'package:flutter_custom_charts/flutter_custom_charts.dart';

class _Example2MockSegment {
  const _Example2MockSegment({
    required this.zone,
    required this.xMin,
    required this.xMax,
    required this.duration,
  });
  final int zone;
  final double xMin;
  final double xMax;
  final Duration duration;

  @override
  String toString() {
    return '_Ex2MockSegment(zone: $zone, xMin: $xMin, xMax: $xMax, duration: $duration)';
  }
}

class _MyCustomBar extends Bar {
  _MyCustomBar({
    required this.detailsBelowCircleFill,
    required this.detailsBelowCircleStroke,
    required super.primaryAxisMin,
    required super.primaryAxisMax,
    required super.secondaryAxisMax,
    super.secondaryAxisMin = 0,
    super.fill = Colors.blue,
    super.stroke,
    super.lines = const [],
    super.detailsAbove,
    super.detailsBelow,
  }) : super();

  final Color detailsBelowCircleFill;
  final Color detailsBelowCircleStroke;

  @override
  void paintDetailsBelow(
    Canvas canvas, {
    required ConstrainedArea constraints,
    required BarDetails details,
  }) {
    if (details.text != null) {
      final text = details.text!;
      final tp = TextPainter(
        text: TextSpan(
          text: text.text,
          style: text.style,
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: constraints.width);

      final center = constraints.center();
      final x = center.dx - (tp.width / 2);
      final y = center.dy - (tp.height / 2);

      final circleFillPaint = Paint()
        ..color = detailsBelowCircleFill
        ..style = PaintingStyle.fill;
      final circleStrokePaint = Paint()
        ..color = detailsBelowCircleStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawCircle(center, 20, circleFillPaint);
      canvas.drawCircle(center, 20, circleStrokePaint);
      tp.paint(canvas, Offset(x, y));
    }
  }
}

class Example2 extends StatefulWidget {
  const Example2({super.key});
  @override
  State<Example2> createState() => _Example2State();
}

class _Example2State extends State<Example2> {
  @override
  void initState() {
    super.initState();

    const zoneSizePrimaryAxis = 100 / 7;
    const reduced = zoneSizePrimaryAxis * .44;

    final mockZoneSegments = List.generate(
      7,
      (index) => _Example2MockSegment(
        zone: index + 1,
        xMin: (index * zoneSizePrimaryAxis) + reduced,
        xMax: (index + 1) * zoneSizePrimaryAxis - reduced,
        duration: Duration(minutes: random.nextInt(7) + 1),
      ),
    );

    final segmentData = BarDataset<_MyCustomBar>(id: 'zone_segments')
      ..addAll(
        mockZoneSegments
            .map(
              (e) => _MyCustomBar(
                primaryAxisMin: e.xMin,
                primaryAxisMax: e.xMax,
                secondaryAxisMax: e.duration.inMilliseconds.toDouble(),
                fill: secondaryZoneColors[e.zone - 1],
                detailsBelowCircleFill: tertiaryZoneColors[e.zone - 1],
                detailsBelowCircleStroke: primaryZoneColors[e.zone - 1],
                detailsBelow: BarDetails(
                  text: ChartText(
                    text: 'Z${e.zone}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                detailsAbove: BarDetails(
                  text: ChartText(
                    text: formatDuration(e.duration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      );

    final secondaryAxisLeft = SecondaryNumericAxisController(
      barDatasets: [segmentData],
      position: AxisPosition.bottom,
    );

    final primaryAxis = PrimaryNumericAxisController(
      secondaryAxisControllers: [secondaryAxisLeft],
      position: AxisPosition.left,
      isScrollable: false,
      barDetailsSpacing: const BarDetailsSpacing(
        spaceAbove: 92,
        spaceBelow: 64,
      ),
      explicitRange: Range(
        min: 0,
        max: 100,
      ),
      scrollableRange: Range(
        min: 0,
        max: 100,
      ),
    );

    chart = XYChart(
      primaryAxisController: primaryAxis,
    );
  }

  late final XYChart chart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 160, horizontal: 16),
        child: SizedBox(
          child: chart,
        ),
      ),
    );
  }
}
