import 'package:flutter/material.dart';

class DeviceDetail extends StatefulWidget{
@override
  State<StatefulWidget> createState() {
    return _DeviceDetailState();
  }
}

class _DeviceDetailState extends State<DeviceDetail>{

  @override
  void initState() {
    super.initState();
  }

@override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.blue,
      home: Scaffold(
        appBar: AppBar(title: Text('Device Detail'),leading: Icon(Icons.arrow_back)),
        body: Stack(children: <Widget>[
          
        ],),
      )
    );
  }
}
