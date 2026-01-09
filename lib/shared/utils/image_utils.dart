// Helper for null-safe NetworkImage
import 'package:flutter/material.dart';

ImageProvider? safeNetworkImage(String? url) {
  if (url == null || url.isEmpty) {
    return null;
  }
  return NetworkImage(url);
}
