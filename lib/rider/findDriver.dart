import 'package:animate_do/animate_do.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:untitled1/driver/homescreen.dart';
import 'package:untitled1/main.dart';
import 'package:untitled1/model/riderModel.dart';
import 'package:untitled1/rider/transportPanel.dart';
import 'package:untitled1/utills/constants.dart';

class FindDriver extends StatefulWidget {
  const FindDriver({Key? key}) : super(key: key);

  @override
  _FindDriverState createState() => _FindDriverState();
}

class _FindDriverState extends State<FindDriver> {
  DatabaseReference dbref =
      FirebaseDatabase.instance.ref().child("CustomerRequest");

  DatabaseReference driverDb =
      FirebaseDatabase.instance.ref().child("DriverAvailable");

  bool driverFound = false;
  double radius = 5.0;
  String driverkey = "";
  String test = "";
  String message = "Please wat....";
  List<String> keysRetrieved = [];
  @override
  void initState() {
    Geofire.initialize(driverDb.path);
    super.initState();
    getClosestDriver();
  }

  saveRideRequest() {
    Map pickupdata = {
      "latitude": Provider.of<RiderModel>(context, listen: false)
          .pickuplocation
          .latitude,
      "longitude": Provider.of<RiderModel>(context, listen: false)
          .pickuplocation
          .longitude,
    };

    Map dropoffdata = {
      "latitude": Provider.of<RiderModel>(context, listen: false)
          .dropofflocation
          .latitude,
      "longitude": Provider.of<RiderModel>(context, listen: false)
          .dropofflocation
          .longitude,
    };

    Map maindata = {
      "driver_id": Provider.of<RiderModel>(context, listen: false).driverKey,
      'pickup': pickupdata,
      'dropoff': dropoffdata,
      'pickup_address':
          Provider.of<RiderModel>(context, listen: false).pickupaddress,
      'dropoff_address':
          Provider.of<RiderModel>(context, listen: false).dropoffaddress,
      'cost': Provider.of<RiderModel>(context, listen: false).selectedRide ==
              "Ride X"
          ? Provider.of<RiderModel>(context, listen: false).rideXPrice
          : Provider.of<RiderModel>(context, listen: false).rideXLPrice,
      'payment_mode': 'cash',
      'distance':
          Provider.of<RiderModel>(context, listen: false).traveldistance,
      'time': Provider.of<RiderModel>(context, listen: false).traveltime,
      'status': 'confirm',
      'date': new DateTime.now().toString()
    };

    dbref.child(firebaseAuth.currentUser!.uid).set(maindata);
  }

  getClosestDriver() {
    try {
      Geofire.queryAtLocation(
              Provider.of<RiderModel>(context, listen: false)
                  .pickuplocation
                  .latitude,
              Provider.of<RiderModel>(context, listen: false)
                  .pickuplocation
                  .longitude,
              radius)!
          .listen((map) {
        if (map != null) {
          var callBack = map['callBack'];

          //latitude will be retrieved from map['latitude']
          //longitude will be retrieved from map['longitude']

          switch (callBack) {
            case Geofire.onKeyEntered:
              if (!driverFound) {
                setState(() {
                  driverFound = true;
                  driverkey = map["key"];
                  message = "Driver found";
                });

                // Map customerInfo = {
                //   "customerId": firebaseAuth.currentUser!.uid
                // };
                FirebaseDatabase.instance
                    .ref()
                    .child("Users")
                    .child('Drivers')
                    .child(map["key"])
                    .update({"customerId": firebaseAuth.currentUser!.uid});

// Remove driver from availability
                // driverDb.child(map['key']).remove();
                Provider.of<RiderModel>(context, listen: false).driverKey =
                    map["key"];

                saveRideRequest();

                if (Provider.of<RiderModel>(context, listen: false)
                    .driverKey
                    .isNotEmpty) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => TransportPanel()),
                      (route) => false);
                } else {
                  FirebaseDatabase.instance
                      .ref()
                      .child("Users")
                      .child('Drivers')
                      .child(map["key"])
                      .child("customerId")
                      .remove();
                  Navigator.pop(context);
                }
              }

              break;

            case Geofire.onKeyExited:
              // keysRetrieved.remove(map["key"]);
              break;

            case Geofire.onKeyMoved:
//              keysRetrieved.add(map[callBack]);
              setState(() {
                radius = radius + 1.0;
              });
              break;

            case Geofire.onGeoQueryReady:
//              map["result"].forEach((key){
//                keysRetrieved.add(key);
//              });
              if (radius == 5) {
                break;
              }
              setState(() {
                radius = radius + 1.0;
              });
              if (!driverFound) {
                print(radius);
                getClosestDriver();
              }

              break;
          }
        }

        setState(() {});
      });
    } catch (e) {
      print(e.toString());
    }
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.withOpacity(0.8),
      body: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * .30,
            ),
            RippleAnimation(
                repeat: true,
                color: Colors.white,
                minRadius: 120,
                ripplesCount: 6,
                child: Container(
                  child: Column(
                    children: [
                      Pulse(
                        animate: true,
                        infinite: true,
                        child: Icon(
                          Iconsax.search_normal,
                          size: 68,
                        ),
                      ),
                      Text(
                        "Searching for driver.",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      Text(message),
                      Text(test)
                    ],
                  ),
                )),
            Spacer(),
            Container(
              width: double.infinity,
              height: 46,
              margin: EdgeInsets.symmetric(horizontal: 24, vertical: 23),
              child: MaterialButton(
                onPressed: () {
                  Geofire.removeLocation(firebaseAuth.currentUser!.uid);
                  Navigator.pop(context);
                },
                child: Text(
                  "Cancel Ride",
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.red.shade700,
              ),
            )
          ],
        ),
      ),
    );
  }
}
