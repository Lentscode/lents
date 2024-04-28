import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class FileUtilities {
  static Future<File?> getImageAndCrop(
      {double ratioX = 3, double ratioY = 4, List<CropAspectRatioPreset> presets = const []}) async {
    // Crea un'istanza di ImagePicker
    final ImagePicker picker = ImagePicker();

    // Scegli l'immagine dalla galleria o dalla fotocamera
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      // Passa l'immagine a ImageCropper per il ritaglio
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: CropAspectRatio(ratioX: ratioX, ratioY: ratioY),
          aspectRatioPresets: presets);

      if (croppedFile != null) {
        return File(croppedFile.path);
      }
    }
    return null; // Restituisce null se l'utente annulla la scelta
  }
}

class TimeUtilities {
  static String formatTimeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inDays > 365) {
      return '${(diff.inDays / 365).floor()} ann${diff.inDays > 730 ? 'i' : 'o'} fa';
    } else if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()} mes${diff.inDays > 60 ? 'i' : 'e'} fa';
    } else if (diff.inDays > 7) {
      return '${(diff.inDays / 7).floor()} settiman${diff.inDays > 14 ? 'e' : 'a'} fa';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} giorn${diff.inDays > 1 ? 'i' : 'o'} fa';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} or${diff.inHours > 1 ? 'e' : 'a'} fa';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minut${diff.inMinutes > 1 ? 'i' : 'o'} fa';
    } else {
      return 'Ora';
    }
  }
}

class LocationUtilities {
  static Future<Position?> getPosition() async {
    await Geolocator.checkPermission().then((value) async {
      if (value == LocationPermission.denied) {
        Geolocator.requestPermission();
      } else if (value == LocationPermission.deniedForever) {
        Geolocator.openAppSettings();
      } else {
        return await Geolocator.getCurrentPosition();
      }
    });
    return null;
  }
}