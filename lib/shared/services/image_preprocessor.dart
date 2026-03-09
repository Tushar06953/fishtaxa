import 'dart:io';
import 'package:image/image.dart' as img;

class ImagePreprocessor {
  static Future<List<List<List<List<double>>>>> fromPath(String path) async {
    final bytes = await File(path).readAsBytes();
    final original = img.decodeImage(bytes)!;
    final resized = img.copyResize(original, width: 224, height: 224);

    return List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            final pixel = resized.getPixel(x, y);
            return [
              (pixel.r / 127.5) - 1.0,
              (pixel.g / 127.5) - 1.0,
              (pixel.b / 127.5) - 1.0,
            ];
          },
        ),
      ),
    );
  }
}
