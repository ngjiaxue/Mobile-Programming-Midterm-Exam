import 'dart:async';
import 'location.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LocationDetails extends StatefulWidget {
  final Location location;
  const LocationDetails({Key key, this.location}) : super(key: key);
  @override
  _LocationDetailsState createState() => _LocationDetailsState();
}

class _LocationDetailsState extends State<LocationDetails> {
  CameraPosition _userpos;
  Set<Marker> markers = Set();
  MarkerId markerId1 = MarkerId("12");
  GoogleMapController gmcontroller;
  Completer<GoogleMapController> _controller = Completer();
  double screenHeight, screenWidth;
  double latitude, longitude;

  @override
  void initState() {
    super.initState();
    latitude = double.parse(widget.location.getLatitude());
    longitude = double.parse(widget.location.getLongitude());
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.lightBlue[50],
        appBar: AppBar(
          backgroundColor: Colors.greenAccent[400],
          title: Text(
            "${widget.location.getLocName()}",
            style: TextStyle(
              fontFamily: "PatuaOne Regular",
              fontSize: 20.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Colors.greenAccent[700],
                    Colors.greenAccent[400],
                    Colors.greenAccent,
                  ]),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ClipRRect(
                  child: CachedNetworkImage(
                      width: double.infinity,
                      fit: BoxFit.cover,
                      imageUrl:
                          "http://slumberjer.com/visitmalaysia/images/${widget.location.getImageName()}"),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Table(
                    border: TableBorder.all(
                      color: Colors.black,
                    ),
                    children: [
                      _tableRow("Location Description: ",
                          "${widget.location.getDescription()}", true),
                      _tableRow("Location URL: ", "${widget.location.getUrl()}",
                          false),
                      _tableRow("Location Address: ",
                          "${widget.location.getAddress()}", true),
                      _tableRow("Location Contact: ",
                          "${widget.location.getContact()}", false),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _tableRow(String a1, String a2, bool tableColor) {
    Color color = Colors.white;
    if (tableColor) {
      color = Colors.teal[100];
    }
    return TableRow(decoration: BoxDecoration(color: color), children: [
      _tableCell(a1),
      _tableCell(a2),
    ]);
  }

  _tableCell(String text) {
    if (text == "${widget.location.getUrl()}" ||
        text == "${widget.location.getContact()}" ||
        text == "${widget.location.getAddress()}") {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: TableRowInkWell(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: "Acme Regular",
              fontSize: 20.0,
            ),
          ),
          onTap: () {
            if (text == "${widget.location.getUrl()}") {
              _launchURL("http://$text");
            } else if (text == "${widget.location.getContact()}") {
              _launchContact("tel: $text");
            } else {
              _loadMap();
            }
          },
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: SizedBox(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: "Acme Regular",
              fontSize: 20.0,
            ),
          ),
        ),
      );
    }
  }

  void _launchURL(String text) async {
    if (await canLaunch(text)) {
      await launch(text);
    } else {
      throw 'Could not launch $text';
    }
  }

  void _launchContact(String text) async {
    if (await canLaunch(text)) {
      await launch(text);
    } else {
      throw 'Could not launch $text';
    }
  }

  _loadMap() {
    try {
      _controller = Completer();
      _userpos = CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 14.4746,
      );

      markers.add(Marker(
          markerId: markerId1,
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(
            title: 'Current Location',
            snippet: '${widget.location.getLocName()}',
          )));

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, newSetState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0))),
                title: Text(
                  "Location on Map",
                  style: TextStyle(
                    fontFamily: "Acme Regular",
                    fontSize: 20.0,
                    color: Colors.green,
                  ),
                ),
                titlePadding: EdgeInsets.all(5),
                //content: Text(curaddress),
                actions: <Widget>[
                  Text(widget.location.getAddress()),
                  Container(
                    height: screenHeight / 2 ?? 600,
                    width: screenWidth ?? 360,
                    child: GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: _userpos,
                      markers: markers.toSet(),
                      onMapCreated: (controller) {
                        _controller.complete(controller);
                      },
                    ),
                  ),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    //minWidth: 200,
                    height: 30,
                    child: Text('Close'),
                    color: Colors.green,
                    textColor: Colors.white,
                    elevation: 10,
                    onPressed: () =>
                        {markers.clear(), Navigator.of(context).pop(false)},
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      print(e);
      return;
    }
  }
}
