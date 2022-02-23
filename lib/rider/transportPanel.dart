import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_unicons/flutter_unicons.dart';
import 'package:google_directions_api/google_directions_api.dart' as gda;
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/main.dart';
import 'package:untitled1/model/riderModel.dart';
import 'package:untitled1/rider/startRide.dart';
import 'package:untitled1/rider/welcome.dart';
import 'package:untitled1/utills/constants.dart';

class TransportPanel extends StatefulWidget {
  const TransportPanel({Key? key}) : super(key: key);

  @override
  _TransportPanelState createState() => _TransportPanelState();
}

class _TransportPanelState extends State<TransportPanel> {
  Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController mainController;

  CameraPosition? _kGooglePlex;
  PolylinePoints polylinePoints = new PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};
  Map<MarkerId, Marker> markers = {};
  BitmapDescriptor? pickLocationIcon;
  final directionsService = gda.DirectionsService();

  DatabaseReference transportDb = FirebaseDatabase.instance
      .ref()
      .child("CustomerRequest")
      .child(firebaseAuth.currentUser!.uid);

  Map driverDetails = {};
  Map transportData = {};
  int timetravel = 0;
  int minute = 0;
  int sec = 0;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    _kGooglePlex = CameraPosition(
        target: LatLng(
            Provider.of<RiderModel>(context, listen: false)
                .pickuplocation
                .latitude,
            Provider.of<RiderModel>(context, listen: false)
                .pickuplocation
                .longitude),
        zoom: 16);
    super.initState();
    getDriverDetails();

    // updateTransport();
  }

  getDriverDetails() {
    FirebaseDatabase.instance
        .ref()
        .child("Users")
        .child("Drivers")
        .child(Provider.of<RiderModel>(context, listen: false).driverKey)
        .get()
        .then((datasnapshot) {
      if (datasnapshot.exists) {
        Map data = datasnapshot.value as Map;

        setState(() {
          driverDetails = data;
        });
      }
    });
  }

  timerchecker() {
    Future.delayed(Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        timetravel += 1;
        minute = (timetravel / 60).truncate();
      });
    });
  }

  getAllDetails() {
    transportDb.get().then((value) {
      if (value != null) {
        Map data = value.value as Map;
        if (!mounted) return;
        setState(() {
          transportData = data;
        });
        if (data['status'] == "trip start") {
          if (!mounted) return;
          setState(() {
            timetravel += 1;
            minute = (timetravel / 60).truncate();
          });
        }
        print(data.toString());
      }
    });
  }

  updateTransport() {
    transportDb.onValue.first.then((value) => {
          if (value.snapshot.exists)
            {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        content: Text("Value"),
                      ))
            }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseDatabase.instance
              .ref()
              .child("CustomerRequest")
              .child(firebaseAuth.currentUser!.uid)
              .onValue,
          builder: (context, snapshot) {
            Map data = (snapshot.data as DatabaseEvent).snapshot.value as Map;

            if (snapshot.hasData) {
              if (data['status'] == "trip start") {
                timerchecker();
              }
            }

            if (!snapshot.hasData) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 1,
                        valueColor: AlwaysStoppedAnimation<Color>(dirty_green),
                      ),
                      Text("Please wait...")
                    ]),
              );
            }
            if (data != null && data['status'] == "completed") {
              double totals = 0;
              if (data['timer'] >
                  double.parse(data['time'].toString().split(" ").first) * 60) {
                totals = (data['timer'] -
                            double.parse(
                                    data['time'].toString().split(" ").first) *
                                60) /
                        60 *
                        100 +
                    data['cost'];
              } else {
                totals = data['cost'];
              }
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/ubc.jpg",
                        width: 80,
                      ),
                      Text("Pay Driver"),
                      SizedBox(
                        height: 34,
                      ),
                      Text(
                        "N${totals.toStringAsFixed(0)}",
                        style: TextStyle(
                            fontSize: 21, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 34,
                      ),
                      Container(
                        height: 46,
                        width: 300,
                        child: MaterialButton(
                          color: dirty_green,
                          textColor: Colors.white,
                          onPressed: () {
                            FirebaseDatabase.instance
                                .ref()
                                .child("Users")
                                .child("Customers")
                                .child(firebaseAuth.currentUser!.uid)
                                .child("driver_id")
                                .remove();
                            // transportDb.remove();
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: ((context) => WelcomeScreen())),
                                (route) => false);
                          },
                          child: Text("Okay"),
                        ),
                      )
                    ]),
              );
            }
            return Stack(
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
                DraggableScrollableSheet(
                  expand: true,
                  maxChildSize: 1.0,
                  initialChildSize: .45,
                  minChildSize: .45,
                  builder: (context, scrollController) => Material(
                    elevation: 12,
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12)),
                    child: Column(children: [
                      Container(
                        width: 45,
                        height: 4,
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade300),
                      ),
                      Expanded(
                        child: ListView(
                          physics: BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: 21),
                          controller: scrollController,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      driverDetails['plate'].toString() ??
                                          "...",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24),
                                    ),
                                    Text(driverDetails['cartype'].toString() ??
                                        "..."),
                                    Text(driverDetails['color'].toString() +
                                            " Color" ??
                                        "..."),
                                  ],
                                ),
                                Column(
                                  children: [
                                    ClipOval(
                                      child: Image.asset(
                                        "assets/images/driver.jpg",
                                        width: 65,
                                      ),
                                    ),
                                    Text(driverDetails['name'].toString() ??
                                        "...")
                                  ],
                                )
                              ],
                            ),
                            ListTile(
                              dense: true,
                              leading: Icon(Iconsax.clock),
                              title: Text(
                                data['time'].toString() ?? "...",
                                style: TextStyle(
                                    fontSize: 21, fontWeight: FontWeight.bold),
                              ),
                              trailing: Text(
                                "Extra Time N100/min",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ),
                            Text(
                                "N" +
                                    double.parse(data['cost'].toString())
                                        .toStringAsFixed(0),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                    fontSize: 34, fontWeight: FontWeight.bold)),
                            Divider(),
                            ListTile(
                              dense: true,
                              leading: Icon(Iconsax.location),
                              title: Text(
                                  data['dropoff_address'].toString() ?? "..."),
                              subtitle: Text("Dropoff address"),
                              trailing: Icon(Iconsax.arrow_right),
                            )
                          ],
                        ),
                      )
                    ]),
                  ),
                ),
                // Message
                Positioned(
                  top: 65,
                  left: 45,
                  right: 45,
                  child: SlideInDown(
                    duration: Duration(seconds: 1),
                    child: Material(
                      color: Colors.white,
                      shadowColor: Colors.black26,
                      elevation: 12,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 34,
                        width: double.infinity,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 12,
                            ),
                            Center(
                                child: data['status'].toString() == "accepted"
                                    ? Text(
                                        "Don't keep driver waiting",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )
                                    : data['status'].toString() == "arrived"
                                        ? Text(
                                            "Meet your driver outside",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )
                                        : data['status'].toString() ==
                                                "trip start"
                                            ? Text(
                                                "On Trip",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            : Text(
                                                "...",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                            Spacer(),
                            data['timer'] != null
                                ? Text(
                                    "${(data['timer'] / 60).truncate().toString().padLeft(2, '0')}:${(data['timer'] % 60).toString().padLeft(2, '0')}")
                                : Text(''),
                            Icon(IconlyLight.notification)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                data['status'] == "confirm"
                    ? Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 46,
                          child: MaterialButton(
                            color: Colors.red,
                            textColor: Colors.white,
                            onPressed: () {
                              FirebaseDatabase.instance
                                  .ref()
                                  .child("Users")
                                  .child("Drivers")
                                  .child(Provider.of<RiderModel>(context,
                                          listen: false)
                                      .driverKey)
                                  .child("customerId")
                                  .remove();
                              transportDb.remove();
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: ((context) => WelcomeScreen())),
                                  (route) => false);
                            },
                            child: Text("Cancel Ride"),
                          ),
                        ))
                    : SizedBox.shrink()
              ],
            );
          }),
    );
  }
}
