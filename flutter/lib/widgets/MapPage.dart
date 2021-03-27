import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:toilet_tracker/elements/getMapIfHasUserLocation.dart';
import 'package:toilet_tracker/elements/googleMapsPoi.dart';
import 'package:toilet_tracker/elements/loadingWheelAndMessage.dart';
import 'package:toilet_tracker/elements/searchAppbar.dart';
import 'package:toilet_tracker/widgets/PoiNameBar.dart';
import 'package:toilet_tracker/widgets/SearchPage.dart';
import 'package:toilet_tracker/widgets/poiCapacityBar.dart';

class MapPage extends StatefulWidget {
  MapPage({Key key, this.title}) : super(key: key);

  final String title;
  final TextEditingController searchController = TextEditingController();

  @override
  State<StatefulWidget> createState() {
    return _MapPage();
  }
}

class _MapPage extends State<MapPage> {
  _MapPage() {
    print("Adding Listener");
    _addLocationListener();
    _renderMapWidget();
  }

  bool _searching = false;
  Position _userLocation;
  GoogleMapsPoi _poi;
  Completer<GoogleMapController> _controller;
  Widget _mapWidget = loadingWheelAndMessage("Initalizing...");

  void _toggleSearch() {
    print(_userLocation);
    if (_userLocation != null) {
      setState(() {
        _searching = !_searching;
      });
    }
  }

  void _setPoi(GoogleMapsPoi newPoi) async {
    setState(() {
      _poi = newPoi;
    });
    Future.delayed(Duration(milliseconds: 500), () async {
      try {
        GoogleMapController controller = await _controller.future;
        controller.moveCamera(
          CameraUpdate.newCameraPosition((_poi != null)
              ? CameraPosition(target: _poi.location, zoom: 17)
              : CameraPosition(
                  target:
                      LatLng(_userLocation.latitude, _userLocation.longitude),
                  zoom: 17)),
        );
      } catch (err) {
        print("Map not initialized yet...");
      }
    });
  }

  void _renderMapWidget() async {
    LocationPermission permission = await Geolocator.checkPermission();
    setState(
      () {
        _mapWidget = getMapIfHasUserLocation(
          permission,
          _userLocation,
          _controller,
          _mapWidget,
          _addLocationListener,
          (_poi != null) ? _poi.location : null,
          _setController,
          _setPoi,
        );
      },
    );
  }

  void _addLocationListener() {
    Geolocator.getPositionStream(distanceFilter: 10).listen(_setUserLocation);
  }

  void _setController(GoogleMapController controller) {
    _controller = Completer();
    _controller.complete(controller);
  }

  List<Widget> _generateMapPageBody() {
    List<Widget> mapPageBody = [
      Container(
        child: Expanded(
          child: _mapWidget,
        ),
      )
    ];
    if (_poi != null) {
      mapPageBody.insert(
        0,
        PoiNameBar(
          poiInfo: _poi,
          onClose: () => _setPoi(null),
        ),
      );
      mapPageBody.add(PoiCapacityBar(poiInfo: _poi));
    }
    return mapPageBody;
  }

  Function _onSearchFactory(BuildContext context) => (String input) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchPage(
              title: "Search Page",
              searchController: widget.searchController,
              setPoi: _setPoi,
              userLocation: _userLocation,
            ),
          ),
        );
        _toggleSearch();
      };

  void _setUserLocation(Position userPosition) {
    setState(() {
      _userLocation = userPosition;
    });
    _renderMapWidget();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: searchAppBar(
            title: widget.title,
            searching: this._searching,
            toggleSearch: this._toggleSearch,
            autofocus: true,
            onSearch: _onSearchFactory(context),
            searchController: widget.searchController),
        body: Column(
          children: _generateMapPageBody(),
        ),
      );
}