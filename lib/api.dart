import 'dart:async';
import 'dart:io';
import 'package:meta/meta.dart';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;

class MissionInfo {
  const MissionInfo({
    @required this.patchUrl,
    @required this.name,
    @required this.customer,
    @required this.vehicle,
    @required this.location,
    @required this.time,
    @required this.launched,
    @required this.landed,
    @required this.landSuccess,
    @required this.landingLocation,
    @required this.orbitPosition,
    @required this.success,
    @required this.tags,
    @required this.usedBefore,
  });
  
  final String patchUrl;
  final String name;
  final String customer;
  final String location;
  final String vehicle;
  final String time; // TODO: DateTime
  final bool launched;
  final String landed;
  final bool landSuccess;
  final LandingLocation landingLocation;
  final OrbitPosition orbitPosition;
  final bool success;
  final Set<String> tags;
  final bool usedBefore;
}

enum LandingLocation {
  NONE,
  LAND,
  DRONESHIP,
  OCEAN,
  PARACHUTE,
}

enum OrbitPosition {
  NONE,
  GTO,
  TMI,
  LEO,
  POLAR,
  SSO,
}

FutureOr<List<MissionInfo>> allMissions;

Map<String, Set<String>> allLaunchpads;

Future<List<MissionInfo>> fetchMissions() async {
  List<MissionInfo> process(String raw, bool launched) {
    var o = <MissionInfo>[];
    
    for (var rawCell in raw.split("<div class=\"missioncell\"")) {
      var name = new RegExp(
        r'<div class="(missionTitle|missionFailureTitle)">(.+?)</div>')
        .firstMatch(rawCell);
      if (name == null) continue;
    
      var info = new RegExp(r'<div class="infoLeft">(.+?)</div>').allMatches(
        rawCell).map((m) => m.group(1)).toList();
    
      var ukTags = new RegExp(r'<div class="landingUnknownBadge">(.+?)</div>')
        .allMatches(rawCell).map((m) => m.group(1))
        .toSet();
    
      var lloc = new RegExp(
        r'<div class="(landingSuccessBadge|landingFailureBadge)" ?>(.+?)</div>')
        .firstMatch(rawCell)
        ?.group(2);
    
      LandingLocation loc = LandingLocation.NONE;
      if (lloc == "Chutes") {
        loc = LandingLocation.PARACHUTE;
      } else if (lloc == "Ocean") {
        loc = LandingLocation.OCEAN;
      } else if (lloc == "JRTI" || lloc == "OCISLY") {
        loc = LandingLocation.DRONESHIP;
      } else if (lloc == "LZ-1" || lloc == "LZ-1/2") {
        loc = LandingLocation.LAND;
      }
    
      var op = OrbitPosition.NONE;
      if (ukTags.contains("TMI")) {
        op = OrbitPosition.TMI;
      } else if (ukTags.contains("Polar")) {
        op = OrbitPosition.POLAR;
      } else if (ukTags.contains("GTO")) {
        op = OrbitPosition.GTO;
      } else if (ukTags.contains("LEO")) {
        op = OrbitPosition.LEO;
      } else if (ukTags.contains("SSO")) {
        op = OrbitPosition.SSO;
      }
    
      o.add(new MissionInfo(
        patchUrl: new RegExp(r'<img class="missionpatch" src="(.+?)"')
          .firstMatch(rawCell)
          .group(1),
        name: name.group(2),
        customer: info[0],
        location: info[1],
        vehicle: info[2],
        time: info[3],
        launched: launched,
        landed: lloc,
        landingLocation: loc,
        orbitPosition: op,
        landSuccess: new RegExp(
          r'<div class="(landingSuccessBadge|landingFailureBadge)" >')
          .firstMatch(rawCell)
          ?.group(1) == "landingSuccessBadge",
        success: name.group(1) == "missionTitle",
        tags: ukTags,
        usedBefore: ukTags.contains("Reused"),
      ));
    }
    
    return o;
  }

  var o = process(await http.read("https://spacexnow.com/upcoming.php"), false).reversed.toList()..addAll(process(await http.read("https://spacexnow.com/past.php"), true));
  
  allLaunchpads = {};
  for (var ms in o) {
    var ls = ms.location.split(", ");
    if (ls.length != 2) {
      continue;
    }
    
    allLaunchpads.putIfAbsent(ls[0], () => new Set());
    allLaunchpads[ls[0]].add(ls[1]);
  }
  
  return allMissions = o;
}

class Stat {
  Stat({
    @required this.value,
    @required this.desc,
  });
  
  final String value;
  final String desc;
}

final rxSection = new RegExp(
  r'<div id="(.+?)">\s*'
  r'<(?:div.+?|p)>(.+?)<\/(?:div|p)>\s*'
  r'<div class="statsAdditional">(.{0,}?)<\/div>\s*'
  r'<\/div>'
);

FutureOr<Map<String, Map<String, Stat>>> allStats;

Future<Map<String, Map<String, Stat>>> fetchStats() async {
  Map<String, Map<String, Stat>> o = {};
  
  var raw = await http.read("https://spacexnow.com/stats.php");
  
  for (var rawBox in raw.split('<div class="statHeader">').skip(1)) {
    var name = new RegExp(r"(.+?)</div>").firstMatch(rawBox).group(1);
    var sectionNames = new Map<String, String>.fromIterable(
      new RegExp(r'<li><a href="#(.+?)">(.+?)<\/a><\/li>').allMatches(rawBox),
      // ignore: uses_dynamic_as_bottom
      key: (Match e) => e.group(1),
      // ignore: uses_dynamic_as_bottom
      value: (Match e) => e.group(2)
    );
    
    if (sectionNames.length == 0) continue;
    
    o[name] = new Map<String, Stat>.fromIterable(
      rxSection.allMatches(rawBox),
      // ignore: uses_dynamic_as_bottom
      key: (Match e) => sectionNames[e.group(1)],
      // ignore: uses_dynamic_as_bottom
      value: (Match e) => new Stat(
        value: e.group(2),
        desc: e.group(3),
      )
    );
  }
  
  return allStats = o;
}
