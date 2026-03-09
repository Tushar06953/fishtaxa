import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/services/inference_service.dart';

part 'inference_provider.g.dart';

@riverpod
Future<List<PredictionResult>> inference(
        InferenceRef ref, String imagePath) =>
    InferenceService.predict(imagePath);
