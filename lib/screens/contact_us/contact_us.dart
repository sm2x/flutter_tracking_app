import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tracking_app/animation/fadeAnimation.dart';
import 'package:flutter_tracking_app/utilities/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ContactUs extends StatefulWidget {
  @override
  _ContactUsState createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  static LatLng position = LatLng(kOfficeLocation.latitude, kOfficeLocation.longitude);

  Completer<GoogleMapController> _mapController = Completer();
  LatLng lastPosition = LatLng(position.latitude, position.longitude);
  bool hideContactInfo = false;
  Map<MarkerId, Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _setMapMarker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            _googleMap(context),
            _customAppBar(),
            !hideContactInfo ? _contactInfo() : kEmptyWidget,
          ],
        ),
      ),
    );
  }

  Widget _contactInfo() {
    var textStyle = TextStyle(color: Colors.black87, letterSpacing: 0.5, fontSize: 15);
    return Positioned(
      bottom: 25,
      child: FadeAnimation(
        0.5,
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Material(
            elevation: 3.0,
            borderRadius: BorderRadius.circular(30),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width - 20,
                height: 200,
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: Icon(
                          Icons.contact_phone,
                          color: kThemeContrastColor,
                        ),
                        title: Text(
                          kOfficePhone,
                          style: textStyle,
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.email,
                          color: kThemeContrastColor,
                        ),
                        title: Text(
                          kOfficeEmail,
                          style: textStyle,
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.my_location,
                          color: kThemeContrastColor,
                        ),
                        title: Text(
                          kOfficeAddress,
                          style: textStyle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //Custom AppBar
  Widget _customAppBar() {
    Color foreColor = Colors.white;
    return Positioned(
      top: 10,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          width: MediaQuery.of(context).size.width - 20,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(color: Colors.grey, blurRadius: 1.5, spreadRadius: 0.2),
              BoxShadow(color: Colors.grey, blurRadius: 1.5, spreadRadius: 0.2),
            ],
          ),
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: foreColor,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Contact Us',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, letterSpacing: 0.5, color: foreColor),
                    ),
                    SizedBox(width: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contactMap() {}

  Widget _googleMap(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(target: LatLng(lastPosition.latitude, lastPosition.longitude), zoom: 15),
        onMapCreated: (GoogleMapController controller) async {
          if (!_mapController.isCompleted) {
            _mapController.complete(controller);
            _animateCameraPosition();
          }
        },
        markers: Set<Marker>.of(_markers.values),
        onTap: (latlng) => setState(() => hideContactInfo = false),
      ),
    );
  }

  void _animateCameraPosition() async {
    GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(kOfficeLocation.latitude, kOfficeLocation.longitude), zoom: 15)));
  }

  void _setMapMarker() async {
    MarkerId deviceMarkerId = MarkerId('office');
    Marker deviceMarker = Marker(
      markerId: deviceMarkerId,
      position: LatLng(position.latitude, position.longitude),
      icon: BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(
        title: kCompanyName,
      ),
      onTap: () => setState(() => hideContactInfo = true),
    );
    _markers[deviceMarkerId] = deviceMarker;
  }

  Marker officeMarker = Marker(
    markerId: MarkerId('office'),
    position: LatLng(position.latitude, position.longitude),
    icon: BitmapDescriptor.defaultMarker,
    infoWindow: InfoWindow(
      title: kCompanyName,
    ),
  );
}
