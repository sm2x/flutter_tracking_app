import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_tracking_app/utilities/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapPage(),
    ));

const double CAMERA_ZOOM = 13;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;
const LatLng SOURCE_LOCATION = LatLng(33.533297, 73.089087);
const LatLng DEST_LOCATION = LatLng(33.609932, 73.044615);

class MapPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  Map<PolylineId, Polyline> _mapPolylines = {};
  int _polylineIdCounter = 0;
  LocationData _currentLocation;
  LocationData _destinationLocation;
  Location _location;
  Map<MarkerId, Marker> _mapMarkers = {};
  final List<LatLng> points = <LatLng>[];

  void initState() {
    super.initState();
    _location = new Location();
    initMarker();
    _createPoints();
  }

  void setInitialLocation() async {
    _currentLocation = await _location.getLocation();
    _destinationLocation = LocationData.fromMap({"longitude": SOURCE_LOCATION.longitude, "latitude": SOURCE_LOCATION.latitude});
  }

  void initMarker() {
    _mapMarkers.clear();
    final MarkerId markerId = MarkerId('marker_$_polylineIdCounter');
    var position = LatLng(SOURCE_LOCATION.latitude, SOURCE_LOCATION.longitude);
    BitmapDescriptor m1 = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    final Marker marker = Marker(markerId: markerId, position: position, icon: m1);
    _mapMarkers[markerId] = marker;
  }

  void _add() async {
    if (_polylineIdCounter < points.length) {
      _mapPolylines.clear();
      _mapMarkers.clear();
      final String polylineIdVal = 'polyline_id_$_polylineIdCounter';

      //Polylines
      final PolylineId polylineId = PolylineId(polylineIdVal);
      final Polyline polyline = Polyline(
        polylineId: polylineId,
        consumeTapEvents: true,
        color: Colors.blue,
        width: 3,
        points: points,
      );

      //on Adding displacing marker position
      final MarkerId markerId = MarkerId('marker_$_polylineIdCounter');
      var position = points[_polylineIdCounter];
      BitmapDescriptor markerIcon =
          await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 'assets/images/source_marker1.png');
      BitmapDescriptor m1 = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
      final Marker marker = Marker(markerId: markerId, position: position, icon: m1);

      _polylineIdCounter++;

      setState(() {
        _mapPolylines[polylineId] = polyline;
        _mapMarkers[markerId] = marker;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Maps"),
        actions: <Widget>[IconButton(icon: Icon(Icons.add), onPressed: _add)],
      ),
      body: GoogleMap(
          initialCameraPosition: const CameraPosition(target: LatLng(33.519971, 73.087819), zoom: 10.0),
          polylines: Set<Polyline>.of(_mapPolylines.values),
          markers: Set<Marker>.of(_mapMarkers.values)),
    );
  }

  List<LatLng> _createPoints() {
    points.add(LatLng(SOURCE_LOCATION.latitude, SOURCE_LOCATION.longitude));
    points.add(LatLng(33.555785, 73.093280));
    points.add(LatLng(33.559939, 73.087996));
    points.add(LatLng(33.565543, 73.078087));
    points.add(LatLng(33.579903, 73.069860));
    points.add(LatLng(33.585756, 73.063375));
    points.add(LatLng(33.589208, 73.056769));
    points.add(LatLng(DEST_LOCATION.latitude, DEST_LOCATION.longitude));
  }
}
