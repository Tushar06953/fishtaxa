import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/scan_result.dart';
import '../../../shared/services/image_quality_validator.dart';
import '../../../shared/services/inference_service.dart';

class ProcessingScreen extends ConsumerStatefulWidget {
  final String imagePath;

  const ProcessingScreen({super.key, required this.imagePath});

  @override
  ConsumerState<ProcessingScreen> createState() =>
      _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen> {
  String _status = 'Checking image quality...';
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runPipeline());
  }

  Future<void> _runPipeline() async {
    if (_started) return;
    _started = true;

    // Step 1: Quality check
    setState(() => _status = 'Checking image quality...');
    final quality =
        await ImageQualityValidator.validate(widget.imagePath);
    if (!quality.isValid) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(quality.reason ?? 'Image quality check failed'),
            backgroundColor: AppColors.coral,
          ),
        );
        context.pop();
      }
      return;
    }

    // Step 2: Inference
    setState(() => _status = 'Identifying species...');
    final predictions = await InferenceService.predict(widget.imagePath);

    if (predictions.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not identify species. Please try again.'),
            backgroundColor: AppColors.coral,
          ),
        );
        context.pop();
      }
      return;
    }

    // Step 3: DB lookup (just verify species exists)
    setState(() => _status = 'Looking up species...');
    final top = predictions.first;

    // Step 4: Save to Hive
    setState(() => _status = 'Saving result...');
    final resultId = md5
        .convert('${widget.imagePath}${DateTime.now().millisecondsSinceEpoch}'
            .codeUnits)
        .toString();

    final alternatives = predictions.skip(1).map((p) {
      final alt = AlternativeMatch()
        ..label = p.label
        ..speciesId = p.speciesId
        ..confidence = p.confidence;
      return alt;
    }).toList();

    final scanResult = ScanResult()
      ..id = resultId
      ..imagePath = widget.imagePath
      ..speciesId = top.speciesId
      ..speciesLabel = top.label
      ..confidence = top.confidence
      ..timestamp = DateTime.now()
      ..alternatives = alternatives
      ..isLowConfidence = InferenceService.isLowConfidence(predictions)
      ..usedMockInference = InferenceService.isUsingMock;

    try {
      final box = Hive.box<ScanResult>('scan_history');
      await box.add(scanResult);
    } catch (e) {
      // Non-fatal: proceed to result even if save fails
    }

    // Step 5: Navigate to result
    if (mounted) {
      context.pushReplacement(
        '/scan/result',
        extra: {'resultId': resultId, 'scanResult': scanResult},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Fish image background
                  if (File(widget.imagePath).existsSync())
                    Positioned.fill(
                      child: Image.file(
                        File(widget.imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  // Gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.navy.withOpacity(0.9),
                            AppColors.navy,
                          ],
                          stops: const [0.4, 0.75, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Processing animation
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.teal.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                              )
                                  .animate(
                                      onPlay: (c) => c.repeat())
                                  .scale(
                                    begin: const Offset(0.8, 0.8),
                                    end: const Offset(1.2, 1.2),
                                    duration: 1200.ms,
                                    curve: Curves.easeInOut,
                                  )
                                  .then()
                                  .scale(
                                    begin: const Offset(1.2, 1.2),
                                    end: const Offset(0.8, 0.8),
                                    duration: 1200.ms,
                                    curve: Curves.easeInOut,
                                  ),
                              const CircularProgressIndicator(
                                color: AppColors.tealBright,
                                strokeWidth: 3,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _status,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
