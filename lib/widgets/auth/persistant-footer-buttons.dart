import 'package:flutter/material.dart';
import 'package:flutter_tracking_app/utilities/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FooterButtons {
  final widgetsColor;
  FooterButtons(this.widgetsColor);

  List<Widget> getFooterButtons(BuildContext context) {
    return [
      InkWell(
        child: Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: Text(kFooterHyperLinkText, style: TextStyle(color: widgetsColor)),
        ),
        onTap: () {
          launch(kFooterHyperLinkUrl);
        },
      ),
      IconButton(
        color: widgetsColor,
        icon: Icon(FontAwesomeIcons.facebook),
        onPressed: () {},
      ),
      IconButton(
        color: widgetsColor,
        icon: Icon(FontAwesomeIcons.skype),
        onPressed: () {},
      ),
      IconButton(
        color: widgetsColor,
        icon: Icon(FontAwesomeIcons.twitter),
        onPressed: () {},
      )
    ];
  }
}
