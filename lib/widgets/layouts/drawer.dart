import 'package:flutter/material.dart';
import 'package:flutter_tracking_app/api-services/api_services.dart';
import 'package:flutter_tracking_app/providers/app_provider.dart';
import 'package:flutter_tracking_app/utilities/constants.dart';
import 'package:flutter_tracking_app/widgets/auth/persistant-footer-buttons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class DrawerLayout extends StatelessWidget {
  AppProvider appProvider;
  @override
  Widget build(BuildContext context) {
    appProvider = Provider.of<AppProvider>(context);
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(padding: EdgeInsets.zero, children: <Widget>[
                DrawerHeader(
                  duration: Duration(milliseconds: 3000),
                  child: ListView(
                    children: <Widget>[
                      Image(
                        image: AssetImage('assets/logos/v_logo.png'),
                        height: 150,
                      ),
                    ],
                  ),
                  // decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                ),
                ListTile(
                  leading: Icon(Icons.track_changes, color: Theme.of(context).primaryColor),
                  title: Text('All Devices'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/Devices');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.receipt, color: Theme.of(context).primaryColor),
                  title: Text('Reports'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/Reports');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.share, color: Theme.of(context).primaryColor),
                  title: Text('Share With Friends'),
                  onTap: () {
                    Navigator.pop(context);
                    Share.share(kShareAppUrl, subject: kShareAppSubject);
                  },
                ),
              ]),
            ),
            Divider(),
            ListTile(
              leading: Icon(FontAwesomeIcons.signOutAlt, color: Theme.of(context).primaryColor),
              title: Text('Logout'),
              onTap: () async {
                await TraccarClientService(appProvider: appProvider).logout(context: context);
              },
            ),
            Divider(),
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
          ],
        ),
      ),
    );
  }
}
