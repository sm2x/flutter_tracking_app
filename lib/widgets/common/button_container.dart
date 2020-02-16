import 'package:flutter/material.dart';

class ButtonContainer extends StatelessWidget {
  final IconData iconData;
  final Function onTap;
  final double height;
  final double width;
  final Color containerColor;
  final Color iconColor;
  ButtonContainer({this.iconData, this.onTap, this.height, this.width, this.containerColor, this.iconColor});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: containerColor, boxShadow: [
          BoxShadow(color: Colors.grey, spreadRadius: 0.5, blurRadius: 3.0),
        ]),
        child: Center(
          child: Icon(
            iconData,
            color: iconColor,
            size: 20,
          ),
        ),
      ),
    );
  }
}
