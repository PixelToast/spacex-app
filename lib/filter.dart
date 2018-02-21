import 'package:flutter/material.dart';
import 'package:spacex/api.dart';

enum SuccessType {
  UPCOMING,
  FAIL,
  SUCCESS,
  BOTH,
  ANY,
}

enum LandingType {
  OCEAN,
  DRONESHIP,
  LAND,
  PARACHUTE,
  NONE,
  ANY,
}

enum LandingSuccessType {
  SUCCESS,
  FAIL,
  ANY,
}

enum ReusedType {
  BEFORE,
  NEW,
  ANY,
}

enum OrbitType {
  GTO,
  TMI,
  LEO,
  POLAR,
  SSO,
  NONE,
  ANY,
}

class FilterSettings {
  SuccessType successType = SuccessType.ANY;
  LandingType landingType = LandingType.ANY;
  LandingSuccessType landingSuccessType = LandingSuccessType.ANY;
  ReusedType reusedType = ReusedType.ANY;
  OrbitType orbitType = OrbitType.ANY;
  
  Iterable<MissionInfo> filter() {
    var res = (allMissions as List<MissionInfo>).where((m) {
      return (
        successType == SuccessType.ANY ? true :
        successType == SuccessType.UPCOMING ? !m.launched :
        successType == SuccessType.BOTH ? m.launched :
        successType == SuccessType.FAIL ? m.launched && !m.success :
        successType == SuccessType.SUCCESS ? m.launched && m.success : null
      ) && (
        landingType == LandingType.ANY ? true :
        landingType == LandingType.NONE ? m.landingLocation == LandingLocation.NONE :
        landingType == LandingType.DRONESHIP ? m.landingLocation == LandingLocation.DRONESHIP:
        landingType == LandingType.LAND ? m.landingLocation == LandingLocation.LAND :
        landingType == LandingType.OCEAN ? m.landingLocation == LandingLocation.OCEAN :
        landingType == LandingType.PARACHUTE ? m.landingLocation == LandingLocation.PARACHUTE : null
      ) && (
        landingSuccessType == LandingSuccessType.ANY ? true :
        landingSuccessType == LandingSuccessType.SUCCESS ? m.landSuccess :
        landingSuccessType == LandingSuccessType.FAIL ? m.landed != null && !m.landSuccess : null
      ) && (
        reusedType == ReusedType.ANY ? true :
        reusedType == ReusedType.BEFORE ? m.usedBefore :
        reusedType == ReusedType.NEW ? !m.usedBefore : null
      ) && (
        orbitType == OrbitType.ANY ? true :
        orbitType == OrbitType.NONE ? m.orbitPosition == OrbitPosition.NONE :
        orbitType == OrbitType.SSO ? m.orbitPosition == OrbitPosition.SSO :
        orbitType == OrbitType.GTO ? m.orbitPosition == OrbitPosition.GTO :
        orbitType == OrbitType.POLAR ? m.orbitPosition == OrbitPosition.POLAR :
        orbitType == OrbitType.TMI ? m.orbitPosition == OrbitPosition.TMI :
        orbitType == OrbitType.LEO ? m.orbitPosition == OrbitPosition.LEO : null
      );
    });
    
    return res;
  }

  FilterSettings get copy => new FilterSettings()
    ..successType = successType
    ..landingType = landingType
    ..landingSuccessType = landingSuccessType
    ..reusedType = reusedType
    ..orbitType = orbitType;
}


class FilterDialog extends StatefulWidget {
  FilterDialog(this.initial);
  final FilterSettings initial;
  createState() => new _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  FilterSettings ft;
  bool landed = false;

  initState() {
    super.initState();
    ft = widget.initial;
  }
  
