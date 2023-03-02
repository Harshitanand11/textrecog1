import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

late List<CameraDescription> cameras;
 late CameraController _controller; // Define _controller as a global variable


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  await Permission.camera.request();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('TEXT RECOGNITION APP'),
        ),
        body: CameraPreview(_controller),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _captureImage(); // Call _captureImage function
          },
          child: Icon(Icons.camera_alt),
        ),
      ),
    );
  }
}

void _captureImage() async {
  final Directory extDir = await getApplicationDocumentsDirectory();
  final String dirPath = '${extDir.path}/Pictures/flutter_test';
  await Directory(dirPath).create(recursive: true);
  final String filePath = '$dirPath/${DateTime.now().millisecondsSinceEpoch}.jpg';
  await _controller.takePicture();

  final url = Uri.parse('http://your-flask-server-url.com/upload');
  final request = http.MultipartRequest('POST', url);
  final file = await http.MultipartFile.fromPath('image', filePath);
  request.files.add(file);

  final response = await request.send();
  if (response.statusCode == 200) {
    print('Image uploaded!');
  } else {
    print('Image upload failed.');
  }
}
