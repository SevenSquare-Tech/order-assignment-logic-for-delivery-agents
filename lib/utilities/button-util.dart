import 'package:flutter/material.dart';
import '../utilities/textstyle-util.dart';

class ButtonUtil {
  static RaisedButton getRaiseButton(action, caption, btnColor) {
    return RaisedButton(
      color: btnColor,
      onPressed: action,
      child: Text(
        caption,
        style: TextStyleUtil.getButtonTextStyle(),
      ),
    );
  }
}
