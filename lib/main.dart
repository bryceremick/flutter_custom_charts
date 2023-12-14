import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_custom_charts/flutter_custom_charts.dart';

const primaryFill = Color(0xFF155B75);
const secondaryFill = Color(0xFF155B75);
const tertiaryFill = Color(0xFF1C3F4C);
const stroke = Color(0xFF00B0F0);

final rng = Random();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final autoWidthController = BarChartController(
    bars: List.generate(
      10,
      (index) => Bar(
        fill: primaryFill,
        stroke: stroke,
        yMax: rng.nextDouble(),
        label: Label(
          text: 'Bar ${index + 1}',
          style: const TextStyle(fontSize: 12, color: Colors.white),
          alignment: Alignment.center,
          // padding: const EdgeInsets.only(bottom: 5),
        ),
        // lines: [
        //   HorizontalLine(
        //     fill: Colors.white,
        //     dy: const LineDimension(
        //         mode: LineConstraintMode.percentage, value: 0.5),
        //     width: const LineDimension(
        //         mode: LineConstraintMode.percentage, value: 1),
        //     height:
        //         const LineDimension(mode: LineConstraintMode.pixel, value: 1),
        //     style: const Dashed(),
        //   ),
        // ],
      ),
    ),
    xAxisType: AxisDistanceType.auto,
    yAxisType: AxisDistanceType.auto,
    // padding: const EdgeInsets.all(20)
    lines: [
      HorizontalLine(
        fill: Colors.white,
        dy: const LineDimension(mode: LineConstraintMode.percentage, value: .5),
        width:
            const LineDimension(mode: LineConstraintMode.percentage, value: 1),
        height: const LineDimension(mode: LineConstraintMode.pixel, value: 1),
        style: const Dashed(),
      ),
    ],
  );

  final percentageWidthController = BarChartController(
    bars: [
      Bar(
        fill: primaryFill,
        stroke: stroke,
        width: 0.20,
        yMax: 10,
        yMin: 5,
      ),
      Bar(
        fill: primaryFill,
        stroke: stroke,
        width: 0.10,
        yMax: 9,
        yMin: 3,
      ),
      Bar(
        fill: primaryFill,
        stroke: stroke,
        width: 0.10,
        yMax: 8,
        yMin: 1,
      ),
      Bar(
        fill: primaryFill,
        stroke: stroke,
        width: 0.50,
        yMax: 2,
        yMin: 1,
      ),
      Bar(
        fill: primaryFill,
        stroke: stroke,
        width: 0.1,
        yMax: 6,
        yMin: 1,
      ),
    ],
    xAxisType: AxisDistanceType.percentage,
    yAxisType: AxisDistanceType.auto,
    explicitChartMax: 11,
    // padding: const EdgeInsets.all(15),
  );

  final pixelWidthController = BarChartController(
    bars: List.generate(
      20,
      (index) => Bar(
        fill: primaryFill,
        stroke: stroke,
        yMax: rng.nextDouble(),
        width: 200,
        label: Label(
          text: 'Bar ${index + 1}',
          style: const TextStyle(fontSize: 12, color: Colors.white),
          alignment: Alignment.center,
          // padding: const EdgeInsets.only(bottom: 5),
        ),
        lines: [
          HorizontalLine(
            fill: Colors.white,
            dy: const LineDimension(
                mode: LineConstraintMode.percentage, value: 0.5),
            width: const LineDimension(
                mode: LineConstraintMode.percentage, value: 1),
            height:
                const LineDimension(mode: LineConstraintMode.pixel, value: 1),
            style: const Dashed(),
          ),
        ],
      ),
    ),
    xAxisType: AxisDistanceType.pixel,
    yAxisType: AxisDistanceType.auto,
    padding: const EdgeInsets.all(40),
    lines: [
      HorizontalLine(
        fill: Colors.white,
        dy: const LineDimension(mode: LineConstraintMode.pixel, value: 20),
        width:
            const LineDimension(mode: LineConstraintMode.percentage, value: 1),
        height: const LineDimension(mode: LineConstraintMode.pixel, value: 1),
      ),
    ],
  );

  BarChartController<Bar> get controller => pixelWidthController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Text(widget.title),
      // ),
      body: Center(
        child: SizedBox(
          height: 400,
          child: BarChart(
            controller: controller,
            onTap: (index, cube) {
              if (cube.fill == primaryFill) {
                controller.replace(
                  index,
                  cube.copyWith(
                    fill: stroke,
                    // secondaryFill: stroke,
                    // tertiaryFill: stroke,
                    stroke: primaryFill,
                  ),
                );
              } else {
                controller.replace(
                  index,
                  cube.copyWith(
                    fill: primaryFill,
                    // secondaryFill: secondaryFill,
                    // tertiaryFill: tertiaryFill,
                    stroke: stroke,
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
