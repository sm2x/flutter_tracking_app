import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tracking_app/api-services/traccar_client.service.dart';
import 'package:flutter_tracking_app/models/device.custom.dart';
import 'package:flutter_tracking_app/utilities/common_functions.dart';
import 'package:flutter_tracking_app/utilities/constants.dart';
import 'package:flutter_tracking_app/widgets/common/button_container.dart';
import 'package:flutter_tracking_app/widgets/common/snapping_sheet.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traccar_client/traccar_client.dart';
import 'package:google_map_polyline/google_map_polyline.dart';

const LatLng SOURCE_LOCATION = LatLng(33.533297, 73.089087);

class DevicePositionScreen extends StatefulWidget {
  static const String route = '/DevicePosition';
  @override
  _DevicePositionScreenState createState() => _DevicePositionScreenState();
}

class _DevicePositionScreenState extends State<DevicePositionScreen> {
  RefreshController _refreshController = RefreshController(initialRefresh: true);
  List<Device> _devices = [];
  Completer<GoogleMapController> _mapController = Completer();
  GoogleMapPolyline googleMapPolyline = new GoogleMapPolyline(apiKey: kGoogleMapsApiKey);
  Map<MarkerId, Marker> markers = new Map<MarkerId, Marker>();
  List<LatLng> routeCoords;
  final List<LatLng> _points = <LatLng>[];
  final List<Device> _routesList = <Device>[];
  DeviceCustomModel _deviceInfo;
  Map<MarkerId, Marker> _markers = {};
  Map<PolylineId, Polyline> _mapPolylines = {};
  LatLng lastPosition = LatLng(SOURCE_LOCATION.latitude, SOURCE_LOCATION.longitude);
  DateTime _lastUpdated;
  double _lastSpeed;
  DeviceCustomModel _lastPositionData;
  double _zoomLevel = 7.0;
  double _camTilt = 0.0;
  double _camBearing = 0.0;
  bool _isLoading = false;
  int _initialHours = 3;
  int _lastHours = 3;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DeviceAttributes _deviceAttributes = DeviceAttributes();
  Circle _markerCircle;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(DevicePositionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _mapPolylines.clear();
    _markers.clear();
    _points.clear();
    _routesList.clear();
    super.dispose();
  }

  //Get device position against positionId
  Future<DeviceCustomModel> _getDevicePosition() async {
    if (_deviceInfo != null) {
      try {
        _deviceInfo = await TraccarClientService.getDeviceInfo(deviceId: _deviceInfo.id); //get latest deviceInfo
        if (_deviceInfo.positionId != null) {
          try {
            setState(() => _isLoading = true);
            _lastPositionData = await TraccarClientService.getPositionFromId(positionId: _deviceInfo.positionId);
            if (_lastPositionData != null) {
              _deviceAttributes = _lastPositionData.attributes;
              lastPosition =
                  LatLng(_lastPositionData.position.geoPoint.latitude, _lastPositionData.position.geoPoint.longitude);
              _lastUpdated = _lastPositionData.position.date.toLocal();
              _lastSpeed = _lastPositionData.position.geoPoint.speed;
              _setMapMarker(_lastPositionData, _deviceInfo);
              _animateCameraPosition(_lastPositionData);
            }
          } catch (error) {
            _scaffoldKey.currentState
                .showSnackBar(SnackBar(content: Text('Last Position Not Found'), duration: Duration(seconds: 3)));
          }
        } else {
          _scaffoldKey.currentState
              .showSnackBar(SnackBar(content: Text('No Available Last Position'), duration: Duration(seconds: 3)));
        }
      } catch (error) {
        _scaffoldKey.currentState
            .showSnackBar(SnackBar(content: Text('Device Not Found'), duration: Duration(seconds: 3)));
      }
    }

    setState(() => _isLoading = false);
    return _lastPositionData;
  }

  void _onRefresh(DeviceCustomModel deviceInfo) async {
    _lastHours = _initialHours;
    await _getDeviceRoutes(deviceInfo);
    if (_routesList.isNotEmpty) {
      _animateCameraPosition(_lastPositionData);
    }
    _refreshController.refreshCompleted();
  }

