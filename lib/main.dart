import 'dart:math';

import 'package:flutter/material.dart';
import 'package:three_dimensional_bar_chart/models/bar_chart_data.dart';
import 'package:three_dimensional_bar_chart/widgets/bar_chart.dart';
import 'package:three_dimensional_bar_chart/widgets/entities/bar.dart';
import 'package:three_dimensional_bar_chart/widgets/entities/line.dart';

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
          height: BarDimension(
            mode: AxisDistanceType.percentage,
            value: rng.nextDouble(),
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
      barWidthType: AxisDistanceType.auto,
      padding: const EdgeInsets.all(20)
      // lines: [
      //   HorizontalLine(
      //     fill: Colors.white,
      //     dy: const LineDimension(mode: LineConstraintMode.pixel, value: 20),
      //     width:
      //         const LineDimension(mode: LineConstraintMode.percentage, value: 1),
      //     height: const LineDimension(mode: LineConstraintMode.pixel, value: 1),
      //   ),
      // ],
      );

  final percentageWidthController = BarChartController(
    bars: [
      Bar(
        fill: primaryFill,
        stroke: stroke,
        width: 0.20,
        height:
            const BarDimension(mode: AxisDistanceType.percentage, value: 0.5),
      ),
      Bar(
        fill: primaryFill,
        stroke: stroke,
        width: 0.10,
        height:
            const BarDimension(mode: AxisDistanceType.percentage, value: 0.5),
      ),
      Bar(
        fill: primaryFill,
        stroke: stroke,
        width: 0.10,
        height:
            const BarDimension(mode: AxisDistanceType.percentage, value: 0.5),
      ),
      Bar(
        fill: primaryFill,
        stroke: stroke,
        width: 0.50,
        height:
            const BarDimension(mode: AxisDistanceType.percentage, value: 0.5),
      ),
      Bar(
        fill: primaryFill,
        stroke: stroke,
        width: 0.1,
        height:
            const BarDimension(mode: AxisDistanceType.percentage, value: 0.5),
      ),
    ],
    barWidthType: AxisDistanceType.percentage,
    padding: const EdgeInsets.all(15),
  );

  final pixelWidthController = BarChartController(
    bars: List.generate(
      20,
      (index) => Bar(
        fill: primaryFill,
        stroke: stroke,
        height: const BarDimension(
          mode: AxisDistanceType.percentage,
          value: 0.5,
        ),
        width: 200,
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
    barWidthType: AxisDistanceType.pixel,
    // padding: const EdgeInsets.all(15),
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
          height: 200,
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
