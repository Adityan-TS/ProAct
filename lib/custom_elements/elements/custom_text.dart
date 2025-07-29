
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../custom_elements.dart';

class CustomText extends StatelessWidget {
  CustomText({required this.text, this.key,this.color,this.fontWeight,this.maxLines,this.fontSize,this.textAlign,this.textDecoration,this.fontStyle,this.fontFamily,this.overflow,this.textStyle});

  String text;
  Color? color;
  FontStyle? fontStyle;
  FontWeight? fontWeight;
  double? fontSize;
  int? maxLines;
  String? fontFamily;
  TextOverflow? overflow;
  TextAlign? textAlign;
  TextStyle? textStyle;
  TextDecoration? textDecoration;
  Key? key;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      key: key,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.ellipsis,
      textAlign: textAlign,
      style: textStyle ?? CustomStyles.textStyle(
          fontSize: fontSize,
          fontColor: color,
          textDecoration: textDecoration,fontStyle:fontStyle,
          fontWeight: fontWeight ?? FontWeight.w400,
      ),
    );
  }
}
