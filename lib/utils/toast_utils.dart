

import 'package:flutter/cupertino.dart';
import 'package:toastification/toastification.dart';

class ToastUtils{



  static getAlert(BuildContext context, String text,Color color){
    toastification.show(
      //sbackgroundColor:color,
      type: ToastificationType.error,
      context: context, // optional if you use ToastificationWrapper
      title: Text(text),
      autoCloseDuration: const Duration(seconds: 5),showProgressBar: false
    );
  }



}