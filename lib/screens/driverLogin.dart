import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:untitled1/driver/homescreen.dart';
import 'package:untitled1/main.dart';
import 'package:untitled1/rider/welcome.dart';
import 'package:untitled1/screens/register.dart';
import 'package:untitled1/utills/constants.dart';

class DriverLogin extends StatefulWidget {
  const DriverLogin({Key? key}) : super(key: key);

  @override
  _DriverLoginState createState() => _DriverLoginState();
}

class _DriverLoginState extends State<DriverLogin> {
  bool loading = false;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool showpassword = true;
  TextEditingController _email = TextEditingController();
  TextEditingController _pass = TextEditingController();
  bool status = false;
  void SignInUser() {
    setState(() {
      loading = !loading;
    });
    _firebaseAuth
        .signInWithEmailAndPassword(
            email: _email.text.trim(), password: _pass.text.trim())
        .then((user) {
      if (user != null) {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (_) => HomeScreen()), (route) => false);
      } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  content: Text("No record found"),
                ));
      }
    }).catchError((error) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                content: Text("No record found"),
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
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              elevation: 0.0,
              backgroundColor: Colors.transparent,
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
                    "SignIn Driver",
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
                          controller: _pass,
                          keyboardType: TextInputType.text,
                          obscureText: showpassword,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(4.0),
                              prefixIcon: Icon(Iconsax.lock),
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      showpassword = !showpassword;
                                    });
                                  },
                                  icon: Icon(
                                    showpassword
                                        ? Iconsax.eye_slash
                                        : Iconsax.eye,
                                    color: Colors.black,
                                  )),
                              hintText: "Password",
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none)),
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Divider(),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 35.0),
                        child: Row(
                          children: [
                            Text("Don't have an account?"),
                            MaterialButton(
                              minWidth: 12,
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            RegisterScreen()));
                              },
                              child: Text(
                                "SignUp",
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
                              borderRadius: BorderRadius.circular(18)),
                          child: TextButton(
                              onPressed: () {
                                SignInUser();
                              },
                              style: TextButton.styleFrom(
                                  backgroundColor: dirty_green,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  primary: Colors.white),
                              child: Text("Sign In"))),
                    ],
                  ))
                ],
              ),
            ),
          );
  }
}
