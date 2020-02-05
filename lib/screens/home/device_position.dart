import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tracking_app/api-services/traccar_client.service.dart';
import 'package:flutter_tracking_app/utilities/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission/permission.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
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
  LatLng _devicePosition;
  final List<LatLng> _points = <LatLng>[];
  Device _deviceInfo;
  Map<MarkerId, Marker> _markers = {};
  Map<PolylineId, Polyline> _mapPolylines = {};
  LatLng lastPosition = LatLng(SOURCE_LOCATION.latitude, SOURCE_LOCATION.longitude);
  double _zoomLevel = 7.0;
  bool _isLoading = false;
  int _lastHours = 11;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _mapPolylines.clear();
    _markers.clear();
    _points.clear();
    super.dispose();
  }

  void _onRefresh(Device deviceInfo) async {
    _getDeviceRoutes(deviceInfo);
    _refreshController.refreshCompleted();
  }

  void _onLoading(Device deviceInfo) async {
    _getDeviceRoutes(deviceInfo);
    _refreshController.loadComplete();
  }

  //Get device report Routes
  void _getDeviceRoutes(Device deviceInfo) async {
    if (_lastHours < 24) {
      setState(() {
        _isLoading = true;
      });
      List<Device> data = await TraccarClientService().getDevicePositions(
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
    }
  }

  //Get PolyLine points from routes
  void _setPolyLinePoints(List<Device> data) {
    if (data.length > 0) {
      _points.clear();
      for (Device route in data) {
        var position = LatLng(route.position.geoPoint.latitude, route.position.geoPoint.longitude);
        print(position);
        _points.add(position);
        //create polyLine objects
        PolylineId pId = PolylineId(route.id.toString());
        Polyline polyline = Polyline(polylineId: pId, points: _points, width: 3, color: Colors.red, consumeTapEvents: true);
        _mapPolylines[pId] = polyline;
      }
    }
    if (_points.isNotEmpty) {
      lastPosition = _points.last;
      _setMapMarker(lastPosition);
      _animateCameraPosition();
    }
  }

  //Set Marker for google map
  void _setMapMarker(LatLng position) {
    MarkerId deviceMarkerId = MarkerId(_deviceInfo.id.toString());
    Marker deviceMarker = Marker(
        markerId: deviceMarkerId,
        position: position,
        onTap: () {},
        infoWindow: InfoWindow(title: _deviceInfo.name.toString(), anchor: Offset(0.5, 0.5), snippet: lastPosition.toString()));
    _markers[deviceMarkerId] = deviceMarker;
  }

  //Animate CameraPosition
  void _animateCameraPosition() async {
    _zoomLevel = 12.0;
    GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: lastPosition, zoom: _zoomLevel)));
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    _deviceInfo = args["deviceInfo"];
    Color textColor = Theme.of(context).primaryTextTheme.title.color;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Device Position'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          _deviceInfoWidget(_deviceInfo, textColor),
          _renderMap(_deviceInfo),
        ],
      ),
    );
  }

  //Device Info Container
  Widget _deviceInfoWidget(Device deviceInfo, Color textColor) {
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

  //Device Map Container
  Widget _deviceInfoMapWidget(Device deviceInfo) {
    return Expanded(
      child: Container(
        decoration: kBoxDecoration1(Theme.of(context).canvasColor),
        width: MediaQuery.of(context).size.width,
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              enablePullUp: false,
              onRefresh: () => _onRefresh(deviceInfo),
              onLoading: () => _onLoading(deviceInfo),
              child: ListView.builder(
                  itemCount: _devices.length,
                  itemBuilder: (context, index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          _devices[index].position.geoPoint.latitude.toString(),
                        ),
                        Text(
                          _devices[index].position.geoPoint.longitude.toString(),
                        )
                      ],
                    );
                  }),
            )),
      ),
    );
  }

  Widget _renderMap(Device deviceInfo) {
    return Expanded(
      child: Container(
        child: Stack(
          children: <Widget>[
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(target: lastPosition, zoom: _zoomLevel),
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
              },
              markers: Set<Marker>.of(_markers.values),
              polylines: Set<Polyline>.of(_mapPolylines.values),
            ),
            //Refresh Widget
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: GestureDetector(
                  onTap: () => _onRefresh(deviceInfo),
                  child: Container(
                    height: 50,
                    width: 50,
                    child: Icon(
                      Icons.refresh,
                      color: Colors.white,
                    ),
                    decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
            ),
            _isLoading
                ? Center(
                    child: SizedBox(
                      child: CircularProgressIndicator(strokeWidth: 2.0, backgroundColor: Colors.white),
                      height: 30,
                      width: 30,
                    ),
                  )
                : Center(),
          ],
        ),
      ),
    );
  }
}
