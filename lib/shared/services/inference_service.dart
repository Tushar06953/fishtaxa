import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'image_preprocessor.dart';

class PredictionResult {
  final String label;
  final int speciesId;
  final double confidence;

  const PredictionResult({
    required this.label,
    required this.speciesId,
    required this.confidence,
  });
}

class InferenceService {
  static Interpreter? _interpreter;
  static List<String>? _labels;
  static bool _useMock = true;
  static int _mockIndex = 0;

  static const double confidenceThreshold = 0.60;
  static const int topK = 3;

  static const Map<String, int> labelToId = {
    'Rewa': 1,       'Baran': 2,       'Chalwa': 3,      'Kavai': 4,
    'Chana': 5,      'Dhol': 6,        'pothiya3': 7,    'Pothiya5': 8,
    'Sahura_G': 9,   'chana1': 10,     'Jalkapoor': 11,  'Bhaura': 12,
    'Bhula': 13,     'kamalkant': 14,  'kursa': 15,      'Bicket': 16,
    'Kauwa': 17,     'pothiya4': 18,   'Basain2': 19,    'Bachba': 20,
    'Naini': 21,     'pothiya1': 22,   'Sinhi': 23,      'Tengra': 24,
    'Garai': 25,     'Kotra': 26,      'Darhi': 27,      'Gacha': 28,
    'Derhwa': 29,    'pothiya': 30,    'Bula': 31,       'Anwa': 32,
    'Bhakur': 33,    'Grass': 34,      'Rohu': 35,       'Cheranga': 36,
    'kamalkant2': 37,'pothiya2': 38,   'patiya': 39,     'Dhabal': 40,
    'Dhalo': 41,     'Mangur': 42,     'Bami': 43,       'Kanti': 44,
    'Pathra': 45,
  };

  // Mock predictions — rotate on each call
  static final _mockSets = [
    [
      const PredictionResult(label: 'Rohu',      speciesId: 35, confidence: 0.94),
      const PredictionResult(label: 'kamalkant', speciesId: 14, confidence: 0.04),
      const PredictionResult(label: 'Bhakur',    speciesId: 33, confidence: 0.02),
    ],
    [
      const PredictionResult(label: 'Tengra',  speciesId: 24, confidence: 0.89),
      const PredictionResult(label: 'Sinhi',   speciesId: 23, confidence: 0.07),
      const PredictionResult(label: 'kursa',   speciesId: 15, confidence: 0.04),
    ],
    [
      const PredictionResult(label: 'Mangur',    speciesId: 42, confidence: 0.91),
      const PredictionResult(label: 'Jalkapoor', speciesId: 11, confidence: 0.06),
      const PredictionResult(label: 'Bhula',     speciesId: 13, confidence: 0.03),
    ],
    [
      const PredictionResult(label: 'Baran', speciesId: 2,  confidence: 0.87),
      const PredictionResult(label: 'Garai', speciesId: 25, confidence: 0.08),
      const PredictionResult(label: 'Darhi', speciesId: 27, confidence: 0.05),
    ],
    [
      const PredictionResult(label: 'Sinhi',  speciesId: 23, confidence: 0.92),
      const PredictionResult(label: 'Tengra', speciesId: 24, confidence: 0.05),
      const PredictionResult(label: 'Gacha',  speciesId: 28, confidence: 0.03),
    ],
  ];

  static Future<void> initialize() async {
    // Try to load real model — fall back to mock if not present
    try {
      // Check if file exists in assets (will throw if not bundled)
      await rootBundle.load('assets/model/fish_classifier_v1.tflite');
      _interpreter = await Interpreter.fromAsset(
          'assets/model/fish_classifier_v1.tflite');
      _useMock = false;
    } catch (_) {
      _useMock = true; // model not placed yet — use mock
    }

    final labelStr =
        await rootBundle.loadString('assets/model/labels.txt');
    _labels = labelStr
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
  }

  static Future<List<PredictionResult>> predict(String imagePath) async {
    if (_labels == null) await initialize();

    if (_useMock) {
      // Simulate inference delay
      await Future.delayed(const Duration(milliseconds: 800));
      final result = _mockSets[_mockIndex % _mockSets.length];
      _mockIndex++;
      return result;
    }

    // Real inference path
    final input = await ImagePreprocessor.fromPath(imagePath);
    final output = [List.filled(45, 0.0)];
    _interpreter!.run(input, output);

    final probs = output[0];
    final indexed =
        List.generate(probs.length, (i) => MapEntry(i, probs[i]));
    indexed.sort((a, b) => b.value.compareTo(a.value));

    final labels = _labels!;
    return indexed.take(topK).map((e) {
      final label = labels[e.key];
      return PredictionResult(
        label: label,
        speciesId: labelToId[label] ?? 0,
        confidence: e.value,
      );
    }).toList();
  }

  static bool isLowConfidence(List<PredictionResult> results) =>
      results.isEmpty || results.first.confidence < confidenceThreshold;

  static bool get isUsingMock => _useMock;
}
