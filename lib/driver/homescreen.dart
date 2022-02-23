import 'dart:async';
import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_directions_api/google_directions_api.dart' as gda;
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/main.dart';
import 'package:untitled1/model/driverModel.dart';
import 'package:untitled1/rider/welcome.dart';
import 'package:untitled1/screens/login.dart';
import 'package:untitled1/utills/constants.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController _pageController = PageController();
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: WaterDropNavBar(
          bottomPadding: 18,
          waterDropColor: Color(0xff2c4260),
          barItems: [
            BarItem(
                filledIcon: IconlyBold.home, outlinedIcon: IconlyLight.home),
            BarItem(
                filledIcon: IconlyBold.chart, outlinedIcon: IconlyLight.chart),
            BarItem(
                filledIcon: IconlyBold.activity,
                outlinedIcon: IconlyLight.activity),
            BarItem(
                filledIcon: IconlyBold.profile,
                outlinedIcon: IconlyLight.profile),
          ],
          selectedIndex: selectedIndex,
          onItemSelected: (index) {
            setState(() {
              selectedIndex = index;
            });
            _pageController.animateToPage(selectedIndex,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutQuad);
          }),
      body: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            DriverMap(),
            DriverHistory(),
            DriverEarning(),
            DriverProfile()
          ]),
    );
  }
}

class DriverHistory extends StatelessWidget {
  const DriverHistory({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xff2c4260),
        centerTitle: true,
        title: Text("History", style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<Object>(
          stream: FirebaseDatabase.instance
              .ref()
              .child("Users")
              .child("Drivers")
              .child(firebaseAuth.currentUser!.uid)
              .child("History")
              .onValue,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Map data = (snapshot.data as DatabaseEvent).snapshot.value as Map;
              return ListView(
                children: data.entries
                    .map((e) => Container(
                          padding:
                              EdgeInsets.only(bottom: 8.0, left: 12, right: 12),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.grey))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Iconsax.location,
                                            size: 18,
                                            color: Colors.green.shade600,
                                          ),
                                          Text(
                                            e.value['pickup_address'],
                                            style: TextStyle(fontSize: 18),
                                          )
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Iconsax.location,
                                            size: 18,
                                            color: Colors.red.shade600,
                                          ),
                                          Text(e.value['dropoff_address'],
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ))
                                        ],
                                      )
                                    ],
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(e.value['distance']),
                                        Text(
                                            "N" +
                                                double.parse(e.value['cost']
                                                        .toString())
                                                    .toStringAsFixed(0),
                                            style: TextStyle(
                                              fontSize: 21,
                                              fontWeight: FontWeight.bold,
                                            ))
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              Text("12 Feb. 2022")
                            ],
                          ),
                        ))
                    .toList(),
              );
            } else {
              return Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      IconlyLight.graph,
                      size: 65,
                      color: Colors.grey,
                    ),
                    Center(child: Text("No History")),
                  ],
                ),
              );
            }
          }),
    );
  }
}

class DriverEarning extends StatefulWidget {
  const DriverEarning({
    Key? key,
  }) : super(key: key);

  @override
  State<DriverEarning> createState() => _DriverEarningState();
}

class _DriverEarningState extends State<DriverEarning> {
  final Color leftBarColor = const Color(0xff53fdd7);
  final Color rightBarColor = const Color(0xffff5182);
  final double width = 7;

  late List<BarChartGroupData> rawBarGroups;
  late List<BarChartGroupData> showingBarGroups;

  int touchedGroupIndex = -1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final barGroup1 = makeGroupData(0, 5, 12);
    final barGroup2 = makeGroupData(1, 16, 12);
    final barGroup3 = makeGroupData(2, 18, 5);
    final barGroup4 = makeGroupData(3, 20, 16);
    final barGroup5 = makeGroupData(4, 17, 6);
    final barGroup6 = makeGroupData(5, 19, 1.5);
    final barGroup7 = makeGroupData(6, 10, 1.5);

