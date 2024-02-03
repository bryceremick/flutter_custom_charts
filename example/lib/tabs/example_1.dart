import 'dart:math';

import 'package:example/mock_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_charts/flutter_custom_charts.dart';

const List<Color> colors = [
  Color(0xFF5A5A5A), // Zone 1
  Color(0xFF00B0F0), // Zone 2
  Color(0xFF00B050), // Zone 3
  Color(0xFFF6991E), // Zone 4
  Color(0xFFFF0000), // Zone 5
  Color(0xFFFF3232), // Zone 6
  Color(0xFF960096), // Zone 7
];

const opacity = 0.35;
const List<Color> tertiaryZoneColors = [
  Color.fromRGBO(90, 90, 90, opacity), // Zone 1: 0xFF5A5A5A
  Color.fromRGBO(0, 176, 240, opacity), // Zone 2: 0xFF00B0F0
  Color.fromRGBO(0, 176, 80, opacity), // Zone 3: 0xFF00B050
  Color.fromRGBO(246, 153, 30, opacity), // Zone 4: 0xFFF6991E
  Color.fromRGBO(255, 0, 0, opacity), // Zone 5: 0xFFFF0000
  Color.fromRGBO(255, 50, 50, opacity), // Zone 6: 0xFFFF3232
  Color.fromRGBO(150, 0, 150, opacity), // Zone 7: 0xFF960096
];
List<double> zoneMaxes = [54, 75, 90, 105, 120, 150, 180];

Color getColorFromPercentage(double percentage) {
  if (percentage > 150) {
    return colors.last;
  }

  int zoneIndex = 0;
  for (int i = 0; i < zoneMaxes.length; i++) {
    if (percentage <= zoneMaxes[i]) {
      zoneIndex = i;
      break;
    }
  }

  double lowerBound = zoneIndex == 0 ? 0 : zoneMaxes[zoneIndex - 1];
  double upperBound = zoneMaxes[zoneIndex];
  double zoneSize = upperBound - lowerBound;
  double fraction = (percentage - lowerBound) / (upperBound - lowerBound);

  // Adjust the exponent based on the size of the zone
  double exponent = 1 + (zoneSize / 20); // Example dynamic adjustment
  fraction = pow(fraction, exponent).toDouble();

  Color startColor = colors[zoneIndex];
  Color endColor =
      zoneIndex < colors.length - 1 ? colors[zoneIndex + 1] : colors[zoneIndex];
  return Color.lerp(startColor, endColor, fraction)!;
}

class Example1 extends StatefulWidget {
  const Example1({super.key});

  @override
  State<Example1> createState() => _Example1State();
}

class _Example1State extends State<Example1> {
  @override
  void initState() {
    super.initState();

    final mockBikeDate = generateBikeData(DateTime.now(), durationMinutes: 60);
    final startTime = mockBikeDate.first.timestamp;
    final endTime = mockBikeDate.last.timestamp;
    final mockZoneSegments =
        generateZoneSegments(start: startTime, end: endTime, numSegments: 20);

    final segmentData = BarDataset()
      ..addAll(
        mockZoneSegments
            .map(
              (e) => Bar(
                primaryAxisMin: e.start.millisecondsSinceEpoch.toDouble(),
                primaryAxisMax: e.end.millisecondsSinceEpoch.toDouble(),
                secondaryAxisMax: 100,
                fill: tertiaryZoneColors[e.zone - 1],
              ),
            )
            .toList(),
      );

    final ftpData = PointDataset(connectPoints: true)
      ..addAll(
        mockBikeDate
            .map(
              (e) => Point(
                primaryAxisValue: e.timestamp.millisecondsSinceEpoch.toDouble(),
                secondaryAxisValue: e.ftp.toDouble(),
                fill: getColorFromPercentage(e.ftp.toDouble()),
                stroke: null,
                radius: 0,
                strokeWidth: 5,
              ),
            )
            .toList(),
      );

    final rpmData = PointDataset(connectPoints: true)
      ..addAll(
        mockBikeDate
            .map(
              (e) => Point(
                primaryAxisValue: e.timestamp.millisecondsSinceEpoch.toDouble(),
                secondaryAxisValue: e.rpm.toDouble(),
                stroke: const Color(0xFFFDFC38),
                radius: 0,
                strokeWidth: 2,
              ),
            )
            .toList(),
      );

    final hiddenSecondaryAxis = SecondaryNumericAxisController(
      barDatasets: [segmentData],
      position: AxisPosition.left,
    );

    final leftSecondaryAxis = SecondaryNumericAxisController(
      pointDatasets: [rpmData],
      position: AxisPosition.left,
      details: AxisDetails(
        steps: 12,
        crossAlignmentPixelSize: 64,
        stepLabelFormatter: (value) => '${value.round()}',
        stepLabelStyle: const TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
        gridStyle: const AxisGridStyle(
          color: Color(0xFF000000),
          strokeWidth: 3,
        ),
      ),
      explicitRange: Range(min: 0, max: 150),
    );

    final rightSecondaryAxis = SecondaryNumericAxisController(
      pointDatasets: [ftpData],
      position: AxisPosition.right,
      details: AxisDetails(
        steps: 12,
        crossAlignmentPixelSize: 64,
        stepLabelFormatter: (value) => '${value.round()}',
        stepLabelStyle: const TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
        gridStyle: null,
      ),
      explicitRange: Range(min: 0, max: 225),
    );

    final primaryAxis = PrimaryNumericAxisController(
      secondaryAxisControllers: [
        hiddenSecondaryAxis,
        leftSecondaryAxis,
        rightSecondaryAxis
      ],
      position: AxisPosition.bottom,
      explicitRange: Range(
        min: startTime.millisecondsSinceEpoch.toDouble(),
        max: startTime
            .add(const Duration(minutes: 10))
            .millisecondsSinceEpoch
            .toDouble(),
      ),
      // scrollableRange: Range(min: -100, max: 1000),
      details: AxisDetails(
        crossAlignmentPixelSize: 48,
        stepLabelFormatter: (value) => '${Duration(
          milliseconds: value.toInt() - startTime.millisecondsSinceEpoch,
        ).inMinutes} min',
        steps: 12,
        stepLabelStyle: const TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
        gridStyle: const AxisGridStyle(
          color: Color(0xFF000000),
          strokeWidth: 1,
        ),
      ),
    );
    chart = XYChart(
      primaryAxisController: primaryAxis,
      padding: const EdgeInsets.only(top: 16),
    );
  }

  late final XYChart chart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Expanded(
          flex: 1,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'RPM',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'FTP',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 20,
          child: Center(
            child: SizedBox(
              // height: 400,
              // width: 1000,
              child: chart,
            ),
          ),
        ),
      ],
    );
  }
}
