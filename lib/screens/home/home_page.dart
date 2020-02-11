import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tracking_app/api-services/traccar_client.service.dart';
import 'package:flutter_tracking_app/models/device.custom.dart';
import 'package:flutter_tracking_app/models/user.model.dart';
import 'package:flutter_tracking_app/providers/app_provider.dart';
import 'package:flutter_tracking_app/screens/home/devices.dart';
import 'package:flutter_tracking_app/utilities/common_functions.dart';
import 'package:flutter_tracking_app/utilities/constants.dart';
import 'package:flutter_tracking_app/widgets/common/button_container.dart';
import 'package:flutter_tracking_app/widgets/layouts/drawer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import '../../widgets/home/boxes.dart';
import './websockets.dart';
import 'package:location/location.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  Completer<GoogleMapController> _mapController = Completer();
  Map<MarkerId, Marker> markers = new Map<MarkerId, Marker>();
  LocationData currentLocation;
  var location = new Location();
  Map<MarkerId, Marker> _markers = {};
  double _zoomLevel = 7.0;
  AppProvider _appProvider;
  List<DeviceCustomModel> _devices = List<DeviceCustomModel>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<List<DeviceCustomModel>> _getDevicesWithPosition() async {
    if (_devices.isEmpty) {
      _isLoading = true;
    }
    print('loading-devices');
    var data = await TraccarClientService().getDevices();
    _appProvider.setDevices(data);
    for (DeviceCustomModel item in data) {
      if (item.isActive) {
        var positionItem = await TraccarClientService.getPositionFromId(positionId: item.positionId);
        _setMapMarker(positionItem);
        _devices.add(positionItem);
      }
    }
    print(_devices.length);
    if (_isLoading == true) {
      _isLoading = false;
      //setState(() {});
    }
    return _devices;
  }

  //Set Marker for google map
  void _setMapMarker(DeviceCustomModel device) async {
    var pinLocationIcon = await CommonFunctions().getCustomMarker(deviceInfo: device, context: context);
    MarkerId deviceMarkerId = MarkerId(device.id.toString());
    Marker deviceMarker = Marker(
      markerId: deviceMarkerId,
      position: LatLng(device.position.geoPoint.latitude, device.position.geoPoint.longitude),
      onTap: () {},
      infoWindow: InfoWindow(title: device.name.toString(), anchor: Offset(0.5, 0.5), snippet: device.position.date.toLocal().toString()),
      icon: pinLocationIcon,
      zIndex: 2,
      anchor: Offset(0.5, 0.5),
    );
    _markers[deviceMarkerId] = deviceMarker;
  }

  /* Build Method */
  @override
  Widget build(BuildContext context) {
    _appProvider = Provider.of<AppProvider>(context);
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
          _optionsListView(),
          _mapButtonWidget(),
          _bottomRightButtons(),
          _buildContainer(),
          FutureBuilder(
            future: _getDevicesWithPosition(),
            builder: (contex, snapshot) {
              var data = snapshot.data;
              if (snapshot.data != null) {
                return Text('CCC');
              }
              return Text('');
            },
          ),
        ],
      ),
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
                item.name.toString(),
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
          _animateCameraPosition();
          _mapController.complete(controller);
          // currentLocation = await location.getLocation();
          //var data = await _getDevicesWithPosition();
          print('length-in-map: ');
        },
        markers: Set<Marker>.of(_markers.values),
      ),
    );
  }

  // options tabs listView Widget //
  Widget _optionsListView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ButtonContainer(iconData: Icons.person_pin, height: 40.0, width: 40.0, onTap: () => Navigator.pushNamed(context, DevicesScreen.route)),
          ButtonContainer(iconData: Icons.search, onTap: () {}, height: 40.0, width: 40.0),
        ],
      ),
    );
  }

  Widget _mapButtonWidget() {
    return Positioned(
      top: 50,
      right: 5,
      child: ButtonContainer(iconData: Icons.map, onTap: () {}, height: 40.0, width: 40.0),
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
              Navigator.pushNamed(context, DevicesScreen.route);
            },
            height: 50.0,
            width: 50.0,
          ),
          SizedBox(height: 10),
          // Share Button //
          ButtonContainer(
            iconData: Icons.share,
            onTap: () {
              Share.share(kShareAppUrl, subject: kShareAppSubject);
            },
            height: 50.0,
            width: 50.0,
          ),
        ],
      ),
    );
  }

  //Animate CameraPosition
  void _animateCameraPosition() async {
    var position = LatLng(currentLocation.latitude, currentLocation.longitude);
    _zoomLevel = 11.0;
    GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: position, zoom: _zoomLevel)));
  }
}
