import 'package:flutter/material.dart';
import 'package:three_dimensional_bar_chart/models/bar_chart_data.dart';
import 'package:three_dimensional_bar_chart/widgets/bar_chart.dart';
import 'package:three_dimensional_bar_chart/widgets/bars/cube.dart';

const primaryFill = Color(0xFF155B75);
const secondaryFill = Color(0xFF155B75);
const tertiaryFill = Color(0xFF1C3F4C);
const stroke = Color(0xFF00B0F0);

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
      (index) => Cube(
        fill: primaryFill,
        secondaryFill: secondaryFill,
        tertiaryFill: tertiaryFill,
        stroke: stroke,
      ),
    ),
    barWidthType: BarConstraintMode.auto,
  );

  final percentageWidthController = BarChartController(
    bars: [
      Cube(
        fill: primaryFill,
        secondaryFill: secondaryFill,
        tertiaryFill: tertiaryFill,
        stroke: stroke,
        width: 0.20,
        height: 1,
      ),
      Cube(
        fill: primaryFill,
        secondaryFill: secondaryFill,
        tertiaryFill: tertiaryFill,
        stroke: stroke,
        width: 0.10,
        height: 0,
      ),
      Cube(
        fill: primaryFill,
        secondaryFill: secondaryFill,
        tertiaryFill: tertiaryFill,
        stroke: stroke,
        width: 0.10,
        height: 0.10,
      ),
      Cube(
        fill: primaryFill,
        secondaryFill: secondaryFill,
        tertiaryFill: tertiaryFill,
        stroke: stroke,
        width: 0.50,
        height: 0.50,
      ),
      Cube(
        fill: primaryFill,
        secondaryFill: secondaryFill,
        tertiaryFill: tertiaryFill,
        stroke: stroke,
        width: 0.1,
        height: 0.1,
      ),
    ],
    barWidthType: BarConstraintMode.percentage,
    barHeightType: BarConstraintMode.percentage,
  );

  final pixelWidthController = BarChartController(
    bars: [
      Cube(
        fill: primaryFill,
        secondaryFill: secondaryFill,
        tertiaryFill: tertiaryFill,
        stroke: stroke,
        width: 50,
      ),
      Cube(
        fill: primaryFill,
        secondaryFill: secondaryFill,
        tertiaryFill: tertiaryFill,
        stroke: stroke,
        width: 100,
      ),
      Cube(
        fill: primaryFill,
        secondaryFill: secondaryFill,
        tertiaryFill: tertiaryFill,
        stroke: stroke,
        width: 50,
      ),
      Cube(
        fill: primaryFill,
        secondaryFill: secondaryFill,
        tertiaryFill: tertiaryFill,
        stroke: stroke,
        width: 75,
      ),
      Cube(
        fill: primaryFill,
        secondaryFill: secondaryFill,
        tertiaryFill: tertiaryFill,
        stroke: stroke,
        width: 100,
      ),
    ],
    barWidthType: BarConstraintMode.pixel,
  );

  BarChartController<Cube> get controller => percentageWidthController;

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
                    secondaryFill: stroke,
                    tertiaryFill: stroke,
                    stroke: primaryFill,
                  ),
                );
              } else {
                controller.replace(
                  index,
                  cube.copyWith(
                    fill: primaryFill,
                    secondaryFill: secondaryFill,
                    tertiaryFill: tertiaryFill,
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
