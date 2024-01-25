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
    barDataset1 = DynamicBarDataset()
      ..addAll(
        List.generate(
          200,
          (index) => DynamicBar(
            primaryAxisMin: index * 10,
            primaryAxisMax: ((index + 1) * 10) - 1,
            // secondaryAxisMin:
            //     index % 2 == 0 ? 0 : (rng.nextInt(10).toDouble() + 3) * -1,
            // secondaryAxisMax:
            //     index % 2 == 0 ? rng.nextInt(10).toDouble() + 3 : 0,
            secondaryAxisMin: 0,
            secondaryAxisMax: rng.nextInt(10).toDouble() + 3,
            fill: Colors.blue,
            label: Label(
              text: '$index',
              style: const TextStyle(fontSize: 12, color: Colors.white),
              alignment: Alignment.bottomCenter,
              // padding: const EdgeInsets.only(bottom: 5),
            ),
          ),
        ),
      );
    // barDataset2 = DynamicBarDataset()
    //   ..addAll(
    //     List.generate(
    //       200,
    //       (index) => DynamicBar(
    //         primaryAxisMin: index * 10,
    //         primaryAxisMax: ((index + 1) * 10) - 1,
    //         secondaryAxisMin: 2,
    //         // secondaryAxisMax: rng.nextInt(10).toDouble() + 3,
    //         secondaryAxisMax: 12,
    //         fill: Colors.blue,
    //       ),
    //     ),
    //   );

    secondaryAxis = SecondaryNumericAxisController(
      barDatasets: [barDataset1],
      position: AxisPosition.left,
      details: AxisDetails(
        stepLabelFormatter: (value) => '${value.round()}',
      ),
      // explicitRange: Range(min: -15, max: 15),
    );
    secondaryAxis2 = SecondaryNumericAxisController(
      barDatasets: [],
      position: AxisPosition.right,
      explicitRange: Range(min: 0, max: 20),
      details: AxisDetails(
        stepLabelFormatter: (value) => '${value.round()}',
      ),
      // explicitRange: Range(min: 0, max: 20),
    );
    primaryAxis = PrimaryNumericAxisController(
      secondaryAxisControllers: [secondaryAxis, secondaryAxis2],
      position: AxisPosition.bottom,
      explicitRange: Range(min: 1000, max: 1500),
      // scrollableRange: Range(min: -100, max: 2100),
      details: AxisDetails(
        stepLabelFormatter: (value) => '${value.round()}',
      ),
      onExplicitRangeChange: (range) {
        primaryAxis2.explicitRange = range;
      },
    );
    primaryAxis2 = PrimaryNumericAxisController(
      secondaryAxisControllers: [secondaryAxis, secondaryAxis2],
      position: AxisPosition.bottom,
      explicitRange: Range(min: 1000, max: 1500),
      // scrollableRange: Range(min: -100, max: 2100),
      details: AxisDetails(
        stepLabelFormatter: (value) => '${value.round()}',
      ),
    );
    chart = NewXYChart(
      primaryAxisController: primaryAxis,
      padding: const EdgeInsets.all(30),
    );
    chart2 = NewXYChart(
      primaryAxisController: primaryAxis2,
      padding: const EdgeInsets.all(30),
    );

    // Future.delayed(const Duration(seconds: 5), () {
    //   primaryAxis.zoomTo(
    //     Range(min: -200, max: 600),
    //     const Duration(seconds: 3),
    //     Curves.linear,
    //   );
    // });
    // Future.delayed(const Duration(seconds: 10), () {
    //   primaryAxis.zoomTo(
    //     Range(min: 1800, max: 2200),
    //     const Duration(seconds: 3),
    //     Curves.linear,
    //   );
    // });

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

  late final DynamicBarDataset barDataset1;
  late final DynamicBarDataset barDataset2;
  late final SecondaryNumericAxisController<DynamicBarDataset<DynamicBar>>
      secondaryAxis;
  late final SecondaryNumericAxisController<DynamicBarDataset<DynamicBar>>
      secondaryAxis2;
  late final PrimaryNumericAxisController primaryAxis;
  late final PrimaryNumericAxisController primaryAxis2;
  late final NewXYChart chart;
  late final NewXYChart chart2;

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
              child: Center(
                child: SizedBox(
                  // height: 400,
                  width: 1000,
                  child: chart2,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: SizedBox(
                  // height: 400,
                  width: 1000,
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
