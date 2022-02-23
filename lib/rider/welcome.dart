import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/driver/homescreen.dart';
import 'package:untitled1/main.dart';
import 'package:untitled1/model/riderModel.dart';
import 'package:untitled1/rider/searchpickup.dart';
import 'package:untitled1/rider/searchplace.dart';
import 'package:untitled1/screens/login.dart';
import 'package:untitled1/utills/constants.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  Position? position;
  Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController newMapController;
  CameraPosition _initialcameraposition = CameraPosition(
    target: LatLng(4.893916560114828, 6.906338496562588),
    zoom: 16,
  );

  GlobalKey<ScaffoldState> homekey = GlobalKey();
  Map detail = {};

  @override
  void initState() {
    _determinePosition();
    super.initState();
    getUserDetails();
  }

  getUserDetails() {
    FirebaseDatabase.instance
        .ref()
        .child("Users")
        .child("Customers")
        .child(firebaseAuth.currentUser!.uid)
        .get()
        .then((value) {
      if (value == null) {
        firebaseAuth.signOut();
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) => Login()), (route) => false);
      }
      setState(() {
        detail = value.value as Map;
      });
    });
  }

  _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      // return Future.error('Location services are disabled.');
      await Geolocator.getCurrentPosition().then((pos) {
        Provider.of<RiderModel>(context, listen: false).pickuplocation;
        getUserAddress(pos).then((value) {
          Provider.of<RiderModel>(context, listen: false).pickupaddress =
              value.first.street! + " " + value.first.locality!;
        });
        WidgetsBinding.instance!.addPersistentFrameCallback((_) {
          setState(() {
            position = pos;
          });
        });

        newMapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(pos.latitude, pos.longitude), zoom: 16)));
      });
      // showDialog(
      //     context: context,
      //     builder: (context) => AlertDialog(
      //           content: Text("Location services are disabled."),
      //         ));
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        // return Future.error('Location permissions are denied');
        await Geolocator.getCurrentPosition().then((pos) {
          Provider.of<RiderModel>(context, listen: false).pickuplocation;
          getUserAddress(pos).then((value) {
            Provider.of<RiderModel>(context, listen: false).pickupaddress =
                value.first.street! + " " + value.first.locality!;
          });
          WidgetsBinding.instance!.addPersistentFrameCallback((_) {
            setState(() {
              position = pos;
            });
          });

          newMapController.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(
                  target: LatLng(pos.latitude, pos.longitude), zoom: 16)));
        });
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      // return Future.error(
      //     'Location permissions are permanently denied, we cannot request permissions.');
      // showDialog(
      //     context: context,
      //     builder: (context) => AlertDialog(
      //           content: Text("Location permissions are permanently denied."),
      //         ));

      firebaseAuth.signOut();
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    await Geolocator.getCurrentPosition().then((pos) {
      Provider.of<RiderModel>(context, listen: false).pickuplocation;
      getUserAddress(pos).then((value) {
        Provider.of<RiderModel>(context, listen: false).pickupaddress =
            value.first.street! + " " + value.first.locality!;
      });
      WidgetsBinding.instance!.addPersistentFrameCallback((_) {
        setState(() {
          position = pos;
        });
      });

      newMapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(pos.latitude, pos.longitude), zoom: 16)));
    });
  }

  Future<List<Placemark>> getUserAddress(Position pos) async {
    return await GeocodingPlatform.instance
        .placemarkFromCoordinates(pos.latitude, pos.longitude);
  }

  updateUserLocation() async {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
    );
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? _position) {
      if (_position != null) {
        if (Provider.of<RiderModel>(context, listen: false)
            .dropoffaddress
            .isEmpty) {
          getUserAddress(_position).then((value) {
            Provider.of<RiderModel>(context, listen: false).pickupaddress =
                value.first.street! + " " + value.first.locality!;
          });
          Provider.of<RiderModel>(context, listen: false).pickuplocation =
              _position;

          WidgetsBinding.instance!.addPersistentFrameCallback((_) {
            setState(() {
              position = _position;
            });
          });
          newMapController.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(
                  target: LatLng(_position.latitude, _position.longitude),
                  zoom: 16)));
        }
      }
    });
  }

  @override
  void dispose() {
    // position = null;
    // newMapController.dispose();
    // updateUserLocation();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    updateUserLocation();
    return Scaffold(
      key: homekey,
      drawer: CustomDrawer(detail: detail),
      body: Stack(
        children: [
          SafeArea(
            child: GoogleMap(
                mapType: MapType.normal,
                zoomControlsEnabled: false,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                initialCameraPosition: _initialcameraposition,
                onMapCreated: (GoogleMapController controller) {
                  // _controller.complete(controller);
                  newMapController = controller;
                  // updateUserLocation();
                },
                onCameraMove: (position) {
                  // newMapController
                  //     .animateCamera(CameraUpdate.newCameraPosition(position));
                }),
          ),
          Stack(
            children: [
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
                                homekey.currentState!.openDrawer();
                              },
                              child: Icon(Iconsax.menu))),
                    ),
                  )),
              Positioned(
                  left: 18,
                  right: 18,
                  bottom: 38,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
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
                                    onTap: () {}, child: Icon(Iconsax.home))),
                          ),
                          Container(
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
                                    onTap: () {}, child: Icon(Iconsax.clock))),
                          ),
                          Spacer(),
                          Container(
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
                                      _determinePosition();
                                      // await showCupertinoDialog(
                                      //     context: context,
                                      //     builder: (context) =>
                                      //         SearchPickup()).then((value) {});
                                    },
                                    child: Icon(Iconsax.location))),
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        height: 45,
                        padding: EdgeInsets.symmetric(horizontal: 12),
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
                                onTap: Provider.of<RiderModel>(context,
                                            listen: false)
                                        .pickupaddress
                                        .isEmpty
                                    ? null
                                    : () {
                                        // Navigator.push(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //         builder: (context) => SearchPlace()));
                                        showCupertinoDialog(
                                            context: context,
                                            builder: (context) =>
                                                SearchPlace());
                                      },
                                child: Row(
                                  children: [
                                    Icon(Iconsax.search_normal_1),
                                    Text(" Where to?")
                                  ],
                                ))),
                      ),
                    ],
                  ))
            ],
          ),
        ],
      ),
    );
  }
}

