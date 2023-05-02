import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Uploader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Image Uploader'),
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
  File? _image;

  Future<void> _getImageFromCamera() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final compressedImage = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        pickedFile.path + '_compressed.jpg',
        quality: 50,
      );
      setState(() {
        _image = compressedImage;
      });
    }
  }

  Future<void> _getImageFromGallery() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final compressedImage = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        pickedFile.path + '_compressed.jpg',
        quality: 50,
      );
      setState(() {
        _image = compressedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child:
            _image == null ? Text('No image selected.') : Image.file(_image!),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _getImageFromCamera,
            tooltip: 'Take a picture',
            child: Icon(Icons.camera_alt),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _getImageFromGallery,
            tooltip: 'Pick from gallery',
            child: Icon(Icons.photo_library),
          ),
        ],
      ),
    );
  }
}
