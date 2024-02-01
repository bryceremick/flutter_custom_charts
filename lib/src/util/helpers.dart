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

Offset translatePointToCanvas({
  required double primaryAxisValue,
  required double secondaryAxisValue,
  required Range primaryAxisDatasetRange,
  required Range secondaryAxisDatasetRange,
  required AxisPosition primaryAxisPosition,
  required ConstrainedArea constraints,
}) {
  final canvasXAxisRange = Range(min: constraints.xMin, max: constraints.xMax);
  final canvasYAxisRange = Range(min: constraints.yMin, max: constraints.yMax);
  switch (primaryAxisPosition) {
    case AxisPosition.left:
      return Offset(
        linearTransform(
          secondaryAxisValue,
          rangeA: secondaryAxisDatasetRange,
          rangeB: canvasXAxisRange,
        ),
        linearTransform(
          primaryAxisValue,
          rangeA: primaryAxisDatasetRange,
          rangeB: canvasYAxisRange,
        ),
      );
    case AxisPosition.right:
      return Offset(
        linearTransform(
          secondaryAxisValue,
          rangeA: secondaryAxisDatasetRange,
          rangeB: canvasXAxisRange.inverted(),
        ),
        linearTransform(
          primaryAxisValue,
          rangeA: primaryAxisDatasetRange,
          rangeB: canvasYAxisRange,
        ),
      );
    case AxisPosition.top:
      return Offset(
        linearTransform(
          primaryAxisValue,
          rangeA: primaryAxisDatasetRange,
          rangeB: canvasXAxisRange,
        ),
        linearTransform(
          secondaryAxisValue,
          rangeA: secondaryAxisDatasetRange,
          rangeB: canvasYAxisRange,
        ),
      );
    case AxisPosition.bottom:
      return Offset(
        linearTransform(
          primaryAxisValue,
          rangeA: primaryAxisDatasetRange,
          rangeB: canvasXAxisRange,
        ),
        linearTransform(
          secondaryAxisValue,
          rangeA: secondaryAxisDatasetRange,
          rangeB: canvasYAxisRange.inverted(),
        ),
      );
  }
}

double calculateDragDelta(
  double delta, {
  required Range canvasRange,
  required Range implicitDatasetRange,
  required Range explicitDatasetRange,
}) {
  double canvasAxisRange = canvasRange.difference();
  double totalRange = implicitDatasetRange.difference();
  double canvasProportion = explicitDatasetRange.difference() / totalRange;
  double deltaPerPx = totalRange / canvasAxisRange;
  return delta * deltaPerPx * canvasProportion;
}

void paintRectangle(
  Canvas canvas, {
  required ConstrainedArea constraints,
  required Color fill,
}) {
  final background = Rect.fromLTRB(
    constraints.xMin,
    constraints.yMin,
    constraints.xMax,
    constraints.yMax,
  );
  canvas.drawRect(
    background,
    Paint()
      ..color = fill
      ..style = PaintingStyle.fill,
  );
}

ConstrainedArea determineAxisDetailsConstraints({
  required ConstrainedArea constraints,
  required AxisPosition position,
  required double detailsCrossAxisPixelSize,
}) {
  switch (position) {
    case AxisPosition.left:
      return constraints.copyWith(
        xMin: constraints.xMin - detailsCrossAxisPixelSize,
        xMax: constraints.xMin,
      );
    case AxisPosition.right:
      return constraints.copyWith(
        xMin: constraints.xMax,
        xMax: constraints.xMax + detailsCrossAxisPixelSize,
      );
    case AxisPosition.top:
      return constraints.copyWith(
        yMin: constraints.yMin - detailsCrossAxisPixelSize,
        yMax: constraints.yMin,
      );
    case AxisPosition.bottom:
      return constraints.copyWith(
        yMin: constraints.yMax,
        yMax: constraints.yMax + detailsCrossAxisPixelSize,
      );
  }
}

bool isSecondaryAxisInverted(AxisPosition primary) {
  switch (primary) {
    case AxisPosition.left:
    case AxisPosition.top:
      return false;
    case AxisPosition.right:
    case AxisPosition.bottom:
      return true;
  }
}
