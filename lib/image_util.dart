import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class ImageUtil {
  static Future<Map<String, dynamic>?> pickImage() async {
    try {
      if (kIsWeb) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
        if (result != null && result.files.isNotEmpty) {
          final bytes = result.files.first.bytes;
          if (bytes != null) {
            return {'imageBytes': bytes}; // Return Uint8List for web
          }
        }
      } else {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          return {'imagePath': pickedFile.path}; // Return file path for mobile/desktop
        }
      }
    } catch (e) {
      print('[ImageUtil][pickImage] Error picking image: $e');
    }
    return null; // Return null if no image was picked or an error occurred
  }

  static Widget buildProfileImageWidget({
    String? imagePath,
    String? imageBytesBase64,
    double radius = 50,
    Widget? defaultWidget,
  }) {
    if (kIsWeb && imageBytesBase64 != null && imageBytesBase64.isNotEmpty) {
      try {
        final decodedBytes = base64Decode(imageBytesBase64);
        return CircleAvatar(
          radius: radius,
          backgroundImage: MemoryImage(decodedBytes),
          onBackgroundImageError: (exception, stackTrace) {
            print('[ImageUtil][buildProfileImageWidget] Error loading web image: $exception');
          },
        );
      } catch (e) {
        print('[ImageUtil][buildProfileImageWidget] Error decoding base64 for web image: $e');
        return CircleAvatar(radius: radius, child: defaultWidget ?? Icon(Icons.person, size: radius));
      }
    } else if (!kIsWeb && imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (file.existsSync()) {
        return CircleAvatar(
          radius: radius,
          backgroundImage: FileImage(file),
          onBackgroundImageError: (exception, stackTrace) {
            print('[ImageUtil][buildProfileImageWidget] Error loading file image: $exception');
          },
        );
      } else {
        print('[ImageUtil][buildProfileImageWidget] Image file does not exist: $imagePath');
      }
    }

    // Default placeholder if no image or error
    return CircleAvatar(radius: radius, child: defaultWidget ?? Icon(Icons.person, size: radius));
  }
}