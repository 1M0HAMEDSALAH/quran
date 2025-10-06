import 'package:flutter/material.dart';
import 'package:quran_app/app/modules/Sound/view/widgets/min_quran_player.dart';

class AppLayout extends StatelessWidget {
  final Widget child;

  const AppLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          child,

          // Mini player at the bottom
          const Positioned(
            left: 0,
            right: 0,
            bottom: 60,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: MiniQuranPlayer(),
            ),
          ),
        ],
      ),
    );
  }
}
