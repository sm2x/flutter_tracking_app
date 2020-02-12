import 'package:flutter/material.dart';
import 'package:flutter_tracking_app/utilities/constants.dart';
import 'package:flutter_tracking_app/widgets/auth/persistant-footer-buttons.dart';
import 'package:share/share.dart';
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
                  kCompanyTitle,
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ],
          ),
          decoration: BoxDecoration(color: Theme.of(context).primaryColor),
        ),
        ListTile(
          leading: Icon(Icons.share),
          title: Text('Share With Friends'),
          onTap: () {
            Navigator.pop(context);
            Share.share(kShareAppUrl, subject: kShareAppSubject);
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.track_changes),
          title: Text('My Devices'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/Devices');
          },
        ),
        SizedBox(height: 280),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(height: 10),
              Row(
                children: FooterButtons(Theme.of(context).primaryColor).getFooterButtons(context).toList(),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
