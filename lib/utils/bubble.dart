import 'package:flutter/material.dart';

class Bubble extends StatelessWidget {
  const Bubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(3.5),
      height: 8.0,
      width: 8.0,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        
      ),
    );
  }
}
