import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tracking_app/api-services/traccar_client.service.dart';
import 'package:flutter_tracking_app/models/user.model.dart';
import 'package:flutter_tracking_app/providers/app_provider.dart';
import 'package:flutter_tracking_app/utilities/constants.dart';
import 'package:flutter_tracking_app/widgets/layouts/drawer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
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
  Map<MarkerId, Marker> markers = new Map<MarkerId, Marker>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    User _user = Provider.of<AppProvider>(context).getUser();
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
          children: <Widget>[
            _googleMap(context),
            _allDevices(),
          ],
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
        markers: {officeMarker},
      ),
    );
  }

  _createMarker(LatLng latLng) {
    var markerIdVal = markers.length + 1;
    String marKey = markerIdVal.toString();
    final MarkerId markerId = MarkerId(marKey);
    final Marker marker = Marker(markerId: markerId, position: latLng);
    setState(() {
      markers[markerId] = marker;
    });
    print(markers);
  }

  //All devices option
  Widget _allDevices() {
    return Positioned(
      top: 5,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/Devices'),
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              color: Theme.of(context).canvasColor),
          child: ListTile(
            leading: Icon(Icons.local_shipping),
            title: Text('All Devices'),
            trailing: Icon(Icons.arrow_right),
          ),
        ),
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
