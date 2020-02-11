import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tracking_app/models/device.custom.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CommonFunctions {
  static String getMapIconImageAsset({String category}) {
    String mapDescriptor;
    switch (category) {
      case 'car':
        mapDescriptor = "assets/images/car_transparent.png";
        break;
      case 'pickup':
        mapDescriptor = "assets/images/pickup_transparent.png";
        break;
      case 'bike':
        mapDescriptor = "assets/images/bike_transparent.png";
        break;
      case 'offroad':
        mapDescriptor = "assets/images/offroad.png";
        break;
      default:
        mapDescriptor = "assets/images/car_transparent.png";
        break;
    }
    return mapDescriptor;
  }

  /* 
   * Get customMapMarker BitmapDescriptor device-category wise 
   */
  Future<BitmapDescriptor> getCustomMarker({DeviceCustomModel deviceInfo, BuildContext context}) async {
    // String imgAsset = CommonFunctions.getMapIconImageAsset(category: deviceInfo.category.toString());
    // ByteData byteData = await DefaultAssetBundle.of(context).load(imgAsset);
    // Uint8List imageData = byteData.buffer.asUint8List();
    // BitmapDescriptor bitmapDescriptor = BitmapDescriptor.fromBytes(imageData);
    BitmapDescriptor bitmapDescriptor = BitmapDescriptor.defaultMarker;
    return bitmapDescriptor;
  }

  // Get IconData category wise
  static IconData getIconData({String category}) {
    IconData iconData;
    switch (category) {
      case 'car':
        iconData = Icons.directions_car;
        break;
      case 'pickup':
        iconData = Icons.local_shipping;
        break;
      case 'bike':
        iconData = Icons.motorcycle;
        break;
      default:
        iconData = Icons.directions_car;
        break;
    }
    return iconData;
  }

  //showError  Snackbar
  static void showError(_scaffoldKey, message, {context = null}) {
    final snackBar = SnackBar(
      content: Text('Warning : $message'),
      duration: Duration(seconds: 10),
      action: SnackBarAction(
        onPressed: () {},
        label: 'Close',
      ),
    );
    context == null ? _scaffoldKey.currentState.showSnackBar(snackBar) : Scaffold.of(context).showSnackBar(snackBar);
  }

  //showSuccess  Snackbar
  static void showSuccess(_scaffoldKey, String message) {
    final snackBar = SnackBar(
      content: Text('$message'),
      duration: Duration(seconds: 10),
      action: SnackBarAction(
        onPressed: () {},
        label: 'Close',
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
