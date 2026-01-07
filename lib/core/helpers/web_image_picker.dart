import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class WebImagePicker {
  static Future<XFile?> pickImageWithCameraOption(BuildContext context) async {
    if (kIsWeb) {
      // On web, we can show camera option using browser's media devices
      final source = await showModalBottomSheet<String?>(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.blue),
                  title: const Text('Use Camera'),
                  onTap: () => Navigator.pop(context, 'camera'),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.green),
                  title: const Text('Upload from Computer'),
                  onTap: () => Navigator.pop(context, 'gallery'),
                ),
                ListTile(
                  leading: const Icon(Icons.cancel, color: Colors.red),
                  title: const Text('Cancel'),
                  onTap: () => Navigator.pop(context, null),
                ),
              ],
            ),
          );
        },
      );

      if (source == 'camera') {
        return await _pickImageFromCameraWeb();
      } else if (source == 'gallery') {
        return await _pickImageFromGalleryWeb();
      }
      return null;
    } else {
      // For mobile, use the standard image picker
      final picker = ImagePicker();
      final source = await showModalBottomSheet<ImageSource?>(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take Photo'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          );
        },
      );

      if (source != null) {
        return await picker.pickImage(source: source);
      }
      return null;
    }
  }

  static Future<XFile?> _pickImageFromCameraWeb() async {
    try {
      // Get camera stream
      final mediaDevices = html.window.navigator.mediaDevices;
      final stream = await mediaDevices.getUserMedia({'video': true});
      
      // This is simplified - in production you'd need to:
      // 1. Show video preview
      // 2. Capture frame
      // 3. Convert to XFile
      
      // For now, fall back to file picker
      return await _pickImageFromGalleryWeb();
    } catch (e) {
      print('Camera error on web: $e');
      return await _pickImageFromGalleryWeb();
    }
  }

  static Future<XFile?> _pickImageFromGalleryWeb() async {
    final picker = ImagePicker();
    return await picker.pickImage(source: ImageSource.gallery);
  }
}