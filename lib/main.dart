import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart'; //saves image to gallery
import 'package:image_picker/image_picker.dart'; //picks image from gallery
import 'package:permission_handler/permission_handler.dart';
import 'package:screen_drawing/predictscreen.dart'; //drawing
import 'package:screenshot/screenshot.dart'; //screen shot
import 'package:http/http.dart' as http; //for restapi

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "HNR",
    home: CanvasWriting(),
  ));
}

class CanvasWriting extends StatefulWidget {
  const CanvasWriting({Key? key}) : super(key: key);

  @override
  _CanvasWritingState createState() => _CanvasWritingState();
}

class _CanvasWritingState extends State<CanvasWriting> {
  //offsets for drwaing in screen
  var offsets = <Offset>[];

  //controller
  final controller = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, //for avoiding resize issue due to keyboard
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Nepali character reconigation"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Write A devanagari character here:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          SizedBox(
            height: (MediaQuery.of(context).size.height) * .05,
          ),
          Center(
            child: Screenshot(
              //only screenshot this widget
              controller: controller,
              child: Container(
                height: (MediaQuery.of(context).size.width) * .9,
                width: (MediaQuery.of(context).size.width) * .9,
                decoration: BoxDecoration(
                    color: Colors.black, border: Border.all(width: 2)),
                child: GestureDetector(
                  //knows drags on screen
                  //onpanstart--> pointer toched the screen and started to move
                  onPanStart: (details) {
                    setState(() {
                      if (details.localPosition.dx > 0 &&
                          details.localPosition.dy > 0) {
                        offsets.add(details.localPosition);
                      }
                    });
                  },
                  //onpanupdate --> pointer drag in screen
                  onPanUpdate: (details) {
                    setState(() {
                      if (details.localPosition.dx > 0 &&
                          details.localPosition.dy > 0) {
                        offsets.add(details.localPosition);
                      }
                    });
                  },
                  //onpanend--> remove the pointer
                  onPanEnd: (details) {},

                  child: CustomPaint(
                    //draws the offsets
                    painter: HandPainter(offsets),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            //extra space hehe
            height: (MediaQuery.of(context).size.height) * .15,
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
              //Goes to predict Screen
              child: Icon(Icons.book),
              onPressed: () {
                print(File("main.dart"));
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => predictScreen()));
              }),
          SizedBox(
            width: (MediaQuery.of(context).size.width) * .33,
          ),
          FloatingActionButton(
            //saves the drawn image
            child: Icon(Icons.save),
            onPressed: () async {
              final image = await controller.capture();
              if (image == null) return;
              await saveImage(image);
              setState(() {
                offsets = <Offset>[];
              });
            },
          ),
          SizedBox(
            width: (MediaQuery.of(context).size.width) * .1,
          ),
          FloatingActionButton(
            //clears the image field
            child: Icon(Icons.restore_outlined),
            onPressed: () {
              setState(() {
                offsets = <Offset>[];
              });
            },
          ),
        ],
      ),
    );
  }

//fucntion to saveimage to gallary
  Future<String> saveImage(Uint8List image) async {
    await [Permission.storage].request();
    const name = 'predict';
    final result = await ImageGallerySaver.saveImage(image, name: name);
    return result['filepath'];
  }
}

//class to draw the offset points
class HandPainter extends CustomPainter {
  final offsets;

  HandPainter(this.offsets) : super();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..isAntiAlias = false
      ..strokeWidth = 20
      ..strokeJoin = StrokeJoin.bevel;
    for (var offset in offsets) {
      canvas.drawPoints(PointMode.points, [offset], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
