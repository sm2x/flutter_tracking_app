import 'package:flutter/material.dart';
import 'package:flutter_tracking_app/api-services/traccar_client.service.dart';
import 'package:flutter_tracking_app/models/device.custom.dart';
import 'package:flutter_tracking_app/providers/app_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:traccar_client/traccar_client.dart';

class DevicesScreen extends StatefulWidget {
  static const route = '/Devices';
  @override
  _DevicesScreenState createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  List<DeviceCustomModel> _devices = [];
  RefreshController _refreshController = RefreshController(initialRefresh: true);
  AppProvider _appProvider;
  @override
  void initState() {
    super.initState();
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
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Devices'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child:
            // FutureBuilder(
            //   future: _getDevices(),
            //   builder: (BuildContext context, AsyncSnapshot snapshot) {
            //     if (snapshot.connectionState == ConnectionState.done) {
            //       return ListView(
            //           children: _devices.map((item) {
            //         return _listViewElementWidget(item);
            //       }).toList());
            //     }
            //     return Center(
            //         child: CircularProgressIndicator(
            //       strokeWidth: 2.0,
            //     ));
            //   },
            // ),
            SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          onRefresh: _onRefresh,
          child: ListView.builder(
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
          onTap: () => Navigator.pushNamed(context, '/DevicePosition', arguments: {"deviceInfo": item}),
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
                    SizedBox(width: 20),
                    Expanded(child: Text(item.name, style: GoogleFonts.openSans(fontWeight: FontWeight.w400))),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(color: item.isActive ? Colors.yellow : Colors.red, borderRadius: BorderRadius.circular(30)),
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
