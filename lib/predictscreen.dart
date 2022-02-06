import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class predictScreen extends StatefulWidget {
  const predictScreen({Key? key}) : super(key: key);

  @override
  _predictScreenState createState() => _predictScreenState();
}

class _predictScreenState extends State<predictScreen> {
  //File selectedImage = File("main.dart");
  File? selectedImage = null;
  var resJson;
  String prediction = "";

  // var arr = ['क', 'ख', 'ग', 'घ', 'ङ'];

  onUploadImage() async {
    var request = http.MultipartRequest(
        'POST',
        //for andriod studio
        //Uri.parse("http://10.0.2.2:5000/"),
        //for mobile
        Uri.parse("http://192.168.1.75:5000/"));

    Map<String, String> headers = {"Content-type": "multipart/form-data"};
    request.files.add(
      http.MultipartFile(
        'image',
        selectedImage!.readAsBytes().asStream(),
        selectedImage!.lengthSync(),
        filename: selectedImage!.path.split('/').last,
      ),
    );
    request.headers.addAll(headers);
    print("request: " + request.toString());
    var res = await request.send();
    http.Response response = await http.Response.fromStream(res);
    setState(() {
      resJson = jsonDecode(response.body);
      prediction = resJson['message'];
      // prediction = arr[2];
      // print(prediction);
    });
  }

  Future getImage() async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);

    setState(() {
      selectedImage = File(image!.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Nepali character reconigation"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            selectedImage == null
                ? Text(
                    'Please Pick a image to Upload',
                  )
                : Image.file(selectedImage!),
            SizedBox(
              height: MediaQuery.of(context).size.height * .05,
            ),
            RaisedButton(
              color: Colors.green[300],
              onPressed: onUploadImage,
              child: Text(
                "Upload",
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              prediction,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Increment',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}
