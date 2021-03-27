import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import "package:toilet_tracker/config/googleMapsApiKey.dart";
import 'package:toilet_tracker/elements/googleMapsPoi.dart';
import 'package:toilet_tracker/elements/loadingWheelAndMessage.dart';

Widget getMapIfHasUserLocation(
  LocationPermission permission,
  Position position,
  Completer<GoogleMapController> controllerPointer,
  Widget mapWidgetPointer,
  Function refreshPermissions,
  LatLng poiLocation,
  Function setController,
  Function setPoi,
  List<Marker> markers,
) =>
    (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse)
        ? (position != null)
            ? (controllerPointer != null)
                ? mapWidgetPointer
                : GoogleMap(
                    myLocationEnabled: true,
                    initialCameraPosition: CameraPosition(
                      target: (poiLocation != null)
                          ? poiLocation
                          : LatLng(position.latitude, position.longitude),
                      zoom: 17,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      setController(controller);
                    },
                    onTap: (data) async {
                      print(data);
                      http.Response placeData = await http.post(Uri.parse(
                          "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=" +
                              googleMapsApiKey +
                              "&location=" +
                              data.latitude.toString() +
                              "," +
                              data.longitude.toString() +
                              "&radius=50&rankby=prominence"));
                      print("Place Data:");
                      print(jsonDecode(placeData.body));
                      var poiRaw = jsonDecode(placeData.body)["results"][1];
                      setPoi(GoogleMapsPoi(
                          businessStatus: poiRaw["business_status"],
                          formattedAddress: poiRaw["vicinity"],
                          name: poiRaw["name"],
                          types: poiRaw["types"]
                              .map<String>((item) => item.toString())
                              .toList(),
                          icon: poiRaw["icon"],
                          placeId: poiRaw["place_id"],
                          photos: poiRaw["photos"] != null
                              ? poiRaw["photos"]
                                  .map<GoogleMapsPoiPhoto>(
                                      (photo) => GoogleMapsPoiPhoto(
                                            height: poiRaw["height"],
                                            width: poiRaw["width"],
                                            photoReference:
                                                poiRaw["photo_reference"],
                                          ))
                                  .toList()
                              : List.filled(0, GoogleMapsPoiPhoto()),
                          location: LatLng(
                            poiRaw["geometry"]["location"]["lat"],
                            poiRaw["geometry"]["location"]["lng"],
                          )));
                    },
                    markers: () {
                      print(markers);
                      return Set<Marker>.from(markers);
                    }(),
                  )
            : loadingWheelAndMessage("Loading Location...")
        : Column(
            children: <Widget>[
              Center(
                child: Text(
                  "This app needs access to location services in order to run.",
                ),
              ),
              IconButton(
                  icon: Icon(Icons.refresh),
                  tooltip: "Recheck Permissions",
                  onPressed: refreshPermissions),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
          );
