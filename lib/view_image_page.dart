import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ViewImagePage extends StatelessWidget {
  File? selectedImage;
  final selectedImageUrl;
  ViewImagePage({super.key, this.selectedImage, this.selectedImageUrl});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
      ),
      body: Container(
        child: Center(
          child: Hero(
            tag: selectedImage != null ? "pickedImage" : selectedImageUrl,
            child: SizedBox(
              child: selectedImage != null
                  ? PhotoView(
                      imageProvider: FileImage(selectedImage!),
                      backgroundDecoration: const BoxDecoration(
                        color: Colors.black, // Background color
                      ),
                    )
                  : PhotoView(
                      imageProvider: NetworkImage(selectedImageUrl),
                      backgroundDecoration: const BoxDecoration(
                        color: Colors.white, // Background color
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
