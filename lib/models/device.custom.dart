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
  DeviceCustomModel({
    this.id,
    this.position,
    this.positionId,
    this.device,
    this.isActive,
    this.lastUpdate,
    this.name,
    this.category,
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
      device: data["deviceId"] != null ? Device.fromPosition(data) : null,
    );
  }
}
