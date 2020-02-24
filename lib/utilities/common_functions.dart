import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_tracking_app/models/device.custom.dart';
import 'package:flutter_tracking_app/utilities/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class CommonFunctions {
  //Get mapIcon image path from assets
  static String getMapIconImageAsset({String category}) {
    String mapDescriptor;
    switch (category) {
      case 'car':
        mapDescriptor = "assets/images/car_transparent.png";
        break;
      case 'pickup':
        mapDescriptor = "assets/images/pickup_transparent.png";
        break;
      case 'motorcycle':
        mapDescriptor = "assets/images/bike_transparent.png";
        break;
      case 'offroad':
        mapDescriptor = "assets/images/offroad.png";
        break;
      case 'truck':
        mapDescriptor = "assets/images/truck_transparent.png";
        break;
      case 'van':
        mapDescriptor = "assets/images/van_transparent.png";
        break;
      default:
        mapDescriptor = "assets/images/car_transparent.png";
        break;
    }
    return mapDescriptor;
  }

  static String getImageForMarker({String category}) {
    String mapDescriptor;
    switch (category) {
      case 'car':
        mapDescriptor = "assets/images/map/car.png";
        break;
      case 'pickup':
        mapDescriptor = "assets/images/map/pickup.png";
        break;
      case 'motorcycle':
        mapDescriptor = "assets/images/map/bike.png";
        break;
      case 'offroad':
        mapDescriptor = "assets/images/map/pickup.png";
        break;
      case 'truck':
        mapDescriptor = "assets/images/map/truck.png";
        break;
      case 'van':
        mapDescriptor = "assets/images/map/van.png";
        break;
      default:
        mapDescriptor = "assets/images/map/car.png";
        break;
    }
    return mapDescriptor;
  }

  /* 
   * Get customMapMarker BitmapDescriptor device-category wise 
   */
  Future<BitmapDescriptor> getCustomMarker({String category, BuildContext context}) async {
    String imgAsset = CommonFunctions.getImageForMarker(category: category.toString());
    ByteData byteData = await DefaultAssetBundle.of(context).load(imgAsset);
    Uint8List imageData = byteData.buffer.asUint8List();
    BitmapDescriptor bitmapDescriptor = BitmapDescriptor.fromBytes(imageData);
    // BitmapDescriptor bitmapDescriptor = BitmapDescriptor.defaultMarker;
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
      case 'van':
        iconData = FontAwesomeIcons.shuttleVan;
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

  //Show Datetime Pattern
  static formatDateTime(dateTime) {
    return dateTime != null ? DateFormat.yMMMd().add_jms().format(dateTime) : '';
  }

  //Get LatLng from deviceCustomModel
  static LatLng getLatLng(geoPoint) {
    return LatLng(geoPoint.latitude, geoPoint.longitude);
  }

  //Label for Device Motion
  static String getMotion({String motion}) {
    return motion == 'moving' ? 'Moving' : 'Stopped';
  }

  //Label for Device Odometer
  static String getOdometerString({int odometer}) {
    return odometer == null ? 'not availble' : odometer.toString() + kKmUnit;
  }
}
