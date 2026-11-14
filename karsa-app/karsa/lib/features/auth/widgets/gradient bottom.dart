import 'package:flutter/material.dart';

class BottomGradientScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Your main content
          Column(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    "Your Form Content",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const Divider(color: Colors.black26, height: 1),
            ],
          ),
          
          // 2. The bottom gradient overlay
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 200, // Height of the gradient area
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.0), // Transparent at the top
                    const Color(0xFFC8E6C9).withOpacity(0.8), // Green at the bottom
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}