class PickCars extends StatelessWidget {
  const PickCars({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          DraggableScrollableSheet(
            maxChildSize: 1.0,
            minChildSize: .40,
            expand: true,
            initialChildSize: .40,
            builder: (context, scrollController) => Material(
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    width: 45,
                    height: 3,
                    margin: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(34),
                        color: Colors.grey.shade300),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      controller: scrollController,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 28.0, vertical: 9),
                          child: Text("Select your ride"),
                        ),
                        ListTile(
                          leading: Image.asset(
                            "assets/images/ubc.jpg",
                            width: 65,
                          ),
                          title: Text(
                            "Ride X",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 23),
                          ),
                          subtitle: Text("Simple ride for 4"),
                          trailing: Text(
                            "₦1,500",
                            style: TextStyle(
                                fontSize: 34, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListTile(
                          leading: Image.asset(
                            "assets/images/ubb.jpg",
                            width: 65,
                          ),
                          title: Text(
                            "Ride XL",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 23),
                          ),
                          subtitle: Text("Premium"),
                          trailing: Text(
                            "₦2,500",
                            style: TextStyle(
                                fontSize: 34, fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
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
                          leading: Icon(Iconsax.money),
                          title: Text("Cash"),
                          trailing: Icon(Entypo.chevron_down)),
                      Container(
                        height: 45,
                        width: double.infinity,
                        child: MaterialButton(
                          onPressed: () {},
                          child: Text("Confirm",
                              style:
                                  TextStyle(fontSize: 24, color: Colors.white)),
                          color: dirty_green,
                        ),
                      )
                    ],
                  ))),
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
                          onTap: () {}, child: Icon(Iconsax.arrow_left))),
                ),
              )),
        ],
      ),
    );
  }
}

class CustomDrawer extends StatefulWidget {
  final Map detail;
  const CustomDrawer({Key? key, required this.detail}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  Map details = {};
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    details = widget.detail;
    if (details.isEmpty) {
      firebaseAuth.signOut();
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => Login()), (route) => false);
    }
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  ClipOval(
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        "assets/images/rider.jpg",
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      )),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          details['name'],
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  IconButton(onPressed: () {}, icon: Icon(Iconsax.edit))
                ],
              ),
            ),
            Divider(),
            SizedBox(
              height: 23,
            ),
            ListTile(
              leading: SvgPicture.asset("assets/icons/fi-rr-share.svg"),
              title: Text(
                "Invite A Friend",
                style: TextStyle(fontSize: 24),
              ),
            ),
            ListTile(
              leading: SvgPicture.asset("assets/icons/fi-rr-bell.svg"),
              title: Text(
                "Ride History",
                style: TextStyle(fontSize: 24),
              ),
            ),
            ListTile(
              leading: SvgPicture.asset("assets/icons/fi-rr-credit-card.svg"),
              title: Text(
                "Wallet",
                style: TextStyle(fontSize: 24),
              ),
            ),
            ListTile(
              leading: SvgPicture.asset("assets/icons/fi-rr-interrogation.svg"),
              title: Text(
                "Help",
                style: TextStyle(fontSize: 24),
              ),
            ),
            Spacer(),
            ListTile(
              leading: SvgPicture.asset("assets/icons/fi-rr-settings.svg"),
              title: Text(
                "Settings",
                style: TextStyle(fontSize: 24),
              ),
            ),
            ListTile(
              onTap: () {
                firebaseAuth.signOut();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => Login()),
                    (route) => false);
              },
              leading: SvgPicture.asset(
                "assets/icons/fi-rr-power.svg",
                color: Colors.red,
              ),
              title: Text(
                "SignOut",
                style: TextStyle(fontSize: 24),
              ),
            )
          ],
        ),
      ),
    );
  }
}
