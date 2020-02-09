import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tracking_app/models/device.custom.dart';
import 'package:flutter_tracking_app/models/user.model.dart';
import 'package:traccar_client/traccar_client.dart';

class AppProvider with ChangeNotifier {
  bool isLoggedIn = false;
  int homeActiveTabIndex = 2;
  User user = new User(email: 'admin', password: 'monarch@account14');
  List<DeviceCustomModel> _devices = [];

  //loggedIn Updates
  setLoggedIn({bool status}) {
    isLoggedIn = status;
  }

  getLoggedIn() {
    return isLoggedIn;
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
