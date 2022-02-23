import 'package:flutter/material.dart';

class StartRide extends StatefulWidget {
  const StartRide({Key? key}) : super(key: key);

  @override
  _StartRideState createState() => _StartRideState();
}

class _StartRideState extends State<StartRide> {
  int num = 0;
  counterTravel() {
    Future.delayed(Duration(seconds: 1), () {
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        if (!mounted) return;
        setState(() {
          num += 1;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(children: [Text("On Trip"), Text('${num}')]),
    );
  }
}
