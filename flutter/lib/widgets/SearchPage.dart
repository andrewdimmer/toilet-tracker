import 'dart:convert';

import 'package:toilet_tracker/config/googleMapsApiKey.dart';
import 'package:toilet_tracker/elements/googleMapsPoi.dart';
import 'package:toilet_tracker/elements/loadingWheelAndMessage.dart';
import 'package:toilet_tracker/elements/searchAppbar.dart';
import 'package:toilet_tracker/widgets/PoiSearchResultItem.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  SearchPage(
      {Key key,
      this.title,
      this.searchController,
      this.setPoi,
      this.userLocation})
      : super(key: key);

  final String title;
  final TextEditingController searchController;
  final Function setPoi;
  final Position userLocation;

  @override
  State<StatefulWidget> createState() => _SearchPage(setPoi);
}

class _SearchPage extends State<SearchPage> {
  _SearchPage(Function setPoi) {
    _setPoi = setPoi;
    Future.delayed(Duration(milliseconds: 10), () async {
      _search(widget.searchController.text);
    });
  }

  bool _busySearching = true;
  List<Widget> _searchResults = [];
  Function _setPoi;

  void _resetSearchBox() => setState(() {
        widget.searchController.clear();
      });

  Future<void> _search(String input, [bool initialLoad = false]) async {
    if (!initialLoad) {
      setState(() {
        _busySearching = true;
      });
    }
    String fields =
        "business_status,formatted_address,geometry,icon,name,photos,place_id,types";
    http.Response testResults = await http.post(Uri.parse(
        "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?key=" +
            googleMapsApiKey +
            "&input=" +
            input.replaceAll(" ", "%20") +
            "&inputtype=textquery&fields=" +
            fields +
            "&locationbias=point:" +
            widget.userLocation.latitude.toString() +
            "," +
            widget.userLocation.longitude.toString()));
    var locations = jsonDecode(testResults.body);
    List<GoogleMapsPoi> results = locations["candidates"]
        .map<GoogleMapsPoi>((item) => GoogleMapsPoi(
            businessStatus: item["business_status"],
            formattedAddress: item["formatted_address"],
            name: item["name"],
            types:
                item["types"].map<String>((item) => item.toString()).toList(),
            icon: item["icon"],
            placeId: item["place_id"],
            photos: item["photos"]
                .map<GoogleMapsPoiPhoto>((photo) => GoogleMapsPoiPhoto(
                      height: item["height"],
                      width: item["width"],
                      photoReference: item["photo_reference"],
                    ))
                .toList(),
            location: LatLng(
              item["geometry"]["location"]["lat"],
              item["geometry"]["location"]["lng"],
            )))
        .toList();
    setSearchResults(results);
  }

  void setSearchResults(List<GoogleMapsPoi> results) {
    List<Widget> newSearchResults = [
      Center(child: Text("Results", style: TextStyle(fontSize: 18)))
    ];
    newSearchResults.addAll(
      results.map(
        (poiInfo) => PoiSearchResultItem(poiInfo: poiInfo, setPoi: _setPoi),
      ),
    );
    setState(() {
      _searchResults = newSearchResults;
      _busySearching = false;
    });
  }

  @override
  Widget build(BuildContext context) => () {
        return Scaffold(
          appBar: searchAppBar(
              title: widget.title,
              toggleSearch: _resetSearchBox,
              onSearch: (string) => _search(string),
              searchController: widget.searchController),
          body: _busySearching
              ? loadingWheelAndMessage("Searching...")
              : Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: _searchResults,
                  ),
                  padding: EdgeInsets.all(8.0),
                ),
        );
      }();
}
