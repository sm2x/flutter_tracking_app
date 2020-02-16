import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tracking_app/api-services/api_services.dart';
import 'package:flutter_tracking_app/config/config.dart';
import 'package:flutter_tracking_app/models/device.custom.dart';
import 'package:flutter_tracking_app/providers/app_provider.dart';
import 'package:flutter_tracking_app/utilities/common_functions.dart';
import 'package:flutter_tracking_app/utilities/constants.dart';
import 'package:flutter_tracking_app/widgets/common/button_container.dart';
import 'package:flutter_tracking_app/widgets/common/snapping_sheet.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traccar_client/traccar_client.dart';
import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:http/http.dart' as http;

const LatLng SOURCE_LOCATION = LatLng(33.533297, 73.089087);

class DeviceReport extends StatefulWidget {
  static const String route = '/DeviceReports';
  @override
  _DeviceReportState createState() => _DeviceReportState();
}

class _DeviceReportState extends State<DeviceReport> {
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
  DateTime _fromDateTimeFilter;
  DateTime _toDateTimeFilter;
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(DeviceReport oldWidget) {
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

  Future _onRefresh(DeviceCustomModel deviceInfo) async {
    _lastHours = _initialHours;
    await _getDeviceRoutesForReports(deviceInfo);
    if (_routesList.isNotEmpty) {
      _animateCameraPosition(_lastPositionData);
    }
    _refreshController.refreshCompleted();
  }

  //Get DeviceRoutes for Reports Filter
  Future<void> _getDeviceRoutesForReports(DeviceCustomModel deviceInfo) async {
    setState(() => _isLoading = true);
    Duration dateTimeDiff = _toDateTimeFilter.difference(_fromDateTimeFilter);
    List<Device> data = await TraccarClientService().getDeviceRoutes(
      date: _toDateTimeFilter,
      since: Duration(hours: dateTimeDiff.inHours),
      deviceInfo: deviceInfo,
    );
    if (data.isNotEmpty) {
      _lastPositionData = data.last;
      _deviceAttributes = _lastPositionData.attributes;
      lastPosition =
          LatLng(_lastPositionData.position.geoPoint.latitude, _lastPositionData.position.geoPoint.longitude);
      _lastUpdated = _lastPositionData.position.date.toLocal();
      _lastSpeed = _lastPositionData.position.geoPoint.speed;
      print(data.length);
      _setPolyLinePoints(data);
      setState(() => _isLoading = false);
    } else {
      setState(() => _isLoading = false);
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("No Activity Since ${dateTimeDiff.inHours} hrs"),
        duration: Duration(seconds: 3),
      ));
    }
  }

  //Get PolyLine points from routes
  void _setPolyLinePoints(List<Device> data) {
    if (data.length > 0) {
      _points.clear();
      _routesList.clear();
      for (Device route in data) {
        var position = LatLng(route.position.geoPoint.latitude, route.position.geoPoint.longitude);
        _points.add(position);
        _routesList.add(route);
      }
      Polyline polyline = Polyline(
        polylineId: PolylineId("polyLine"),
        color: Colors.red,
        points: _points,
        width: 3,
      );

      // add the constructed polyline as a set of points
      // to the polyline set, which will eventually
      // end up showing up on the map
      _polylines.add(polyline);
    }
    print('route-list:' + _routesList.length.toString());
    print('polylines:' + _mapPolylines.length.toString());
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

  Future<void> createLoadingDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
            title: Text(
              'Generating Tracker Link',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            content: FutureBuilder(
                future: TraccarClientService.generateTrackerLink(deviceId: _deviceInfo.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    String sharingUrl = snapshot.data;
                    if (sharingUrl != null) {
                      print(sharingUrl);
                      Share.share(sharingUrl, subject: 'Track Ride Online').then((res) {
                        Navigator.pop(context);
                      });
                    } else {
                      Navigator.pop(context);
                      CommonFunctions.showError(_scaffoldKey, "Couldn't fetch link !");
                    }
                  }
                  return Container(
                    child: LinearProgressIndicator(),
                  );
                }),
          );
        });
  }

  // Build Method //
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    _deviceInfo = args["deviceInfo"];
    _fromDateTimeFilter = args["fromDateTime"];
    _toDateTimeFilter = args["toDateTime"];
    AppProvider appProvider = Provider.of<AppProvider>(context);
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
      body: Column(
        children: <Widget>[
          _renderMap(_deviceInfo),
        ],
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
                  //await _getDevicePosition();
                  await _onRefresh(deviceInfo);
                }
              },
              onCameraMove: _onCameraMove,
              markers: Set<Marker>.of(_markers.values),
              // polylines: Set<Polyline>.of(_mapPolylines.values),
              polylines: _polylines,
            ),
            _speedIgnitionContainer(),
            _refreshButtonOnMap(deviceInfo),
            _loaderOnMap(),
            _shareLocationWidget(),
            _snappingSheetWidget(),
          ],
        ),
      ),
    );
  }

  Widget _speedIgnitionContainer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Container(
        height: 40,
        width: MediaQuery.of(context).size.width / 2.3,
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).canvasColor, boxShadow: [
          BoxShadow(color: Colors.grey, blurRadius: 0.2),
          BoxShadow(color: Colors.grey, blurRadius: 0.2),
        ]),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    FontAwesomeIcons.tachometerAlt,
                    // color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 5),
                  Text(_lastSpeed != null ? _lastSpeed.round().toString() + kSpeedUnit : '',
                      style: TextStyle(fontSize: 13)),
                ],
              ),
              SizedBox(width: 20),
              Row(
                children: <Widget>[
                  Icon(
                    FontAwesomeIcons.key,
                    // color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 5),
                  Text(
                    _deviceAttributes.ignition != null ? _deviceAttributes.ignition ? 'On' : 'Off' : 'Off',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _shareLocationWidget() {
    return Positioned(
      bottom: 60,
      left: 10,
      child: Container(
        height: 60,
        width: 60,
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(30), color: Theme.of(context).primaryColor, boxShadow: [
          BoxShadow(color: Colors.grey, spreadRadius: 0.5, blurRadius: 3.0),
        ]),
        child: InkWell(
          onTap: () async {
            createLoadingDialog(context);
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
      bottom: 130,
      left: 10,
      child: ButtonContainer(
        iconData: Icons.refresh,
        onTap: () => _onRefresh(deviceInfo),
        height: 60,
        width: 60,
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
        iconData: Icons.arrow_forward,
        onTap: () => Navigator.pushNamed(context, '/Reports', arguments: {"deviceInfo": _deviceInfo}),
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
                    DateFormat.jm().format(_fromDateTimeFilter).toString() +
                        ' To ' +
                        DateFormat.jm().format(_toDateTimeFilter).toString(),
                  ),
                )
              : Text(''),
          _deviceAttributes != null
              ? _sheetWidgetChild(
                  leading: FontAwesomeIcons.tachometerAlt,
                  title: Text('Odometer'),
                  subtitle:
                      Text(_deviceAttributes.odometer != null ? _deviceAttributes.odometer.toString() + kKmUnit : ''),
                )
              : Text(''),
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