    final items = [
      barGroup1,
      barGroup2,
      barGroup3,
      barGroup4,
      barGroup5,
      barGroup6,
      barGroup7,
    ];

    rawBarGroups = items;

    showingBarGroups = rawBarGroups;
    return Scaffold(
      backgroundColor: Color(0xff2c4260),
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        toolbarHeight: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              color: const Color(0xff2c4260),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        makeTransactionsIcon(),
                        const SizedBox(
                          width: 38,
                        ),
                        const Text(
                          'Transactions',
                          style: TextStyle(color: Colors.white, fontSize: 22),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        const Text(
                          'state',
                          style:
                              TextStyle(color: Color(0xff77839a), fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 38,
                    ),
                    Expanded(
                      child: BarChart(
                        BarChartData(
                          maxY: 20,
                          barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                tooltipBgColor: Colors.grey,
                                getTooltipItem: (_a, _b, _c, _d) => null,
                              ),
                              touchCallback: (FlTouchEvent event, response) {
                                if (response == null || response.spot == null) {
                                  setState(() {
                                    touchedGroupIndex = -1;
                                    showingBarGroups = List.of(rawBarGroups);
                                  });
                                  return;
                                }

                                touchedGroupIndex =
                                    response.spot!.touchedBarGroupIndex;

                                setState(() {
                                  if (!event.isInterestedForInteractions) {
                                    touchedGroupIndex = -1;
                                    showingBarGroups = List.of(rawBarGroups);
                                    return;
                                  }
                                  showingBarGroups = List.of(rawBarGroups);
                                  if (touchedGroupIndex != -1) {
                                    var sum = 0.0;
                                    for (var rod
                                        in showingBarGroups[touchedGroupIndex]
                                            .barRods) {
                                      sum += rod.y;
                                    }
                                    final avg = sum /
                                        showingBarGroups[touchedGroupIndex]
                                            .barRods
                                            .length;

                                    showingBarGroups[touchedGroupIndex] =
                                        showingBarGroups[touchedGroupIndex]
                                            .copyWith(
                                      barRods:
                                          showingBarGroups[touchedGroupIndex]
                                              .barRods
                                              .map((rod) {
                                        return rod.copyWith(y: avg);
                                      }).toList(),
                                    );
                                  }
                                });
                              }),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: SideTitles(showTitles: false),
                            topTitles: SideTitles(showTitles: false),
                            bottomTitles: SideTitles(
                              showTitles: true,
                              getTextStyles: (context, value) =>
                                  const TextStyle(
                                      color: Color(0xff7589a2),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                              margin: 20,
                              getTitles: (double value) {
                                switch (value.toInt()) {
                                  case 0:
                                    return 'Mn';
                                  case 1:
                                    return 'Te';
                                  case 2:
                                    return 'Wd';
                                  case 3:
                                    return 'Tu';
                                  case 4:
                                    return 'Fr';
                                  case 5:
                                    return 'St';
                                  case 6:
                                    return 'Sn';
                                  default:
                                    return '';
                                }
                              },
                            ),
                            leftTitles: SideTitles(
                              showTitles: true,
                              getTextStyles: (context, value) =>
                                  const TextStyle(
                                      color: Color(0xff7589a2),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                              margin: 8,
                              reservedSize: 28,
                              interval: 1,
                              getTitles: (value) {
                                if (value == 0) {
                                  return '1K';
                                } else if (value == 10) {
                                  return '5K';
                                } else if (value == 19) {
                                  return '10K';
                                } else {
                                  return '';
                                }
                              },
                            ),
                          ),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          barGroups: showingBarGroups,
                          gridData: FlGridData(show: false),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                  ],
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              IconlyLight.wallet,
              color: Colors.white,
              size: 25,
            ),
            title: SlideInLeft(
              child: Text(
                "N45,000",
                style: TextStyle(fontSize: 34, color: Colors.white),
              ),
            ),
            subtitle: SlideInLeft(
                child: Text("Total Earning",
                    style: TextStyle(color: Colors.white))),
          )
        ],
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(barsSpace: 4, x: x, barRods: [
      BarChartRodData(
        y: y1,
        colors: [leftBarColor],
        width: width,
      ),
      BarChartRodData(
        y: y2,
        colors: [rightBarColor],
        width: width,
      ),
    ]);
  }

