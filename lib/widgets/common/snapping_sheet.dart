import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

class CustomSnappingSheet extends StatelessWidget {
  final Widget sheetBelowWidget;
  CustomSnappingSheet({this.sheetBelowWidget});
  @override
  Widget build(BuildContext context) {
    return SnappingSheet(
      grabbingHeight: 50,
      grabbing: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            color: Theme.of(context).canvasColor,
            boxShadow: [
              BoxShadow(blurRadius: 2.0, color: Colors.grey),
            ]),
        child: Center(
          child: Column(
            children: <Widget>[
              Icon(Icons.linear_scale, color: Colors.black26),
              Text(
                'Details',
                style: GoogleFonts.openSans(letterSpacing: 0.5, fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
      sheetBelow: Container(
        height: 300,
        decoration: BoxDecoration(color: Theme.of(context).canvasColor, boxShadow: [
          BoxShadow(blurRadius: 1.0, color: Colors.grey),
        ]),
        child: sheetBelowWidget,
      ),
    );
  }
}
