import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_tracking_app/config/config.dart';
import 'package:flutter_tracking_app/models/device.custom.dart';
import 'package:flutter_tracking_app/models/user.model.dart';
import 'package:flutter_tracking_app/providers/app_provider.dart';
import 'package:flutter_tracking_app/utilities/constants.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traccar_client/traccar_client.dart';
import 'package:pedantic/pedantic.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';

class TraccarClientService {
  final _dio = Dio();
  AppProvider _appProvider = AppProvider();
  TraccarClientService({AppProvider appProvider});
  /*
   * @description Login Api
   */
  Future login({String username, String password}) async {
    var url = serverProtocol + serverUrl + '/api/session';
    var payLoad = Map<String, dynamic>();
    payLoad['email'] = username;
    payLoad['password'] = password;
    var response = await _dio.post(url,
        data: payLoad,
        options: Options(
          contentType: ContentType.parse("application/x-www-form-urlencoded"),
          headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        ));
    String cookie = response.headers["set-cookie"][0];
    User data = User.fromJson(response.data as Map<String, dynamic>);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(kCookieKey, cookie);
    sharedPreferences.setString(kTokenKey, data.token);
    // _appProvider.setLoggedIn(status: true);
    return data;
  }

  /*
   * @description Listen device-positions Stream emmitting by Websocket
   */
  Stream<Device> get getDevicePositionsStream {
    String cookie = "JSESSIONID=djwbu6ve4icrh0hxejgbgxni; path=/api;";
    final channel = IOWebSocketChannel.connect("ws://$serverUrl/api/socket", headers: {"Cookie": cookie});
    final posStream = channel.stream;
    StreamSubscription<dynamic> rawPosSub;
    final streamController = StreamController<Device>.broadcast();
    rawPosSub = posStream.listen((dynamic data) {
      final dataMap = jsonDecode(data.toString()) as Map<String, dynamic>;
      if (dataMap.containsKey("positions")) {
        // print(dataMap);
        DevicePosition pos;
        DeviceCustomModel device;
        for (final posMap in dataMap["positions"]) {
          pos = DevicePosition.fromJson(posMap as Map<String, dynamic>);
          //device = Device.fromPosition(posMap as Map<String, dynamic>);
          device = DeviceCustomModel.fromJson(posMap);
        }
        device.position = pos;
        streamController.sink.add(device);
      }
    });
    return streamController.stream;
    // return posStream;
  }

  // Get All Devices of current User //
  Future<List<Device>> getDevices() async {
    String cookie = await getCookie();
    String uri = "$serverProtocol$serverUrl/api/devices";
    var response = await Dio().get(
      uri,
      options: Options(
        contentType: ContentType.json,
        headers: <String, dynamic>{
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Cookie": cookie,
        },
      ),
    );
    if (response.statusCode == 200) {
      final devices = <DeviceCustomModel>[];
      for (final data in response.data) {
        // print(data);
        var item = DeviceCustomModel.fromJson(data as Map<String, dynamic>);
        devices.add(item);
      }
      return devices;
    } else {
      throw Exception("Unexpected Happened !");
    }
  }

  // Get All Devices of current User //
  Future<List<DeviceCustomModel>> getDeviceLatestPositions() async {
    String cookie = await getCookie();
    String uri = "$serverProtocol$serverUrl/api/positions";
    var response = await Dio().get(
      uri,
      options: Options(
        contentType: ContentType.json,
        headers: <String, dynamic>{
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Cookie": cookie,
        },
      ),
    );
    print(response.data);
    if (response.statusCode == 200) {
      final devices = <DeviceCustomModel>[];
      for (final data in response.data) {
        // print(data);
        var item = DeviceCustomModel.fromJson(data as Map<String, dynamic>);
        devices.add(item);
      }
      return devices;
    } else {
      throw Exception("Unexpected Happened !");
    }
  }

  // Get Api Cookie //
  static Future<String> getCookie() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String cookie = sharedPreferences.getString(kCookieKey);
    if (cookie == null) {
      final trac = await getTraccarInstance();
      cookie = trac.query.cookie;
      sharedPreferences.setString(kCookieKey, cookie);
    }
    return cookie;
  }

  /*
   * @description Get Traccar Instance
   */
  static Future<Traccar> getTraccarInstance() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userToken = sharedPreferences.getString(kTokenKey);
    final trac = Traccar(serverUrl: serverUrl, userToken: userToken, verbose: true);
    unawaited(trac.init());
    await trac.onReady;
    return trac;
  }

  /*
   * @description Get Device Routes
   */
  Future<List<Device>> getDeviceRoutes({DeviceCustomModel deviceInfo, DateTime date, Duration since}) async {
    String cookie = await getCookie();
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
    var response = await _dio.get(
      uri,
      queryParameters: queryParameters,
      options: Options(contentType: ContentType.json, headers: <String, dynamic>{
        "Accept": "application/json",
        "Cookie": cookie,
      }),
    );
    print(response);
    for (final data in response.data) {
      _devicePositions.add(DeviceCustomModel.fromJson(data));
    }
    return _devicePositions;
  }

  // @description date conversion //
  String _formatDate(DateTime date) {
    final d = date.toIso8601String().split(".")[0];
    final l = d.split(":");
    return "${l[0]}:${l[1]}:00Z";
  }

  // @description Get SinglePosition
  static Future<DeviceCustomModel> getPositionFromId({int positionId}) async {
    String cookie = await getCookie();
    String uri = "$serverProtocol$serverUrl/api/positions";
    final queryParameters = <String, dynamic>{"id": positionId};
    var response = await Dio().get(
      uri,
      queryParameters: queryParameters,
      options: Options(
        contentType: ContentType.json,
        headers: <String, dynamic>{
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Cookie": cookie,
        },
      ),
    );
    if (response.statusCode == 200) {
      DeviceCustomModel devicePosition = DeviceCustomModel.fromJson(response.data[0]);
      return devicePosition;
    } else {
      throw Exception("Unexpected Happened !");
    }
  }
}
