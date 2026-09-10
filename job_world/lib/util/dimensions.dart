import 'package:flutter/material.dart';

class Dimensions {

  Dimensions._();

  /// Base design size
  static const double _baseWidth = 375.0;
  static const double _baseHeight = 812.0;

  // ----------------------------------------------------------------
  // SCREEN SIZE
  // ----------------------------------------------------------------

  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // ----------------------------------------------------------------
  // RESPONSIVE SCALE
  // ----------------------------------------------------------------

  static double _scaleFactor(
      BuildContext context) {

    return screenWidth(context) / _baseWidth;
  }

  // ----------------------------------------------------------------
  // RESPONSIVE TEXT
  // ----------------------------------------------------------------

  static double _textScale(
      BuildContext context,
      double size,
      ) {

    double scale =
    _scaleFactor(context);

    double textScale =
        MediaQuery.of(context)
            .textScaleFactor;

    return (size * scale) / textScale;
  }

  // ----------------------------------------------------------------
  // TEXT SIZE
  // ----------------------------------------------------------------

  static double xlargeTextSize(
      BuildContext context) {
    return _textScale(context, 22.0);
  }

  static double largerTextSize(
      BuildContext context) {
    return _textScale(context, 19.0);
  }

  static double largeTextSize(
      BuildContext context) {
    return _textScale(context, 15.0);
  }

  static double mediumTextSize(
      BuildContext context) {
    return _textScale(context, 13.0);
  }

  static double navigationTitleSize(
      BuildContext context) {
    return _textScale(context, 11.0);
  }

  static double smallTextSize(
      BuildContext context) {
    return _textScale(context, 11.0);
  }

  static double superSmallTextSize(
      BuildContext context) {
    return _textScale(context, 9.0);
  }

  static double smallerTextSize(
      BuildContext context) {
    return _textScale(context, 7.0);
  }

  static double subheadingTextSize(
      BuildContext context) {
    return _textScale(context, 7.0);
  }

  static double utilizationTextSize(
      BuildContext context) {
    return _textScale(context, 12.0);
  }

  // ----------------------------------------------------------------
  // MARGIN
  // ----------------------------------------------------------------

  static double level1Margin(
      BuildContext context) {
    return 4.0 * _scaleFactor(context);
  }

  static double level2Margin(
      BuildContext context) {
    return 8.0 * _scaleFactor(context);
  }

  static double level3Margin(
      BuildContext context) {
    return 16.0 * _scaleFactor(context);
  }

  static double level4Margin(
      BuildContext context) {
    return 32.0 * _scaleFactor(context);
  }

  static double level5Margin(
      BuildContext context) {
    return 50.0 * _scaleFactor(context);
  }

  static double stepperMargin(
      BuildContext context) {
    return 6.0 * _scaleFactor(context);
  }

  // ----------------------------------------------------------------
  // PADDING
  // ----------------------------------------------------------------

  static double level0Padding(
      BuildContext context) {
    return 2.0 * _scaleFactor(context);
  }

  static double level1Padding(
      BuildContext context) {
    return 4.0 * _scaleFactor(context);
  }

  static double level2Padding(
      BuildContext context) {
    return 8.0 * _scaleFactor(context);
  }

  // ----------------------------------------------------------------
  // ICON SIZE
  // ----------------------------------------------------------------

  static double iconSize(
      BuildContext context) {
    return 25.0 * _scaleFactor(context);
  }

  // ----------------------------------------------------------------
  // SIZE
  // ----------------------------------------------------------------

  static double smallSize(
      BuildContext context) {
    return 40.0 * _scaleFactor(context);
  }

  static double level1Size(
      BuildContext context) {
    return 50.0 * _scaleFactor(context);
  }

  static double level2Size(
      BuildContext context) {
    return 75.0 * _scaleFactor(context);
  }

  static double level3Size(
      BuildContext context) {
    return 100.0 * _scaleFactor(context);
  }

  static double level4Size(
      BuildContext context) {
    return 125.0 * _scaleFactor(context);
  }

  static double level5Size(
      BuildContext context) {
    return 150.0 * _scaleFactor(context);
  }

  static double level6Size(
      BuildContext context) {
    return 200.0 * _scaleFactor(context);
  }

  static double level7Size(
      BuildContext context) {
    return 380.0 * _scaleFactor(context);
  }

  // ----------------------------------------------------------------
  // EXTRA HELPERS
  // ----------------------------------------------------------------

  static SizedBox verticalSpace(
      BuildContext context,
      double value,
      ) {
    return SizedBox(
      height: value * _scaleFactor(context),
    );
  }

  static SizedBox horizontalSpace(
      BuildContext context,
      double value,
      ) {
    return SizedBox(
      width: value * _scaleFactor(context),
    );
  }
}