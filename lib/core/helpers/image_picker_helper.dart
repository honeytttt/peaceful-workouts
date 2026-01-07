import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class ImagePickerHelper {
  static Future<XFile?> pickImage({
    required BuildContext context,
    bool allowCamera = true,
  }) async {
    final picker = ImagePicker();
    
    // On web, we can't use camera directly
    final isWeb = kIsWeb;
    
    // For mobile, check if camera is available
    bool cameraAvailable = false;
    if (allowCamera && !isWeb) {
      try {
        // Test camera availability
        final hasCamera = await picker.pickImage(source: ImageSource.camera);
        cameraAvailable = hasCamera != null;
      } catch (e) {
        cameraAvailable = false;
        print('Camera not available: $e');
      }
    }

    final source = await showModalBottomSheet<ImageSource?>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose Photo',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (cameraAvailable && !isWeb)
                      ListTile(
                        leading: const Icon(Icons.camera_alt, color: Colors.blue),
                        title: const Text('Take Photo'),
                        subtitle: const Text('Use camera to take a new photo'),
                        onTap: () => Navigator.pop(context, ImageSource.camera),
                      ),
                    ListTile(
                      leading: const Icon(Icons.photo_library, color: Colors.green),
                      title: const Text('Choose from Gallery'),
                      subtitle: isWeb 
                          ? const Text('Select image from your computer')
                          : const Text('Select from photo gallery'),
                      onTap: () => Navigator.pop(context, ImageSource.gallery),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, null),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return null;

    try {
      return await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return null;
    }
  }
  
  // Simple picker for web (no camera option)
  static Future<XFile?> pickImageForWeb(BuildContext context) async {
    final picker = ImagePicker();
    try {
      return await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );
    } catch (e) {
      debugPrint('Error picking image on web: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }
}