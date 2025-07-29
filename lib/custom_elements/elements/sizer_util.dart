import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

extension SizerExt on num {
  /// Calculates the height depending on the device's screen size
  ///
  /// Eg: 20.h -> will take 20% of the screen's height
  double get h => this * SizerUtil.height / 100;

  /// Calculates the width depending on the device's screen size
  ///
  /// Eg: 20.w -> will take 20% of the screen's width
  double get w => this * SizerUtil.width / 100;

  /// Calculates the sp (Scalable Pixel) depending on the device's screen size
  double get sp => this * (SizerUtil.width / 3) / 100;
}


/// Type of Device
///
/// This can be either mobile or tablet
enum DeviceType { mobile, tablet, web, mac, windows, linux, fuchsia }
/// Provides `Context`, `Orientation`, and `DeviceType` parameters to the builder function
typedef ResponsiveBuild = Widget Function(
    BuildContext context,
    Orientation orientation,
    DeviceType deviceType,
    );

class SizerUtil {
  /// Device's BoxConstraints
  static late BoxConstraints boxConstraints;

  /// Device's Orientation
  static late Orientation orientation;

  /// Type of Device
  ///
  /// This can either be mobile or tablet
  static late DeviceType deviceType;

  /// Device's Height
  static late double height;

  /// Device's Width
  static late double width;

  /// Sets the Screen's size and Device's Orientation,
  /// BoxConstraints, Height, and Width
  static void setScreenSize(
      BoxConstraints constraints, Orientation currentOrientation) {
    // Sets boxconstraints and orientation
    boxConstraints = constraints;
    orientation = currentOrientation;

    // Sets screen width and height
    if (orientation == Orientation.portrait) {
      width = boxConstraints.maxWidth;
      height = boxConstraints.maxHeight;
    } else {
      width = boxConstraints.maxHeight;
      height = boxConstraints.maxWidth;
    }

    // Sets ScreenType
    if (kIsWeb) {
      deviceType = DeviceType.web;
    } else if (Platform.isAndroid || Platform.isIOS) {
      if ((orientation == Orientation.portrait && width < 600) ||
          (orientation == Orientation.landscape && height < 600)) {
        deviceType = DeviceType.mobile;
      } else {
        deviceType = DeviceType.tablet;
      }
    } else if (Platform.isMacOS) {
      deviceType = DeviceType.mac;
    } else if (Platform.isWindows) {
      deviceType = DeviceType.windows;
    } else if (Platform.isLinux) {
      deviceType = DeviceType.linux;
    } else {
      deviceType = DeviceType.fuchsia;
    }
  }

  //for responsive web
  static getWebResponsiveSize({smallSize, mediumSize, largeSize}) {
    return width < 600
        ? smallSize //'phone'
        : width >= 600 && width <= 1024
        ? mediumSize //'tablet'
        : largeSize; //'desktop';
  }
}

/// A widget that gets the device's details like orientation and constraints
///
/// Usage: Wrap MaterialApp with this widget
class Sizer extends StatelessWidget {
  const Sizer({Key? key, required this.builder}) : super(key: key);

  /// Builds the widget whenever the orientation changes
  final ResponsiveBuild builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return OrientationBuilder(builder: (context, orientation) {
        SizerUtil.setScreenSize(constraints, orientation);
        return builder(context, orientation, SizerUtil.deviceType);
      });
    });
  }
}