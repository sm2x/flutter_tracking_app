import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tracking_app/api-services/api_services.dart';
import 'package:flutter_tracking_app/models/device.custom.dart';
import 'package:flutter_tracking_app/providers/app_provider.dart';
import 'package:flutter_tracking_app/screens/devices/devices.dart';
import 'package:flutter_tracking_app/utilities/common_functions.dart';
import 'package:flutter_tracking_app/utilities/constants.dart';
import 'package:flutter_tracking_app/widgets/common/button_container.dart';
import 'package:flutter_tracking_app/widgets/custom_loader.dart';
import 'package:flutter_tracking_app/widgets/layouts/drawer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import '../../widgets/home/boxes.dart';
import 'package:location/location.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _mapController = Completer();
  Map<MarkerId, Marker> markers = new Map<MarkerId, Marker>();
  LocationData currentLocation;
  var location = new Location();
  Map<MarkerId, Marker> _markers = {};
  double _zoomLevel = 7.0;
  AppProvider _appProvider;
  List<DeviceCustomModel> _devices = List<DeviceCustomModel>();

  @override
  void initState() {
    super.initState();
  }

  Future<List<DeviceCustomModel>> _getDevicesWithPosition() async {
    if (_devices.isEmpty) {
      var data = await TraccarClientService().getDevices();
      _appProvider.setDevices(data);
      List<DeviceCustomModel> positions = await TraccarClientService().getDeviceLatestPositions();
      _devices = data;
      for (DeviceCustomModel item in positions) {
        int findDeviceIndex = _devices.indexWhere((row) => row.id == item.device.id);
        item.name = _devices[findDeviceIndex].name;
        _setMapMarker(item, _devices[findDeviceIndex].name, _devices[findDeviceIndex]);
      }
    }
    return _devices;
  }

  //Set Marker for google map
  void _setMapMarker(DeviceCustomModel devicePosition, String name, DeviceCustomModel deviceInfo) async {
    var pinLocationIcon = await CommonFunctions().getCustomMarker(deviceInfo: devicePosition, context: context);
    MarkerId deviceMarkerId = MarkerId(devicePosition.id.toString());
    Marker deviceMarker = Marker(
      markerId: deviceMarkerId,
      position: LatLng(devicePosition.position.geoPoint.latitude, devicePosition.position.geoPoint.longitude),
      infoWindow: InfoWindow(
        title: name.toString(),
        anchor: Offset(0.5, 0.5),
        snippet: 'Click For Tracking',
        onTap: () => Navigator.pushNamed(context, '/DevicePosition', arguments: {"deviceInfo": deviceInfo}),
      ),
      icon: pinLocationIcon,
    );
    _markers[deviceMarkerId] = deviceMarker;
  }

  /* Build Method */
  @override
  Widget build(BuildContext context) {
    _appProvider = Provider.of<AppProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      body: FutureBuilder(
          future: _getDevicesWithPosition(),
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              return SafeArea(
                child: Stack(
                  children: <Widget>[
                    _googleMap(context),
                    _customAppBar(),
                    _optionsListView(),
                    _bottomRightButtons(),
                    _buildContainer(),
                  ],
                ),
              );
            }
            return CustomLoader();
          }),
      drawer: DrawerLayout(),
    );
  }

  /*
   * Build Container Widget on bottom left
   */
  Widget _buildContainer() {
    var devices = _appProvider.getDevices();
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20.0),
        height: 150.0,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: devices.map((item) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Boxes(
                CommonFunctions.getMapIconImageAsset(category: item.category.toString()),
                33.535090,
                73.089921,
                item,
              ),
            );
          }).toList(),
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
        initialCameraPosition: CameraPosition(target: LatLng(33.519971, 73.087819), zoom: 5),
        onMapCreated: (GoogleMapController controller) async {
          if (!_mapController.isCompleted) {
            _mapController.complete(controller);
          }
        },
        markers: Set<Marker>.of(_markers.values),
      ),
    );
  }

  //Custom AppBar
  Widget _customAppBar() {
    Color foreColor = Colors.white;
    return Positioned(
      top: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Container(
          width: MediaQuery.of(context).size.width - 10,
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
                  Icons.blur_on,
                  color: foreColor,
                ),
                onPressed: () {
                  _scaffoldKey.currentState.openDrawer();
                },
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      FontAwesomeIcons.mapMarkerAlt,
                      color: foreColor,
                    ),
                    SizedBox(width: 8),
                    Text(
                      kCompanyName,
                      style: GoogleFonts.pacifico(
                          fontSize: 20, fontWeight: FontWeight.w400, letterSpacing: 0.5, color: foreColor),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(FontAwesomeIcons.signOutAlt, size: 25),
                color: foreColor,
                onPressed: () async {
                  await _appProvider.setLoggedIn(status: false);
                  Navigator.popAndPushNamed(context, '/Login');
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  // options tabs listView Widget //
  Widget _optionsListView() {
    return Positioned(
      top: 70,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            ButtonContainer(
              iconData: Icons.person_pin,
              height: 40.0,
              width: 40.0,
              onTap: () => Navigator.pushNamed(context, DevicesScreen.route),
              containerColor: Theme.of(context).canvasColor,
              iconColor: Colors.black87,
            ),
            // ButtonContainer(iconData: Icons.search, onTap: () {}, height: 40.0, width: 40.0),
          ],
        ),
      ),
    );
  }

  Widget _mapButtonWidget() {
    return Positioned(
      top: 50,
      right: 5,
      child: ButtonContainer(
        iconData: Icons.map,
        onTap: () {},
        height: 40.0,
        width: 40.0,
        containerColor: Theme.of(context).canvasColor,
        iconColor: Colors.black54,
      ),
    );
  }

  Widget _bottomRightButtons() {
    return Positioned(
      bottom: 180,
      right: 5,
      child: Column(
        children: <Widget>[
          // Gps Location Button ///
          ButtonContainer(
            iconData: Icons.location_searching,
            onTap: () {
              _animateCameraPosition();
            },
            height: 50.0,
            width: 50.0,
            containerColor: Theme.of(context).canvasColor,
            iconColor: Colors.black87,
          ),
          SizedBox(height: 10),
          // Share Button //
          // ButtonContainer(
          //   iconData: Icons.share,
          //   onTap: () {
          //     Share.share(kShareAppUrl, subject: kShareAppSubject);
          //   },
          //   height: 50.0,
          //   width: 50.0,
          //   containerColor: Theme.of(context).canvasColor,
          //   iconColor: Colors.black87,
          // ),
        ],
      ),
    );
  }

  //Animate CameraPosition
  void _animateCameraPosition() async {
    currentLocation = await location.getLocation();
    var position = LatLng(currentLocation.latitude, currentLocation.longitude);
    _zoomLevel = 11.0;
    GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: position, zoom: _zoomLevel)));
  }
}
