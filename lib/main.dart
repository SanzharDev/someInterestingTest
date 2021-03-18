import 'package:flutter/material.dart';
import 'package:flutter_sound_trial/View/bottom_control_panel_view.dart';

void main() {
  runApp(HomeWidget());
}

class HomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Hello'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(
              child: Text('Body'),
            ),
            BottomControlPanelView(),
          ],
        ),
      ),
    );
  }
}

/*
Scaffold(
        appBar: AppBar(
          title: Text('Hello'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(
              child: Text('Body'),
            ),
            BottomControlPanelView(),
          ],
        ),
      ),
 */
