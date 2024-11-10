import 'package:flutter/material.dart';
import 'screens/color_palette.dart';

/// The entry point of the application.
///
/// This function initializes the app by calling `runApp` with
/// an instance of `MyApp`, which builds the main widget tree.
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  /// Builds the main application widget.
  ///
  /// This method returns a [MaterialApp] widget configured with the
  /// application's title and home screen. The debug banner is disabled
  /// for a cleaner appearance.
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Color Palette Generator',
      home: ColorPalette(),
    );
  }
}
