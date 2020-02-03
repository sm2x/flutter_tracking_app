import 'package:flutter/material.dart';
import '../../screens/home/websockets.dart';

class DrawerLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(padding: EdgeInsets.zero, children: <Widget>[
        DrawerHeader(
          duration: Duration(milliseconds: 3000),
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[],
              ),
              Positioned(
                bottom: 10,
                left: 20,
                child: Text(
                  'Tracking App',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ],
          ),
          decoration: BoxDecoration(color: Theme.of(context).primaryColor),
        ),
        ListTile(
          leading: Icon(Icons.person),
          title: Text('Web Sockets'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => MySocket()));
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.track_changes),
          title: Text('My Devices'),
          onTap: () {
            Navigator.pushNamed(context, '/Devices');
          },
        ),
      ]),
    );
  }
}