  build(BuildContext context) {
    DropdownMenuItem dmi<T>(String text, T value, bool viable) =>
      new DropdownMenuItem(value: value, child: new Text(text, style: new TextStyle(
        color: viable ? Colors.black : Colors.grey,
      )));
    
    DropdownMenuItem dmiMission(String text, SuccessType sc) =>
      dmi(text, sc, (ft.copy..successType = sc).filter().isNotEmpty);
    
    return new AlertDialog(
      title: const Text("Show only"),
      content: new Column(children: [
        new Row(children: [
          new Text("Mission: "),
          new Expanded(child: new DropdownButton(key: new UniqueKey(), items: [
            dmiMission("upcoming", SuccessType.UPCOMING),
            dmiMission("success or failure", SuccessType.BOTH),
            dmiMission("failure", SuccessType.FAIL),
            dmiMission("success", SuccessType.SUCCESS),
            dmiMission("any", SuccessType.ANY),
          ], onChanged: (e) => setState(() => ft.successType = e), value: ft.successType)),
        ]),
        
        const Padding(padding: const EdgeInsets.only(bottom: 8.0)),
        
        new Row(children: [
          new Text("Landed: "),
          new Expanded(child: new Column(children: [
            new Row(children: [new Expanded(child: new DropdownButton(key: new UniqueKey(), items: [
              new DropdownMenuItem(child: const Text("in ocean"), value: LandingType.OCEAN),
              new DropdownMenuItem(child: const Text("on droneship"), value: LandingType.DRONESHIP),
              new DropdownMenuItem(child: const Text("on landing pad"), value: LandingType.LAND),
              new DropdownMenuItem(child: const Text("anywhere"), value: LandingType.ANY),
              new DropdownMenuItem(child: const Text("nowhere"), value: LandingType.NONE),
            ], onChanged: (e) => setState(() => ft.landingType = e), value: ft.landingType))]),
            
            new Row(children: [new Expanded(child: new DropdownButton(key: new UniqueKey(), items: [
              new DropdownMenuItem(child: const Text("successfully"), value: LandingSuccessType.SUCCESS),
              new DropdownMenuItem(child: const Text("unsuccessfully"), value: LandingSuccessType.FAIL),
              new DropdownMenuItem(child: const Text("any"), value: LandingSuccessType.ANY),
            ], onChanged: (e) => setState(() => ft.landingSuccessType = e), value: ft.landingSuccessType))]),
          ])),
        ]),
        
        const Padding(padding: const EdgeInsets.only(bottom: 8.0)),
        
        new Row(children: [
          new Text("Reused: "),
          new Expanded(child: new DropdownButton(key: new UniqueKey(), items: [
            new DropdownMenuItem(child: const Text("before launch"), value: ReusedType.BEFORE),
            new DropdownMenuItem(child: const Text("brand new"), value: ReusedType.NEW),
            new DropdownMenuItem(child: const Text("any"), value: ReusedType.ANY),
          ], onChanged: (e) => setState(() => ft.reusedType = e), value: ft.reusedType)),
        ]),
        
        const Padding(padding: const EdgeInsets.only(bottom: 8.0)),
        
        new Row(children: [
          new Text("Orbit: "),
          new Expanded(child: new DropdownButton(key: new UniqueKey(), items: [
            new DropdownMenuItem(child: const Text("any"), value: OrbitType.ANY),
            new DropdownMenuItem(child: const Text("LEO"), value: OrbitType.LEO),
            new DropdownMenuItem(child: const Text("GTO"), value: OrbitType.GTO),
            new DropdownMenuItem(child: const Text("SSO"), value: OrbitType.SSO),
            new DropdownMenuItem(child: const Text("Polar"), value: OrbitType.POLAR),
            new DropdownMenuItem(child: const Text("TMI"), value: OrbitType.TMI),
            new DropdownMenuItem(child: const Text("none"), value: OrbitType.NONE),
          ], onChanged: (e) => setState(() => ft.orbitType = e), value: ft.orbitType)),
        ]),
        
        new Align(alignment: Alignment.bottomCenter, child: new Padding(child: new Text("${ft.filter().length} results"), padding: const EdgeInsets.all(8.0))),
      ]),
      actions: [
        new FlatButton(onPressed: () {
          Navigator.of(context).pop(ft);
        }, child: const Text("OK")),
        
        new FlatButton(onPressed: () {
          ft = new FilterSettings();
          Navigator.of(context).pop(ft);
        }, child: const Text("CLEAR")),
      ],
    );
  }
}