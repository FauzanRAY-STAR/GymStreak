import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileImageService {
  ProfileImageService._();

  static final ProfileImageService instance =
  ProfileImageService._();

  static const String _profileImageKey =
      'profile_image_path';

  final ImagePicker _picker = ImagePicker();

  Future<String?> getProfileImagePath() async {
    final prefs = await SharedPreferences.getInstance();

    final path = prefs.getString(_profileImageKey);

    if (path == null || path.isEmpty) {
      return null;
    }

    final file = File(path);

    if (!await file.exists()) {
      await prefs.remove(_profileImageKey);
      return null;
    }

    return path;
  }

  Future<String?> pickProfileImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (picked == null) {
      return null;
    }

    final directory =
    await getApplicationDocumentsDirectory();

    final extension = p.extension(picked.path);

    final fileName =
        'profile_photo${extension.isEmpty ? '.jpg' : extension}';

    final destinationPath = p.join(
      directory.path,
      fileName,
    );

    final oldPath = await getProfileImagePath();

    if (oldPath != null && oldPath != destinationPath) {
      final oldFile = File(oldPath);

      if (await oldFile.exists()) {
        await oldFile.delete();
      }
    }

    await File(picked.path).copy(destinationPath);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _profileImageKey,
      destinationPath,
    );

    return destinationPath;
  }

  Future<void> removeProfileImage() async {
    final prefs = await SharedPreferences.getInstance();

    final path = prefs.getString(_profileImageKey);

    if (path != null) {
      final file = File(path);

      if (await file.exists()) {
        await file.delete();
      }
    }

    await prefs.remove(_profileImageKey);
  }
}