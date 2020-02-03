import 'package:traccar_client/traccar_client.dart';

class DeviceCustomModel extends Device {
  final int id;
  final DevicePosition position;
  DeviceCustomModel({this.id, this.position});
  factory DeviceCustomModel.fromJson(Map<String, dynamic> data) {
    return DeviceCustomModel(
      id: int.parse(data["deviceId"].toString()),
      position: DevicePosition.fromJson(data),
    );
  }
}
