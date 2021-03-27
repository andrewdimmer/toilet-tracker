import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:toilet_tracker/widgets/MapPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) => () {
        Firebase.initializeApp();
        return MaterialApp(
          title: 'Toilet Tracker',
          theme: ThemeData(
            primarySwatch: Colors.brown,
          ),
          home: MapPage(title: 'Toilet Tracker'),
        );
      }();
}
