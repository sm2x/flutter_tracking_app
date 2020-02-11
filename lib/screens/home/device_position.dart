import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tracking_app/api-services/traccar_client.service.dart';
import 'package:flutter_tracking_app/models/device.custom.dart';
import 'package:flutter_tracking_app/utilities/common_functions.dart';
import 'package:flutter_tracking_app/utilities/constants.dart';
import 'package:flutter_tracking_app/widgets/common/button_container.dart';
import 'package:flutter_tracking_app/widgets/common/snapping_sheet.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:traccar_client/traccar_client.dart';
import 'package:google_map_polyline/google_map_polyline.dart';

const LatLng SOURCE_LOCATION = LatLng(33.533297, 73.089087);

class DevicePositionScreen extends StatefulWidget {
  @override
  _DevicePositionScreenState createState() => _DevicePositionScreenState();
}

class _DevicePositionScreenState extends State<DevicePositionScreen> {
  RefreshController _refreshController = RefreshController(initialRefresh: true);
  List<Device> _devices = [];
  Completer<GoogleMapController> _mapController = Completer();
  // GoogleMapController _mapController;
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
  DeviceCustomModel _lastPositionData;
  double _zoomLevel = 7.0;
  bool _isLoading = false;
  int _initialHours = 3;
  int _lastHours = 3;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(DevicePositionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
  }

  @override
  void dispose() {
    _mapPolylines.clear();
    _markers.clear();
    _points.clear();
    super.dispose();
  }

