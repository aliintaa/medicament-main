import 'dart:async';
import 'package:flutter/material.dart';

class Proggres extends StatefulWidget {
  const Proggres({super.key});

  @override
  State<Proggres> createState() => _ProggresState();
}

bool costl = false;
var progress = 0.0;

class _ProggresState extends State<Proggres>  {
  @override
  void starTimer() {
    Timer.periodic(
      Duration(seconds: 1),
      (Timer timer) => setState(
        () {
          if (progress == 1) {
            timer.cancel();
            Navigator.pushNamed(context, "/home");
          } else {
            progress += 0.2;
          }
        },
      ),
    );
  }

  Widget build(BuildContext context) {
    if (costl == false) {
      starTimer();
      costl = true;
    }
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          value: progress,
        ),
      ),
    );
  }
}
