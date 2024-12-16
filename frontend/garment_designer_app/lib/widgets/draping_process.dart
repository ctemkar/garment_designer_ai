import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:garment_designer_app/services/background_removal.dart';

import 'image_upload.dart';
import 'image_display.dart';

class DrapingProcess extends StatefulWidget {
  const DrapingProcess({Key? key}) : super(key: key);

  @override
  State<DrapingProcess> createState() => _DrapingProcessState();
}

class _DrapingProcessState extends State<DrapingProcess> {
  Uint8List? _garmentImage;
  Uint8List? _modelImage;
  String? _processedImage;
  bool _isLoading = false;
  String? _errorMessage;
  final _backgroundRemovalService = BackgroundRemovalService();

  void _handleImageSelected(Uint8List? image, bool isGarment) {
    setState(() {
      if (isGarment) {
        _garmentImage = image;
        if (kDebugMode) {
          print("Garment image selected - bytes: ${_garmentImage?.length}");
        }
        _processGarment();
      } else {
        _modelImage = image;
        if (kDebugMode) {
          print("Model image selected - bytes: ${_modelImage?.length}");
        }
      }
    });
  }

  Future<void> _processGarment() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _processedImage = null;
      if (kDebugMode) {
        print("Processing Images - Loading: $_isLoading");
      }
    });
    if (_garmentImage == null) {
      setState(() {
        _errorMessage = "Please select a garment image";
        _isLoading = false;
        if (kDebugMode) {
          print("Error: Please select a garment image - Loading: $_isLoading");
        }
      });
      return;
    }
    try {
      final result =
          await _backgroundRemovalService.removeBackground(_garmentImage!);

      if (result['success']) {
        setState(() {
          _processedImage = result['image_data'];
          _isLoading = false;
          if (kDebugMode) {
            print("Processed Image received: ${_processedImage?.length}");
          }
        });
      } else {
        setState(() {
          _errorMessage = result['error'];
          _isLoading = false;
          if (kDebugMode) {
            print(
                "Error calling backend -  Error: ${result['error']}, Loading: $_isLoading");
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: $e";
        _isLoading = false;
        if (kDebugMode) {
          print("Error during processing - Error: $e - Loading: $_isLoading");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
      ImageUpload(onImageSelected: _handleImageSelected),
      if (_errorMessage != null) Text(_errorMessage!),
      if (_isLoading) const CircularProgressIndicator(),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        if (_garmentImage != null)
          Column(children: [
            const Text("Original Garment",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(
                width: 300, height: 300, child: Image.memory(_garmentImage!)),
          ]),
        if (_processedImage != null)
          Column(children: [
            const Text("Processed Garment",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(
              width: 300,
              height: 300,
              child: ImageDisplay(image: _processedImage!),
            )
          ]),
      ])
    ])));
  }
}
