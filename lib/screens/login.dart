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
import 'package:untitled1/screens/driverLogin.dart';
import 'package:untitled1/screens/register.dart';
import 'package:untitled1/screens/riderLogin.dart';
import 'package:untitled1/utills/constants.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
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
        .signInWithEmailAndPassword(email: _email.text, password: _pass.text)
        .then((user) {
      if (user != null) {
        loggedInUser.get().then((value) {
          if (status == false) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => WelcomeScreen()),
                (route) => false);

            // setState(() {
            //   loading = !loading;
            // });
          } else {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => HomeScreen()),
                (route) => false);
            // setState(() {
            //   loading = !loading;
            // });
          }
        });
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
    return Scaffold(
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
              "Welcome",
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
                    margin: EdgeInsets.only(top: 35, left: 35, right: 35),
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18)),
                    child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RiderLogin()));
                        },
                        style: TextButton.styleFrom(
                            backgroundColor: dirty_green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            primary: Colors.white),
                        child: Text(
                          "Login As Rider",
                          style: TextStyle(fontSize: 21),
                        ))),
                Container(
                    margin: EdgeInsets.only(top: 5, left: 35, right: 35),
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18)),
                    child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DriverLogin()));
                        },
                        style: TextButton.styleFrom(
                            backgroundColor: dirty_green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            primary: Colors.white),
                        child: Text(
                          "Login As Driver",
                          style: TextStyle(fontSize: 21),
                        ))),
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
                                  builder: (context) => RegisterScreen()));
                        },
                        child: Text(
                          "SignUp",
                          style: TextStyle(color: dirty_green),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ))
          ],
        ),
      ),
    );
  }
}