  //Get device position against positionId
  Future<DeviceCustomModel> _getDevicePosition() async {
    if (_deviceInfo.positionId != null) {
      print(_deviceInfo.positionId);
      try {
        setState(() => _isLoading = true);
        _lastPositionData = await TraccarClientService.getPositionFromId(positionId: _deviceInfo.positionId);
        if (_lastPositionData != null) {
          lastPosition =
              LatLng(_lastPositionData.position.geoPoint.latitude, _lastPositionData.position.geoPoint.longitude);
          _lastUpdated = _lastPositionData.position.date.toLocal();
          _setMapMarker(lastPosition);
          _animateCameraPosition();
          setState(() {});
        }
      } catch (error) {
        _scaffoldKey.currentState
            .showSnackBar(SnackBar(content: Text('Last Position Not Found'), duration: Duration(seconds: 3)));
      }
    } else {
      _scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text('No Available Last Position'), duration: Duration(seconds: 3)));
    }
    setState(() => _isLoading = false);
    return _lastPositionData;
  }

  void _onRefresh(DeviceCustomModel deviceInfo) async {
    _lastHours = _initialHours;
    _getDeviceRoutes(deviceInfo);
    _refreshController.refreshCompleted();
  }

  void _onLoading(DeviceCustomModel deviceInfo) async {
    _lastHours = _initialHours;
    _getDeviceRoutes(deviceInfo);
    if (_routesList.isNotEmpty) {
      _animateCameraPosition();
    }
    _refreshController.loadComplete();
  }

  //Get device report Routes
  void _getDeviceRoutes(DeviceCustomModel deviceInfo) async {
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
        _getDeviceRoutes(deviceInfo);
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
        // print(position);
        _points.add(position);
        _routesList.add(route);
        // create polyLine objects
        PolylineId pId = PolylineId(route.id.toString());
        Polyline polyline =
            Polyline(polylineId: pId, points: _points, width: 3, color: Colors.red, consumeTapEvents: true);
        _mapPolylines[pId] = polyline;
      }
      print(_mapPolylines.length.toString());
    }
    if (_points.isNotEmpty) {
      lastPosition = _points.last;
      _setMapMarker(lastPosition);
    }
  }

  //Set Marker for google map
  void _setMapMarker(LatLng position) async {
    var pinLocationIcon = await CommonFunctions().getCustomMarker(deviceInfo: _deviceInfo, context: context);
    print(_deviceInfo.category);
    MarkerId deviceMarkerId = MarkerId(_deviceInfo.id.toString());
    Marker deviceMarker = Marker(
      markerId: deviceMarkerId,
      position: position,
      onTap: () {},
      infoWindow:
          InfoWindow(title: _deviceInfo.name.toString(), anchor: Offset(0.5, 0.5), snippet: _lastUpdated.toString()),
      icon: pinLocationIcon,
      zIndex: 2,
      anchor: Offset(0.5, 0.5),
    );
    _markers[deviceMarkerId] = deviceMarker;
  }

  // Marker set by Stream //
  void _setMapMarkerByStream(DeviceCustomModel device) async {
    var pinLocationIcon = await CommonFunctions().getCustomMarker(deviceInfo: device, context: context);
    var position = LatLng(device.position.geoPoint.latitude, device.position.geoPoint.longitude);
    MarkerId deviceMarkerId = MarkerId(_deviceInfo.id.toString());
    Marker deviceMarker = Marker(
      markerId: deviceMarkerId,
      position: position,
      onTap: () {},
      infoWindow:
          InfoWindow(title: _deviceInfo.name.toString(), anchor: Offset(0.5, 0.5), snippet: _lastUpdated.toString()),
      icon: pinLocationIcon,
      zIndex: 2,
      anchor: Offset(0.5, 0.5),
    );
    _markers[deviceMarkerId] = deviceMarker;
  }

  //Animate CameraPosition
  void _animateCameraPosition() async {
    _zoomLevel = 11.0;
    GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: lastPosition, zoom: _zoomLevel)));
  }

  // Create AlertDialog
  Future<void> createAlertDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Apply Filters'),
            // titleTextStyle: GoogleFonts.openSans(letterSpacing: 0.5, fontWeight: FontWeight.bold),
            content: Text('content here'),
            actions: <Widget>[
              MaterialButton(
                onPressed: () {},
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
    Color textColor = Theme.of(context).primaryTextTheme.title.color;
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
              LatLng position = LatLng(data.position.geoPoint.latitude, data.position.geoPoint.longitude);
              var text = data.id.toString() +
                  '   ' +
                  data.position.geoPoint.latitude.toString() +
                  '  ' +
                  data.device.id.toString();
              print(data.id.toString() +
                  '  ' +
                  data.position.totalDistance.toString() +
                  '   ' +
                  position.toString() +
                  '   ' +
                  data.device.id.toString() +
                  ' ' +
                  data.position.date.toString() +
                  ' ' +
                  data.position.geoPoint.heading.toString());
              _setMapMarkerByStream(data);
              // setState(() {});
              // _animateCameraPosition();
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

  //Device Info Container
  Widget _deviceInfoWidget(DeviceCustomModel deviceInfo, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: ListTile(
        leading: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: Colors.white),
          height: 30,
          width: 30,
          child: Icon(
            Icons.location_on,
            size: 20,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(deviceInfo.name, style: TextStyle(color: textColor)),
        trailing: Text(
          deviceInfo.isActive ? 'Active' : 'InActive',
          style: TextStyle(color: textColor),
        ),
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
                  // _getDeviceRoutes(deviceInfo);
                  _onLoading(deviceInfo);
                }
              },
              markers: Set<Marker>.of(_markers.values),
              polylines: Set<Polyline>.of(_mapPolylines.values),
            ),
            //Refresh Widget
            _refreshButtonOnMap(deviceInfo),
            _loaderOnMap(),
            _filtersButton(),
            _snappingSheetWidget(),
          ],
        ),
      ),
    );
  }

  // Refresh Button Widget
  Widget _refreshButtonOnMap(deviceInfo) {
    return Positioned(
      top: 10,
      right: 10,
      child: ButtonContainer(
        iconData: Icons.refresh,
        onTap: () => _onRefresh(deviceInfo),
        height: 50,
        width: 50,
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
      right: 10,
      child: ButtonContainer(
        iconData: Icons.filter_list,
        onTap: () => createAlertDialog(context),
        height: 50,
        width: 50,
      ),
    );
  }

  // SnappingSheet widget //
  Widget _snappingSheetWidget() {
    // var lastUpdated = DateTime.parse(_deviceInfo.position.date.toString()).toLocal();
    var lastUpdated = _lastUpdated ?? '';
    var motion = '';
    if (_routesList.isNotEmpty) {
      motion = _lastPositionData.attributes.motion ? 'Moving' : 'Stopped';
    }
    return CustomSnappingSheet(
      sheetBelowWidget: Column(
        children: <Widget>[
          //Name
          Expanded(
            child: ListTile(
              leading: Icon(Icons.person),
              title: Text(_deviceInfo.name.toString() ?? ''),
              subtitle: Text(_deviceInfo.phone.toString() ?? ''),
            ),
          ),
          //Category
          Expanded(
            child: ListTile(
              leading: Icon(CommonFunctions.getIconData(category: _deviceInfo.category ?? '')),
              title: Text(_deviceInfo.category.toString() ?? ''),
              subtitle: Text(_deviceInfo.model.toString() ?? ''),
            ),
          ),
          //Last Communication
          Expanded(
            child: ListTile(
              leading: Icon(Icons.network_wifi),
              title: Text('Last Communication'),
              subtitle: Text(lastUpdated.toString()),
            ),
          ),
          //Status
          Expanded(
            child: ListTile(
              leading: Icon(Icons.directions_walk),
              title: Text('Status'),
              subtitle: Text(motion),
            ),
          )
        ],
      ),
    );
  }
}
