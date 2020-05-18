import 'dart:convert';
import 'location.dart';
import 'locationdetails.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() => runApp(MainScreen());

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List _destinationList;
  List<String> _dropDownState = [
    "Johor",
    "Kedah",
    "Kelantan",
    "Perak",
    "Selangor",
    "Melaka",
    "Negeri Sembilan",
    "Pahang",
    "Perlis",
    "Penang",
    "Sabah",
    "Sarawak",
    "Terengganu"
  ];
  String _state = "Kedah";
  bool _isFiltering = false;
  bool _showLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadPref();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.greenAccent[400],
            title: Text(
              "Place to visit in Malaysia",
              style: TextStyle(
                fontFamily: "PatuaOne Regular",
                fontSize: 22.0,
                fontWeight: FontWeight.w500,
                // color: Colors.black87,
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
            actions: <Widget>[
              !_isFiltering
                  ? IconButton(
                    color: Colors.black,
                      icon: Icon(Icons.filter_list),
                      onPressed: () {
                        _filterByState();
                        setState(() {
                          _isFiltering = !_isFiltering;
                        });
                      },
                    )
                  : IconButton(
                    color: Colors.black,
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _loadData();
                        setState(() {
                          _isFiltering = !_isFiltering;
                        });
                      }),
            ],
          ),
          body: SafeArea(
            child: _showPage(),
          ),
        ),
      ),
    );
  }

  _showPage() {
    if (_destinationList != null && _showLoading == false) {
      return GridView.count(
        crossAxisCount: 2,
        children: List.generate(_destinationList.length, (index) {
          return InkWell(
            child: Card(
              color: Colors.lightBlue[50],
              shadowColor: Colors.greenAccent[700],
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
                side: BorderSide(
                  color: Colors.black,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ClipOval(
                      child: CachedNetworkImage(
                          height: 120.0,
                          fit: BoxFit.cover,
                          imageUrl:
                              "http://slumberjer.com/visitmalaysia/images/${_destinationList[index]['imagename']}"),
                    ),
                    Text(
                      "${_destinationList[index]['loc_name']}",
                      style: TextStyle(
                        fontFamily: "Acme Regular",
                        fontSize: 15.0,
                      ),
                    ),
                    Text(
                      "${_destinationList[index]['state']}",
                      style: TextStyle(
                        fontFamily: "Acme Regular",
                        fontSize: 15.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              Location location = new Location(
                  "${_destinationList[index]['pid']}",
                  "${_destinationList[index]['loc_name']}",
                  "${_destinationList[index]['state']}",
                  "${_destinationList[index]['description']}",
                  "${_destinationList[index]['latitude']}",
                  "${_destinationList[index]['longitude']}",
                  "${_destinationList[index]['url']}",
                  "${_destinationList[index]['contact']}",
                  "${_destinationList[index]['address']}",
                  "${_destinationList[index]['imagename']}");
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          LocationDetails(location: location)));
            },
          );
        }),
      );
    } else if (_destinationList == null && _showLoading == false) {
      return Container(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "No Data Found",
              style: TextStyle(
                fontFamily: "Acme Regular",
                fontSize: 18.0,
                color: Colors.red[300],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: InkWell(
                child: Text(
                  "Clear Search?",
                  style: TextStyle(
                      fontFamily: "Acme Regular",
                      decoration: TextDecoration.underline),
                ),
                onTap: () {
                  _loadData();
                  setState(() {
                    _isFiltering = !_isFiltering;
                  });
                },
              ),
            )
          ],
        ),
      );
    } else {
      return Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }

  _filterByState() {
    setState(() {
      _showLoading = true;
    });
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
              title: Text(
                "Filter By State?",
                style: TextStyle(
                  fontFamily: "Acme Regular",
                  fontSize: 20.0,
                  color: Colors.green,
                ),
              ),
              content: DropdownButton<String>(
                isExpanded: true,
                value: _state,
                items: _dropDownState
                    .map((value) => DropdownMenuItem(
                          child: Text(
                            value,
                            style: TextStyle(
                              fontFamily: "Acme Regular",
                              fontSize: 20.0,
                            ),
                          ),
                          value: value,
                        ))
                    .toList(),
                onChanged: (String value) {
                  setState(() {
                    _state = value;
                  });
                },
                hint: Text(
                  "Select State",
                  style: TextStyle(
                    fontFamily: "Acme Regular",
                    fontSize: 20.0,
                    color: Colors.green,
                  ),
                ),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: Text(
                    "No",
                    style: TextStyle(
                      fontFamily: "Acme Regular",
                      fontSize: 20.0,
                      color: Colors.green,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _makeClearToFilter();
                  },
                ),
                new FlatButton(
                  child: Text(
                    "Yes",
                    style: TextStyle(
                      fontFamily: "Acme Regular",
                      fontSize: 20.0,
                      color: Colors.green,
                    ),
                  ),
                  onPressed: () {
                    _searchState(_state);
                    _savePref(_state);
                    Navigator.of(context).pop();
                    Future.delayed(const Duration(milliseconds: 500), () {
                      setState(() {
                        _showLoading = false;
                      });
                    });
                  },
                ),
              ],
            );
          });
        });
    setState(() {
      _showLoading = false;
    });
  }

  _searchState(String state) {
    setState(() {
      _showLoading = true;
    });
    http.post("http://slumberjer.com/visitmalaysia/load_destinations.php",
        body: {
          'state': state,
        }).then((res) {
      setState(() {
        if (res.body != "nodata") {
          var extractdata = json.decode(res.body);
          _destinationList = extractdata['locations'];
        } else {
          _destinationList = null;
        }
      });
    }).catchError((err) {
      print(err);
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _showLoading = false;
      });
    });
  }

  _makeClearToFilter() {
    setState(() {
      _isFiltering = false;
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _showLoading = true;
    });
    var res = await http.get(
        Uri.encodeFull(
            "http://slumberjer.com/visitmalaysia/load_destinations.php"),
        headers: {"Accept": "application/json"});

    setState(() {
      var extractdata = json.decode(res.body);
      _destinationList = extractdata['locations'];
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _showLoading = false;
      });
    });
  }

  void _savePref(String value) async {
    //start _savePref method
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value.isNotEmpty) {
      await prefs.setString('state', value);
    } else {
      await prefs.setString('state', '');
      setState(() {
        _state = "Kedah";
      });
    }
  } //end _savePref method

  void _loadPref() async {
    //start _loadPref method
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String state = (prefs.getString('state')) ?? '';
    if (state.isNotEmpty) {
      setState(() {
        _state = state;
      });
    } else {
      setState(() {
        prefs.setString('state', "Kedah");
      });
    }
  } //end _loadPref method

  Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            title: new Text(
              'Are you sure?',
              style: TextStyle(
                fontFamily: "Acme Regular",
                fontSize: 20.0,
                color: Colors.green,
              ),
            ),
            content: new Text(
              'Do you want to exit this App?',
              style: TextStyle(
                fontFamily: "Acme Regular",
                fontSize: 20.0,
              ),
            ),
            actions: <Widget>[
              MaterialButton(
                  onPressed: () {
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  },
                  child: Text(
                    "Exit",
                    style: TextStyle(
                      fontFamily: "Acme Regular",
                      fontSize: 20.0,
                      color: Colors.green,
                    ),
                  )),
              MaterialButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      fontFamily: "Acme Regular",
                      fontSize: 20.0,
                      color: Colors.green,
                    ),
                  )),
            ],
          ),
        ) ??
        false;
  }
}