  //Get device report Routes
  Future<void> _getDeviceRoutes(DeviceCustomModel deviceInfo) async {
    if (_lastHours < 24) {
      setState(() {
        _isLoading = true;
      });
      List<Device> data = await TraccarClientService().getDeviceRoutes(
        date: DateTime.now(),
        since: Duration(hours: _lastHours),
        deviceInfo: deviceInfo,
      );
      if (data.isNotEmpty) {
        _setPolyLinePoints(data);
        if (mounted) {
          setState(() {
            _devices = data;
          });
        }
      } else {
        _lastHours += 3;
        await _getDeviceRoutes(deviceInfo);
        return;
      }
      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("No Activity Since $_lastHours hrs"),
        duration: Duration(seconds: 3),
      ));
    }
  }

  //Get PolyLine points from routes
  void _setPolyLinePoints(List<Device> data) {
    if (data.length > 0) {
      _points.clear();
      _routesList.clear();
      // Reducing routes List //
      if (data.length > kRoutePointsLimit) {
        for (var i = 0; i < data.length; i++) {
          if (data.length > kRoutePointsLimit) {
            data.removeAt(0);
          }
        }
      }
      for (Device route in data) {
        var position = LatLng(route.position.geoPoint.latitude, route.position.geoPoint.longitude);
        _points.add(position);
        _routesList.add(route);
        // create polyLine objects
        PolylineId pId = PolylineId(route.id.toString());
        Polyline polyline =
            Polyline(polylineId: pId, points: _points, width: 3, color: Colors.red, consumeTapEvents: true);
        _mapPolylines[pId] = polyline;
      }
    }
    if (_points.isNotEmpty) {
      lastPosition = _points.last;
      _setMapMarker(data.last, _deviceInfo);
    }
  }

  // Marker set by Stream //
  void _setMapMarker(DeviceCustomModel devicePosition, DeviceCustomModel deviceInfo) async {
    var pinLocationIcon = await CommonFunctions().getCustomMarker(deviceInfo: devicePosition, context: context);
    var position = LatLng(devicePosition.position.geoPoint.latitude, devicePosition.position.geoPoint.longitude);
    MarkerId deviceMarkerId = MarkerId(deviceInfo.id.toString());
    Marker deviceMarker = Marker(
      markerId: deviceMarkerId,
      position: position,
      onTap: () {},
      infoWindow: InfoWindow(
        title: deviceInfo.name.toString(),
        anchor: Offset(0.5, 0.5),
        snippet: CommonFunctions.formatDateTime(_lastUpdated).toString(),
      ),
      icon: pinLocationIcon,
      zIndex: 2,
    );
    _markers[deviceMarkerId] = deviceMarker;
    CircleId mapCircleId = CircleId("deviceCircle");
    _markerCircle = Circle(
      circleId: mapCircleId,
      radius: devicePosition.position.geoPoint.accuracy,
      zIndex: 1,
      strokeColor: Colors.blue,
      center: position,
      fillColor: Colors.blue.withAlpha(70),
    );
  }

  //Animate CameraPosition
  void _animateCameraPosition(DeviceCustomModel devicePosition) async {
    GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: CommonFunctions.getLatLng(devicePosition.position.geoPoint),
        zoom: _zoomLevel,
        tilt: _camTilt,
        bearing: _camBearing)));
  }

  //On Camera Move
  void _onCameraMove(CameraPosition camPostion) {
    _zoomLevel = camPostion.zoom;
    _camTilt = camPostion.tilt;
    _camBearing = camPostion.bearing;
  }

  // Create AlertDialog
  Future<void> createAlertDialog(BuildContext context) {
    final userNameController = TextEditingController(text: 'admin');
    final passwordController = TextEditingController(text: 'monarch@account14');
    final usernameField = TextFormField(
      controller: userNameController,
      cursorColor: Colors.white,
      decoration: InputDecoration(labelText: 'Username'),
    );
    final passwordField = TextFormField(
      obscureText: true,
      controller: passwordController,
      decoration: InputDecoration(
        labelText: 'Password',
      ),
    );
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Apply Filters'),
            // titleTextStyle: GoogleFonts.openSans(letterSpacing: 0.5, fontWeight: FontWeight.bold),
            content: Container(
              child: Column(
                children: <Widget>[
                  usernameField,
                  passwordField,
                ],
              ),
            ),
            actions: <Widget>[
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                  _onRefresh(_deviceInfo);
                },
                elevation: 5.0,
                child: Text('Submit'),
              ),
              MaterialButton(elevation: 5.0, child: Text('Close'), onPressed: () => Navigator.pop(context)),
            ],
          );
        });
  }

  // Build Method //
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    _deviceInfo = args["deviceInfo"];
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_deviceInfo.name.toString()),
        centerTitle: true,
        actions: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                children: <Widget>[
                  Container(
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                      color: _deviceInfo.isActive ? Colors.yellow : Colors.red,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(_deviceInfo.isActive ? 'Active' : 'Inactive'),
                ],
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: TraccarClientService().getDevicePositionsStream,
        builder: (BuildContext context, AsyncSnapshot snapShot) {
          if (snapShot.hasData) {
            DeviceCustomModel data = snapShot.data;
            if (data.device.id == _deviceInfo.id) {
              _devices.add(data);
              _lastSpeed = data.position.geoPoint.speed;
              _lastPositionData = data;
              _deviceAttributes = _lastPositionData.attributes;
              _setPolyLinePoints(_devices);
              _setMapMarker(data, _deviceInfo);
              if (_mapController.isCompleted) {
                return Column(
                  children: <Widget>[
                    _renderMap(_deviceInfo),
                  ],
                );
              }
            }
          }
          return Column(
            children: <Widget>[
              _renderMap(_deviceInfo),
            ],
          );
        },
      ),
    );
  }

  // Google Map //
  Widget _renderMap(DeviceCustomModel deviceInfo) {
    return Expanded(
      child: Container(
        child: Stack(
          children: <Widget>[
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(target: lastPosition, zoom: _zoomLevel),
              onMapCreated: (GoogleMapController controller) async {
                if (!_mapController.isCompleted) {
                  _mapController.complete(controller);
                  await _getDevicePosition();
                  _onRefresh(deviceInfo);
                }
              },
              onCameraMove: _onCameraMove,
              markers: Set<Marker>.of(_markers.values),
              polylines: Set<Polyline>.of(_mapPolylines.values),
              // circles: {_markerCircle},
            ),
            //Refresh Widget
            _refreshButtonOnMap(deviceInfo),
            // _filtersButton(),
            _loaderOnMap(),
            _speedWidget(),
            _ignitionWidget(),
            _shareLocationWidget(),
            _snappingSheetWidget(),
          ],
        ),
      ),
    );
  }

  Widget _speedWidget() {
    return Positioned(
      top: 10,
      left: 10,
      child: Container(
        height: 50,
        width: 50,
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(30), color: Theme.of(context).primaryColor, boxShadow: [
          BoxShadow(color: Colors.grey, spreadRadius: 0.5, blurRadius: 3.0),
        ]),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Icon(
                FontAwesomeIcons.tachometerAlt,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(height: 1),
              Text(_lastSpeed != null ? _lastSpeed.round().toString() + kSpeedUnit : '',
                  style: TextStyle(fontSize: 11, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ignitionWidget() {
    return Positioned(
      top: 70,
      left: 10,
      child: Container(
        height: 50,
        width: 50,
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(30), color: Theme.of(context).primaryColor, boxShadow: [
          BoxShadow(color: Colors.grey, spreadRadius: 0.5, blurRadius: 3.0),
        ]),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Icon(
                FontAwesomeIcons.key,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(height: 1),
              Text(
                _deviceAttributes.ignition != null ? _deviceAttributes.ignition ? 'On' : 'Off' : 'Off',
                style: TextStyle(fontSize: 11, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Share Location Widget
  Widget _shareLocationWidget() {
    return Positioned(
      top: 130,
      left: 10,
      child: Container(
        height: 50,
        width: 50,
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(30), color: Theme.of(context).primaryColor, boxShadow: [
          BoxShadow(color: Colors.grey, spreadRadius: 0.5, blurRadius: 3.0),
        ]),
        child: InkWell(
          onTap: () async {
            String token = (await SharedPreferences.getInstance()).getString(kTokenKey);
            Share.share(kShareLocationUrl + '?token=' + token, subject: 'Sharing Location');
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Icon(
                  FontAwesomeIcons.mapMarkerAlt,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(height: 1),
                Text(
                  'Share',
                  style: TextStyle(fontSize: 11, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Refresh Button Widget
  Widget _refreshButtonOnMap(deviceInfo) {
    return Positioned(
      top: 10,
      right: 4,
      child: ButtonContainer(
        iconData: Icons.refresh,
        onTap: () => _onRefresh(deviceInfo),
        height: 50,
        width: 50,
        containerColor: Theme.of(context).primaryColor,
        iconColor: Colors.white,
      ),
    );
  }

  // Loader on Map //
  Widget _loaderOnMap() {
    return _isLoading
        ? Center(
            child: SizedBox(
              child: CircularProgressIndicator(strokeWidth: 2.0, backgroundColor: Colors.white),
              height: 30,
              width: 30,
            ),
          )
        : Center();
  }

  // Filters Button //
  Widget _filtersButton() {
    return Positioned(
      top: 70,
      right: 5,
      child: ButtonContainer(
        iconData: Icons.filter_list,
        onTap: () => createAlertDialog(context),
        height: 50,
        width: 50,
        containerColor: Theme.of(context).primaryColor,
        iconColor: Colors.white,
      ),
    );
  }

  // SnappingSheet widget //
  Widget _snappingSheetWidget() {
    var motion = '';
    if (_routesList.isNotEmpty) {
      if (_deviceAttributes != null) {
        motion = _deviceAttributes.motion ? 'Moving' : 'Stopped';
      }
    }
    return CustomSnappingSheet(
      sheetBelowWidget: Column(
        children: <Widget>[
          _sheetWidgetChild(
            leading: Icons.person,
            title: Text(_deviceInfo.name.toString() ?? ''),
            subtitle: Text(_deviceInfo.phone.toString() ?? ''),
          ),
          _sheetWidgetChild(
            leading: CommonFunctions.getIconData(category: _deviceInfo.category) ?? '',
            title: Text((_deviceInfo.model == null ? 'Category' : _deviceInfo.category.toString())),
            subtitle: Text(_deviceInfo.model == null ? _deviceInfo.category.toString() : _deviceInfo.model.toString()),
          ),
          _sheetWidgetChild(
            leading: Icons.network_wifi,
            title: Text('Last Communication'),
            subtitle: Text(CommonFunctions.formatDateTime(_lastUpdated).toString()),
          ),
          _sheetWidgetChild(
            leading: Icons.directions_walk,
            title: Text('Status'),
            subtitle: Text(motion),
          ),
          _lastPositionData != null
              ? _sheetWidgetChild(
                  leading: FontAwesomeIcons.route,
                  title: Text('Route Interval'),
                  subtitle: Text(
                    DateFormat.jm().format(DateTime.now().subtract(Duration(hours: _lastHours))).toString() +
                        ' To ' +
                        DateFormat.jm().format(DateTime.now()).toString(),
                  ),
                )
              : Text(''),
          _sheetWidgetChild(
            leading: FontAwesomeIcons.tachometerAlt,
            title: Text('Odometer'),
            subtitle: Text(_deviceAttributes != null ? _deviceAttributes.odometer.toString() + kKmUnit : ''),
          ),
        ],
      ),
    );
  }

  Widget _sheetWidgetChild({IconData leading, Widget title, Widget subtitle}) {
    return Expanded(
      child: ListTile(
        leading: Icon(leading, color: Theme.of(context).primaryColor),
        title: title,
        subtitle: subtitle,
      ),
    );
  }
}