  Widget makeTransactionsIcon() {
    const width = 4.5;
    const space = 3.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: width,
          height: 10,
          color: Colors.white.withOpacity(0.4),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 42,
          color: Colors.white.withOpacity(1),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 10,
          color: Colors.white.withOpacity(0.4),
        ),
      ],
    );
  }
}

class DriverProfile extends StatefulWidget {
  const DriverProfile({
    Key? key,
  }) : super(key: key);

  @override
  State<DriverProfile> createState() => _DriverProfileState();
}

class _DriverProfileState extends State<DriverProfile> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  Map detail = {};

  getUserDetails() {
    FirebaseDatabase.instance
        .ref()
        .child("Users")
        .child("Drivers")
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2c4260),
      appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Profile",
            style: TextStyle(color: Colors.grey),
          ),
          elevation: 0.0,
          backgroundColor: Color(0xff2c4260),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
                onPressed: () {},
                icon: Icon(
                  IconlyLight.editSquare,
                  color: Colors.grey,
                ))
          ]),
      body: Container(
        color: Color(0xff2c4260),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: Image.asset(
                "assets/images/driver.jpg",
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            Text(
              detail['name'] ?? "...",
              style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            Text("Driver", style: TextStyle(color: Colors.white)),
            ListTile(
              leading: Icon(Iconsax.call, color: Colors.white),
              title: Text(
                detail['mobile'] ?? "...",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "Mobile Number",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
              trailing: Icon(
                Iconsax.arrow_right_41,
                color: Colors.white,
              ),
            ),
            Spacer(),
            MaterialButton(
              onPressed: () {
                firebaseAuth.signOut();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => Login()),
                    (route) => false);
              },
              color: Colors.red,
              textColor: Colors.white,
              child: Text("Logout"),
            ),
            SizedBox(
              height: 56,
            )
          ],
        ),
      ),
    );
  }
}

class DriverMap extends StatefulWidget {
  const DriverMap({
    Key? key,
  }) : super(key: key);

  @override
  State<DriverMap> createState() => _DriverMapState();
}

