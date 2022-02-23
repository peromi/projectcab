import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:untitled1/main.dart';

class RiderModel extends ChangeNotifier {
  String _pickupaddress = "";
  String _dropoffaddress = "";
  double _rideXPrice = 0;
  double _rideXLPrice = 0;
  String _traveltime = "";
  String _traveldistance = "";
  String _selectedRide = "Ride X";
  String _price = "";
  Map _details = {};
  String _driverkey = "";

  Position? _pickuplocation;
  Position? _dropofflocation;

  String get pickupaddress => _pickupaddress;
  String get dropoffaddress => _dropoffaddress;
  double get rideXPrice => _rideXPrice;
  double get rideXLPrice => _rideXLPrice;
  String get traveltime => _traveltime;
  String get traveldistance => _traveldistance;
  String get selectedRide => _selectedRide;
  String get driverKey => _driverkey;
  String get price => _price;

  Position get pickuplocation => _pickuplocation!;
  Position get dropofflocation => _dropofflocation!;

  Map get details => _details;

  set price(String val) {
    _price = val;
    notifyListeners();
  }

  set driverKey(String val) {
    _driverkey = val;
    notifyListeners();
  }

  Map riderDetails() {
    Map detail = {};
    loggedInUser.get().then((value) {
      detail = value.value as Map;
    });

    notifyListeners();
    return detail;
  }

  set pickupaddress(String value) {
    _pickupaddress = value;
    notifyListeners();
  }

  set dropoffaddress(String value) {
    _dropoffaddress = value;
    notifyListeners();
  }

  set traveltime(String value) {
    _traveltime = value;
    notifyListeners();
  }

  set traveldistance(String value) {
    _traveldistance = value;
    notifyListeners();
  }

  set selectedRide(String value) {
    _selectedRide = value;
    notifyListeners();
  }

  set rideXPrice(double price) {
    _rideXPrice = price;
    notifyListeners();
  }

  set rideXLPrice(double price) {
    _rideXLPrice = price;
    notifyListeners();
  }

  set pickuplocation(Position pos) {
    _pickuplocation = pos;
    notifyListeners();
  }

  set dropofflocation(Position pos) {
    _dropofflocation = pos;
    notifyListeners();
  }

  reset() {
    dropoffaddress = "";
    pickupaddress = "";
    dropofflocation = Position(
        longitude: 0,
        latitude: 0,
        timestamp: null,
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0);
    pickuplocation = Position(
        longitude: 0,
        latitude: 0,
        timestamp: null,
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0);
    traveldistance = "";
    traveltime = "";
  }

  customerDetails() {}
}
