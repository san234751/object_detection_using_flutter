//@dart=2.9
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;
import 'camera.dart';
import 'bndbox.dart';

List<CameraDescription> cameras;
const String ssd = "SSD MobileNet";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange,
      appBar: AppBar(
        title: Text(
          "object detection using flutter",
          style: TextStyle(color: Colors.black),
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: Colors.white,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        height: 50,
        backgroundColor: Colors.deepOrange,
        animationDuration: Duration(milliseconds: 200),
        index: 0,
        items: <Widget>[
          Icon(Icons.home),
          Icon(Icons.camera_alt),
          Icon(Icons.logout)
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => Cameraw(cameras)));
          } else {
            print(index);
          }
        },
      ),
    );
  }
}

class Cameraw extends StatefulWidget {
  final List<CameraDescription> camerae;

  Cameraw(this.camerae);

  @override
  _CamerawState createState() => new _CamerawState();
}

class _CamerawState extends State<Cameraw> {
  List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _model = ssd;

  @override
  void initState() {
    super.initState();
  }

  loadModel() async {
    String res;
    res = await Tflite.loadModel(
        model: "asset/ssd_mobilenet.tflite", labels: "asset/ssd_mobilenet.txt");
    print(res);
    print("successful sankit");
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    loadModel();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text(
          "object detection camara",
          style: TextStyle(color: Colors.white),
          textDirection: TextDirection.rtl,
        ),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Camera(
            widget.camerae,
            _model,
            setRecognitions,
          ),
          BndBox(
            _recognitions == null ? [] : _recognitions,
            math.max(_imageHeight, _imageWidth),
            math.min(_imageHeight, _imageWidth),
            screen.height,
            screen.width,
          ),
        ],
      ),
    );
  }
}
