import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            Directionality(
              textDirection: TextDirection.ltr,
              child: Overlay(
                initialEntries: [
                  OverlayEntry(
                    builder: (context) => Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Material(
                        child: PopupMenuButton<int>(
                          itemBuilder: (context) => [
                            PopupMenuItem(value: 1, child: Text('Test')),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      home: Scaffold(
        appBar: AppBar(title: Text('Test')),
      ),
    ),
  );
}
