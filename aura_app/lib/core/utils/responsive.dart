import 'package:flutter/material.dart';

class Responsive {
  final BuildContext context;

  Responsive(this.context);

  MediaQueryData get _mq => MediaQuery.of(context);
  Size get _size => _mq.size;

  double get width => _size.width;
  double get height => _size.height;

  double get shortest => _size.shortestSide;
  double get longest => _size.longestSide;

  double get pixelRatio => _mq.devicePixelRatio;
  double get textScale => _mq.textScaleFactor;

  bool get isPortrait => _mq.orientation == Orientation.portrait;
  bool get isLandscape => !isPortrait;

  bool get isSmallPhone => shortest < 360;
  bool get isPhone => shortest >= 360 && shortest < 600;
  bool get isTablet => shortest >= 600 && shortest < 900;
  bool get isLargeTablet => shortest >= 900;
  bool get isDesktop => width >= 1024;

  double w(double percentage) => width * (percentage / 100);

  double h(double percentage) => height * (percentage / 100);

  double text(double size) {
    double scaled = size / textScale;

    if (isTablet) scaled *= 1.2;
    if (isLargeTablet) scaled *= 1.35;
    if (isDesktop) scaled *= 1.55;

    return scaled;
  }

  double radius(double value) {
    if (isLargeTablet || isDesktop) return value * 1.4;
    if (isTablet) return value * 1.2;
    return value;
  }

  double space(double value) {
    if (isLargeTablet) return value * 1.4;
    if (isTablet) return value * 1.2;
    return value;
  }

  double icon(double value) {
    if (isLargeTablet) return value * 1.5;
    if (isTablet) return value * 1.25;
    return value;
  }

  EdgeInsets get defaultPadding {
    if (isTablet) return EdgeInsets.symmetric(horizontal: w(6));
    if (isLargeTablet) return EdgeInsets.symmetric(horizontal: w(8));
    if (isDesktop) return EdgeInsets.symmetric(horizontal: w(10));
    return EdgeInsets.symmetric(horizontal: w(4));
  }

  EdgeInsets horizontal(double percent) =>
      EdgeInsets.symmetric(horizontal: w(percent));

  EdgeInsets vertical(double percent) =>
      EdgeInsets.symmetric(vertical: h(percent));

  static Responsive of(BuildContext context) => Responsive(context);
}
