import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tracking_app/models/device.custom.dart';
import 'package:flutter_tracking_app/providers/app_provider.dart';
import 'package:flutter_tracking_app/utilities/common_functions.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Reports extends StatefulWidget {
  @override
  _ReportsState createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  int dropdownValue = 0;
  List<DeviceCustomModel> _devices;
  DeviceCustomModel _selectedDevice;
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  TextEditingController _fromController = new TextEditingController();
  TextEditingController _toController = new TextEditingController();
  final dateTimeFormat = DateFormat("yyyy-MM-dd HH:mm");
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = Provider.of<AppProvider>(context);
    _devices = appProvider.getDevices();
    Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    _selectedDevice = args["deviceInfo"];
    _fromDate = args["fromDateTime"];
    _toDate = args["toDateTime"];
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _customAppBar(),
            // SizedBox(height: 30),
            //Content//
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: ListView(
                    children: <Widget>[
                      _devicesDropdown(),
                      _intervalWidget(),
                      SizedBox(height: 20),
                      _submitButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Custom AppBar
  Widget _customAppBar() {
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              color: Colors.white,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Vehicle Reports',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white))
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            left: 50,
            child: Container(
              width: MediaQuery.of(context).size.width - 60,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'View activites for selected device in selected time interval',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //Dropdown
  Widget _devicesDropdown() {
    return ListTile(
      leading: Icon(
        FontAwesomeIcons.mobileAlt,
        color: Theme.of(context).primaryColor,
      ),
      title: Text('Select Device'),
      subtitle: Row(
        children: <Widget>[
          Expanded(
            child: DropdownButton<DeviceCustomModel>(
              isExpanded: true,
              hint: Text('Select Device'),
              items: _devices.map((DeviceCustomModel item) {
                return DropdownMenuItem(
                  value: item,
                  child: Row(
                    children: <Widget>[
                      Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                            color: item.isActive ? Colors.yellow : Colors.red, borderRadius: BorderRadius.circular(30)),
                      ),
                      SizedBox(width: 10),
                      Expanded(child: Text(item.name.toString())),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedDevice = value);
                print(value.toString());
              },
              value: _selectedDevice,
            ),
          ),
        ],
      ),
    );
  }

  Widget _intervalWidget() {
    return ListTile(
      leading: Icon(
        Icons.timelapse,
        color: Theme.of(context).primaryColor,
      ),
      title: Text('Select DateTime Interval'),
      subtitle: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: _fromDateTimeWidget()),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(child: _toDateTimeWidget()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fromDateTimeWidget() {
    return DateTimeField(
      decoration: InputDecoration(labelText: 'yyyy-MM-dd H:mm'),
      initialValue: _fromDate,
      format: dateTimeFormat,
      onShowPicker: (context, currentValue) async {
        final date = await showDatePicker(
            context: context,
            firstDate: DateTime(1900),
            initialDate: currentValue ?? DateTime.now(),
            lastDate: DateTime(2100));
        if (date != null) {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
          );
          _fromDate = DateTimeField.combine(date, time);
          return _fromDate;
        }
      },
    );
  }

  Widget _toDateTimeWidget() {
    return DateTimeField(
      decoration: InputDecoration(labelText: 'yyyy-MM-dd H:mm'),
      initialValue: _toDate,
      format: dateTimeFormat,
      onShowPicker: (context, currentValue) async {
        final date = await showDatePicker(
            context: context,
            firstDate: DateTime(1900),
            initialDate: currentValue ?? DateTime.now(),
            lastDate: DateTime(2100));
        if (date != null) {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
          );
          _toDate = DateTimeField.combine(date, time);
          return _toDate;
        }
      },
    );
  }

  // Submit Button Widget
  Widget _submitButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          onPressed: _validateSubmit,
          color: Theme.of(context).primaryColor,
          highlightColor: Theme.of(context).primaryColor,
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          child: Text(
            'Submit',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ),
      ],
    );
  }

  _validateSubmit() {
    if (_selectedDevice != null && _fromDate != null && _toDate != null) {
      Duration diff = _toDate.difference(_fromDate);
      if (diff.inHours > 48) {
        CommonFunctions.showError(_scaffoldKey, 'Maximum 24 hours Interval Allowed');
      } else {
        Navigator.pushNamed(context, '/DeviceReport', arguments: {
          "deviceInfo": _selectedDevice,
          "fromDateTime": _fromDate,
          "toDateTime": _toDate,
        });
      }
    } else {
      CommonFunctions.showError(_scaffoldKey, 'Invalid Parameters');
    }
  }
}
