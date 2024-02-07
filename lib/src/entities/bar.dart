part of flutter_custom_charts;

// TODO - change secondaryAxisMax and secondaryAxisMin to a Range instance

class ChartIcon {
  ChartIcon({
    required this.icon,
    required this.size,
    required this.color,
  });

  final IconData icon;
  final double size;
  final Color color;
}

// TODO - use this class for all labels/text throughout the library
class ChartText {
  ChartText({
    required this.text,
    required this.style,
  });

  final String text;
  final TextStyle style;
}

class BarDetails {
  BarDetails({
    this.icon,
    this.text,
  });

  final ChartText? text;
  final ChartIcon? icon;
}

class Bar extends PlottableXYEntity with ConstrainedPainter {
  Bar({
    required this.primaryAxisMin,
    required this.primaryAxisMax,
    required this.secondaryAxisMax,
    this.secondaryAxisMin = 0,
    this.fill = Colors.blue,
    this.stroke,
    this.lines = const [],
    this.detailsAbove,
    this.detailsBelow,
  }) : super(sortableValue: primaryAxisMin) {
    if (secondaryAxisMin >= secondaryAxisMax) {
      throw XYChartException('Bar yMin must be less than yMax');
    }
    if (primaryAxisMin >= primaryAxisMax) {
      throw XYChartException('Bar xMin must be less than xMax');
    }
  }

  final Color? fill;
  final Color? stroke;
  final EdgeInsets padding = const EdgeInsets.all(0);
  final double secondaryAxisMax;
  final double secondaryAxisMin;
  final BarDetails? detailsAbove;
  final BarDetails? detailsBelow;

  final double primaryAxisMin;
  final double primaryAxisMax;
  final List<Line> lines;

  double get perceivedHeight => (secondaryAxisMax - secondaryAxisMin).abs();
  double get perceivedWidth => (primaryAxisMax - primaryAxisMin).abs();

  // bool isOutOfBounds(double x, double y) {
  //   return constraints.isOutOfBoundsX(x) ||
  //       y < barArea.yMin ||
  //       y > barArea.yMax;
  // }

  Range get secondaryAxisRange => Range(
        min: secondaryAxisMin,
        max: secondaryAxisMax,
      );

  void _paintDetails(
    Canvas canvas, {
    required ConstrainedArea constraints,
    required BarDetails details,
  }) {
    if (details.text != null) {
      final text = details.text!;
      final tp = TextPainter(
        text: TextSpan(
          text: text.text,
          style: text.style,
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: constraints.width);

      final center = constraints.center();
      final x = center.dx - (tp.width / 2);
      final y = center.dy - (tp.height / 2);
      tp.paint(canvas, Offset(x, y));
    }

    if (details.icon != null) {
      final icon = details.icon!;

      TextSpan span = TextSpan(
        style: TextStyle(
          fontSize: icon.size,
          fontFamily: icon.icon.fontFamily,
          package: icon.icon.fontPackage,
          color: icon.color,
        ),
        text: String.fromCharCode(icon.icon.codePoint),
      );

      TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: constraints.width);

      final center = constraints.center();
      final x = center.dx - (tp.width / 2);
      final y = center.dy - (tp.height / 2);
      tp.paint(canvas, Offset(x, y));
    }
  }

  void paintDetailsAbove(
    Canvas canvas, {
    required ConstrainedArea constraints,
    required BarDetails details,
  }) {
    _paintDetails(
      canvas,
      constraints: constraints,
      details: details,
    );
  }

  void paintDetailsBelow(
    Canvas canvas, {
    required ConstrainedArea constraints,
    required BarDetails details,
  }) {
    _paintDetails(
      canvas,
      constraints: constraints,
      details: details,
    );
  }

  @override
  void paint(
    Canvas canvas, {
    required ConstrainedArea constraints,
    ConstrainedArea? detailsAboveConstraints,
    ConstrainedArea? detailsBelowConstraints,
  }) {
    super.constraints = constraints;

    if (perceivedHeight == 0 ||
        constraints.height == 0 ||
        constraints.width == 0) {
      return;
    }

    Paint? strokePaint;
    Paint? fillPaint;

    if (fill == null && stroke == null) {
      throw XYChartException('Bar fill and stroke cannot both be null');
    }

    if (fill != null) {
      fillPaint = Paint()
        ..color = fill!
        ..style = PaintingStyle.fill;
    }

    if (stroke != null) {
      strokePaint = Paint()
        ..color = stroke!
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
    }

    final l = super.constraints.xMin + padding.left;
    // final t = super.barArea.yMin + padding.top;
    final t = super.constraints.yMin + padding.top;
    final r = super.constraints.xMax - padding.right;
    // final b = super.barArea.yMax - padding.bottom;
    final b = super.constraints.yMax - padding.bottom;

    final bar = Rect.fromLTRB(l, t, r, b);

    if (fill != null) {
      canvas.drawRect(bar, fillPaint!);
    }

    if (stroke != null) {
      canvas.drawRect(bar, strokePaint!);
    }

    if (detailsAboveConstraints != null && detailsAbove != null) {
      paintDetailsAbove(
        canvas,
        constraints: detailsAboveConstraints,
        details: detailsAbove!,
      );
    }

    if (detailsBelowConstraints != null && detailsBelow != null) {
      paintDetailsBelow(
        canvas,
        constraints: detailsBelowConstraints,
        details: detailsBelow!,
      );
    }

    if (lines.isNotEmpty) {
      for (final line in lines) {
        line.paint(
          canvas,
          constraints: ConstrainedArea(
            xMin: l,
            xMax: r,
            yMin: t,
            yMax: b,
          ),
        );
      }
    }
  }

  @override
  bool operator ==(covariant Bar other) {
    if (identical(this, other)) return true;

    return other.secondaryAxisMax == secondaryAxisMax &&
        other.secondaryAxisMin == secondaryAxisMin &&
        other.primaryAxisMax == primaryAxisMax &&
        other.primaryAxisMin == primaryAxisMin;
  }

  @override
  int get hashCode {
    return fill.hashCode ^
        stroke.hashCode ^
        secondaryAxisMax.hashCode ^
        secondaryAxisMin.hashCode ^
        primaryAxisMax.hashCode ^
        primaryAxisMin.hashCode ^
        lines.hashCode;
  }
}
