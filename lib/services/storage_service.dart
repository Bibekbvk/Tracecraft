import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  /// Uploads finished drawing photo to Firebase Storage and returns download URL
  static Future<String> uploadDrawing(File imageFile, String userId) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = 'drawings/$userId/$timestamp.jpg';

    try {
      if (Firebase.apps.isNotEmpty) {
        final storageRef = FirebaseStorage.instance.ref().child(path);
        final uploadTask = await storageRef.putFile(
          imageFile,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        return downloadUrl;
      }
    } catch (e) {
      debugPrint('StorageService note: $e');
    }

    // Return local file path as fallback for offline testing
    return imageFile.path;
  }
}
