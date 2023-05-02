import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Uploader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Image Uploader'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  final dio = Dio(); ///added dio 
  String imageClass = ''; /// added string 

  Future<void> _getImageFromCamera() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final compressedImage = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        '${pickedFile.path}_compressed.jpg',
        quality: 50,
      );
      /// send form data 
      final formData = FormData.fromMap({
        'files': await MultipartFile.fromFile(compressedImage!.path,
            filename: "${pickedFile.path}_compressed.jpg"),
      });
      /// response form data
      final response = await dio.post(
          'http://ec2-18-136-200-224.ap-southeast-1.compute.amazonaws.com/classify/',
          data: formData);
      print(response.data); //print 
      setState(() {
        imageClass = response.data['Prediction'][0]['class']; //print 
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
        '${pickedFile.path}_compressed.jpg',
        quality: 50,
      );
      final formData = FormData.fromMap({
        'files': await MultipartFile.fromFile(compressedImage!.path,
            filename: "${pickedFile.path}_compressed.jpg"),
      });
      final response = await dio.post(
          'http://ec2-18-136-200-224.ap-southeast-1.compute.amazonaws.com/classify/',
          data: formData);
      print(response.data);
      setState(() {
        imageClass = response.data['Prediction'][0]['class'];
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
          child: SingleChildScrollView(
        child: Column(
          children: [
            _image == null
                ? const Text('No image selected.')
                : Column(
                    children: [
                      Image.file(_image!),
                      const SizedBox(height: 20),
                      Text(
                        'This image is $imageClass',
                        style: const TextStyle(
                          fontSize: 30,
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _getImageFromCamera,
            tooltip: 'Take a picture',
            child: const Icon(Icons.camera_alt),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _getImageFromGallery,
            tooltip: 'Pick from gallery',
            child: const Icon(Icons.photo_library),
          ),
        ],
      ),
    );
  }
}
