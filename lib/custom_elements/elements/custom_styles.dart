import 'package:flutter/material.dart';
import '../custom_elements.dart';

class CustomStyles {
  static TextStyle textStyle(
      {String? fontFamily,
      double? fontSize,
      Color? fontColor,
      TextDecoration? textDecoration,
      FontStyle? fontStyle,
      FontWeight? fontWeight}) {
    return TextStyle(
        fontFamily: 'Palanquin',
        fontStyle: fontStyle,decorationColor: CustomColors.primary,
        decoration: textDecoration,
        fontSize: fontSize ?? (15),
        color: fontColor,
        fontWeight: fontWeight);
  }
}
