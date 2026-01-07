import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../config/cloudinary_config.dart';

class CloudinaryService {
  // Simple upload without complex progress tracking
  static Future<String?> uploadImage(XFile imageFile) async {
    try {
      print('🚀 Starting Cloudinary upload...');
      
      // Check configuration
      print('✅ Cloudinary Config:');
      print('   - Cloud Name: ${CloudinaryConfig.cloudName}');
      print('   - Upload Preset: ${CloudinaryConfig.uploadPreset}');
      
      // Read image bytes
      final bytes = await imageFile.readAsBytes();
      print('📊 Image size: ${bytes.length} bytes');
      
      // Validate size (max 10MB)
      if (bytes.length > 10 * 1024 * 1024) {
        throw Exception('Image is too large. Maximum size is 10MB.');
      }
      
      // Create the multipart request
      final uri = Uri.parse(CloudinaryConfig.uploadUrl);
      final request = http.MultipartRequest('POST', uri);
      
      // Add the file
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: 'workout_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      request.files.add(multipartFile);
      
      // Add upload preset (MUST be unsigned)
      request.fields['upload_preset'] = CloudinaryConfig.uploadPreset;
      
      // Add optional fields for organization
      request.fields['folder'] = 'peaceful_workouts';
      request.fields['tags'] = 'workout,fitness,peaceful';
      
      print('📤 Sending to Cloudinary...');
      
      // Send the request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonData = json.decode(responseBody);
      
      print('📥 Cloudinary Response:');
      print('   Status: ${response.statusCode}');
      print('   Data: $jsonData');
      
      if (response.statusCode == 200) {
        final secureUrl = jsonData['secure_url'];
        final publicId = jsonData['public_id'];
        print('✅ UPLOAD SUCCESS!');
        print('   🔗 URL: $secureUrl');
        print('   🆔 Public ID: $publicId');
        return secureUrl;
      } else {
        final error = jsonData['error']?['message'] ?? 'Unknown error';
        print('❌ UPLOAD FAILED: $error');
        throw Exception('Cloudinary error: $error');
      }
    } catch (e) {
      print('💥 UPLOAD ERROR: $e');
      rethrow;
    }
  }
  
  // Upload with simulated progress (for UI)
  static Future<String?> uploadImageWithProgress(
    XFile imageFile,
    void Function(double) onProgress,
  ) async {
    try {
      // Simulate starting progress
      onProgress(0.1);
      
      // Read image
      final bytes = await imageFile.readAsBytes();
      onProgress(0.3);
      
      // Upload to Cloudinary
      final url = await uploadImage(imageFile);
      
      // Simulate completion
      onProgress(1.0);
      
      return url;
    } catch (e) {
      rethrow;
    }
  }
}