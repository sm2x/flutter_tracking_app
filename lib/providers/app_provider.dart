import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tracking_app/models/device.custom.dart';
import 'package:flutter_tracking_app/models/user.model.dart';
import 'package:flutter_tracking_app/utilities/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traccar_client/traccar_client.dart';

class AppProvider with ChangeNotifier {
  bool isLoggedIn = false;
  int homeActiveTabIndex = 2;
  User user = new User();
  List<DeviceCustomModel> _devices = [];

  //loggedIn Updates
  Future setLoggedIn({bool status}) async {
    isLoggedIn = status;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setBool(kIsloggedInKey, status);
  }

  Future getLoggedIn() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    isLoggedIn = sharedPreferences.getBool(kIsloggedInKey) ?? isLoggedIn;
    return Future.value(isLoggedIn);
  }

  //User states
  setUser({User user}) {
    user = user;
  }

  User getUser() {
    return user;
  }

  //Active Tabs//
  getSelectedTabIndex() => homeActiveTabIndex;
  setSelectedTabIndex(int index) {
    homeActiveTabIndex = index;
    notifyListeners();
  }

  //Devices
  List<DeviceCustomModel> getDevices() => _devices;
  setDevices(List<Device> devices) {
    _devices = devices;
    notifyListeners();
  }
}
