import 'package:firebase_database/firebase_database.dart';

class Users {
  String? id;
  String? name;
  String? email;
  String? mobile;

  Users(
      {required this.id,
      required this.email,
      required this.mobile,
      required this.name});

  Users.fromSnapshot(DataSnapshot dataSnapshot) {
    Map map = dataSnapshot as Map;

    id = map['id'];
    name = map['name'];
    email = map['email'];
    mobile = map['mobile'];
  }
}
