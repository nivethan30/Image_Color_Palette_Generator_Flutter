import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:badges/badges.dart' as badges;
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';

class ColorPalette extends StatefulWidget {
  const ColorPalette({super.key});

  @override
  State<ColorPalette> createState() => _ColorPaletteState();
}

class _ColorPaletteState extends State<ColorPalette> {
  File? _imageFile;
  List<Color> _colors = [];

  /// Picks an image from the gallery and updates the state with the selected
  /// image file. If an image is successfully picked, it reads the image bytes
  /// and generates a color palette from the image.
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      setState(() {
        _imageFile = imageFile;
      });
      final imageBytes = await imageFile.readAsBytes();
      _generatePalette(imageBytes);
    }
  }

  /// Generates a color palette from the given [imageBytes].
  ///
  /// [imageBytes] should be the raw bytes of the image.
  ///
  /// The generated palette is stored in [_colors].
  ///
  /// The image is resized to 200x200 before generating the palette.
  ///
  /// The generated palette will contain at most 200 colors.
  Future<void> _generatePalette(Uint8List imageBytes) async {
    final image = imageBytes;
    final paletteGenerator = await PaletteGenerator.fromImageProvider(
      MemoryImage(image),
      size: const Size(200, 200),
      maximumColorCount: 200,
    );

    setState(() {
      _colors = paletteGenerator.colors.toList();
    });
  }

  /// Converts the given [color] to a hex string in the format '#RRGGBB'.
  ///
  /// The returned string is in upper case.
  ///
  /// The alpha channel is ignored.
  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  /// Copies the given [text] to the user's clipboard and shows a snackbar
  /// indicating the text was copied.
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBarOnce(context, text);
  }

  /// Displays a snackbar notification indicating that the given [hexCode]
  /// has been copied to the clipboard.
  ///
  /// Clears any existing snackbars before showing the new one.
  ///
  /// The snackbar includes an action button labeled 'Ok', which can be
  /// pressed to dismiss the snackbar.
  void _showSnackBarOnce(BuildContext context, String hexCode) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$hexCode copied to clipboard!'),
        action: SnackBarAction(
          label: 'Ok',
          onPressed: () => ScaffoldMessenger.of(context).clearSnackBars(),
        ),
      ),
    );
  }

  @override
  /// Builds the UI for the color palette generator screen.
  ///
  /// This widget returns a [Scaffold] containing an [AppBar] with the title
  /// 'Color Palette Generator' and a [Center] widget with a [Column] of children.
  /// 
  /// The column contains a [DottedBorder] with an [InkWell] that allows the user
  /// to pick an image from the gallery. If an image is selected, it displays the
  /// image with a badge that allows removing the image when tapped. A message
  /// prompts the user to select an image if none is selected.
  /// 
  /// If colors are generated from the image, it displays the total number of
  /// colors and a [GridView] of color swatches. Each color swatch is tappable,
  /// copying the color's hex code to the clipboard.
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Palette Generator'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: DottedBorder(
                color: Colors.black,
                strokeWidth: 2,
                dashPattern: const [6, 3],
                borderType: BorderType.RRect,
                radius: const Radius.circular(12),
                child: InkWell(
                  onTap: _pickImage,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    height: 250,
                    width: double.infinity,
                    child: Center(
                      child: _imageFile != null
                          ? badges.Badge(
                              onTap: () {
                                setState(() {
                                  _imageFile = null;
                                  _colors = [];
                                });
                              },
                              badgeStyle: badges.BadgeStyle(
                                  badgeColor: Colors.red.shade300),
                              badgeContent: const Tooltip(
                                message: 'Remove image',
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              child: Image.file(
                                _imageFile!,
                                height: 220,
                              ))
                          : const Text(
                              'Click here to select image',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20),
                            ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_colors.isNotEmpty)
              Text(
                'Total Colors : ${_colors.length}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            const SizedBox(height: 20),
            if (_colors.isNotEmpty)
              Expanded(
                child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: _colors.length,
                    scrollDirection: Axis.vertical,
                    physics: const ScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3),
                    itemBuilder: (context, index) {
                      Color color = _colors[index];
                      String hexCode = _colorToHex(color);
                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              _copyToClipboard(hexCode);
                            },
                            child: Container(
                              width: 100,
                              height: 70,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hexCode,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      );
                    }),
              )
          ],
        ),
      ),
    );
  }
}
