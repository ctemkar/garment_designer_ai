import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:garment_designer_app/services/background_removal.dart';

class GarmentImageProcessor extends StatefulWidget {
  final Uint8List originalImage;
  final Function(Uint8List) onProcessed;

  const GarmentImageProcessor({
    Key? key,
    required this.originalImage,
    required this.onProcessed,
  }) : super(key: key);

  @override
  State<GarmentImageProcessor> createState() => _GarmentImageProcessorState();
}

class _GarmentImageProcessorState extends State<GarmentImageProcessor> {
  Uint8List? processedImage;
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await BackgroundRemovalService()
          .removeBackground(widget.originalImage);

      if (result['success']) {
        // Convert base64 to Uint8List
        final String base64String = result['image_data'];
        final Uint8List imageBytes = base64Decode(base64String);

        setState(() {
          processedImage = imageBytes;
          isLoading = false;
        });

        widget.onProcessed(imageBytes);
      } else {
        setState(() {
          error = result['error'];
          isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error processing image: $e');
      }
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing image...'),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error: $error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _processImage,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (processedImage != null) {
      return Image.memory(
        processedImage!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          if (kDebugMode) {
            print('Error displaying image: $error');
          }
          return const Center(
            child: Text('Error displaying image'),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }
}
