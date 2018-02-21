import 'package:flutter/material.dart';
import 'package:spacex/pages/home.dart';
import 'package:spacex/api.dart';

void main() {
  allMissions = fetchMissions();
  allStats = fetchStats();
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  build(BuildContext context) {
    return new MaterialApp(
      title: 'SpaceX',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new HomePage(),
    );
  }
}