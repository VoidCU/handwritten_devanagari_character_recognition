import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screen_drawing/predictscreen.dart';
import 'package:screenshot/screenshot.dart';
import 'package:http/http.dart' as http;

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
  var offsets = <Offset>[];
  int display = 0;
  Offset nulloffset = Offset(-1, -1);
  final controller = ScreenshotController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              controller: controller,
              child: Container(
                height: (MediaQuery.of(context).size.width) * .9,
                width: (MediaQuery.of(context).size.width) * .9,
                decoration: BoxDecoration(
                    color: Colors.black, border: Border.all(width: 2)),
                child: GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      if (details.localPosition.dx > 0 &&
                          details.localPosition.dy > 0) {
                        offsets.add(details.localPosition);
                      }
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      if (details.localPosition.dx > 0 &&
                          details.localPosition.dy > 0) {
                        offsets.add(details.localPosition);
                      }
                    });
                  },
                  onPanEnd: (details) {},
                  child: CustomPaint(
                    painter: HandPainter(offsets),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: (MediaQuery.of(context).size.height) * .15,
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                  child: Icon(Icons.book),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => predictScreen()));
                  }),
              SizedBox(
                width: (MediaQuery.of(context).size.width) * .4,
              ),
              Column(
                children: [
                  FloatingActionButton(
                    child: Icon(Icons.save),
                    onPressed: () async {
                      final image = await controller.capture();
                      if (image == null) return;
                      await saveImage(image);
                    },
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  FloatingActionButton(
                    child: Icon(Icons.restore_outlined),
                    onPressed: () {
                      setState(() {
                        offsets = <Offset>[];
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String> saveImage(Uint8List image) async {
    //postData(image);
    await [Permission.storage].request();
    const name = 'predict';
    final result = await ImageGallerySaver.saveImage(image, name: name);
    return result['filepath'];
  }
}

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
