import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ImagePreviewWidget extends StatelessWidget {
  final XFile? imageFile;
  final VoidCallback onRemove;
  final double width;
  final double height;

  const ImagePreviewWidget({
    super.key,
    required this.imageFile,
    required this.onRemove,
    this.width = double.infinity,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (imageFile == null) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[100],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to add photo',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // Image preview
        Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: _buildImage(context),
        ),
        
        // Remove button
        Positioned(
          top: 8,
          right: 8,
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.black54,
            child: IconButton(
              icon: const Icon(Icons.close, size: 16),
              color: Colors.white,
              onPressed: onRemove,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: imageFile!.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(
            child: Icon(Icons.error, color: Colors.red),
          );
        }
        
        final bytes = snapshot.data!;
        
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.error, color: Colors.red),
            );
          },
        );
      },
    );
  }
}