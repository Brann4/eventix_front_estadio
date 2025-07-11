import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

class SvgPathClipper extends CustomClipper<Path> {
  final String svgPathData;

  SvgPathClipper(this.svgPathData);

  @override
  Path getClip(Size size) {
    final path = Path();
    final regExp = RegExp(r'[-]?\d*\.?\d+');
    final matches = regExp.allMatches(svgPathData);
    final coords = matches.map((m) => double.parse(m.group(0)!)).toList();

    if (coords.isNotEmpty) {
      path.moveTo(coords[0], coords[1]);
      for (int i = 2; i < coords.length; i += 2) {
        path.lineTo(coords[i], coords[i+1]);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}