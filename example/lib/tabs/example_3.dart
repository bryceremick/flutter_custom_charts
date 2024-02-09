import 'package:example/helpers.dart';
import 'package:flutter/material.dart';

import 'package:flutter_custom_charts/flutter_custom_charts.dart';

class Example3 extends StatefulWidget {
  const Example3({super.key});
  @override
  State<Example3> createState() => _Example3State();
}

class _Example3State extends State<Example3> {
  @override
  void initState() {
    super.initState();

    const zoneSizePrimaryAxis = 100 / 7;
    const reduced = zoneSizePrimaryAxis * .25;

    final mockZoneSegments = List.generate(
      7,
      (index) => _Example3MockSegment(
        zone: index + 1,
        xMin: (index * zoneSizePrimaryAxis) + reduced,
        xMax: (index + 1) * zoneSizePrimaryAxis - reduced,
        successRate: random.nextDouble() * 100,
      ),
    );

    final segmentData = BarDataset<_3DBar>()
      ..addAll(
        mockZoneSegments
            .map(
              (e) => _3DBar(
                primaryAxisMin: e.xMin,
                primaryAxisMax: e.xMax,
                secondaryAxisMax: 100,
                innerBarPercentageValue: e.successRate,
                stroke: primaryZoneColors[e.zone - 1],
                fill: secondaryZoneColors[e.zone - 1],
                secondaryFill: tertiaryZoneColors[e.zone - 1],
                detailsBelow: BarDetails(
                  text: ChartText(
                    text: 'Z${e.zone}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                ),
                detailsAbove: BarDetails(
                  text: ChartText(
                    text: '${e.successRate.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      // fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      );

    final secondaryAxisLeft = SecondaryNumericAxisController(
      barDatasets: [segmentData],
      position: AxisPosition.left,
    );

    final primaryAxis = PrimaryNumericAxisController(
      secondaryAxisControllers: [secondaryAxisLeft],
      position: AxisPosition.bottom,
      isScrollable: false,
      barDetailsSpacing: const BarDetailsSpacing(
        spaceAbove: 64,
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
        padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 160),
        child: SizedBox(
          child: chart,
        ),
      ),
    );
  }
}

class _Example3MockSegment {
  const _Example3MockSegment({
    required this.zone,
    required this.xMin,
    required this.xMax,
    required this.successRate,
  });
  final int zone;
  final double xMin;
  final double xMax;
  final double successRate;
}

class _3DBar extends Bar {
  _3DBar({
    required super.primaryAxisMin,
    required super.primaryAxisMax,
    required super.secondaryAxisMax,
    required this.secondaryFill,
    required this.innerBarPercentageValue,
    this.thirdDimensionX = 28,
    this.thirdDimensionY = 20,
    super.secondaryAxisMin = 0,
    required this.fill,
    required this.stroke,
    super.lines = const [],
    super.detailsAbove,
    super.detailsBelow,
  }) : super();

  @override
  final Color fill;

  @override
  final Color stroke;

  final Color secondaryFill;
  final double innerBarPercentageValue;
  double thirdDimensionX;
  double thirdDimensionY;

  void _paintX3D(
    Canvas canvas, {
    required ConstrainedArea constraints,
    required double yMinOffset,
    required Paint fill,
    Paint? stroke,
  }) {
    final rightPath = Path();
    rightPath.moveTo(
      constraints.xMax,
      yMinOffset - thirdDimensionY,
    );
    rightPath.lineTo(
      constraints.xMax,
      (constraints.yMax - thirdDimensionY),
    );
    rightPath.lineTo(
      constraints.xMax - thirdDimensionX,
      constraints.yMax,
    );
    rightPath.lineTo(
      constraints.xMax - thirdDimensionX,
      yMinOffset,
    );
    rightPath.close();

    canvas.drawPath(rightPath, fill);
    if (stroke != null) {
      canvas.drawPath(rightPath, stroke);
    }
  }

  void _paintY3D(
    Canvas canvas, {
    required ConstrainedArea constraints,
    required double yMinOffset,
    required Paint fill,
    Paint? stroke,
  }) {
    final topPath = Path();
    topPath.moveTo(constraints.xMin, yMinOffset);
    topPath.lineTo(
      constraints.xMin + thirdDimensionX,
      yMinOffset - thirdDimensionY,
    );
    topPath.lineTo(
      constraints.xMin + constraints.width,
      yMinOffset - thirdDimensionY,
    );
    topPath.lineTo(
      (constraints.xMin + constraints.width) - thirdDimensionX,
      yMinOffset,
    );
    topPath.close();

    canvas.drawPath(topPath, fill);
    if (stroke != null) {
      canvas.drawPath(topPath, stroke);
    }
  }

  @override
  void paint(
    Canvas canvas, {
    required ConstrainedArea constraints,
    ConstrainedArea? detailsAboveConstraints,
    ConstrainedArea? detailsBelowConstraints,
  }) {
    super.constraints = constraints;

    if (perceivedHeight == 0 ||
        constraints.height == 0 ||
        constraints.width == 0) {
      return;
    }

    final fillPaint = Paint()
      ..color = fill
      ..style = PaintingStyle.fill;

    final secondaryFillPaint = Paint()
      ..color = secondaryFill
      ..style = PaintingStyle.fill;

    const strokeWidth = 1.0;
    final strokePaint = Paint()
      ..color = stroke
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final yMinOffset = constraints.yMin + thirdDimensionY;

    final bar = Rect.fromLTRB(
      constraints.xMin,
      yMinOffset,
      constraints.xMax - thirdDimensionX,
      constraints.yMax,
    );

    final innerBar = Rect.fromLTRB(
      constraints.xMin,
      linearTransform(
        innerBarPercentageValue,
        rangeA: Range(min: 0, max: 100).inverted(),
        rangeB: Range(min: yMinOffset, max: constraints.yMax),
      ),
      constraints.xMax - thirdDimensionX,
      constraints.yMax,
    );

    canvas.drawRect(bar, secondaryFillPaint);
    canvas.drawRect(bar, strokePaint);
    canvas.drawRect(innerBar, fillPaint);
    canvas.drawRect(innerBar, strokePaint);

    // 3d y background
    _paintY3D(
      canvas,
      constraints: constraints,
      yMinOffset: yMinOffset,
      fill: secondaryFillPaint,
      stroke: strokePaint,
    );

    if (innerBarPercentageValue >= 100) {
      _paintY3D(
        canvas,
        constraints: constraints,
        yMinOffset: yMinOffset,
        fill: fillPaint,
        stroke: strokePaint,
      );
    }

    // 3d x background
    _paintX3D(
      canvas,
      constraints: constraints,
      yMinOffset: yMinOffset,
      fill: secondaryFillPaint,
      stroke: strokePaint,
    );

    // 3d x bar fill
    if (innerBarPercentageValue > 0) {
      _paintX3D(
        canvas,
        constraints: constraints,
        yMinOffset: linearTransform(
          innerBarPercentageValue,
          rangeA: Range(min: 0, max: 100).inverted(),
          rangeB: Range(min: yMinOffset, max: constraints.yMax),
        ),
        fill: fillPaint,
        stroke: strokePaint,
      );
    }

    if (detailsAboveConstraints != null && detailsAbove != null) {
      paintDetailsAbove(
        canvas,
        constraints: detailsAboveConstraints,
        details: detailsAbove!,
      );
    }

    if (detailsBelowConstraints != null && detailsBelow != null) {
      paintDetailsBelow(
        canvas,
        constraints: detailsBelowConstraints,
        details: detailsBelow!,
      );
    }
  }
}
