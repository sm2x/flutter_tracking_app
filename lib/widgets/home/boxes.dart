import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tracking_app/models/device.custom.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Boxes extends StatelessWidget {
  final String _image;
  final double lat;
  final double long;
  final String resturantName;
  final DeviceCustomModel device;
  final Completer<GoogleMapController> _controller = Completer();
  Boxes(this._image, this.lat, this.long, this.resturantName, this.device);

  //Future functions
  Future<void> _gotoLocation(double lat, double long) async {
    final GoogleMapController controller = await _controller.future;
    print(long);
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, long),
      zoom: 15,
      tilt: 50.0,
      bearing: 45.0,
    )));
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/DevicePosition', arguments: {"deviceInfo": device}),
      child: Container(
        child: new FittedBox(
          child: Material(
              color: Colors.white,
              elevation: 14.0,
              borderRadius: BorderRadius.circular(24.0),
              shadowColor: Color(0x802196F3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 180,
                    height: 200,
                    child: ClipRRect(
                      borderRadius: new BorderRadius.circular(24.0),
                      child: Image(
                        fit: BoxFit.fill,
                        image: AssetImage(_image),
                      ),
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: myDetailsContainer1(resturantName),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  //Details Container widget
  Widget myDetailsContainer1(String restaurantName) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
              child: Text(
            restaurantName,
            style: TextStyle(color: Color(0xff6200ee), fontSize: 18.0, fontWeight: FontWeight.bold),
          )),
        ),
        SizedBox(height: 5.0),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                height: 10,
                width: 10,
                decoration: BoxDecoration(
                  color: device.isActive ? Colors.yellow : Colors.red,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              SizedBox(width: 10),
              Text(
                device.isActive ? 'Online' : 'Offline',
                style: TextStyle(color: Colors.black54, fontSize: 18.0, fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
        SizedBox(height: 5.0),
        Container(
            child: Text(
          device.phone.toString(),
          style: TextStyle(color: Colors.black54, fontSize: 18.0, fontWeight: FontWeight.bold),
        )),
      ],
    );
  }
}
