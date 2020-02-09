import 'package:flutter/material.dart';

class ButtonContainer extends StatelessWidget {
  final IconData iconData;
  final Function onTap;
  final double height;
  final double width;
  ButtonContainer({this.iconData, this.onTap, this.height, this.width});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: Theme.of(context).canvasColor, boxShadow: [
            BoxShadow(color: Colors.grey, spreadRadius: 0.5, blurRadius: 3.0),
          ]),
          child: Center(
            child: Icon(
              iconData,
              color: Colors.black87,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
