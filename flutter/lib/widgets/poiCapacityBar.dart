import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toilet_tracker/elements/googleMapsPoi.dart';
import 'package:toilet_tracker/elements/loadingWheelAndMessage.dart';
import 'package:toilet_tracker/widgets/ChangeCapacityPage.dart';
import 'package:flutter/material.dart';

class PoiCapacityBar extends StatefulWidget {
  PoiCapacityBar({Key key, this.poiInfo}) : super(key: key);

  final GoogleMapsPoi poiInfo;

  @override
  State<StatefulWidget> createState() => _PoiCapacityBar(poiInfo);
}

class _PoiCapacityBar extends State<PoiCapacityBar> {
  _PoiCapacityBar(GoogleMapsPoi poiInfo) {
    _poiInfo = poiInfo;
    var snapshots = FirebaseFirestore.instance
        .collection("places")
        .doc(poiInfo.placeId)
        .snapshots();
    snapshots.listen(_processNewCrowdAndCapacityData);
  }

  GoogleMapsPoi _poiInfo;
  bool _busyLoading = false;
  int _crowd = 0;
  String _capacity = "?";

  String _newEditConfirm = "new";
  int _stars = 0;
  bool _open = false;
  bool _fee = false;

  void _processNewCrowdAndCapacityData(DocumentSnapshot snapshot) {
    setState(() {
      _crowd = snapshot.exists ? snapshot.data()["crowd"] : 0;
      _capacity = snapshot.exists ? snapshot.data()["capacity"] : "?";
    });
  }

  void _openUpdateCapacity() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeCapacityPage(
            poiInfo: _poiInfo,
          ),
        ),
      );

  void _setNewEdit() {
    setState(() {
      if (_newEditConfirm == "new") {
        _newEditConfirm = "confirm";
      } else if (_newEditConfirm == "edit") {
        _newEditConfirm = "confirm";
      } else if (_newEditConfirm == "confirm") {
        _newEditConfirm = "edit";
      }
    });
  }

  void _setStars(int numberOfStars) {
    if (_newEditConfirm == "confirm") {
      setState(() {
        _stars = numberOfStars;
      });
    }
  }

  void _setOpen() {
    if (_newEditConfirm == "confirm") {
      setState(() {
        _open = !_open;
      });
    }
  }

  void _setFee() {
    if (_newEditConfirm == "confirm") {
      setState(() {
        _fee = !_fee;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        child: _busyLoading
            ? loadingWheelAndMessage("Loading Crowd and Capacity Data...")
            : Column(
                children: <Widget>[
                  ButtonBar(
                    children: <Widget>[
                      ClipOval(
                        child: Material(
                          color: Colors.brown, // button color
                          child: InkWell(
                            splashColor: Colors.green, // inkwell color
                            child: SizedBox(
                                width: 56,
                                height: 56,
                                child: Icon(
                                  (_newEditConfirm == "new")
                                      ? Icons.add
                                      : (_newEditConfirm == "edit")
                                          ? Icons.edit
                                          : (_newEditConfirm == "confirm")
                                              ? Icons.check
                                              : Icons.block,
                                  color: Colors.white,
                                )),
                            onTap: () {
                              _setNewEdit();
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 290.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ButtonBar(
                              alignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  icon: Icon((_stars >= 1)
                                      ? Icons.star
                                      : Icons.star_border),
                                  onPressed: () {
                                    _setStars(1);
                                  },
                                  color: (_stars >= 1)
                                      ? Colors.yellow
                                      : Colors.black,
                                ),
                                IconButton(
                                  icon: Icon((_stars >= 2)
                                      ? Icons.star
                                      : Icons.star_border),
                                  onPressed: () {
                                    _setStars(2);
                                  },
                                  color: (_stars >= 2)
                                      ? Colors.yellow
                                      : Colors.black,
                                ),
                                IconButton(
                                  icon: Icon((_stars >= 3)
                                      ? Icons.star
                                      : Icons.star_border),
                                  onPressed: () {
                                    _setStars(3);
                                  },
                                  color: (_stars >= 3)
                                      ? Colors.yellow
                                      : Colors.black,
                                ),
                                IconButton(
                                  icon: Icon((_stars >= 4)
                                      ? Icons.star
                                      : Icons.star_border),
                                  onPressed: () {
                                    _setStars(4);
                                  },
                                  color: (_stars >= 4)
                                      ? Colors.yellow
                                      : Colors.black,
                                ),
                                IconButton(
                                  icon: Icon((_stars >= 5)
                                      ? Icons.star
                                      : Icons.star_border),
                                  onPressed: () {
                                    _setStars(5);
                                  },
                                  color: (_stars >= 5)
                                      ? Colors.yellow
                                      : Colors.black,
                                ),
                              ],
                            ),
                            ButtonBar(
                              alignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  child: Text(_open ? "Open" : "Closed"),
                                  onPressed: () {
                                    _setOpen();
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty
                                        .resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                        if (_open) {
                                          return Colors.green;
                                        } else if (!_open) {
                                          return Colors.red;
                                        }
                                        return null; // Use the component's default.
                                      },
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  child: Text(_fee ? "Free" : "Paid"),
                                  onPressed: () {
                                    _setFee();
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty
                                        .resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                        if (_fee) {
                                          return Colors.green;
                                        } else if (!_fee) {
                                          return Colors.red;
                                        }
                                        return null; // Use the component's default.
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                    alignment: MainAxisAlignment.spaceEvenly,
                  )
                ],
              ),
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(color: Theme.of(context).primaryColorLight),
      );
}
