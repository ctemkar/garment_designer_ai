import 'package:flutter/material.dart';

class ImageDisplay extends StatelessWidget {
  final String image;
  const ImageDisplay({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return  Image.network('data:image/png;base64,$image', width: 200, height: 200,);
  }
}