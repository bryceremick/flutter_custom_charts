import 'package:example/mock_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_charts/flutter_custom_charts.dart';

class Example2 extends StatefulWidget {
  const Example2({super.key});
  @override
  State<Example2> createState() => _Example2State();
}

class _Example2State extends State<Example2> {
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
                secondaryAxisMax: e.zone.toDouble(),
                fill: secondaryZoneColors[e.zone - 1],
                detailsBelow: BarDetails(
                  text: ChartText(
                    text: 'Z${e.zone}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 1,
                    ),
                  ),
                ),
                detailsAbove: BarDetails(
                  icon: ChartIcon(
                    icon: Icons.star,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            )
            .toList(),
      );

    final secondaryAxisLeft = SecondaryNumericAxisController(
      barDatasets: [segmentData],
      position: AxisPosition.left,
      details: AxisDetails(
        stepLabelFormatter: (value) => value.toStringAsFixed(1),
        steps: 7,
        gridStyle: const AxisGridStyle(
          color: Colors.grey,
          strokeWidth: 1,
        ),
      ),
    );
    final secondaryAxisLeft2 = SecondaryNumericAxisController(
      barDatasets: [segmentData],
      position: AxisPosition.left,
      details: AxisDetails(
        stepLabelFormatter: (value) => value.toStringAsFixed(1),
        steps: 7,
        gridStyle: const AxisGridStyle(
          color: Colors.grey,
          strokeWidth: 1,
        ),
      ),
    );

    final secondaryAxisLeft3 = SecondaryNumericAxisController(
      barDatasets: [segmentData],
      position: AxisPosition.left,
      details: AxisDetails(
        stepLabelFormatter: (value) => value.toStringAsFixed(1),
        steps: 7,
        gridStyle: const AxisGridStyle(
          color: Colors.grey,
          strokeWidth: 1,
        ),
      ),
    );

    final secondaryAxisRight = SecondaryNumericAxisController(
      barDatasets: [segmentData],
      position: AxisPosition.right,
      details: AxisDetails(
        stepLabelFormatter: (value) => value.toStringAsFixed(1),
        steps: 7,
        gridStyle: const AxisGridStyle(
          color: Colors.grey,
          strokeWidth: 1,
        ),
      ),
    );

    final secondaryAxisRight2 = SecondaryNumericAxisController(
      barDatasets: [segmentData],
      position: AxisPosition.right,
      details: AxisDetails(
        stepLabelFormatter: (value) => value.toStringAsFixed(1),
        steps: 7,
        gridStyle: const AxisGridStyle(
          color: Colors.grey,
          strokeWidth: 1,
        ),
      ),
    );

    final primaryAxis = PrimaryNumericAxisController(
      secondaryAxisControllers: [
        secondaryAxisLeft,
        secondaryAxisRight,
        secondaryAxisLeft2,
        secondaryAxisRight2,
        secondaryAxisLeft3,
      ],
      isScrollable: false,
      details: AxisDetails(
        stepLabelFormatter: (value) => '${Duration(
          milliseconds: value.toInt() - startTime.millisecondsSinceEpoch,
        ).inMinutes} min',
      ),
      detailsAboveSize: 32,
      detailsBelowSize: 32,
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
        padding: const EdgeInsets.all(0),
        child: SizedBox(
          child: chart,
        ),
      ),
    );
  }
}
