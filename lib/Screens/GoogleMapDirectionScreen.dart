import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flexi_profiler/Constants/AppColors.dart';
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:ui' as ui;

import 'package:provider/provider.dart';

const double CAMERA_ZOOM = 16;

const LatLng SOURCE_LOCATION = LatLng(21.775293, 72.170195);

class GoogleMapDirectionScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MapPageState();
}

class MapPageState extends State<GoogleMapDirectionScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  String _mapStyle;

  StreamSubscription<LocationData> locationSubscription;

  //Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();

  GoogleMapController mapController;
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints;
  String googleAPIKey = "AIzaSyAzDE3Ghsd_mbNCvehA2Yl25TrBqLD7_EU";
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
  LocationData currentLocation;
  LocationData destinationLocation;
  Location location;
  bool isLoaded = false;
  bool isGetLocationContinue = true;
  String title = "", detail = "";

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
  }

  @override
  void dispose() {
    locationSubscription.cancel();
    super.dispose();
  }

  setSourceAndDestinationIcons() async {
    if (Platform.isIOS) {
      sourceIcon = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(size: Size(25, 25)), 'assets/images/source_marker.png');

      destinationIcon = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(size: Size(25, 25)), 'assets/images/destination_marker.png');
    } else {
      Uint8List markerIcon = await getBytesFromAsset('assets/images/source_marker.png', 100);
      sourceIcon = BitmapDescriptor.fromBytes(markerIcon);

      markerIcon = await getBytesFromAsset('assets/images/destination_marker.png', 100);
      destinationIcon = BitmapDescriptor.fromBytes(markerIcon);
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
  }

  setInitialLocation(LatLng destinationLatLng) async {
    //currentLocation = await location.getLocation();

    destinationLocation =
        LocationData.fromMap({"latitude": destinationLatLng.latitude, "longitude": destinationLatLng.longitude});
  }

  DarkThemeProvider themeChange;
  ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    Constants_data.currentScreenContext = context;
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    Map<String, dynamic> arg = ModalRoute.of(context).settings.arguments;
    print("received argument : ${arg}");

    LatLng destination = LatLng(21.775293, 72.170195);
    title = arg["title"];
    detail = arg["detail"];

//    print("Argument for MapScreen : ${destination}");
//    LatLng destination = LatLng(21.775293, 72.170195);
//    LatLng destination = LatLng(21.777999, 72.166537);
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Constants_data.getFlexibleAppBar(themeChange.darkTheme),
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.white_color),
            onPressed: () {
              locationSubscription.cancel();
              Navigator.of(context).pop();
            }),
        title: Text('Map Screen'),
        backgroundColor: AppColors.main_color,
      ),
      body: Stack(
        children: <Widget>[
          !isLoaded
              ? FutureBuilder<dynamic>(
                  future: prepareMap(destination),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return getView();
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                )
              : getView()
        ],
      ),
    );
  }

  Future<dynamic> prepareMap(LatLng latLng) async {
    location = new Location();
    polylinePoints = PolylinePoints();


    locationSubscription = location.onLocationChanged.listen((LocationData cLoc) {
      if (isGetLocationContinue) {
        currentLocation = cLoc;
        updatePinOnMap();
        setPolylines();
      }
    });
    await setSourceAndDestinationIcons();
    await setInitialLocation(latLng);
    isLoaded = true;
  }

  getView() {
    CameraPosition initialCameraPosition = CameraPosition(zoom: CAMERA_ZOOM, target: SOURCE_LOCATION);
    if (currentLocation != null) {
      initialCameraPosition =
          CameraPosition(target: LatLng(currentLocation.latitude, currentLocation.longitude), zoom: CAMERA_ZOOM);
    }

    return GoogleMap(
        myLocationEnabled: true,
        compassEnabled: true,
        tiltGesturesEnabled: false,
        markers: _markers,
        polylines: _polylines,
        mapType: MapType.normal,
        initialCameraPosition: initialCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          // _controller.complete(controller);
          // controller.setMapStyle(_mapStyle);
          mapController = controller;
          showPinsOnMap();
        });
  }

  void showPinsOnMap() {
    if (currentLocation != null && destinationLocation != null) {
      var pinPosition = LatLng(currentLocation.latitude, currentLocation.longitude);

      var destPosition = LatLng(destinationLocation.latitude, destinationLocation.longitude);
      _markers.add(Marker(markerId: MarkerId('sourcePin'), position: pinPosition, icon: sourceIcon));
      _markers.add(Marker(
          infoWindow: InfoWindow(title: title, snippet: detail),
          markerId: MarkerId('destPin'),
          position: destPosition,
          icon: destinationIcon));
    }

    setPolylines();
  }

  void setPolylines() async {
    polylineCoordinates = [];
    if (destinationLocation != null) {
      try {
        List<PointLatLng> result;
        // List<PointLatLng> result = await polylinePoints.getRouteBetweenCoordinates(
        //     googleAPIKey,
        //     currentLocation.latitude,
        //     currentLocation.longitude,
        //     destinationLocation.latitude,
        //     destinationLocation.longitude);
        if (result.isNotEmpty) {
          polylineCoordinates = [];
          result.forEach((PointLatLng point) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          });
          setState(() {
            _polylines = Set<Polyline>();
            _polylines.add(Polyline(
                width: 5, // set the width of the polylines
                polylineId: PolylineId("poly"),
                color: Color.fromARGB(255, 40, 122, 198),
                points: polylineCoordinates));
          });
        } else {
          locationSubscription.cancel();
          Constants_data.toastError("Route not found for destination Location");
          print("Direction is not available for this location");
          this.setState(() {
            isGetLocationContinue = false;
          });
        }
      } on Exception catch (err) {
        print("Error in route : ${err}");
        Constants_data.toastError("Route not found for destination Location");
        this.setState(() {
          isGetLocationContinue = false;
        });
      }
    }
  }

  void updatePinOnMap() async {
    setState(() {
      var pinPosition = LatLng(currentLocation.latitude, currentLocation.longitude);

      _markers.removeWhere((m) => m.markerId.value == 'sourcePin');
      _markers.removeWhere((m) => m.markerId.value == 'destPin');
      _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          position: pinPosition, // updated position
          icon: sourceIcon));
      _markers.add(Marker(
          infoWindow: InfoWindow(title: title, snippet: detail),
          markerId: MarkerId('destPin'),
          position: LatLng(destinationLocation.latitude, destinationLocation.longitude),
          icon: destinationIcon));
    });
  }
}
