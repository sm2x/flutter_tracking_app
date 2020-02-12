import 'package:flutter/material.dart';
import 'package:flutter_tracking_app/providers/app_provider.dart';
import 'package:flutter_tracking_app/screens/auth/login.dart';
import 'package:flutter_tracking_app/screens/home/device_position.dart';
import 'package:flutter_tracking_app/screens/home/devices.dart';
import 'package:flutter_tracking_app/screens/home/test_polylines.dart';
import 'package:flutter_tracking_app/utilities/constants.dart';
import 'package:provider/provider.dart';
import './screens/home/home_page.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:sms/sms.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _appProvider = AppProvider();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider<AppProvider>(create: (context) => _appProvider)],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tracking App',
        theme: ThemeData(primaryColor: kLoginBackgroundColor),
        // home: HomePage(),
        initialRoute: '/',
        routes: <String, WidgetBuilder>{
          '/': (context) => _appProvider.isLoggedIn ? HomePage() : Login(),
          '/Login': (context) => Login(),
          '/Home': (context) => HomePage(),
          '/Devices': (context) => DevicesScreen(),
          '/DevicePosition': (context) => DevicePositionScreen(),
          '/TestPolylines': (context) => MapPage(),
        },
      ),
    );
  }
}
