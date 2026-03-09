import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/camera_provider.dart';
import '../widgets/scan_frame_overlay.dart';

class ScanScreen extends ConsumerWidget {
  const ScanScreen({super.key});

  Future<void> _capturePhoto(
      BuildContext context, CameraController controller) async {
    try {
      final xFile = await controller.takePicture();
      if (context.mounted) {
        context.push(
          '/scan/processing',
          extra: {'imagePath': xFile.path},
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Capture failed: $e')),
        );
      }
    }
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile != null && context.mounted) {
      context.push(
        '/scan/processing',
        extra: {'imagePath': xFile.path},
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraAsync = ref.watch(cameraControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          cameraAsync.when(
            data: (controller) => SizedBox.expand(
              child: CameraPreview(controller),
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.tealBright),
            ),
            error: (e, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.camera_alt_outlined,
                      color: AppColors.textMuted, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Camera unavailable',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please grant camera permissions',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _pickFromGallery(context),
                    child: const Text('Choose from Gallery'),
                  ),
                ],
              ),
            ),
          ),
          const ScanFrameOverlay(),
          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 22),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _pickFromGallery(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.photo_library_outlined,
                          color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Text(
                      'Point camera at fish',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.7),
                          ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: cameraAsync.hasValue
                          ? () =>
                              _capturePhoto(context, cameraAsync.value!)
                          : null,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white, width: 3),
                          color: cameraAsync.hasValue
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                        ),
                        child: Center(
                          child: Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: cameraAsync.hasValue
                                  ? AppColors.teal
                                  : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
