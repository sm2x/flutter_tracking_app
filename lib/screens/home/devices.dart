import 'package:flutter/material.dart';
import 'package:flutter_tracking_app/api-services/traccar_client.service.dart';
import 'package:flutter_tracking_app/providers/app_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:traccar_client/traccar_client.dart';

class DevicesScreen extends StatefulWidget {
  static const route = '/Devices';
  @override
  _DevicesScreenState createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  List<Device> _devices = [];
  @override
  void initState() {
    super.initState();
  }

  Future<List<Device>> _getDevices() async {
    if (_devices.isEmpty) {
      _devices = await TraccarClientService().getDevices();
    }
    return _devices;
  }

  @override
  Widget build(BuildContext context) {
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
        child: FutureBuilder(
          future: _getDevices(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return ListView(
                  children: _devices.map((item) {
                return _listViewElementWidget(item);
              }).toList());
            }
            return Center(
                child: CircularProgressIndicator(
              strokeWidth: 2.0,
            ));
          },
        ),
      ),
    );
  }

  //ListView element widget
  Widget _listViewElementWidget(Device item) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        InkWell(
          onTap: () => Navigator.pushNamed(context, '/DevicePosition', arguments: {"deviceInfo": item}),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
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
                  Column(
                    children: <Widget>[
                      Text(item.name, style: GoogleFonts.openSans(fontWeight: FontWeight.w400)),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                  ),
                ],
              ),
              Container(
                height: 10,
                width: 10,
                decoration: BoxDecoration(color: item.isActive ? Colors.yellow : Colors.red, borderRadius: BorderRadius.circular(30)),
              ),
            ],
          ),
        ),
        Divider()
      ],
    );
  }
}
