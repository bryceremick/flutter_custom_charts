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
            secondaryAxisMin: 0,
            secondaryAxisMax: rng.nextInt(10).toDouble() + 3,
            // secondaryAxisMax: 10,
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
      // explicitRange: Range(min: 0, max: 10),
    );
    primaryAxis = PrimaryNumericAxisController(
      secondaryAxisControllers: [secondaryAxis],
      position: AxisPosition.bottom,
      explicitRange: Range(min: 1000, max: 1500),
      // scrollableRange: Range(min: 1000, max: 1500),
    );
    chart = NewXYChart(
      primaryAxisController: primaryAxis,
      padding: const EdgeInsets.only(bottom: 20, left: 40, top: 10, right: 100),
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
  late final PrimaryNumericAxisController primaryAxis;
  late final NewXYChart chart;

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
        body: Center(
          child: SizedBox(
            height: 400,
            width: 1000,
            child: chart,
          ),
        ),
      ),
    );
  }
}
