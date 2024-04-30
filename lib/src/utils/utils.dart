import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

/// A set of methods to work with files, especially images.
class FileUtilities {
  /// Opens the camera and allows the user to take or choose a picture and then crop it.
  static Future<File?> getImageAndCrop(
      {double ratioX = 3, double ratioY = 4, List<CropAspectRatioPreset> presets = const []}) async {
    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: CropAspectRatio(ratioX: ratioX, ratioY: ratioY),
          aspectRatioPresets: presets);

      if (croppedFile != null) {
        return File(croppedFile.path);
      }
    }
    return null;
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

/// A set of methods to work with the user's location.
class LocationUtilities {
  /// Gets the user's current position.
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

/// A set of methods to show SnackBars.
class SnackBarUtilities {
  /// Shows a SnackBar.
  ///
  /// * [context] is the context of the widget.
  /// * [content] is the widget to show.
  /// * [duration] is the duration of the SnackBar.
  /// * [behavior] is the behavior of the SnackBar, wether is floating or fixed (floating by default).
  /// * [animation] defines an animation that the Snackbar follows appearing.
  /// * [dismissDirection] is the direction in which the SnackBar can be dismissed.
  /// * [onVisible] is a callback that is called when the SnackBar is visible.
  static void show(
    BuildContext context,
    Widget content, {
    Duration duration = const Duration(seconds: 2),
    SnackBarBehavior behavior = SnackBarBehavior.fixed,
    double elevation = 0,
    Animation<double>? animation,
    DismissDirection? dismissDirection,
    void Function()? onVisible,
  }) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: content,
          duration: duration,
          behavior: behavior,
          animation: animation,
          dismissDirection: dismissDirection,
          onVisible: onVisible,
          elevation: elevation,
        ),
      );
}
