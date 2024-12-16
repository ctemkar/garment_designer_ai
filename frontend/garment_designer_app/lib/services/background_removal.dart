import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class BackgroundRemovalService {
  static const String _apiUrl = 'http://127.0.0.1:5000/remove_background';

  Future<Map<String, dynamic>> removeBackground(Uint8List garmentImage) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_apiUrl));

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          garmentImage,
          filename: "garment.png",
        ),
      );

      request.headers['Content-Type'] = 'multipart/form-data';
      if (kDebugMode) {
        print("Sending API Request - Bytes: ${garmentImage.length}");
      }

      final response = await http.Response.fromStream(await request.send());
      if (kDebugMode) {
        print(
            "API Response - Status: ${response.statusCode}, Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (kDebugMode) {
          print(
              "Received image data length: ${decodedData['image_data'].length}");
        }
        return {
          'success': true,
          'image_data': decodedData['image_data'],
        };
      } else {
        return {
          'success': false,
          'error':
              "Error calling the backend. Please check the backend is running. Status Code: ${response.statusCode}, ${response.reasonPhrase}",
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': "Error during processing $e",
      };
    }
  }
}
