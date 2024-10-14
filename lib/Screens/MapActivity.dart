import 'dart:async';

import 'package:flexi_profiler/Constants/AppColors.dart';
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MapActivity extends StatefulWidget {
  @override
  _MapActivity createState() => _MapActivity();
}

String accountType = "";
String title = "";
String detail = "";
double latitude = 23.030440;
double longitude = 72.530217;
String _mapStyle;
List<String> data_map;

class _MapActivity extends State<MapActivity> {
  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
  }

  DarkThemeProvider themeChange;
  ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    Map<String, dynamic> arguments = ModalRoute.of(context).settings.arguments;
    data_map = arguments["data_map"];
    if (data_map.length > 1) {
      title = data_map[0];
      detail = data_map[1];
    } else if (data_map.length == 1) {
      title = data_map[0];
      detail = "N/A";
    } else {
      title = "N/A";
      detail = "N/A";
    }
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          flexibleSpace: Constants_data.getFlexibleAppBar(themeChange.darkTheme),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.white_color),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('Map Screen'),
          backgroundColor: AppColors.main_color,
        ),
        body: MapSample(),
      ),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(latitude, longitude),
    zoom: 15,
  );

  @override
  Widget build(BuildContext context) {
    Constants_data.currentScreenContext = context;
    _add();
    return new Scaffold(
      body: new Container(
          height: MediaQuery.of(context).size.height,
          child: GoogleMap(
            myLocationEnabled: true,
//            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              controller.setMapStyle(_mapStyle);
              _controller.complete(controller);
            },
            markers: Set<Marker>.of(markers.values),
          )),
    );
  }

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{}; // CLASS MEMBER, MAP OF MARKS

  void _add() {
    var markerIdVal = 'MyLocation';
    final MarkerId markerId = MarkerId(markerIdVal);

    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(
        latitude,
        longitude,
      ),
      infoWindow: InfoWindow(title: title, snippet: detail),
      onTap: () {
//        _onMarkerTapped(markerId);
      },
    );

    setState(() {
      markers[markerId] = marker;
    });
  }
}
