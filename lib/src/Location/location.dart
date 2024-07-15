import 'package:burgher/src/Profile/Login.dart';
import 'package:burgher/src/Utils/Location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import 'location_helper.dart';

class Location extends StatefulWidget {
  const Location({super.key});

  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> {
  bool locPer = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocation();
  }

  getLocation() async {
    locPer = await getLocationHelper();
    setState(() {});
    // try {
    //   print("getting location");
    //   var pos = await determineLocation();
    //   setState(() {
    //     locPer = true;
    //   });
    // } catch (e) {
    //   print(e);
    //   print("error in fetching location");
    //   await getLocation();
    // }
  }

  @override
  Widget build(BuildContext context) {
    if (!locPer) {
      return Column(
        children: const [
          Text(
            "Need location access to continue",
          ),
        ],
      );
    } else {
      return const Login();
    }
  }
}
