import 'dart:convert';
import 'dart:io';

import 'package:flutter_tracking_app/config/config.dart';
import 'package:flutter_tracking_app/models/device.custom.dart';
import 'package:traccar_client/traccar_client.dart';
import 'package:pedantic/pedantic.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class TraccarClientService {
  final _dio = Dio();

  Future getDevicePositionsStream() async {
    final trac = Traccar(serverUrl: serverUrl, userToken: userToken, verbose: true);
    unawaited(trac.init());
    await trac.onReady;

    /// listen for updates
    final positions = await trac.positions();
    print("Listening for position updates");
    positions.listen((device) {});
  }

  getDevicesStream() async* {
    final trac = Traccar(serverUrl: serverUrl, userToken: userToken, verbose: true);
    unawaited(trac.init());
    await trac.onReady;

    /// listen for updates
    final positions = await trac.positions();
    print("Listening for position updates");
    positions.listen((device) {
      if (device.id == 509) {
        print("POSITION UPDATE: $device");
        // print("${device.name}: ${device.position.geoPoint.latitude} / " + "${device.position.geoPoint.longitude}");
      }
      return device;
    });
    // yield positions;
  }

  //Get Devices
  Future<List<Device>> getDevices() async {
    List<Device> _devices;
    final trac = Traccar(serverUrl: serverUrl, userToken: userToken, verbose: false);
    unawaited(trac.init());
    await trac.onReady;
    await trac.query.devices().then((List<Device> devices) {
      _devices = devices;
    });
    return _devices;
  }

  //Get Device positions
  Future<List<Device>> getDevicePositions1(Device deviceInfo) async {
    List<Device> _devices;
    final trac = Traccar(serverUrl: serverUrl, userToken: userToken, verbose: true);
    unawaited(trac.init());
    await trac.onReady;
    _devices = await trac.query.positions(
      deviceId: deviceInfo.id.toString(),
      since: Duration(days: 1),
      date: DateTime.now(),
    );
    print(_devices);
    return _devices;
  }

  Future<List<Device>> getDevicePositions({Device deviceInfo, DateTime date, Duration since}) async {
    final trac = Traccar(serverUrl: serverUrl, userToken: userToken, verbose: true);
    unawaited(trac.init());
    await trac.onReady;
    List<Device> _devicePositions = [];
    String uri = "$serverProtocol$serverUrl/api/reports/route";
    final deviceId = deviceInfo.id.toString();
    date ??= DateTime.now();
    final fromDate = date.subtract(since);
    final queryParameters = <String, dynamic>{
      "deviceId": int.parse("$deviceId"),
      "from": _formatDate(fromDate),
      "to": _formatDate(date),
    };
    print(uri);
    print(queryParameters);
    print(trac.query.cookie);
    var response = await _dio.get(
      uri,
      queryParameters: queryParameters,
      options: Options(
        contentType: ContentType.json,
        headers: <String, dynamic>{
          "Accept": "application/json",
          "Cookie": trac.query.cookie,
        },
      ),
    );
    print(response.statusCode);
    print(response.data);
    for (final data in response.data) {
      // _devicePositions.add(Device.fromPosition(data as Map<String, dynamic>));
      _devicePositions.add(DeviceCustomModel.fromJson(data));
    }

    return _devicePositions;
  }

  String _formatDate(DateTime date) {
    final d = date.toIso8601String().split(".")[0];
    final l = d.split(":");
    return "${l[0]}:${l[1]}:00Z";
  }
}
