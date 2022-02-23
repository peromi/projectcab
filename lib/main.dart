import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/driver/homescreen.dart';
import 'package:untitled1/model/driverModel.dart';
import 'package:untitled1/model/riderModel.dart';
import 'package:untitled1/rider/welcome.dart';
import 'package:untitled1/screens/login.dart';

import 'utills/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  DirectionsService.init(APIKEY);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => RiderModel(),
      ),
      ChangeNotifierProvider(
        create: (_) => DriverModel(),
      )
    ],
    child: const MyApp(),
  ));
}

FirebaseAuth firebaseAuth = FirebaseAuth.instance;
DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('Users');
DatabaseReference rideRef = FirebaseDatabase.instance.ref().child('Rides');
DatabaseReference loggedInUser = FirebaseDatabase.instance
    .ref()
    .child("Users")
    .child('Customers')
    .child(firebaseAuth.currentUser!.uid);

DatabaseReference driverUser =
    usersRef.child("Drivers").child(firebaseAuth.currentUser!.uid);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return MaterialApp(
      title: 'Cab Hailing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.dosisTextTheme(),
        primarySwatch: Colors.green,
        // fontFamily: "Strawford"
      ),
      home: Login(),
    );
  }
}
