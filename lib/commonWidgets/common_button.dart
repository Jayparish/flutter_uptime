import 'package:flutter/material.dart';

import '../constants/common_constants.dart';
import 'common_text.dart';

class CommonButton extends StatefulWidget {
  final VoidCallback onTap;
  final String title;

  const CommonButton({super.key, required this.onTap, required this.title});

  @override
  State<CommonButton> createState() => _CommonButtonState();
}

class _CommonButtonState extends State<CommonButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(padding: EdgeInsets.all(10),
          backgroundColor:Color(photomallConnectBgColour) ,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
        onPressed: widget.onTap,
        child: CommonText(
          text: widget.title,
          styleFor: 'button',
        ));
  }
}
