import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String btnText;
  final Function onBtnPressed;

  RoundedButton({required this.btnText, required this.onBtnPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
      ),
      onPressed: () => onBtnPressed(),
      child: Text(
        btnText,
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
