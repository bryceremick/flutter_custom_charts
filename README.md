# flutter_custom_charts

A highly extendable, high performance charting library.

![chart_animation_example](https://github.com/bryceremick/flutter_custom_charts/assets/17426081/58e5d9e5-2635-4cd9-b1a3-a3fdd734fae5)

## Features

- Plot entities on an xy coordinate based chart. Current entities include:
  - `Bar`
  - `Point`
  - `Label`
  - `Line`
- Every entity is extendable. All you have to do is override the `paint` method on an entity, and you can customize it to fit your use-case.
- Animate to a specific `Range` on the `primaryAxis`. This allows you to zoom and pan on the chart.
- Add multiple datasets to an  axis, and multiple axes on a chart.
- Sync the zooming and panning of multiple chart instances.

## Usage

Create some datasets and add some data do them:

```dart
final barDataset = BarDataset()
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

final pointDataset = PointDataset(shouldConnectLines: true)
      ..addAll(
        List.generate(
          10000,
          (index) => Point(
            primaryAxisValue: (index * 10) + 5,
            secondaryAxisValue: rng.nextInt(10).toDouble() + 3,
            fill: Colors.red,
          ),
        ),
      );
```

Create primary and secondary axis controllers:

```dart
final secondaryAxis = SecondaryNumericAxisController(
      barDatasets: [barDataset],
      pointDatasets: [pointDataset],
      position: AxisPosition.left, // y axis
      details: AxisDetails(
        stepLabelFormatter: (value) => '${value.round()}',
      ),
      explicitRange: Range(min: 0, max: 13),
    );

final primaryAxis = PrimaryNumericAxisController(
      secondaryAxisControllers: [secondaryAxis],
      position: AxisPosition.bottom, // x axis
      explicitRange: Range(min: 0, max: 600), // if null, the entire dataset will be painted within chart viewport
      details: AxisDetails(
        stepLabelFormatter: (value) => '${value.round()}',
      ),
    );  
```

Create a chart and pass in the `PrimaryAxisController`:

```dart
final chart = XYChart(
      primaryAxisController: primaryAxis,
    );
```

Add the chart to your flutter build method.

```dart
...
 SizedBox(
    height: 500,
    width: 1000,
    child: chart,
 ),
 ...
```
