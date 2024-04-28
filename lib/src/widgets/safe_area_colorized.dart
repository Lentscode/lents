import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// A widget that enhances the [SafeArea] widget by providing a color to the top and bottom of the screen.
///
/// The default [SafeArea] widget provides a padding to the top and bottom of the screen,
/// but it does not provide a way to colorize the top and bottom of the screen.
/// This widget provides a way to colorize the top and bottom of the screen.
class SafeAreaColorized extends StatelessWidget {
  const SafeAreaColorized({
    super.key,
    required this.firstColor,
    this.secondColor,
    required this.child,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
  });

  /// The color of the top of the screen.
  /// If [secondColor] is not provided, this color is used for the bottom of the screen as well.
  final Color firstColor;

  /// The color of the bottom of the screen.
  final Color? secondColor;

  /// The child of the [SafeArea] widget.
  final Widget child;

  /// Whether to provide padding to the top of the screen.
  final bool top;

  /// Whether to provide padding to the bottom of the screen.
  final bool bottom;

  /// Whether to provide padding to the left of the screen.
  final bool left;

  /// Whether to provide padding to the right of the screen.
  final bool right;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Container(
                color: firstColor,
              ),
            ),
            Expanded(
              child: Container(
                color: secondColor ?? firstColor,
              ),
            ),
          ],
        ),
        SafeArea(
          top: top,
          bottom: bottom,
          left: left,
          right: right,
          child: child,
        ),
      ],
    );
  }
}
