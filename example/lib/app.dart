import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_custom_charts/flutter_custom_charts.dart';

final rng = Random();

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    barDataset1 = BarDataset()
      ..addAll(
        List.generate(
          10000,
          (index) => Bar(
            primaryAxisMin: index * 10,
            primaryAxisMax: ((index + 1) * 10) - 1,
            secondaryAxisMin: 0,
            secondaryAxisMax: rng.nextInt(10).toDouble() + 3,
            fill: const Color.fromRGBO(33, 150, 243, 0.8),
          ),
        ),
      );

    pointDataset1 = PointDataset(connectPoints: true)
      ..addAll(
        List.generate(
          10000,
          (index) => Point(
            primaryAxisValue: (index * 10) + 5,
            secondaryAxisValue: rng.nextInt(10).toDouble() + 3,
            fill: Color.fromARGB(
              255,
              rng.nextInt(256),
              rng.nextInt(256),
              rng.nextInt(256),
            ),
            stroke: null,
            radius: 0,
            strokeWidth: 3,
          ),
        ),
      );

    barDataset2 = BarDataset()
      ..addAll(
        List.generate(
          1000000,
          (index) => Bar(
            primaryAxisMin: index * 30,
            primaryAxisMax: ((index + 1) * 30) - 1,
            // secondaryAxisMin:
            //     index % 2 == 0 ? 0 : (rng.nextInt(10).toDouble() + 3) * -1,
            // secondaryAxisMax:
            //     index % 2 == 0 ? rng.nextInt(10).toDouble() + 3 : 0,
            secondaryAxisMin: 0,
            secondaryAxisMax: rng.nextInt(10).toDouble() + 10,
            fill: const Color.fromRGBO(33, 150, 243, 0.8),
          ),
        ),
      );

    secondaryAxis = SecondaryNumericAxisController(
      barDatasets: [barDataset1],
      pointDatasets: [pointDataset1],
      position: AxisPosition.left,
      details: AxisDetails(
        stepLabelFormatter: (value) => '${value.round()}',
      ),
      explicitRange: Range(min: 0, max: 13),
    );

    secondaryAxis2 = SecondaryNumericAxisController(
      barDatasets: [barDataset2],
      pointDatasets: [],
      position: AxisPosition.left,
      explicitRange: Range(min: 0, max: 20),
      details: AxisDetails(
        stepLabelFormatter: (value) => '${value.round()}',
        gridStyle: null,
      ),
      // explicitRange: Range(min: 0, max: 20),
    );

    primaryAxis = PrimaryNumericAxisController(
      secondaryAxisControllers: [secondaryAxis],
      position: AxisPosition.bottom,
      explicitRange: Range(min: 0, max: 600),
      // scrollableRange: Range(min: -100, max: 1000),
      details: AxisDetails(
        stepLabelFormatter: (value) => '${value.round()}',
      ),
      // onExplicitRangeChange: (range) {
      //   primaryAxis2.explicitRange = range;
      // },
    );
    primaryAxis2 = PrimaryNumericAxisController(
      secondaryAxisControllers: [secondaryAxis2],
      position: AxisPosition.bottom,
      explicitRange: Range(min: 1000, max: 1500),
      // scrollableRange: Range(min: -100, max: 2100),
      details: AxisDetails(
        stepLabelFormatter: (value) => '${value.round()}',
      ),
    );
    chart = XYChart(
      primaryAxisController: primaryAxis,
      // padding: const EdgeInsets.all(30),
    );
    chart2 = XYChart(
      primaryAxisController: primaryAxis2,
      // padding: const EdgeInsets.all(30),
    );

    Future.delayed(const Duration(seconds: 5), () {
      primaryAxis.animateTo(
        to: Range(min: 0, max: 100),
        duration: const Duration(seconds: 3),
        curve: Curves.linear,
      );
    });

    Future.delayed(const Duration(seconds: 9), () {
      primaryAxis.animateTo(
        to: Range(min: 1500, max: 2000),
        duration: const Duration(seconds: 5),
        curve: Curves.linear,
      );
    });

    // Future.delayed(const Duration(seconds: 10), () {
    //   primaryAxis.zoomTo(
    //       Range(min: 0, max: 1000), const Duration(seconds: 3), Curves.linear);
    // });

    // Timer.periodic(const Duration(seconds: 1), (timer) {
    //   barDataset.add(
    //     DynamicBar(
    //       primaryAxisMin: barDataset.data.length * 10,
    //       primaryAxisMax: ((barDataset.data.length + 1) * 10) - 1,
    //       secondaryAxisMin: 0,
    //       secondaryAxisMax: rng.nextInt(10).toDouble() + 2,
    //       fill: Colors.blue,
    //     ),
    //   );
    // });
  }

  late final BarDataset barDataset1;
  late final PointDataset pointDataset1;
  late final BarDataset barDataset2;
  late final SecondaryNumericAxisController secondaryAxis;
  late final SecondaryNumericAxisController secondaryAxis2;
  late final PrimaryNumericAxisController primaryAxis;
  late final PrimaryNumericAxisController primaryAxis2;
  late final XYChart chart;
  late final XYChart chart2;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          background: const Color(0xFF1C1C1C),
        ),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: Center(
                child: SizedBox(
                  // height: 400,
                  // width: 1000,
                  child: chart2,
                ),
              ),
            ),
            const Expanded(
              flex: 1,
              child: SizedBox(
                  // height: 400,
                  // width: 1000,
                  ),
            ),
            Expanded(
              flex: 5,
              child: Center(
                child: SizedBox(
                  // height: 500,
                  // width: 1000,
                  child: chart,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
