import 'package:example/mock_data.dart';
import 'package:flutter/material.dart';

class GradientExample extends StatelessWidget {
  const GradientExample({super.key});
  @override
  Widget build(BuildContext context) {
    int crossAxisCount = MediaQuery.of(context).size.width ~/ 100;
    return GridView.builder(
      // physics: NeverScrollableScrollPhysics(), // Disables scrolling
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.25, // Adjust based on your content
      ),
      itemCount: 200,
      itemBuilder: (context, index) {
        double percentage = index.toDouble();
        Color color = getGradientZoneColorFromPercentage(percentage);
        return Container(
          decoration: BoxDecoration(
            color: color,
            border: zoneMaxes.contains(index)
                ? Border.all(color: Colors.black, width: 5)
                : null,
          ),
          child: Center(
            child: Text('${percentage.toStringAsFixed(0)}%',
                style: TextStyle(color: Colors.white, fontSize: 10)),
          ),
        );
      },
    );
  }
}
