import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../services/background_removal.dart';
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
  String _errorMessage = "";
  final _backgroundRemovalService = BackgroundRemovalService();

  void _handleImageSelected(Uint8List? image, bool isGarment) {
    setState(() {
      if (isGarment) {
        _garmentImage = image;
        print("Garment image selected - bytes: ${_garmentImage?.length}");
        _processGarment();
      } else {
        _modelImage = image;
        print("Model image selected - bytes: ${_modelImage?.length}");
      }
    });
  }

  Future<void> _processGarment() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
      _processedImage = null;
      print("Processing Images - Loading: $_isLoading");
    });

    if (_garmentImage == null) {
      setState(() {
        _errorMessage = "Please select a garment image";
        _isLoading = false;
        print("Error: Please select a garment image - Loading: $_isLoading");
      });
      return;
    }

    try {
      final result = await _backgroundRemovalService.removeBackground(_garmentImage!);

      if (result['success']) {
        setState(() {
          _processedImage = result['image_data'];
          _isLoading = false;
          print("Processed Image received: ${_processedImage?.length}");
        });
      } else {
        setState(() {
          _errorMessage = result['error'];
          _isLoading = false;
          print("Error calling backend -  Error: ${result['error']}, Loading: $_isLoading");
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: $e";
        _isLoading = false;
        print("Error during processing - Error: $e - Loading: $_isLoading");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ImageUpload(onImageSelected: _handleImageSelected),
                  if (_isLoading) const CircularProgressIndicator(),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (_garmentImage != null)
                          Column(
                              children: [
                                const Text("Original Garment",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                SizedBox(
                                    width: 300,
                                    height: 300,
                                    child: Image.memory(_garmentImage!)
                                ),
                              ]),
                        if (_processedImage != null)
                          Column(
                              children: [
                                const Text("Processed Garment",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                SizedBox(
                                  width: 300,
                                  height: 300,
                                  child: ImageDisplay(image: _processedImage!),
                                )
                              ]),
                      ]),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red),
                          ),
                          child: SelectableText(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        )
                    )
                ]
            )
        )
    );
  }
}