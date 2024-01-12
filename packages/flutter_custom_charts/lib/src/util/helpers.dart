part of flutter_custom_charts;

void verifyAxisPositions(AxisPosition primary, AxisPosition secondary) {
  switch (primary) {
    case AxisPosition.right:
    case AxisPosition.left:
      if (secondary == AxisPosition.left || secondary == AxisPosition.right) {
        throw XYChartException(
            'Secondary axis must be positioned on the top or bottom of the chart');
      }
      break;
    case AxisPosition.top:
    case AxisPosition.bottom:
      if (secondary == AxisPosition.top || secondary == AxisPosition.bottom) {
        throw XYChartException(
            'Secondary axis must be positioned on the left or right of the chart');
      }
      break;
    default:
  }
}

/// verifies that [rangeA] is a subset of [rangeB]
/// TODO - put this on the Range class
bool isSubsetRange({
  required Range rangeA,
  required Range rangeB,
}) {
  return rangeA.min >= rangeB.min && rangeA.max <= rangeB.max;
}

/// transforms a value from [rangeA] to the equivalent value in [rangeB]
double linearTransform(
  double rangeAValue, {
  required Range rangeA,
  required Range rangeB,
}) {
  return ((rangeAValue - rangeA.min) / (rangeA.max - rangeA.min)) *
          (rangeB.max - rangeB.min) +
      rangeB.min;
}

ConstrainedArea translateBarToCanvas({
  required Range primaryAxisBarRange,
  required Range secondaryAxisBarRange,
  required Range primaryAxisDatasetRange,
  required Range secondaryAxisDatasetRange,
  required AxisPosition primaryAxisPosition,
  required AxisPosition secondaryAxisPosition,
  required ConstrainedArea constraints,
}) {
  final canvasXAxisRange = Range(min: constraints.xMin, max: constraints.xMax);
  final canvasYAxisRange = Range(min: constraints.yMin, max: constraints.yMax);
  switch (primaryAxisPosition) {
    case AxisPosition.left:
      return ConstrainedArea(
        xMin: linearTransform(
          secondaryAxisBarRange.min,
          rangeA: secondaryAxisDatasetRange,
          rangeB: canvasXAxisRange,
        ),
        xMax: linearTransform(
          secondaryAxisBarRange.max,
          rangeA: secondaryAxisDatasetRange,
          rangeB: canvasXAxisRange,
        ),
        yMin: linearTransform(
          primaryAxisBarRange.min,
          rangeA: primaryAxisDatasetRange,
          rangeB: canvasYAxisRange,
        ),
        yMax: linearTransform(
          primaryAxisBarRange.max,
          rangeA: primaryAxisDatasetRange,
          rangeB: canvasYAxisRange,
        ),
      );
    case AxisPosition.right:
      return ConstrainedArea(
        xMin: linearTransform(
          secondaryAxisBarRange.max,
          rangeA: secondaryAxisDatasetRange,
          rangeB: canvasXAxisRange.inverted(),
        ),
        xMax: linearTransform(
          secondaryAxisBarRange.min,
          rangeA: secondaryAxisDatasetRange,
          rangeB: canvasXAxisRange.inverted(),
        ),
        yMin: linearTransform(
          primaryAxisBarRange.min,
          rangeA: primaryAxisDatasetRange,
          rangeB: canvasYAxisRange,
        ),
        yMax: linearTransform(
          primaryAxisBarRange.max,
          rangeA: primaryAxisDatasetRange,
          rangeB: canvasYAxisRange,
        ),
      );
    case AxisPosition.top:
      return ConstrainedArea(
        xMin: linearTransform(
          primaryAxisBarRange.min,
          rangeA: primaryAxisDatasetRange,
          rangeB: canvasXAxisRange,
        ),
        xMax: linearTransform(
          primaryAxisBarRange.max,
          rangeA: primaryAxisDatasetRange,
          rangeB: canvasXAxisRange,
        ),
        yMin: linearTransform(
          secondaryAxisBarRange.min,
          rangeA: secondaryAxisDatasetRange,
          rangeB: canvasYAxisRange,
        ),
        yMax: linearTransform(
          secondaryAxisBarRange.max,
          rangeA: secondaryAxisDatasetRange,
          rangeB: canvasYAxisRange,
        ),
      );
    case AxisPosition.bottom:
      return ConstrainedArea(
        xMin: linearTransform(
          primaryAxisBarRange.min,
          rangeA: primaryAxisDatasetRange,
          rangeB: canvasXAxisRange,
        ),
        xMax: linearTransform(
          primaryAxisBarRange.max,
          rangeA: primaryAxisDatasetRange,
          rangeB: canvasXAxisRange,
        ),
        yMin: linearTransform(
          secondaryAxisBarRange.max,
          rangeA: secondaryAxisDatasetRange,
          rangeB: canvasYAxisRange.inverted(),
        ),
        yMax: linearTransform(
          secondaryAxisBarRange.min,
          rangeA: secondaryAxisDatasetRange,
          rangeB: canvasYAxisRange.inverted(),
        ),
      );
  }
}
