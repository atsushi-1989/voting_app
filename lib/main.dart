import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Text? _text;
  Image? _image;

  Future<void> _ocr() async {
    PickedFile? pickerFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    final File imageFile = File(pickerFile!.path);
    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(imageFile);
    TextRecognizer textRecognizer =
        FirebaseVision.instance.cloudTextRecognizer();
    final VisionText visionText =
        await textRecognizer.processImage(visionImage);

    String text = visionText.text!;

    for (TextBlock block in visionText.blocks) {
      print(block.text);
    }

    setState(() {
      _text = Text(text);
      _image = Image.file(File(pickerFile.path));
    });

    //リソースの開放
    textRecognizer.close();
  }

  Future<void> _labeling() async {
    PickedFile? pickerFile =
        await ImagePicker().getImage(source: ImageSource.camera);

    final File imageFile = File(pickerFile!.path);
    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(imageFile);

    ImageLabeler labeler = FirebaseVision.instance.imageLabeler();
    List<ImageLabel> labels = await labeler.processImage(visionImage);
    String text = "";
    for (ImageLabel label in labels) {
      print(label.text);
      text += label.text! + " ";
      print(label.confidence);
    }

    // 画面に反映
    setState(() {
      _text = Text(text);
      _image = Image.file(File(pickerFile.path));
    });

    // リソースの開放
    labeler.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_text != null) _text!,
              if (_image != null) SafeArea(child: _image!),
            ],
          ),
        ),
        floatingActionButton:
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          FloatingActionButton(onPressed: _ocr, child: Icon(Icons.photo_album)),
          FloatingActionButton(
              onPressed: _labeling, child: Icon(Icons.photo_camera))
        ]));
  }
}
