class CloudinaryConfig {
  // ⚠️ REPLACE THESE WITH YOUR ACTUAL CLOUDINARY VALUES ⚠️
  // Get these from your Cloudinary dashboard
  
  // Your cloud name (found in Dashboard)
  static const String cloudName = 'ddo14sbqv'; // e.g., 'peacefulworkouts'
  
  // Your upload preset (create in Settings > Upload > Upload presets)
  static const String uploadPreset = 'peaceful_workouts_preset'; // e.g., 'peaceful_workouts_upload'
  
  // Base URL for Cloudinary uploads
  static const String uploadUrl = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';
  
  // URL for displaying images with transformations
  static String getImageUrl(String publicId, {int width = 600, int height = 400}) {
    // Remove Cloudinary URL prefix if it's already a full URL
    if (publicId.contains('res.cloudinary.com')) {
      return publicId;
    }
    return 'https://res.cloudinary.com/$cloudName/image/upload/c_fill,w_$width,h_$height,f_auto,q_auto/$publicId';
  }
  
  // For thumbnail images
  static String getThumbnailUrl(String publicId) {
    if (publicId.contains('res.cloudinary.com')) {
      return publicId.replaceFirst('/upload/', '/upload/c_fill,w_300,h_200,f_auto,q_auto/');
    }
    return 'https://res.cloudinary.com/$cloudName/image/upload/c_fill,w_300,h_200,f_auto,q_auto/$publicId';
  }
  
  // Extract public ID from Cloudinary URL
  static String? extractPublicId(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.length >= 3 && pathSegments[0] == cloudName) {
        // Return everything after 'upload/'
        final uploadIndex = pathSegments.indexOf('upload');
        if (uploadIndex != -1 && uploadIndex + 1 < pathSegments.length) {
          return pathSegments.sublist(uploadIndex + 1).join('/');
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}