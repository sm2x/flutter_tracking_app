import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tracking_app/utilities/constants.dart';
import 'package:flutter_tracking_app/widgets/layouts/drawer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../widgets/home/boxes.dart';
import './websockets.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  Completer<GoogleMapController> _controller = Completer();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Tracking App'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () => {},
            )
          ],
        ),
        body: Stack(
          children: <Widget>[_googleMap(context)],
        ),
        drawer: DrawerLayout());
  }

  /*
   * Build Container Widget on bottom left
   */
  Widget _buildContainer() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20.0),
        height: 150.0,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Boxes(
                "https://apps.olivecliq.com/olivecliqhr/olive_emp_images/2021.jpg",
                33.535090,
                73.089921,
                "DHA House",
              ),
            ),
            SizedBox(
              width: 10.0,
            ),
            Padding(
                padding: EdgeInsets.all(8.0),
                child: Boxes(
                  "https://apps.olivecliq.com/olivecliqhr/olive_emp_images/4168.jpg",
                  33.535090,
                  73.089921,
                  "DHA House",
                ))
          ],
        ),
      ),
    );
  }

  /*
   * Google Map Widget 
   */
  Widget _googleMap(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(target: LatLng(33.519971, 73.087819), zoom: 8),
        onMapCreated: (GoogleMapController controler) {
          _controller.complete();
        },
        markers: {
          officeMarker,
          homeMarker,
          homeMarkerr,
          deviceMarker,
          deviceMarker2,
          deviceMarker3
        },
      ),
    );
  }
}

/*
 * Define markers here
 */
Marker officeMarker = Marker(
  markerId: MarkerId('Trees Office'),
  position: LatLng(33.519971, 73.087819),
  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
  infoWindow: InfoWindow(title: 'Trees Office'),
);

Marker homeMarker = Marker(
  markerId: MarkerId('Home'),
  position: LatLng(33.535090, 73.089921),
  infoWindow: InfoWindow(title: 'Home Marker'),
  icon: BitmapDescriptor.defaultMarker,
);
Marker homeMarkerr = Marker(
  markerId: MarkerId('Home2'),
  position: LatLng(33.535091, 77.089922),
  infoWindow: InfoWindow(title: 'Home Marker2'),
  icon: BitmapDescriptor.defaultMarker,
);

Marker deviceMarker = Marker(
  markerId: MarkerId(dummyRoutes[0]["deviceId"].toString()),
  position: LatLng(dummyRoutes[0]["latitude"], dummyRoutes[0]["longitude"]),
  infoWindow: InfoWindow(title: 'Device'),
  icon: BitmapDescriptor.defaultMarker,
);
Marker deviceMarker2 = Marker(
  markerId: MarkerId(dummyRoutes[1]["deviceId"].toString()),
  position: LatLng(dummyRoutes[1]["latitude"], dummyRoutes[1]["longitude"]),
  infoWindow: InfoWindow(title: 'Device'),
  icon: BitmapDescriptor.defaultMarker,
);
Marker deviceMarker3 = Marker(
  markerId: MarkerId(dummyRoutes[3]["deviceId"].toString()),
  position: LatLng(dummyRoutes[3]["latitude"], dummyRoutes[3]["longitude"]),
  infoWindow: InfoWindow(title: 'Device'),
  icon: BitmapDescriptor.defaultMarker,
);


//get device routes
