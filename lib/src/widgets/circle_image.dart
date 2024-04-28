import 'dart:io';

import 'package:flutter/material.dart';

/// A widget that displays an image in a circular shape.
///
/// The image can be provided as a URL or as a [File].
/// The widget can also have a border color, which by default is [size] * 0.05,
/// but can also be provided.
class CircleImage extends StatelessWidget {
  const CircleImage({
    super.key,
    required this.size,
    this.imageUrl,
    this.borderColor,
    this.imageFile,
    this.borderWidth,
  });

  /// The size of the circular image.
  final double size;

  /// The URL of the image.
  final String? imageUrl;

  /// The color of the border of the circular image.
  final Color? borderColor;

  /// The file of the image.
  final File? imageFile;

  /// The width of the border of the circular image.
  final double? borderWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: imageUrl != null
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              )
            : imageFile != null
                ? DecorationImage(
                    image: FileImage(imageFile!),
                    fit: BoxFit.cover,
                  )
                : null,
        border: Border.all(
          color: borderColor ?? Theme.of(context).colorScheme.primary,
          width: borderWidth ?? (size * 0.05).roundToDouble(),
        ),
      ),
    );
  }
}
