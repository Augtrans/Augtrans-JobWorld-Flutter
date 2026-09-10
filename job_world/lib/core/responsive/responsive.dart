import 'package:flutter/material.dart';

class Responsive {
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static bool isMobile(BuildContext context) =>
      width(context) < 600;

  static bool isTablet(BuildContext context) =>
      width(context) >= 600 &&
          width(context) < 1024;

  static bool isDesktop(BuildContext context) =>
      width(context) >= 1024;

  static double responsiveValue(
      BuildContext context, {
        required double mobile,
        double? tablet,
        double? desktop,
      }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    }

    if (isTablet(context)) {
      return tablet ?? mobile;
    }

    return mobile;
  }
}