class _DriverMapState extends State<DriverMap> {
  Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController mainController;

  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(4.893916560114828, 6.906338496562588),
    zoom: 16,
  );
  PolylinePoints polylinePoints = new PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};
  Map<MarkerId, Marker> markers = {};
  BitmapDescriptor? pickLocationIcon;
  final directionsService = gda.DirectionsService();
  DatabaseReference dbref =
      FirebaseDatabase.instance.ref().child("DriverAvailable");

  geoFireUpdate(LatLng latLng) async {
    await Geofire.setLocation(
        firebaseAuth.currentUser!.uid, latLng.latitude, latLng.longitude);
  }

  stopGeoFire() async {
    await Geofire.removeLocation(firebaseAuth.currentUser!.uid);
  }

  bool online = false;

  Map customer = {};
  String customerKey = "";
  Map rideDetails = {};

  Map userDetail = {};
  int number = 1;
  getUserDetails() {
    FirebaseDatabase.instance
        .ref()
        .child("Users")
        .child("Customers")
        .child(customerKey)
        .get()
        .then((data) {
      if (data.exists) {
        Map users = data.value as Map;
        if (!mounted) return;
        setState(() {
          userDetail = users;
        });
      }
    });
  }

  getIncomingRequest() {
    FirebaseDatabase.instance
        .ref()
        .child("CustomerRequest")
        .child(customerKey)
        .get()
        .then((data) {
      if (data.exists) {
        Map newdata = data.value as Map;
        getCustomerDetails();
        setState(() {
          rideDetails = newdata;
        });
        getUserDetails();
      }
    });
  }

  getCustomerDetails() {
    FirebaseDatabase.instance
        .ref()
        .child("Users")
        .child("Drivers")
        .child(firebaseAuth.currentUser!.uid)
        .get()
        .then((datasnapshot) {
      if (datasnapshot.exists) {
        Map data = datasnapshot.value as Map;

        if (data['customerid'] != null) {
          Provider.of<DriverModel>(context, listen: false).customerKey =
              data['customerId'];
          dbref.child(firebaseAuth.currentUser!.uid).remove();
        }

        setState(() {
          onRide = !onRide;
          customer = data;
          customerKey = data['customerId'];
        });
      }
    });
  }

  userDetails() {}

  bool onRide = false;

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
        mainController.animateCamera(CameraUpdate.newCameraPosition(
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
          mainController.animateCamera(CameraUpdate.newCameraPosition(
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

      await Geolocator.getCurrentPosition().then((pos) {
        mainController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(pos.latitude, pos.longitude), zoom: 16)));
      });
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.

    await Geolocator.getCurrentPosition().then((pos) {
      mainController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(pos.latitude, pos.longitude), zoom: 16)));
    });
  }

  Timer? countdown;

  @override
  void initState() {
    Geofire.initialize(dbref.path);
    super.initState();
    // getCustomerDetails();
    updateUserLocation();
    _determinePosition();
  }

  countdownTimer() {
    countdown = Timer.periodic(Duration(seconds: 1), (timer) {
      FirebaseDatabase.instance
          .ref()
          .child("CustomerRequest")
          .child(customerKey)
          .update({"timer": number++});
    });
  }

  testchange() {
    Future.delayed(Duration(seconds: 1), () {
      getCustomerDetails();
      getIncomingRequest();
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
        mainController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(_position.latitude, _position.longitude),
                zoom: 16)));
      }
    });
  }

  @override
  void dispose() {
    stopGeoFire();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    updateUserLocation();
    if (customerKey.isEmpty) {
      getCustomerDetails();
    }

    return Scaffold(
        body: customerKey.isNotEmpty
            ? StreamBuilder<Object>(
                stream: FirebaseDatabase.instance
                    .ref()
                    .child("CustomerRequest")
                    .child(customerKey)
                    .onValue,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Map data =
                        (snapshot.data as DatabaseEvent).snapshot.value as Map;
                    if (snapshot.hasData) {
                      getUserDetails();
                    }

                    if (!snapshot.hasData) {
                      return Container(
                          width: double.infinity,
                          height: double.infinity,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ));
                    }

                    if (data['status'] == "completed") {
                      double totals = 0;
                      if (data['timer'] >
                          double.parse(
                                  data['time'].toString().split(" ").first) *
                              60) {
                        totals = (data['timer'] -
                                    double.parse(data['time']
                                            .toString()
                                            .split(" ")
                                            .first) *
                                        60) /
                                60 *
                                100 +
                            data['cost'];
                      } else {
                        totals = data['cost'];
                      }

                      return Container(
                        height: 650,
                        width: double.infinity,
                        color: Colors.white,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/images/ubc.jpg",
                                width: 120,
                              ),
                              Text(
                                "Trip Complete",
                                style: TextStyle(
                                    fontSize: 21, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                  "${(data['timer'] / 60).truncate().toString().padLeft(2, '0')}:${(data['timer'] % 60).toString().padLeft(2, '0')}"),
                              SizedBox(
                                height: 34,
                              ),
                              Text(
                                "Pay driver",
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                "N${totals.toStringAsFixed(0)}",
                                style: TextStyle(
                                    fontSize: 21, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                  width: double.infinity,
                                  height: 48,
                                  margin: EdgeInsets.only(
                                      top: 45, left: 12, right: 12),
                                  child: MaterialButton(
                                    onPressed: () {
                                      FirebaseDatabase.instance
                                          .ref()
                                          .child("CustomerRequest")
                                          .child(customerKey)
                                          .remove();

                                      FirebaseDatabase.instance
                                          .ref()
                                          .child("Users")
                                          .child("Drivers")
                                          .child(firebaseAuth.currentUser!.uid)
                                          .child(customerKey)
                                          .remove();

                                      setState(() {
                                        customerKey = "";
                                      });
                                    },
                                    child: Text("Okay"),
                                    textColor: Colors.white,
                                    color: Colors.green.shade900,
                                  ))
                            ]),
                      );
                    }
                    return Stack(
                      children: [
                        SafeArea(
                          child: GoogleMap(
                            mapType: MapType.normal,
                            zoomGesturesEnabled: true,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            compassEnabled: false,
                            zoomControlsEnabled: false,
                            padding: EdgeInsets.only(top: 51),
                            initialCameraPosition: _kGooglePlex,
                            markers: Set<Marker>.of(markers.values),
                            polylines: Set<Polyline>.of(polylines.values),
                            onMapCreated: (GoogleMapController controller) {
                              _controller.complete(controller);
                              mainController = controller;
                              updateUserLocation();
                            },
                            onCameraMove: (position) {
                              if (online) {
                                if (!onRide) {
                                  geoFireUpdate(LatLng(position.target.latitude,
                                      position.target.longitude));
                                }
                              }
                            },
                          ),
                        ),
                        online
                            ? Positioned(
                                left: 45,
                                right: 45,
                                child: SafeArea(
                                  child: MaterialButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      onPressed: () {
                                        if (!mounted) return;
                                        setState(() {
                                          online = !online;

                                          stopGeoFire();
                                        });
                                      },
                                      child: Text("Go Offline"),
                                      color: Colors.red,
                                      textColor: Colors.white),
                                ))
                            : Positioned(
                                left: 45,
                                right: 45,
                                child: SafeArea(
                                  child: MaterialButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      onPressed: () {
                                        if (!mounted) return;
                                        setState(() {
                                          online = !online;
                                        });
                                      },
                                      child: Text("Go Online ${customerKey}"),
                                      color: Color(0xff2c4260),
                                      textColor: Colors.white),
                                )),
                        data != null && data['status'] == "confirm"
                            ? Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 450,
                                  width: double.infinity,
                                  color: Colors.white,
                                  padding: EdgeInsets.all(12),
                                  child: Column(children: [
                                    ClipOval(
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        child: Image.asset(
                                          "assets/images/rider.jpg",
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "${userDetail['name']}",
                                      style: TextStyle(
                                          fontSize: 21,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text("Want to ride with you",
                                        style: TextStyle(
                                            fontSize: 31,
                                            fontWeight: FontWeight.bold)),
                                    Divider(),
                                    Text("${data['pickup_address']}"),
                                    Text(
                                        "N" +
                                            double.parse(
                                                    data['cost'].toString())
                                                .toStringAsFixed(0),
                                        style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold)),
                                    Container(
                                        width: double.infinity,
                                        height: 48,
                                        margin: EdgeInsets.only(top: 45),
                                        child: MaterialButton(
                                          onPressed: () {
                                            FirebaseDatabase.instance
                                                .ref()
                                                .child("CustomerRequest")
                                                .child(customerKey)
                                                .update({"status": "accepted"});

                                            stopGeoFire();

                                            FirebaseDatabase.instance
                                                .ref()
                                                .child("DriverAvailable")
                                                .child(firebaseAuth
                                                    .currentUser!.uid)
                                                .remove();
                                            if (!mounted) return;
                                            setState(() {
                                              onRide = !onRide;
                                            });
                                          },
                                          child: Text("Accept"),
                                          textColor: Colors.white,
                                          color: Colors.green.shade900,
                                        ))
                                  ]),
                                ))
                            : SizedBox.shrink(),
                        data != null && data['status'] == "accepted"
                            ? Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 250,
                                  color: Colors.white,
                                  width: double.infinity,
                                  child: Column(children: [
                                    Text(
                                      "Goto Rider Location",
                                      style: TextStyle(
                                          fontSize: 21,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 34,
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(70)),
                                            child: MaterialButton(
                                              onPressed: () {},
                                              color: Colors.black,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          70)),
                                              child: Icon(
                                                Feather.phone,
                                                color: Colors.white,
                                              ),
                                            )),
                                        SizedBox(
                                          width: 12,
                                        ),
                                        Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(70)),
                                            child: MaterialButton(
                                              onPressed: () {},
                                              color: Colors.black,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          70)),
                                              child: Icon(
                                                Feather.message_square,
                                                color: Colors.white,
                                              ),
                                            )),
                                      ],
                                    ),
                                    Container(
                                        width: double.infinity,
                                        height: 48,
                                        margin: EdgeInsets.only(
                                            top: 45, left: 12, right: 12),
                                        child: MaterialButton(
                                          onPressed: () {
                                            FirebaseDatabase.instance
                                                .ref()
                                                .child("CustomerRequest")
                                                .child(customerKey)
                                                .update({"status": "arrived"});
                                          },
                                          child: Text("Arrived"),
                                          textColor: Colors.white,
                                          color: Colors.green.shade900,
                                        ))
                                  ]),
                                ))
                            : SizedBox.shrink(),
                        data != null && data['status'] == "arrived"
                            ? Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 250,
                                  width: double.infinity,
                                  color: Colors.white,
                                  child: Column(children: [
                                    Text(
                                      "At Rider Location",
                                      style: TextStyle(
                                          fontSize: 21,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 34,
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(70)),
                                            child: MaterialButton(
                                              onPressed: () {},
                                              color: Colors.black,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          70)),
                                              child: Icon(
                                                Feather.phone,
                                                color: Colors.white,
                                              ),
                                            )),
                                        SizedBox(
                                          width: 12,
                                        ),
                                        Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(70)),
                                            child: MaterialButton(
                                              onPressed: () {},
                                              color: Colors.black,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          70)),
                                              child: Icon(
                                                Feather.message_square,
                                                color: Colors.white,
                                              ),
                                            )),
                                      ],
                                    ),
                                    Container(
                                        width: double.infinity,
                                        height: 48,
                                        margin: EdgeInsets.only(
                                            top: 45, left: 12, right: 12),
                                        child: MaterialButton(
                                          onPressed: () {
                                            countdownTimer();
                                            FirebaseDatabase.instance
                                                .ref()
                                                .child("CustomerRequest")
                                                .child(customerKey)
                                                .update(
                                                    {"status": "trip start"});
                                          },
                                          child: Text("Start Trip"),
                                          textColor: Colors.white,
                                          color: Colors.green.shade900,
                                        ))
                                  ]),
                                ))
                            : SizedBox.shrink(),
                        data != null && data['status'] == "trip start"
                            ? Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 350,
                                  width: double.infinity,
                                  color: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: ListView(
                                    physics: BouncingScrollPhysics(),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 21),
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ClipOval(
                                            child: Image.asset(
                                              "assets/images/rider.jpg",
                                              width: 65,
                                            ),
                                          ),
                                          Text(userDetail['name'].toString() ??
                                              "...")
                                        ],
                                      ),
                                      ListTile(
                                        dense: true,
                                        leading: Icon(Iconsax.clock),
                                        title: Text(
                                          data['time'].toString() ?? "...",
                                          style: TextStyle(
                                              fontSize: 21,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        trailing: Text(
                                          "Extra Time N100/min",
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 14),
                                        ),
                                      ),
                                      Text(
                                          "N" +
                                              double.parse(
                                                      data['cost'].toString())
                                                  .toStringAsFixed(0),
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.montserrat(
                                              fontSize: 34,
                                              fontWeight: FontWeight.bold)),
                                      data['timer'] != null
                                          ? Text(
                                              "${(data['timer'] / 60).truncate().toString().padLeft(2, '0')}:${(data['timer'] % 60).toString().padLeft(2, '0')}")
                                          : Text(''),
                                      Divider(),
                                      ListTile(
                                        dense: true,
                                        leading: Icon(Iconsax.location),
                                        title: Text(data['dropoff_address']
                                                .toString() ??
                                            "..."),
                                        subtitle: Text("Dropoff address"),
                                        trailing: Icon(Iconsax.arrow_right),
                                      ),
                                      Container(
                                          width: double.infinity,
                                          height: 48,
                                          margin: EdgeInsets.only(
                                              top: 5, left: 12, right: 12),
                                          child: MaterialButton(
                                            onPressed: () {
                                              FirebaseDatabase.instance
                                                  .ref()
                                                  .child("CustomerRequest")
                                                  .child(customerKey)
                                                  .update(
                                                      {"status": "completed"});
                                              FirebaseDatabase.instance
                                                  .ref()
                                                  .child("Users")
                                                  .child("Customers")
                                                  .child(customerKey)
                                                  .child("History")
                                                  .push()
                                                  .set(data);

                                              FirebaseDatabase.instance
                                                  .ref()
                                                  .child("Users")
                                                  .child("Drivers")
                                                  .child(firebaseAuth
                                                      .currentUser!.uid)
                                                  .child("History")
                                                  .push()
                                                  .set(data);

                                              FirebaseDatabase.instance
                                                  .ref()
                                                  .child('Users')
                                                  .child('Drivers')
                                                  .child(firebaseAuth
                                                      .currentUser!.uid)
                                                  .child('customerId')
                                                  .remove();

                                              countdown!.cancel();
                                              if (!mounted) return;
                                              setState(() {
                                                onRide = !onRide;
                                              });
                                            },
                                            child: Text("End Ride"),
                                            textColor: Colors.white,
                                            color: Colors.red.shade900,
                                          ))
                                    ],
                                  ),
                                ),
                              )
                            // Message

                            : SizedBox.shrink(),
                      ],
                    );
                  } else {
                    return Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: Center(child: Text("No data")),
                    );
                  }
                })
            : Stack(
                children: [
                  SafeArea(
                    child: GoogleMap(
                      mapType: MapType.normal,
                      zoomGesturesEnabled: true,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      compassEnabled: false,
                      zoomControlsEnabled: false,
                      padding: EdgeInsets.only(top: 51, right: 21, left: 21),
                      initialCameraPosition: _kGooglePlex,
                      markers: Set<Marker>.of(markers.values),
                      polylines: Set<Polyline>.of(polylines.values),
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                        mainController = controller;
                        updateUserLocation();
                      },
                      onCameraMove: (position) {
                        if (online) {
                          geoFireUpdate(LatLng(position.target.latitude,
                              position.target.longitude));
                        }
                      },
                    ),
                  ),
                  online
                      ? Positioned(
                          left: 45,
                          right: 45,
                          child: SafeArea(
                            child: MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                onPressed: () {
                                  if (!mounted) return;
                                  setState(() {
                                    online = !online;

                                    stopGeoFire();
                                  });
                                },
                                child: Text("Go Offline".toUpperCase()),
                                color: Colors.red,
                                textColor: Colors.white),
                          ))
                      : Positioned(
                          left: 45,
                          right: 45,
                          child: SafeArea(
                            child: MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                onPressed: () {
                                  if (!mounted) return;
                                  setState(() {
                                    online = !online;
                                  });
                                },
                                child: Text("Go Online".toUpperCase()),
                                color: Color(0xff2c4260),
                                textColor: Colors.white),
                          )),
                ],
              ));
  }
}
