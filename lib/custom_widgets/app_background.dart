import 'dart:ui';

import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          'assets/images/solid.jpg',
          height: double.infinity,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10.0,
            sigmaY:10.0,
          ),
          child: Container(
            color: Colors.black.withOpacity(0.3),
          ),
        )
      ],
    );
  }
}
