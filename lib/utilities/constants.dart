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
const kRoutePointsLimit = 500;
const kShareAppUrl = "http://vt.monarchtrack.com:8082/";
const kShareAppSubject = "MonarchTrack App";
const kLoginWidgetsColor = const Color(0xff304ffe); //blueish
//const kLoginBackgroundColor = const Color(0xffffffff); //white
const kLoginBackgroundColor = const Color(0xFF304ffe);

const kFooterHyperLinkText = "MonarchTrack";
const kFooterHyperLinkUrl = 'https://monarchtrack.com';
const kTokenKey = "sessionToken";
const kCompanyName = 'MonarchTrack';
const kCompanyTitle = "Monarch Tracking Systems";
const kIsloggedInKey = "isLoggedIn";
const kCompanyFBLink = "https://www.facebook.com/monarchTrackingPakistan/";
const kCompanyTwitterLink = "https://twitter.com/TrackMonarch";
const kShareLocationUrl = "http://vt.monarchtrack.com:8085/track";
const kKmUnit = ' km';
const kSpeedUnit = ' km/h';
const kMonarchTrackCookieKey = 'monarchTrackSessionCookie';
const kAppTitle = "MonarchTrack";
Widget kEmptyWidget = Container(width: 0, height: 0);
const kThemeContrastColor = Color(0xFF64b5f6);

