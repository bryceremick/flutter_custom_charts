import 'package:example/mock_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_charts/flutter_custom_charts.dart';

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
                fill: getGradientZoneColorFromPercentage(e.ftp.toDouble()),
                stroke: null,
                radius: 0,
                strokeWidth: 2,
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
                fill: const Color(0xFFFDFC38),
                radius: 3,
                strokeWidth: 2,
              ),
            )
            .toList(),
        reductionFactor: 1,
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
      explicitRange: Range(min: 0, max: 300),
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
      details: AxisDetails(
        crossAlignmentPixelSize: 48,
        stepLabelFormatter: (value) => '${Duration(
          milliseconds: value.toInt() - startTime.millisecondsSinceEpoch,
        ).inMinutes} min',
        steps: 11,
        stepLabelStyle: const TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
        gridStyle: null,
      ),
    );
    chart = XYChart(
      primaryAxisController: primaryAxis,
      padding: const EdgeInsets.only(top: 16),
    );

    // -------------------------
    // TOP CHART
    // -------------------------

    final segmentDataTopChart = BarDataset()
      ..addAll(
        mockZoneSegments
            .map(
              (e) => Bar(
                primaryAxisMin: e.start.millisecondsSinceEpoch.toDouble(),
                primaryAxisMax: e.end.millisecondsSinceEpoch.toDouble(),
                secondaryAxisMax: e.zone / 7,
                fill: secondaryZoneColors[e.zone - 1],
              ),
            )
            .toList(),
      );

    final secondaryAxisTopChart = SecondaryNumericAxisController(
      barDatasets: [segmentDataTopChart],
      position: AxisPosition.left,
    );

    final primaryAxisTopChart = PrimaryNumericAxisController(
      secondaryAxisControllers: [secondaryAxisTopChart],
      isScrollable: false,
    );

    topChart = XYChart(
      primaryAxisController: primaryAxisTopChart,
      // padding: const EdgeInsets.only(top: 16),
    );
  }

  late final XYChart chart;
  late final XYChart topChart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 4,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              child: SizedBox(
                // height: 400,
                // width: 1000,
                child: topChart,
              ),
            ),
          ),
        ),
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
