import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spacex/api.dart';
import 'package:spacex/common.dart';
import 'package:spacex/filter.dart';

class StatCard extends StatefulWidget {
  StatCard(this.title, this.stats);
  final String title;
  final Map<String, Stat> stats;
  createState() => new _StatCardState();
}

class _StatCardState extends State<StatCard> with SingleTickerProviderStateMixin {
  TabController ctrl;
  
  initState() {
    super.initState();
    ctrl = new TabController(length: widget.stats.length, vsync: this);
  }
  
  build(context) => new Column(children: [
    new Padding(
      padding: const EdgeInsets.all(16.0),
      child: new Text(widget.title, style: Theme.of(context).accentTextTheme.title)
    ),
    new Row(
      children: [
        new Expanded(child: new TabBar(isScrollable: true, controller: ctrl, tabs: widget.stats.keys.map((title) {
          return new Tab(text: title);
        }).toList())),
      ],
    ),
    new Container(child: new SizedBox(child: new Row(children: [
      new Expanded(child: new TabBarView(controller: ctrl, children: widget.stats.values.map((st) => new Padding(child: new Column(children: [
        new Text(st.value, style: const TextStyle(
          fontSize: 20.0,
        )),
        const Padding(padding: const EdgeInsets.only(bottom: 16.0)),
        new Text(st.desc),
      ]), padding: const EdgeInsets.all(8.0))).toList())),
    ]), height: 200.0), color: Colors.white),
  ]);
}


class HomePage extends StatefulWidget {
  createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollController ctrl = new ScrollController();
  FilterSettings ft = new FilterSettings();
  
  List<MissionInfo> missions = [];
  int tLength = 0;

  Map<String, Map<String, Stat>> stats = {};
  
  initState() {
    super.initState();
    
    if (allMissions is Future) {
      (allMissions as Future).then((m) {
        if (mounted) setState(() {
          tLength = (allMissions as List).length;
          missions = ft.filter().toList();
        });
      });
    } else {
      tLength = (allMissions as List).length;
      missions = ft.filter().toList();
    }
    
    if (allStats is Future) {
      (allStats as Future).then((m) {
        if (mounted) setState(() {
          stats = allStats;
        });
      });
    } else {
      stats = allStats;
    }
  }
  
  build(BuildContext context) => new Scaffold(
    appBar: new AppBar(
      leading: new Builder(builder: (context) => new IconButton(icon: const Icon(Icons.timeline), onPressed: () {
        Scaffold.of(context).openDrawer();
      })),
      
      title: new Text("SpaceX Launches (${missions.length}/$tLength)"),
      actions: [
        new IconButton(icon: const Icon(Icons.filter_list), onPressed: () {
          showDialog(context: context, child: new FilterDialog(ft)).then((res) {
            if (res != null)  setState(() {
              ft = res;
              missions = ft.filter().toList();
              ctrl.jumpTo(0.0);
            });
          });
        }),
      ],
    ),
    
    body: new ListView(controller: ctrl, children: missions.map((m) {
      return new Column(children: [
        new MissionDetails(m),
        const Divider(height: 1.0),
      ]);
    }).toList()),
    
    drawer: new Drawer(
      child: new Container(
        color: Colors.blue,
        child: new ListView(children: stats.keys.map((title) => new StatCard(title, stats[title])).toList())
      ),
    ),
  );
}
