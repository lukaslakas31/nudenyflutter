import 'dart:io';
import 'package:dio/dio.dart';

class Nudeny {
  static Future<Map<String, dynamic>> moderateImage(String imagePath) async {
    final imageBytes = File(imagePath).readAsBytesSync();
    final imageFile =
        MultipartFile.fromBytes(imageBytes, filename: 'image.jpg');

    final dio = Dio();
    final formData = FormData.fromMap({'image': imageFile});

    final response = await dio.post(
      'http://ec2-18-136-200-224.ap-southeast-1.compute.amazonaws.com/censor/',
      data: formData,
    );

    final responseData = response.data;
    return responseData;
  }
}
