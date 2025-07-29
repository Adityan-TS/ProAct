import 'dart:math' as math;

import 'package:flutter/services.dart';

class TimeTextInputFormatter extends TextInputFormatter {
  TimeTextInputFormatter(
      {required this.hourMaxValue, required this.minuteMaxValue}) {
    _exp = RegExp(r'^$|[0-9:]+$');
  }
  late RegExp _exp;

  final int hourMaxValue;
  final int minuteMaxValue;
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (_exp.hasMatch(newValue.text)) {
    TextSelection newSelection = newValue.selection;

    final String value = newValue.text;
    String newText;

    String leftChunk = '';
    String rightChunk = '';

    if (value.length > 1 &&
        (int.tryParse(value.substring(0, 2)) ?? 0) == hourMaxValue)
    //this logic is to restrict value more than max hour
    {
      if (oldValue.text.contains(':')) {
        leftChunk = value.substring(0, 1);
      } else {
        leftChunk = '${value.substring(0, 2)}:';
        rightChunk = '00';
      }
    } else if (value.length > 5) {
      //this logic is to not allow more value
      leftChunk = oldValue.text;
    } else if (value.length == 5) {
      if ((int.tryParse(value.substring(3)) ?? 0) > minuteMaxValue) {
        //this logic is to restrict value more than max minute
        leftChunk = oldValue.text;
      } else {
        leftChunk = value;
      }
    } else if (value.length == 2) {
      if (oldValue.text.contains(':')) {
        //this logic is to delete : & value before : ,when backspacing
        leftChunk = value.substring(0, 1);
      } else {
        if ((int.tryParse(value) ?? 0) > hourMaxValue) {
          //this logic is to restrict value more than max hour
          leftChunk = oldValue.text;
        } else {
          //this logic is to add : with second letter
          leftChunk = '${value.substring(0, 2)}:';
          rightChunk = value.substring(2);
        }
      }
    } else {
      leftChunk = value;
    }
    newText = leftChunk + rightChunk;

    newSelection = newValue.selection.copyWith(
      baseOffset: math.min(newText.length, newText.length),
      extentOffset: math.min(newText.length, newText.length),
    );

    return TextEditingValue(
      text: newText,
      selection: newSelection,
    ); }
    return oldValue;
  }
}