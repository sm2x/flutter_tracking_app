import 'package:google_maps_flutter/google_maps_flutter.dart';

class DevicePosition {
  final int id;
  final LatLng point;
  final double accuracy;
  final double altitude;
  final double speed;
  final double distance;
  final double totalDistance;
  final String address;
  final DateTime date;
  DevicePosition({
    this.id,
    this.point,
    this.accuracy,
    this.altitude,
    this.speed,
    this.distance,
    this.totalDistance,
    this.address,
    this.date,
  });
}
