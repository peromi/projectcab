import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_directions_api/google_directions_api.dart' as gda;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/model/riderModel.dart';
import 'package:untitled1/rider/confirmRide.dart';
import 'package:untitled1/utills/constants.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class DirectionScreen extends StatefulWidget {
  const DirectionScreen();

  @override
  _DirectionScreenState createState() => _DirectionScreenState();
}

class _DirectionScreenState extends State<DirectionScreen> {
  Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController mainController;

  static final CameraPosition _kGooglePlex = CameraPosition(
      target: LatLng(4.815940191804643, 7.063743295912514),
      zoom: 14.4746,
      tilt: 50);
  PolylinePoints polylinePoints = new PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};
  Map<MarkerId, Marker> markers = {};
  String time = "";
  String distance = "";
  BitmapDescriptor? pickLocationIcon;
  BitmapDescriptor? dropLocationIcon;

  bool isRideX = true;
  String selectedCar = "Ride X";

  final directionsService = gda.DirectionsService();

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
        Polyline p = Polyline(
            polylineId: PolylineId("overview_polyline"),
            color: dirty_green,
            width: 5,
            endCap: Cap.roundCap,
            startCap: Cap.roundCap,
            zIndex: 12,
            points: PolylinePoints()
                .decodePolyline(
                    result!.first.overviewPolyline!.points.toString())
                .map((e) => LatLng(e.latitude, e.longitude))
                .toList());

        //  Add marker for pickup
        var _pickmarker = Marker(
            markerId: MarkerId("pcik"),
            icon: pickLocationIcon!,
            position: LatLng(result.first.legs!.first.startLocation!.latitude,
                result!.first.legs!.first.startLocation!.longitude));

        var _dropmarker = Marker(
            markerId: MarkerId("desti"),
            icon: dropLocationIcon!,
            position: LatLng(result.first.legs!.first.endLocation!.latitude,
                result.first.legs!.first.endLocation!.longitude));

        Provider.of<RiderModel>(context, listen: false).dropofflocation =
            Position(
                longitude: result.first.legs!.first.endLocation!.longitude,
                latitude: result.first.legs!.first.endLocation!.longitude,
                timestamp: DateTime.now(),
                accuracy: 10,
                altitude: 0,
                heading: 90,
                speed: 2.0,
                speedAccuracy: 2.0);

        setState(() {
          polylines[PolylineId("overview_polyline")] = p;
          markers[MarkerId("pcik")] = _pickmarker;
          markers[MarkerId("desti")] = _dropmarker;
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

  @override
  void initState() {
    super.initState();

    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5),
            'assets/images/pick_marker.png')
        .then((onValue) {
      pickLocationIcon = onValue;
    });

    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5),
            'assets/images/destination_map_marker.png')
        .then((onValue) {
      dropLocationIcon = onValue;
    });

    getDirectionUpdate(
        Provider.of<RiderModel>(context, listen: false).pickupaddress,
        Provider.of<RiderModel>(context, listen: false).dropoffaddress);
  }

  Future<List<Placemark>> getUserAddress(Position pos) async {
    return await GeocodingPlatform.instance
        .placemarkFromCoordinates(pos.latitude, pos.longitude);
  }

  @override
  void didChangeDependencies() {
    getDirectionUpdate(
        Provider.of<RiderModel>(context, listen: false).pickupaddress,
        Provider.of<RiderModel>(context, listen: false).dropoffaddress);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    this.build(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: Stack(
        children: [
          GoogleMap(
            tiltGesturesEnabled: true,
            mapType: MapType.normal,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            compassEnabled: false,
            zoomControlsEnabled: false,
            padding: EdgeInsets.only(bottom: 300),
            initialCameraPosition: _kGooglePlex,
            markers: Set<Marker>.of(markers.values),
            polylines: Set<Polyline>.of(polylines.values),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              mainController = controller;
            },
          ),
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
                        InkWell(
                          onTap: () {
                            setState(() {
                              selectedCar = "Ride X";
                              Provider.of<RiderModel>(context, listen: false)
                                  .price = Provider.of<RiderModel>(context,
                                      listen: false)
                                  .rideXPrice
                                  .toString();
                            });
                          },
                          child: Container(
                            color: selectedCar == "Ride X"
                                ? Colors.green.withOpacity(0.1)
                                : Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            child: Material(
                              color: Colors.transparent,
                              child: Row(
                                children: [
                                  Image.asset(
                                    "assets/images/ubc.jpg",
                                    width: 65,
                                  ),
                                  SizedBox(
                                    width: 12,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Ride X",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      Text("Simple ride for 4"),
                                    ],
                                  ),
                                  Spacer(),
                                  Text(
                                    "₦${Provider.of<RiderModel>(context, listen: false).rideXPrice.toStringAsFixed(2)}",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              selectedCar = "Ride XL";
                              Provider.of<RiderModel>(context, listen: false)
                                  .price = Provider.of<RiderModel>(context,
                                      listen: false)
                                  .rideXLPrice
                                  .toString();
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            color: selectedCar == "Ride XL"
                                ? Colors.green.withOpacity(0.1)
                                : Colors.white,
                            child: Material(
                              color: Colors.transparent,
                              child: Row(
                                children: [
                                  Image.asset(
                                    "assets/images/ubb.jpg",
                                    width: 65,
                                  ),
                                  SizedBox(
                                    width: 12,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Ride XL",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      Text("Premium"),
                                    ],
                                  ),
                                  Spacer(),
                                  Text(
                                    "₦${Provider.of<RiderModel>(context, listen: false).rideXLPrice.toStringAsFixed(2)}",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
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
                        margin: EdgeInsets.symmetric(horizontal: 12),
                        width: double.infinity,
                        child: MaterialButton(
                          onPressed: () async {
                            Provider.of<RiderModel>(context, listen: false)
                                .selectedRide = selectedCar;
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ConfirmRide(),
                                )).then((value) {
                              // this.build(context);
                              getDirectionUpdate(
                                  Provider.of<RiderModel>(context,
                                          listen: false)
                                      .pickupaddress,
                                  Provider.of<RiderModel>(context,
                                          listen: false)
                                      .dropoffaddress);
                            });
                          },
                          child: Text("Select ${selectedCar}",
                              style:
                                  TextStyle(fontSize: 24, color: Colors.white)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
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
                          onTap: () {},
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
              top: 54,
              right: 20,
              child: Material(
                elevation: 12,
                shadowColor: Colors.black26,
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  color: Colors.white,
                  height: 44,
                  child: Row(
                    children: [
                      Container(
                        height: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        color: dirty_green,
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.clock,
                              size: 21,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Text(
                              Provider.of<RiderModel>(context, listen: false)
                                  .traveltime
                                  .split(' ')
                                  .first,
                              style: TextStyle(
                                  fontSize: 20,
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
                      SizedBox(
                        width: 5,
                      ),
                      Row(
                        children: [
                          Icon(Iconsax.component),
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            Provider.of<RiderModel>(context, listen: false)
                                .traveldistance
                                .split(' ')
                                .first,
                            style: TextStyle(
                                fontSize: 21, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            Provider.of<RiderModel>(context, listen: false)
                                .traveldistance
                                .split(' ')
                                .last,
                          ),
                          SizedBox(
                            width: 12,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ))
        ],
      ),
    ));
  }
}
