import 'package:traccar_client/traccar_client.dart';

class DeviceCustomModel extends Device {
  final int id;
  final DevicePosition position;
  final Device device;
  final int positionId;
  final String name;
  final bool isActive;
  final String lastUpdate;
  final String category;
  final String phone;
  final String model;
  final String motion;
  final DeviceAttributes attributes;
  DeviceCustomModel({
    this.id,
    this.position,
    this.positionId,
    this.device,
    this.isActive,
    this.lastUpdate,
    this.name,
    this.category,
    this.phone,
    this.model,
    this.motion,
    this.attributes,
  });
  factory DeviceCustomModel.fromJson(Map<String, dynamic> data) {
    data["attributes"]["batteryLevel"] = 0;
    return DeviceCustomModel(
      id: int.parse(data["id"].toString()),
      position: data["latitude"] != null ? DevicePosition.fromJson(data) : null,
      positionId: data["positionId"] != null ? int.parse(data["positionId"].toString()) : null,
      name: data["name"],
      isActive: (data["status"].toString() != "offline"), //for displayPurpose
      lastUpdate: data["lastUpdate"],
      category: data["category"],
      phone: data["phone"],
      model: data["model"],
      motion: data["motion"],
      device: data["deviceId"] != null ? Device.fromPosition(data) : null,
      attributes: data["latitude"] != null ? DeviceAttributes.fromJson(data) : null,
    );
  }
}

class DeviceAttributes {
  bool ignition;
  double distance;
  double totalDistance;
  String ip;
  bool motion;
  DeviceAttributes({this.ignition, this.distance, this.totalDistance, this.ip, this.motion});
  factory DeviceAttributes.fromJson(Map<String, dynamic> data) {
    var attrs = data["attributes"];
    return DeviceAttributes(
      distance: attrs["distance"],
      totalDistance: attrs["totalDistance"],
      ignition: attrs["ignition"],
      ip: attrs["ip"],
      motion: attrs["motion"],
    );
  }
}
