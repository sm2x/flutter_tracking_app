import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
const kLoginWidgetsColor = const Color(0xff42a5f5); //blueish
//const kLoginBackgroundColor = const Color(0xffffffff); //white
const kLoginBackgroundColor = Colors.blueAccent;

const kFooterHyperLinkText = "MonarchTrack";
const kFooterHyperLinkUrl = 'https://monarchtrack.com';
const kTokenKey = "sessionToken";
const kCompanyName = 'MonarchTrack';
const kIsloggedInKey = "isLoggedIn";
