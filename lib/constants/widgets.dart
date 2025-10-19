
import 'package:flutter/material.dart';

Widget boxPlaceHoler1(double height) {
  return Container(
    // padding: const EdgeInsets.all(20),
    margin: const EdgeInsets.all(20),
    height: height,
    decoration: BoxDecoration(
      color: Colors.purple[300],
      borderRadius: BorderRadius.circular(12),
    ),
  );
}

// in the shape of a circle
Widget circlePlaceHoler1(double height) {
  return Container(
    margin: const EdgeInsets.all(20),
    height: height,
    decoration: BoxDecoration(
      color: Colors.purple[300],
      shape: BoxShape.circle,
    ),
  );
}
