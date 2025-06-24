import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Pick and upload a profile image
  Future<String?> pickAndUploadProfileImage() async {
    try {
      // 1. Check if user is logged in
      final user = _auth.currentUser;
      if (user == null) {
        // It's safer to check for a logged-in user first.
        throw Exception("No user logged in to update profile image.");
      }

      // 2. Pick image
      final imagePicker = ImagePicker();
      final XFile? file = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Compress image to save space and upload time
      );

      if (file == null) return null; // User cancelled the picker

      // 3. Get reference to storage root
      final String uid = user.uid;
      final Reference ref =
          _storage.ref().child('profile_images').child('$uid.jpg');

      // 4. Upload the file using platform-specific logic
      if (kIsWeb) {
        // For web, we upload the bytes directly
        await ref.putData(await file.readAsBytes());
      } else {
        // For mobile, we upload the file from its path
        await ref.putFile(File(file.path));
      }

      // 5. Get download URL
      final String downloadURL = await ref.getDownloadURL();

      // 6. Update user's profile in Firebase Auth and Firestore document
      // It's good practice to update both for data consistency.
      await user.updatePhotoURL(downloadURL);
      await _firestore
          .collection('Users')
          .doc(uid)
          .update({'photoURL': downloadURL});

      return downloadURL;
    } on FirebaseException catch (e) {
      // Propagate Firebase-specific exceptions for the UI to handle.
      // This is better than returning null as it provides more error context.
      debugPrint(
          "Firebase error during image upload: ${e.code} - ${e.message}");
      throw e;
    } catch (e) {
      // Catch any other generic exceptions.
      debugPrint("An unexpected error occurred during image upload: $e");
      throw Exception("Failed to upload profile image.");
    }
  }
}
