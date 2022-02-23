import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_google_places/flutter_google_places.dart' as gp;
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_directions_api/google_directions_api.dart' as gda;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/model/riderModel.dart';
import 'package:untitled1/rider/findDriver.dart';
import 'package:untitled1/rider/searchpickup.dart';
import 'package:untitled1/rider/welcome.dart';
import 'package:untitled1/utills/constants.dart';
import 'package:google_maps_webservice/places.dart';

class ConfirmRide extends StatefulWidget {
  const ConfirmRide({Key? key}) : super(key: key);

  @override
  State<ConfirmRide> createState() => _ConfirmRideState();
}

class _ConfirmRideState extends State<ConfirmRide> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController mainController;

  CameraPosition? _kGooglePlex;
  PolylinePoints polylinePoints = new PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};
  Map<MarkerId, Marker> markers = {};
  BitmapDescriptor? pickLocationIcon;
  String address = "jungle";

  GlobalKey<ScaffoldState> _scarkey = GlobalKey();
  final directionsService = gda.DirectionsService();
  DatabaseReference? databaseReference;

  DatabaseReference dbref =
      FirebaseDatabase.instance.ref().child("CustomerRequest");

  geoFireUpdate() async {
    await Geofire.setLocation(
        firebaseAuth.currentUser!.uid,
        Provider.of<RiderModel>(context, listen: false).pickuplocation.latitude,
        Provider.of<RiderModel>(context, listen: false)
            .pickuplocation
            .longitude);
  }

  stopGeoFire() async {
    await Geofire.removeLocation(firebaseAuth.currentUser!.uid);
  }

  @override
  void initState() {
    Geofire.initialize(dbref.path);
    _kGooglePlex = CameraPosition(
        target: LatLng(
            Provider.of<RiderModel>(context, listen: false)
                .pickuplocation
                .latitude,
            Provider.of<RiderModel>(context, listen: false)
                .pickuplocation
                .longitude),
        zoom: 16);

    getlocation();
    super.initState();
    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5),
            'assets/images/pick_marker.png')
        .then((onValue) {
      pickLocationIcon = onValue;
    });

    getlocation();
  }

  getDirectionUpdate(String pickup, String dropoff) {
    final request = gda.DirectionsRequest(
      origin: pickup,
      destination: dropoff,
      travelMode: gda.TravelMode.driving,
    );

    directionsService.route(request, (response, status) {
      if (status == gda.DirectionsStatus.ok) {
        var result = response.routes;
        print("DURATION ${response.routes!.first.legs!.first.duration!.text}");

        // polylinePoints.decodePolyline(response.routes!.first.overviewPolyline!.points.toString());
        Provider.of<RiderModel>(context, listen: false).rideXPrice =
            result!.first.legs!.first.duration!.value!.toDouble() * .10 +
                result!.first.legs!.first.distance!.value!.toDouble() * .15;

        Provider.of<RiderModel>(context, listen: false).rideXLPrice =
            result!.first.legs!.first.duration!.value!.toDouble() * .25 +
                result!.first.legs!.first.distance!.value!.toDouble() * .35;

        //  Add marker for pickup
        var _pickmarker = Marker(
            markerId: MarkerId("pcik"),
            icon: pickLocationIcon!,
            position: LatLng(result.first.legs!.first.startLocation!.latitude,
                result!.first.legs!.first.startLocation!.longitude));

        setState(() {
          markers[MarkerId("pcik")] = _pickmarker;
        });
        Provider.of<RiderModel>(context, listen: false).traveltime =
            result.first.legs!.first.duration!.text.toString();
        Provider.of<RiderModel>(context, listen: false).traveldistance =
            result.first.legs!.first.distance!.text.toString();
        mainController.animateCamera(CameraUpdate.newLatLngBounds(
            LatLngBounds(
                southwest: LatLng(result.first.bounds!.southwest.latitude,
                    result.first.bounds!.southwest.longitude),
                northeast: LatLng(result.first.bounds!.northeast.latitude,
                    result.first.bounds!.northeast.longitude)),
            80));
      }
    });
  }

  getlocation() async {
    await GeocodingPlatform.instance
        .locationFromAddress(
            Provider.of<RiderModel>(context, listen: false).pickupaddress)
        .then((value) {
      var _pickmarker = Marker(
          markerId: MarkerId("pcik"),
          icon: pickLocationIcon!,
          position: LatLng(value.first.latitude, value.first.longitude));

      setState(() {
        markers[MarkerId("pcik")] = _pickmarker;
        _kGooglePlex = CameraPosition(
            target: LatLng(value.first.latitude, value.first.longitude),
            zoom: 16);
      });

      mainController
          .animateCamera(CameraUpdate.newCameraPosition(_kGooglePlex!));
    });
  }

  cancelRequest() {
    databaseReference!.remove();
    Provider.of<RiderModel>(context, listen: false).pickupaddress = "";
    Provider.of<RiderModel>(context, listen: false).dropoffaddress = "";
    Provider.of<RiderModel>(context, listen: false).pickuplocation = Position(
        longitude: 0,
        latitude: 0,
        timestamp: null,
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0);
    Provider.of<RiderModel>(context, listen: false).dropofflocation = Position(
        longitude: 0,
        latitude: 0,
        timestamp: null,
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0);

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
        (route) => false);
  }

  @override
  void didChangeDependencies() {
    getlocation();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            zoomGesturesEnabled: true,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            compassEnabled: false,
            zoomControlsEnabled: false,
            padding: EdgeInsets.only(bottom: 100),
            initialCameraPosition: _kGooglePlex!,
            markers: Set<Marker>.of(markers.values),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              mainController = controller;
            },
          ),
          Positioned(
              top: MediaQuery.of(context).size.height / 4,
              left: MediaQuery.of(context).size.width * .20,
              right: MediaQuery.of(context).size.width * .20,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                elevation: 12,
                clipBehavior: Clip.antiAlias,
                child: Container(
                  child: Row(
                    children: [
                      Container(
                        color: dirty_green,
                        padding:
                            EdgeInsets.symmetric(horizontal: 26, vertical: 8),
                        child: Column(
                          children: [
                            Text(
                              Provider.of<RiderModel>(context, listen: false)
                                  .traveltime
                                  .split(' ')
                                  .first,
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            Text(
                              Provider.of<RiderModel>(context, listen: false)
                                  .traveltime
                                  .split(' ')
                                  .last,
                              style: TextStyle(color: Colors.white),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("My Pickup Point"),
                      )
                    ],
                  ),
                ),
              )),
          Positioned(
              left: 18,
              top: 8,
              child: SafeArea(
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            spreadRadius: 08)
                      ]),
                  margin: EdgeInsets.all(6),
                  child: Material(
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: SvgPicture.asset(
                            "assets/icons/fi-rr-arrow-left.svg",
                            width: 64,
                            height: 65,
                            color: Colors.black,
                            fit: BoxFit.scaleDown,
                          ))),
                ),
              )),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: Column(
                    children: [
                      ListTile(
                          leading: Icon(Iconsax.location),
                          title: Text(
                              Provider.of<RiderModel>(context, listen: false)
                                  .pickupaddress),
                          trailing: GestureDetector(
                              onTap: () async {
                                await showCupertinoDialog(
                                        context: context,
                                        builder: (context) => SearchPickup())
                                    .then((value) {
                                  getDirectionUpdate(
                                      Provider.of<RiderModel>(context,
                                              listen: false)
                                          .pickupaddress,
                                      Provider.of<RiderModel>(context,
                                              listen: false)
                                          .dropoffaddress);
                                });
                              },
                              child: Icon(IconlyLight.edit))),
                      Container(
                        height: 45,
                        margin: EdgeInsets.symmetric(horizontal: 12),
                        width: double.infinity,
                        child: MaterialButton(
                          onPressed: () async {
                            geoFireUpdate();

                            // Navigator.restorablePush(
                            //     context,
                            //     (context, arguments) => MaterialPageRoute(
                            //         builder: (context) => FindDriver()));
                            await showCupertinoDialog(
                                    context: context,
                                    builder: (context) => FindDriver())
                                .then((value) {
                              // getDirectionUpdate(
                              //     Provider.of<RiderModel>(context,
                              //             listen: false)
                              //         .pickupaddress ="",
                              //     Provider.of<RiderModel>(context,
                              //             listen: false)
                              //         .dropoffaddress);
                            });
                          },
                          child: Text("Confirm Order",
                              style:
                                  TextStyle(fontSize: 24, color: Colors.white)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          color: dirty_green,
                        ),
                      ),
                      SizedBox(
                        height: 34,
                      )
                    ],
                  ))),
        ],
      ),
    );
  }
}
