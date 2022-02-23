import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:iconsax/iconsax.dart';
import 'package:untitled1/driver/homescreen.dart';
import 'package:untitled1/main.dart';
import 'package:untitled1/rider/welcome.dart';
import 'package:untitled1/utills/constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  TextEditingController _name = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _mobile = TextEditingController();
  TextEditingController _pass = TextEditingController();
  TextEditingController _color = TextEditingController();
  TextEditingController _plateno = TextEditingController();
  TextEditingController _car = TextEditingController();

  String usertype = "";

  bool loading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void RegisterNewUser() {
    setState(() {
      loading = !loading;
    });
    _firebaseAuth
        .createUserWithEmailAndPassword(
            email: _email.text, password: _pass.text)
        .then((user) {
      if (usertype == "rider") {
        Map userdata = {
          'id': _firebaseAuth.currentUser!.uid.toString(),
          'name': _name.text.trim(),
          'email': _email.text.trim(),
          'mobile': _mobile.text.trim(),
          'role': usertype.toString()
        };
        usersRef
            .child('Customers')
            .child(_firebaseAuth.currentUser!.uid)
            .set(userdata);
      } else {
        Map userdata = {
          'id': _firebaseAuth.currentUser!.uid.toString(),
          'name': _name.text.trim(),
          'email': _email.text.trim(),
          'mobile': _mobile.text.trim(),
          'role': usertype.toString(),
          'cartype': _car.text.toString(),
          'color': _color.text.toString(),
          'plate': _plateno.text.toString()
        };
        usersRef
            .child('Drivers')
            .child(_firebaseAuth.currentUser!.uid)
            .set(userdata);
      }
      if (usertype == "rider") {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => WelcomeScreen()),
            (route) => false);
      } else {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (_) => HomeScreen()), (route) => false);
      }
    }).catchError((error) {
      setState(() {
        loading = !loading;
      });
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                content: Text(error.toString()),
              ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Material(
            child: Container(
              width: double.infinity,
              height: double.infinity,
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
            ),
          )
        : Scaffold(
            appBar: AppBar(
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              leadingWidth: 44,
              leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 12.0),
                  child: SvgPicture.asset(
                    "assets/icons/fi-rr-arrow-left.svg",
                    width: 124,
                    color: Colors.grey,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: 120,
                    child: Image.asset(
                      logoapp,
                      width: 80,
                      height: 80,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                  Text(
                    "Create Account",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: dirty_green),
                  ),
                  Form(
                      child: Column(
                    children: [
                      SizedBox(
                        height: 12,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        margin:
                            EdgeInsets.symmetric(horizontal: 35, vertical: 4),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12)),
                        child: TextFormField(
                          controller: _name,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(4.0),
                              prefixIcon: Icon(Iconsax.user),
                              hintText: "Fullname",
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none)),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        margin: EdgeInsets.symmetric(horizontal: 35),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12)),
                        child: TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(4.0),
                              prefixIcon: Icon(Iconsax.message),
                              hintText: "Email or Username",
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none)),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        margin:
                            EdgeInsets.symmetric(horizontal: 35, vertical: 4),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12)),
                        child: TextFormField(
                          controller: _mobile,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(4.0),
                              prefixIcon: Icon(Iconsax.call),
                              hintText: "Mobile",
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none)),
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          margin:
                              EdgeInsets.symmetric(horizontal: 35, vertical: 4),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12)),
                          child: DropdownButtonFormField(
                            icon: Icon(Feather.chevron_down),
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(right: 8),
                                prefixIcon: Icon(Iconsax.profile_2user),
                                hintText: "Who are you?",
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none)),
                            items: [
                              DropdownMenuItem(
                                child: Text("Rider"),
                                value: "rider",
                              ),
                              DropdownMenuItem(
                                child: Text("Driver"),
                                value: "driver",
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                usertype = value.toString().trim();
                              });
                            },
                          )),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        margin:
                            EdgeInsets.symmetric(horizontal: 35, vertical: 4),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12)),
                        child: TextFormField(
                          controller: _pass,
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(4.0),
                              prefixIcon: Icon(Iconsax.lock),
                              hintText: "Password",
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none)),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        margin:
                            EdgeInsets.symmetric(horizontal: 35, vertical: 4),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12)),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(4.0),
                              prefixIcon: Icon(Iconsax.lock),
                              hintText: "Confirm Password",
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none)),
                        ),
                      ),
                      usertype != "driver"
                          ? SizedBox.shrink()
                          : SizedBox(
                              child: Column(
                                children: [
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 2),
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 35, vertical: 4),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: TextFormField(
                                      controller: _car,
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                          contentPadding: EdgeInsets.all(4.0),
                                          prefixIcon: Icon(Iconsax.car),
                                          hintText: "Car model",
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide.none)),
                                    ),
                                  ),
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 2),
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 35, vertical: 4),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: TextFormField(
                                      controller: _color,
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                          contentPadding: EdgeInsets.all(4.0),
                                          prefixIcon:
                                              Icon(Iconsax.color_swatch),
                                          hintText: "Color of car",
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide.none)),
                                    ),
                                  ),
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 2),
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 35, vertical: 4),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: TextFormField(
                                      controller: _plateno,
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                          contentPadding: EdgeInsets.all(4.0),
                                          prefixIcon: Icon(Iconsax.receipt),
                                          hintText: "Plate Number",
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide.none)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 35.0),
                        child: Row(
                          children: [
                            Text("Already have an account?"),
                            MaterialButton(
                              minWidth: 12,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Login",
                                style: TextStyle(color: dirty_green),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 35, left: 35, right: 35),
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12)),
                          child: TextButton(
                              onPressed: () {
                                RegisterNewUser();
                              },
                              style: TextButton.styleFrom(
                                  backgroundColor: dirty_green,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  primary: Colors.white),
                              child: Text("Create"))),
                    ],
                  )),
                  SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.0),
                    child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            style: TextStyle(color: Colors.black, fontSize: 10),
                            text:
                                "This application is for University Project, it is under-law abiding to the ",
                            children: [
                              TextSpan(
                                text: "Rules",
                                style: TextStyle(
                                    color: Colors.green, fontSize: 12),
                              ),
                              TextSpan(text: " and "),
                              TextSpan(
                                text: "Policies",
                                style: TextStyle(
                                    color: Colors.green, fontSize: 12),
                              ),
                              TextSpan(text: " so use it with caution.")
                            ])),
                  )
                ],
              ),
            ));
  }
}
