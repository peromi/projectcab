import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_place/google_place.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/model/riderModel.dart';
import 'package:untitled1/rider/directionscreen.dart';
import 'package:untitled1/utills/constants.dart';

class SearchPlace extends StatefulWidget {
  const SearchPlace({Key? key}) : super(key: key);

  @override
  _SearchPlaceState createState() => _SearchPlaceState();
}

class _SearchPlaceState extends State<SearchPlace> {
  TextEditingController pickupcontroller = TextEditingController();
  TextEditingController dropoffcontroller = TextEditingController();
  List<AutocompletePrediction> predictions = [];
  bool isSearching = false;
  var googlePlace;
  @override
  void initState() {
    // TODO: implement initState
    googlePlace = GooglePlace(APIKEY);

    super.initState();
  }

  getplace(String val) async {
// var  res = await Geocoder.google(APIKEY, language: 'en').findAddressesFromQuery(val);
    if (!mounted) return;
    setState(() {
      // isSearching = true;
    });

    try {
      var res = await googlePlace.autocomplete.get(val);
      if (!mounted) return;
      setState(() {
        // isSearching = false;
        // print(isSearching);
      });
      if (res.predictions.isNotEmpty) {
        print(res.predictions);
        if (!mounted) return;
        setState(() {
          predictions = res.predictions;
          isSearching = true;
        });
      } else {
        predictions = [];
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    pickupcontroller.text =
        Provider.of<RiderModel>(context, listen: false).pickupaddress;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          DraggableScrollableSheet(
            snap: true,
            initialChildSize: 0.34,
            snapSizes: [0.5, 0.78],
            maxChildSize: 0.78,
            minChildSize: 0.30,
            builder: (context, scrollController) {
              return Material(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18)),
                child: Column(
                  children: [
                    Container(
                      width: 36,
                      height: 4,
                      margin: EdgeInsets.only(top: 12, bottom: 12),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.withOpacity(0.5)),
                    ),
                    Text(
                      isSearching ? "Result" : "Recent Places",
                      style: TextStyle(fontSize: 24),
                    ),
                    Divider(),
                    Expanded(
                      child: isSearching
                          ? ListView.builder(
                              padding: EdgeInsets.only(top: 24),
                              physics: BouncingScrollPhysics(),
                              controller: scrollController,
                              itemCount: predictions.length,
                              itemBuilder: (context, index) {
                                String street;
                                String city;
                                String country;
                                street = predictions[index]
                                    .description!
                                    .split(',')
                                    .first;
                                city = predictions[index]
                                    .description!
                                    .split(',')[1]
                                    .trim();
                                country = predictions[index]
                                    .description!
                                    .split(',')
                                    .last;
                                if (predictions.length < 1) {
                                  return Container(
                                    child: Text("No result found"),
                                  );
                                } else {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: 8.0,
                                        right: 8.0,
                                        top: 4,
                                        bottom: 2),
                                    child: GestureDetector(
                                      onTap: () {
                                        Provider.of<RiderModel>(context,
                                                    listen: false)
                                                .dropoffaddress =
                                            predictions[index].description!;
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DirectionScreen()));
                                      },
                                      child: Row(
                                        children: [
                                          Icon(Iconsax.location),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  RichText(
                                                      text: TextSpan(
                                                          text: predictions[
                                                                  index]
                                                              .description!
                                                              .substring(
                                                                  0,
                                                                  pickupcontroller
                                                                      .text
                                                                      .length),
                                                          style:
                                                              GoogleFonts.dosis(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                          children: [
                                                        TextSpan(
                                                            text: predictions[
                                                                    index]
                                                                .description!
                                                                .substring(
                                                                    pickupcontroller
                                                                        .text
                                                                        .length),
                                                            style: GoogleFonts
                                                                .dosis(
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .grey))
                                                      ])),
                                                  Text(city)
                                                ],
                                              ),
                                            ),
                                          ),
                                          Icon(Iconsax.arrow_right)
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              },
                            )
                          : ListView(
                              physics: BouncingScrollPhysics(),
                              controller: scrollController,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 4),
                              children: [
                                ListTile(
                                  leading: Icon(Iconsax.location),
                                  title: Text("12 King jaja"),
                                  subtitle: Text("Port Harcourt"),
                                  trailing: Icon(Iconsax.arrow_right),
                                ),
                                Divider()
                              ],
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
          // MENU TOP
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      spreadRadius: 08)
                ]),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: EdgeInsets.only(left: 12.0),
                                child: SvgPicture.asset(
                                  "assets/icons/fi-rr-arrow-left.svg",
                                  width: 34,
                                  color: Colors.grey,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Text(
                              "Set Destination",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 34,
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        margin: EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12),
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12))),
                        child: TextFormField(
                          enabled: false,
                          controller: pickupcontroller,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(4.0),
                              prefixIcon: Icon(
                                Iconsax.location,
                                size: 16,
                              ),
                              hintText: "Pickup Location",
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none)),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        margin: EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom:
                                    BorderSide(width: 1, color: Colors.black26),
                                right: BorderSide(color: Colors.black26),
                                left: BorderSide(color: Colors.black26),
                                top: BorderSide(color: Colors.black26)),
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12))),
                        child: TextFormField(
                          onChanged: (value) {
                            if (value.length > 2) {
                              getplace(value);
                              setState(() {
                                isSearching = !isSearching;
                              });
                            }
                          },
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(4.0),
                              prefixIcon: Icon(
                                Iconsax.location,
                                size: 16,
                              ),
                              hintText: "Dropoff Location",
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none)),
                        ),
                      ),
                    ],
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
