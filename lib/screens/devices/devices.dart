import 'package:flutter/material.dart';
import 'package:flutter_tracking_app/api-services/api_services.dart';
import 'package:flutter_tracking_app/models/device.custom.dart';
import 'package:flutter_tracking_app/providers/app_provider.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:traccar_client/traccar_client.dart';

class DevicesScreen extends StatefulWidget {
  static const route = '/Devices';

  @override
  _DevicesScreenState createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  bool _searchClicked = false;
  TextEditingController _searchController = new TextEditingController();
  List<DeviceCustomModel> _devices = [];
  RefreshController _refreshController = RefreshController(initialRefresh: true);
  AppProvider _appProvider;
  List<DeviceCustomModel> _searchResults = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(DevicesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  // onRefresh //
  void _onRefresh() async {
    await _getDevices();
    _appProvider.setDevices(_devices);
    _refreshController.refreshCompleted();
    if (mounted) {
      setState(() {});
    }
  }

  Future<List<Device>> _getDevices() async {
    _devices = await TraccarClientService().getDevices();
    return _devices;
  }

  @override
  Widget build(BuildContext context) {
    _appProvider = Provider.of<AppProvider>(context);
    _devices = _appProvider.getDevices();
    return Scaffold(
      appBar: !_searchClicked
          ? AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text('Devices'),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => setState(() => _searchClicked = true),
                )
              ],
            )
          : AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => setState(() => _searchClicked = false),
              ),
              title: TextField(
                autofocus: true,
                cursorColor: Colors.white,
                style: TextStyle(color: Colors.white, fontSize: 20),
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search',
                  labelStyle: TextStyle(fontSize: 20, color: Colors.white),
                ),
                onChanged: (value) {
                  _searchResults.clear();
                  _devices.forEach((item) {
                    if (item.name.toLowerCase().contains(value.toLowerCase())) {
                      _searchResults.add(item);
                    }
                  });
                  setState(() {});
                },
              ),
            ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          onRefresh: _onRefresh,
          child: _searchResults.isNotEmpty && _searchController.text != ''
              ? ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    return _listViewElementWidget(_searchResults[index]);
                  },
                )
              : ListView.builder(
                  itemCount: _devices.length,
                  itemBuilder: (context, index) {
                    return _listViewElementWidget(_devices[index]);
                  },
                ),
        ),
      ),
    );
  }

  //ListView element widget
  Widget _listViewElementWidget(DeviceCustomModel item) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        InkWell(
          onTap: () {
            _searchClicked = false;
            _searchController.clear();
            Navigator.pushNamed(context, '/DevicePosition', arguments: {"deviceInfo": item});
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Theme.of(context).primaryColor,
                      ),
                      height: 50,
                      width: 50,
                      child: Center(
                        child: Text(
                          item.id.toString(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: Row(
                          children: <Widget>[
                            Container(
                              height: 20,
                              width: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: item.motion == 'stop' ? Colors.red : Colors.blue,
                              ),
                              child: Center(
                                child: Text(
                                  item.motion,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                      color: item.isActive ? Colors.yellow : Colors.red, borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ],
          ),
        ),
        Divider()
      ],
    );
  }
}
