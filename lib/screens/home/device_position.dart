import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tracking_app/api-services/traccar_client.service.dart';
import 'package:flutter_tracking_app/utilities/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission/permission.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:traccar_client/traccar_client.dart';
import 'package:google_map_polyline/google_map_polyline.dart';

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
  Set<Polyline> polyline;
  List<LatLng> routeCoords;

  @override
  void initState() {
    super.initState();
    getaddressPoints();
  }

  void _onRefresh(Device deviceInfo) async {
    var data = await TraccarClientService().getDevicePositions(
      date: DateTime.now(),
      since: Duration(hours: 12),
      deviceInfo: deviceInfo,
    );
    setState(() {
      _devices = data;
    });
    _refreshController.refreshCompleted();
  }

  void _onLoading(Device deviceInfo) async {
    List<Device> data = await TraccarClientService().getDevicePositions(
      date: DateTime.now(),
      since: Duration(hours: 5),
      deviceInfo: deviceInfo,
    );
    if (mounted) {
      setState(() {
        _devices = data;
      });
    }
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    Device deviceInfo = args["deviceInfo"];
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
          // _deviceInfoWidget(deviceInfo, textColor),
          SizedBox(height: 20),
          _renderMap(deviceInfo),
          _deviceInfoMapWidget(deviceInfo),
        ],
      ),
    );
  }

  //Device Info Container
  Widget _deviceInfoWidget(Device deviceInfo, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
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

  //get Coordinates
  getsomePoints() async {
    var permissions = await Permission.getPermissionsStatus([PermissionName.Location]);
    if (permissions[0].permissionStatus == PermissionStatus.notAgain) {
      var askpermissions = await Permission.requestPermissions([PermissionName.Location]);
    } else {
      routeCoords = await googleMapPolyline.getCoordinatesWithLocation(
          origin: LatLng(40.6782, -73.9442), destination: LatLng(40.6944, -73.9212), mode: RouteMode.driving);
    }
  }

  getaddressPoints() async {
    routeCoords = await googleMapPolyline.getPolylineCoordinatesWithAddress(
        origin: '55 Kingston Ave, Brooklyn, NY 11213, USA', destination: '178 Broadway, Brooklyn, NY 11211, USA', mode: RouteMode.driving);
  }

  void onMapCreated(GoogleMapController controller) {
    setState(() {
      polyline.add(
        Polyline(
          polylineId: PolylineId('route1'),
          visible: true,
          points: <LatLng>[
            LatLng(33.663833333333336, 73.00617333333334),
            LatLng(33.66353333333333, 73.00292888888889),
            LatLng(33.66451333333333, 73.00096888888889),
            LatLng(33.66569111111111, 73.00496),
          ],
          width: 4,
          color: Colors.blue,
          startCap: Cap.roundCap,
          endCap: Cap.buttCap,
        ),
      );
    });
  }

  Widget _renderMap(Device deviceInfo) {
    var latlng = LatLng(33.519971, 73.087819);
    Map markers = {};
    MarkerId m1 = MarkerId("1");
    MarkerId m2 = MarkerId("2");
    MarkerId m3 = MarkerId("3");
    MarkerId m4 = MarkerId("4");
    markers[m1] = Marker(
      markerId: m1,
      position: LatLng(33.519971, 73.087819),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
    );
    markers[m2] = Marker(
      markerId: m2,
      position: LatLng(32.097537777777774, 73.06935999999999),
      icon: BitmapDescriptor.defaultMarker,
    );
    markers[m3] = Marker(
      markerId: m2,
      position: LatLng(32.098537777777774, 73.06945999999999),
      icon: BitmapDescriptor.defaultMarker,
    );
    markers[m4] = Marker(
      markerId: m2,
      position: LatLng(33.674857777777774, 73.01130666666667),
      icon: BitmapDescriptor.defaultMarker,
    );

    return Expanded(
      child: Container(
        child: Stack(
          children: <Widget>[
            Container(
              decoration: kBoxDecoration1(Theme.of(context).canvasColor),
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(target: LatLng(33.519971, 73.087819), zoom: 7.0),
                // initialCameraPosition: CameraPosition(target: LatLng(40.6782, -73.9442), zoom: 14.0),
                onMapCreated: (GoogleMapController controller) {
                  _mapController.complete();
                },
                // onMapCreated: onMapCreated,
                //polylines: polyline,
                markers: {
                  markers[m1],
                  markers[m2],
                  markers[m3],
                },
                // markers: Set.of(markers.values),
              ),
            )
          ],
        ),
      ),
    );
  }
}
