import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tracking_app/providers/app_provider.dart';
import 'package:flutter_tracking_app/screens/auth/login.dart';
import 'package:flutter_tracking_app/screens/contact_us/contact_us.dart';
import 'package:flutter_tracking_app/screens/devices/device_position.dart';
import 'package:flutter_tracking_app/screens/devices/device_report.dart';
import 'package:flutter_tracking_app/screens/devices/devices.dart';
import 'package:flutter_tracking_app/screens/home/test_polylines.dart';
import 'package:flutter_tracking_app/utilities/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import './screens/home/home_page.dart';
import 'package:flutter_tracking_app/screens/devices/reports.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _appProvider = AppProvider();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics analytics = FirebaseAnalytics();
    return MultiProvider(
      providers: [ChangeNotifierProvider<AppProvider>(create: (context) => _appProvider)],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: kAppTitle,
        theme: ThemeData(primaryColor: kLoginBackgroundColor, textTheme: GoogleFonts.openSansTextTheme()),
        // home: HomePage(),
        initialRoute: '/',
        routes: <String, WidgetBuilder>{
          '/': (context) => Login(),
          '/Login': (context) => Login(),
          '/Home': (context) => HomePage(),
          '/Devices': (context) => DevicesScreen(),
          '/DevicePosition': (context) => DevicePositionScreen(),
          '/DeviceReport': (context) => DeviceReport(),
          '/TestPolylines': (context) => MapPage(),
          '/Reports': (context) => Reports(),
          '/Contactus': (context) => ContactUs(),
        },
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
        ],
      ),
    );
  }
}
