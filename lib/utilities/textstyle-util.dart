import 'package:flutter/material.dart';

class TextStyleUtil {
  static TextStyle getButtonTextStyle({fontSize:18.0}) {
    return TextStyle(
        color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.w700);
  }

  static InputDecoration getFormFieldInputDecoration(caption) {
    return InputDecoration(
        labelText: caption,
        filled: true, 
        fillColor: Colors.white);
  }
}
