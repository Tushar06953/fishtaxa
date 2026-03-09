import 'dart:io';
import 'package:image/image.dart' as img;

class ImageQualityResult {
  final bool isValid;
  final String? reason;

  const ImageQualityResult.valid()
      : isValid = true,
        reason = null;

  const ImageQualityResult.invalid(this.reason) : isValid = false;
}

class ImageQualityValidator {
  static Future<ImageQualityResult> validate(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) {
      return const ImageQualityResult.invalid('Cannot read image');
    }

    double total = 0;
    final count = image.width * image.height;
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final p = image.getPixel(x, y);
        total += (p.r * 0.299 + p.g * 0.587 + p.b * 0.114);
      }
    }
    final avg = total / count;
    if (avg < 40.0) {
      return const ImageQualityResult.invalid(
          'Image too dark — please retake in better light');
    }
    if (avg > 230.0) {
      return const ImageQualityResult.invalid(
          'Image overexposed — please retake in less light');
    }
    return const ImageQualityResult.valid();
  }
}
