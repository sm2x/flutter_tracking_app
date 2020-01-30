import './devicePositions.model.dart';

class Device {
  final int id;
  String uniqueId;
  int groupId;
  String name;
  double batteryLevel;
  int keepAlive;
  bool isDisabled;
  bool isActive;
  DevicePosition position;
  Device({this.id});
}
