import 'package:flutter/cupertino.dart';

List<Map<String, dynamic>> dummyRoutes = [
  {"deviceId": "61", "latitude": 33.57136444444445, "longitude": 73.0367511111111, "altitude": 0.0, "speed": 0.0, "course": 336.0},
  {"deviceId": "62", "latitude": 33.57851111111111, "longitude": 73.04729333333333, "altitude": 0.0, "speed": 0.0, "course": 336.0},
  {"deviceId": "63", "latitude": 33.57824, "longitude": 73.04728888888889, "altitude": 0.0, "speed": 0.0, "course": 336.0},
  {"deviceId": "64", "latitude": 33.571513333333336, "longitude": 73.03970222222223, "altitude": 0.0, "speed": 0.0, "course": 336.0},
  {"deviceId": "65", "latitude": 33.57160666666667, "longitude": 73.03970222222223, "altitude": 0.0, "speed": 0.0, "course": 336.0},
  {"deviceId": "66", "latitude": 33.57216666666667, "longitude": 73.03918666666667, "altitude": 0.0, "speed": 0.0, "course": 336.0},
];

//top left-right circular
BoxDecoration kBoxDecoration1(Color color) => BoxDecoration(
      color: color,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
    );

//google maps api-key
const kGoogleMapsApiKey = "AIzaSyAaOWBBCIKH6KirngrhnkmyZ3h9PVP9sis";

const kLocalStorageKey = "tracking_app";
const kCookieKey = "traccarCookie";
const kRoutePointsLimit = 200;
const kShareAppUrl = "http://vt.monarchtrack.com:8082/";
const kShareAppSubject = "MonarchTrack App";