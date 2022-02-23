import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:untitled1/main.dart';

class DriverModel extends ChangeNotifier {
  String _pickupaddress = "";
  String _dropoffaddress = "";
  double _rideXPrice = 0;
  double _rideXLPrice = 0;
  String _traveltime = "";
  String _traveldistance = "";
  String _selectedRide = "Ride X";
  String _customerKey = "";
  Map _details = {};

  Position? _pickuplocation;
  Position? _dropofflocation;

  String get pickupaddress => _pickupaddress;
  String get dropoffaddress => _dropoffaddress;
  double get rideXPrice => _rideXPrice;
  double get rideXLPrice => _rideXLPrice;
  String get traveltime => _traveltime;
  String get traveldistance => _traveldistance;
  String get selectedRide => _selectedRide;

  Position get pickuplocation => _pickuplocation!;
  Position get dropofflocation => _dropofflocation!;
  Map get details => _details;
  String get customerKey => _customerKey;

  set customerKey(String val) {
    _customerKey = val;
    notifyListeners();
  }

  Map driverDetails() {
    driverUser.get().then((value) {
      _details = value.value as Map;
    });

    notifyListeners();
    return _details;
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

  customerDetails() {}
}
