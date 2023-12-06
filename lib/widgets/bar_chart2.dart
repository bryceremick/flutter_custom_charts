  //  switch (controller.barWidthType) {
  //     case BarConstraintMode.auto:
  //       {
  //         final barWidth = totalAvailableBarSpace / controller.bars.length;
  //         for (int i = 0; i < controller.bars.length; i++) {
  //           final xMax = (dx + barWidth).roundToDouble();

  //           // if out of bounds
  //           if (xMax > size.width) {
  //             // should never occur
  //             throw Exception(
  //                 'PAINT ERROR: Bar[$i] width is too large for the available space.');
  //           }

  //           controller.bars[i].setBounds(
  //             index: i,
  //             xMin: dx,
  //             xMax: xMax,
  //             yMin: _determineMinY(
  //               controller.barHeightType,
  //               size.height,
  //               controller.bars[i].height,
  //             ),
  //             yMax: size.height,
  //           );
  //           controller.bars[i].draw(canvas);

  //           // next cube starting x position
  //           dx += barWidth + controller.gap;
  //         }
  //       }
  //       break;
  //     case BarConstraintMode.percentage:
  //       {
  //         _verifyPercentageWidths(
  //           controller.barWidthType,
  //           controller.barHeightType,
  //           controller.bars,
  //         );

  //         for (int i = 0; i < controller.bars.length; i++) {
  //           final barWidth = totalAvailableBarSpace * controller.bars[i].width!;
  //           final xMax = (dx + barWidth).roundToDouble();

  //           // if out of bounds
  //           if (xMax > size.width) {
  //             throw Exception(
  //                 'CHART PAINT ERROR: Bar[$i] width is too large for the available space.');
  //           }

  //           controller.bars[i].setBounds(
  //             index: i,
  //             xMin: dx,
  //             xMax: xMax,
  //             yMin: _determineMinY(
  //               controller.barHeightType,
  //               size.height,
  //               controller.bars[i].height,
  //             ),
  //             yMax: size.height,
  //           );
  //           controller.bars[i].draw(canvas);

  //           // next cube starting x position
  //           dx += barWidth + controller.gap;
  //         }
  //       }
  //       break;
  //     case BarConstraintMode.pixel:
  //       {
  //         for (int i = 0; i < controller.bars.length; i++) {
  //           final barWidth = controller.bars[i].width!;

  //           final xMax = (dx + barWidth).roundToDouble();

  //           // if out of bounds
  //           if (xMax > size.width) {
  //             break;
  //           }

  //           controller.bars[i].setBounds(
  //             index: i,
  //             xMin: dx,
  //             xMax: xMax,
  //             yMin: _determineMinY(
  //               controller.barHeightType,
  //               size.height,
  //               controller.bars[i].height,
  //             ),
  //             yMax: size.height,
  //           );
  //           controller.bars[i].draw(canvas);

  //           // next cube starting x position
  //           dx += barWidth + controller.gap;
  //         }
  //       }
  //       break;
  //   }