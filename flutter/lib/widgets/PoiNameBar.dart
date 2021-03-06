import 'package:toilet_tracker/elements/googleMapsPoi.dart';
import 'package:flutter/material.dart';

class PoiNameBar extends StatelessWidget {
  PoiNameBar({Key key, this.poiInfo, this.onClose}) : super(key: key);

  final GoogleMapsPoi poiInfo;
  final Function onClose;

  Widget build(BuildContext context) => Container(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Text(poiInfo.name, style: TextStyle(fontSize: 24.0)),
                  Text(poiInfo.formattedAddress,
                      style: TextStyle(fontSize: 16.0))
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.close),
              tooltip: "Close Information Box",
              onPressed: onClose,
            )
          ],
        ),
        decoration: BoxDecoration(color: Theme.of(context).primaryColorLight),
        padding: EdgeInsets.all(8.0),
      );
}
