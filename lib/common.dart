import 'package:flutter/material.dart';
import 'package:spacex/api.dart';

class _Tag extends StatelessWidget {
  _Tag(this.text, this.color);
  final String text;
  final Color color;
  build(BuildContext context) {
    return new Padding(child: new ClipRRect(
      borderRadius: new BorderRadius.circular(4.0),
      child: new Container(color: color, width: 70.0, child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        new Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.0)),
      ]), padding: const EdgeInsets.all(4.0)),
    ), padding: const EdgeInsets.all(4.0));
  }
}


class MissionPreview extends StatefulWidget {
  MissionPreview(this.info);
  final MissionInfo info;
  createState() => new _MissionPreviewState();
}

class _MissionPreviewState extends State<MissionPreview> {
  build(BuildContext context) {
    return new Material(child: new InkWell(child: new Padding(child: new Row(children: [
      new Image.network(widget.info.patchUrl, width: 100.0, height: 100.0, fit: BoxFit.contain),
      const Padding(padding: const EdgeInsets.only(right: 16.0)),
      new Expanded(child: new Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        new Text(widget.info.name, style: new TextStyle(
          fontWeight: FontWeight.bold,
          color: widget.info.success ? Colors.black : Colors.red,
        )),
        new Padding(padding: const EdgeInsets.only(bottom: 16.0)),
        new Text(widget.info.customer),
        new Text(widget.info.location),
        new Text(widget.info.vehicle),
        new Text(widget.info.time),
      ])),
      new Column(children: [
        widget.info.landed == null ? new Container() : new _Tag(widget.info.landed, widget.info.landSuccess ? Colors.blue : Colors.red)
      ]..addAll(widget.info.tags.map((s) => new _Tag(s, Colors.grey))))
    ]), padding: const EdgeInsets.all(8.0)), onTap: () {
    
    }));
  }
}

class MissionDetails extends StatefulWidget {
  MissionDetails(this.info);
  final MissionInfo info;
  createState() => new _MissionDetailsState();
}

class _MissionDetailsState extends State<MissionDetails> {
  build(BuildContext context) {
    return new Material(child: new InkWell(child: new Padding(child: new Row(children: [
      new Image.network(widget.info.patchUrl, width: 100.0, height: 100.0, fit: BoxFit.contain),
      const Padding(padding: const EdgeInsets.only(right: 16.0)),
      new Expanded(child: new Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        new Row(children: [
          widget.info.launched ? new Container() : new Icon(Icons.date_range, size: 16.0),
          widget.info.launched ? new Container() : const Padding(padding: const EdgeInsets.only(right: 8.0)),
          new Expanded(child: new Text(widget.info.name, style: new TextStyle(
            fontWeight: FontWeight.bold,
            color: widget.info.success ? Colors.black : Colors.red,
          ), softWrap: true)),
        ]),
        new Padding(padding: const EdgeInsets.only(bottom: 16.0)),
        new Text(widget.info.customer),
        new Text(widget.info.location),
        new Text(widget.info.vehicle),
        new Text(widget.info.time),
      ])),
      new Column(children: [
        widget.info.landed == null ? new Container() : new _Tag(widget.info.landed, widget.info.landSuccess ? Colors.blue : Colors.red)
      ]..addAll(widget.info.tags.map((s) => new _Tag(s, Colors.grey))))
    ]), padding: const EdgeInsets.all(8.0)), onTap: () {
    
    }));
  }
}
