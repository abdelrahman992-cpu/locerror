// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

// ignore: duplicate_ignore
class MapSampleState extends State<MapSample> {
  double posla = 0.0;
  double poslo = 0.0;
  String country = "0";
  String admin = "0";
  String local = "0";
  String sublocal = "0";
  String post = "0";
  String street = "0";
  //    print(placemarks[0].locality);
  //  print(placemarks[0].subLocality);
  //print(placemarks[0].postalCode);
  // print(placemarks[0].street);
  static Position cl = Position(
      longitude: 0,
      latitude: 0,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0);
  // ignore: prefer_typing_uninitialized_variables
  late StreamSubscription<Position> ps;
  late var lat;
  late var long;
  late CameraPosition _kGooglePlex;
  Future getper() async {
    bool services;
    LocationPermission per = await Geolocator.checkPermission();

    services = await Geolocator.isLocationServiceEnabled();
    if (services == false) {
      // AwesomeDialog(
      //     context: context,
      //     title: "services",
      //     body: const Text("serices not found"))
      //   ..show();
    }
    if (per == LocationPermission.denied) {
      per = await Geolocator.requestPermission();
      if (per == LocationPermission.always) {}
    }

    print("=========================");
    print(per);
    print("===========================");
    return per;
  }

  Future<Position?> getLatAndLong() async {
    cl = await Geolocator.getCurrentPosition().then((value) => value);
    lat = cl.latitude;
    long = cl.longitude;
    _kGooglePlex = CameraPosition(
        target: LatLng(lat, long), zoom: 12.4746, tilt: 45, bearing: 45);
    mymarker.add(Marker(
      markerId: MarkerId("1"),
      position: LatLng(lat, long),
    ));
    setState(() {});
    return cl;
  }

  @override
  void initState() {
    ps = Geolocator.getPositionStream().listen((Position? position) {
      changemarker(position?.latitude, position?.longitude);
    });
    setMarkerCustomImage();
    getper();
    getLatAndLong();
    super.initState();
  }

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  late GoogleMapController gmc;
  setMarkerCustomImage() async {
    mymarker.add(Marker(
        onTap: () {
          print("object");
        },
        draggable: true,
        onDragEnd: (LatLng t) {
          print("drag end");
        },
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        markerId: const MarkerId("2"),
        infoWindow: InfoWindow(
            title: "2",
            onTap: () {
              print("2");
            }),
        position: LatLng(31.042639, 29.964639)));
  }

  Set<Marker> mymarker = {};
  changemarker(newlat, newlong) {
    mymarker.remove(Marker(markerId: MarkerId("1")));
    mymarker.add(
        Marker(markerId: MarkerId("1"), position: LatLng(newlat, newlong)));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      _kGooglePlex == null
          ? CircularProgressIndicator()
          : Container(
              child: GoogleMap(
                markers: mymarker,
                mapType: MapType.hybrid,
                initialCameraPosition: _kGooglePlex,
                onTap: (LatLng) {},
                onMapCreated: (GoogleMapController controller) {
                  gmc = controller;
                },
              ),
              height: 150,
              width: 500,
            ),
      Text('$posla'),
      Text('$poslo'),
      Text('$country'),
      Text('$admin'),
      Text('$local'),
      Text('$sublocal'),
      Text('$post'),
      Text('$street'),
      ElevatedButton(
          onPressed: () async {
            cl = (await getLatAndLong())!;
            print("lat ${cl.latitude}");
            print("Long ${cl.longitude}");
            List<Placemark> placemarks =
                await placemarkFromCoordinates(cl.latitude, cl.longitude);

            setState(() {
              posla = cl.latitude;
              poslo = cl.longitude;
              country = placemarks[0].country!;
              admin = placemarks[0].administrativeArea!;
              local = placemarks[0].locality!;
              sublocal = placemarks[0].subLocality!;
              post = placemarks[0].postalCode!;
              street = placemarks[0].street!;
            });
          },
          child: Text("إظهر الاحداثيات")),
      ElevatedButton(
          onPressed: () async {
            LatLng latLng = LatLng(31.042639, 29.964639);
            //   gmc.animateCamera(CameraUpdate.newLatLng(latLng));
            gmc.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(target: latLng, zoom: 10)));
          },
          child: Text("gotoalex"))
    ]));
  }
}
//31.042639   29.964639