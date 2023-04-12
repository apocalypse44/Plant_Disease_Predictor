import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final imagepicker = ImagePicker();
  late File image;
  var tf = 1;
  List? predictions = [];

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/disease_new.tflite', labels: 'assets/labels.txt');
  }

  predictModel(image) async {
    var pred = await Tflite.runModelOnImage(
        path: image.path,
        imageMean: 224,
        imageStd: 224,
        numResults: 15,
        threshold: 0.5,
        asynch: true);
    // print(pred);
    setState(() {
      predictions = pred;
      tf = 0;
      // print(predictions);
    });
  }

  loadImageGallery() async {
    var img = await imagepicker.pickImage(source: ImageSource.gallery);

    if (img == null) {
      return null;
    } else {
      image = File(img.path);
    }
    predictModel(image);
  }

  loadCamera() async {
    var img = await imagepicker.pickImage(source: ImageSource.camera);

    if (img == null) {
      return null;
    } else {
      image = File(img.path);
    }
    predictModel(image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('MPL'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const SizedBox(
              height: 20,
            ),
            MaterialButton(
              onPressed: () {
                loadCamera();
              },
              color: Colors.blue,
              child: Text('Camera'),
              shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            const SizedBox(
              height: 20,
            ),
            MaterialButton(
              onPressed: () {
                loadImageGallery();
              },
              color: Colors.blue,
              child: Text('Gallery'),
              shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            tf == 0
                ? Container(
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
                          height: 200,
                          width: 200,
                          child: Image.file(image),
                        ),
                        Text(
                          "IT IS " +
                              predictions![0]['label'].toString().substring(1),
                        ),
                        Text('Confidence : ' +
                            predictions![0]['confidence'].toString())
                      ],
                    ),
                  )
                : Container()
          ]),
        ),
      ),
    );
  }
}
