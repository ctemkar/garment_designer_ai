import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class ImageUpload extends StatefulWidget {
  final Function(Uint8List?, bool) onImageSelected;
  const ImageUpload({super.key, required this.onImageSelected});

  @override
  State<ImageUpload> createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  final _picker = ImagePicker();
  Uint8List? _garmentImageBytes;
  Uint8List? _modelImageBytes;

  Future<void> _pickImage(ImageSource source, bool isGarment) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();

      setState(() {
        if (isGarment) {
          _garmentImageBytes = bytes;
          widget.onImageSelected(_garmentImageBytes, true);
        } else {
          _modelImageBytes = bytes;
          widget.onImageSelected(_modelImageBytes, false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      if (_garmentImageBytes == null)
        ElevatedButton(
            onPressed: () => _pickImage(ImageSource.gallery, true),
            child: const Text("Select Garment Image")),
      if (_modelImageBytes == null)
        ElevatedButton(
            onPressed: () => _pickImage(ImageSource.gallery, false),
            child: const Text("Select Model Image")),
      if (_garmentImageBytes != null || _modelImageBytes != null)
        _garmentImageBytes != null
            ? Image.memory(
                _garmentImageBytes!,
                width: 100,
                height: 100,
              )
            : _modelImageBytes != null
                ? Image.memory(
                    _modelImageBytes!,
                    width: 100,
                    height: 100,
                  )
                : const CircularProgressIndicator()
    ]);
  }
}
