import 'package:flutter/material.dart';
import '../../screens/home/websockets.dart';

class DrawerLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(padding: EdgeInsets.zero, children: <Widget>[
        DrawerHeader(
          duration: Duration(milliseconds: 3000),
          child: Column(children: <Widget>[Text('Track Vehicals')]),
          decoration: BoxDecoration(color: Colors.blue),
        ),
        ListTile(
          leading: Icon(Icons.person),
          title: Text('Web Sockets'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => MySocket()));
          },
        ),
      ]),
    );
  }
}
