import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:dio/dio.dart';
import 'package:nudeny/nudeny.dart'; //2

class CensorPage extends StatefulWidget {
  const CensorPage({super.key});

  @override
  State<CensorPage> createState() => _CensorPageState();
}

class _CensorPageState extends State<CensorPage> {
  File? _image;
  final nudeny = Nudeny(); //1 
  String imageUrl = '';

  Future<void> _getImageFromCamera() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final compressedImage = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        '${pickedFile.path}_compressed.jpg',
        quality: 50,
      );
      // nudeny api 
      try {
        final response = await nudeny.censor([pickedFile.path]); // 2
        setState(() {
          imageUrl = response['Prediction'][0]['url']; //wala pa to
          _image = compressedImage;
        });
      } catch (e) {
        print(e);
      }
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
      final response = await nudeny.censor([pickedFile.path]); //nudeny 
      setState(() {
        imageUrl = response['Prediction'][0]['url'] ?? ''; // wala pa to
        _image = compressedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Censor Page'),
        backgroundColor: const Color.fromARGB(255, 60, 244, 54),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _image == null
                  ? const Text('No image selected.')
                  : Stack(
                      children: [
                        if (imageUrl == '')
                          Image.file(_image!)
                        else
                          Image.network(imageUrl, loadingBuilder:
                              (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return const CircularProgressIndicator();
                            }
                          }),
                      ],
                    ),
            ],
          ),
        ),
      ),
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
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Classify',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Censor',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Get.toNamed('/');
              break;
            case 1:
              Get.toNamed('/censorPage');
              break;
          }
        },
      ),
    );
  }
}
