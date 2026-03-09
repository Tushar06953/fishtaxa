import 'package:camera/camera.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'camera_provider.g.dart';

@riverpod
Future<CameraController> cameraController(CameraControllerRef ref) async {
  final cameras = await availableCameras();
  if (cameras.isEmpty) {
    throw Exception('No cameras available');
  }
  final controller = CameraController(
    cameras.first,
    ResolutionPreset.high,
    enableAudio: false,
  );
  await controller.initialize();
  ref.onDispose(controller.dispose);
  return controller;
}
