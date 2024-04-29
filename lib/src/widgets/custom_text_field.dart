import 'package:flutter/material.dart';

/// A fully customizable [TextField], with simplified layout and full documentation.
class CustomTextField extends StatelessWidget {
  const CustomTextField(
      {super.key,
      this.labelText,
      this.border,
      this.errorBorder,
      this.initialValue,
      this.hintText,
      this.height = 50.0,
      this.fillColor,
      this.enabledBorder,
      this.focusColor,
      this.focusedBorder,
      this.suffixIcon,
      this.textStyle,
      this.maxLines = 1,
      this.controller,
      this.onEditingComplete,
      this.suffix,
      this.validator,
      this.errorText,
      this.keyboardType,
      this.onChanged,
      this.textAlign});

  /// The text that will be displayed above the input field.
  final String? labelText;

  /// The border that will be displayed when the input field is not focused.
  final InputBorder? border;

  /// The border that will be displayed when the input field has an error.
  final InputBorder? errorBorder;

  /// The initial value of the input field.
  final String? initialValue;

  /// The text that will be displayed when the input field is empty.
  final String? hintText;

  /// The height of the input field.
  ///
  /// Set this to `null` to make the input field take as much space as possible.
  final double? height;

  /// The color that will fill the input field.
  final Color? fillColor;

  /// The border that will be displayed when the input field is enabled.
  final InputBorder? enabledBorder;

  /// The color that will be displayed when the input field is focused.
  final Color? focusColor;

  /// The border that will be displayed when the input field is focused.
  final InputBorder? focusedBorder;

  /// The icon that will be displayed at the end of the input field.
  final Widget? suffixIcon;

  /// The style of the text that will be displayed in the input field.
  final TextStyle? textStyle;

  /// The maximum number of lines that the input field can have.
  final int? maxLines;

  /// The controller that will be used to control the input field.
  final TextEditingController? controller;

  /// The function that will be called when the user presses the "Done" button on the keyboard.
  final void Function()? onEditingComplete;

  /// The widget that will be displayed at the end of the input field.
  final Widget? suffix;

  /// The function that will be called to validate the input field.
  ///
  /// It should return `null` if the input is valid, and an error message otherwise.
  final String? Function(String?)? validator;

  /// The text that will be displayed when the input field has an error.
  final String? errorText;

  /// The type of keyboard that will be displayed when the input field is focused.
  final TextInputType? keyboardType;

  /// The function that will be called when the input field changes.
  final void Function(String)? onChanged;

  /// The alignment of the text that will be displayed in the input field.
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextFormField(
        textAlign: textAlign ?? TextAlign.start,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: textStyle,
        validator: validator,
        onTapOutside: (event) => FocusScope.of(context).unfocus(),
        initialValue: initialValue,
        controller: controller,
        autocorrect: false,
        cursorErrorColor: Colors.red,
        cursorColor: Theme.of(context).colorScheme.primary,
        decoration: InputDecoration(
          errorText: errorText,
          suffix: suffix,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          labelText: labelText,
          border: border,
          errorBorder: errorBorder,
          hintText: hintText,
          fillColor: fillColor,
          enabledBorder: enabledBorder ?? border,
          focusColor: focusColor,
          focusedBorder: focusedBorder ?? border,
          hintStyle: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
          suffixIcon: suffixIcon,
        ),
        onEditingComplete: onEditingComplete,
        onChanged: onChanged,
      ),
    );
  }
}
