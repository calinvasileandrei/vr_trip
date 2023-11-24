import 'package:flutter/material.dart';

class MyText extends StatelessWidget {
  final textValue;
  TextStyle? textStyle;

  MyText(this.textValue,{super.key, this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Flexible(
        child: Text(
      textValue,
      style: textStyle,
      overflow: TextOverflow.fade,
      maxLines: 1,
      softWrap: false,
    ));
  }
}
