import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'FishTaxa';
  static const String tagline = 'Offline AI · 26 North Indian River Species';
  static const String modelAssetPath = 'assets/model/fish_classifier_v1.tflite';
  static const String labelsAssetPath = 'assets/model/labels.txt';
  static const String dbAssetPath = 'assets/db/species.db';
  static const String dbName = 'species.db';
  static const String historyBoxName = 'scan_history';
  static const int inputSize = 224;
  static const int numClasses = 26;
  static const int topK = 3;
  static const double confidenceThreshold = 0.60;
  static const int splashDuration = 2500; // ms

  static const Map<String, String> speciesCategory = {
    'Mangur':    'Premium Medicinal',
    'Sinhi':     'Premium Medicinal',
    'Kavai':     'Premium Medicinal',
    'Jalkapoor': 'Prized Catfish',
    'Tengra':    'Prized Catfish',
    'Bachba':    'Prized Catfish',
    'Bhaura':    'Snakehead',
    'Garai':     'Snakehead',
    'Chana':     'Snakehead',
    'Rohu':      'Major Carp',
    'Bhakur':    'Major Carp',
    'Naini':     'Major Carp',
    'Grass':     'Major Carp',
    'Carp':      'Major Carp',
    'Rewa':      'Major Carp',
    'Bami':      'Spiny Eel',
    'Gaicha':    'Spiny Eel',
    'Patiya':    'Spiny Eel',
    'Chalwa':    'Small Carp',
    'Pothiya':   'Small Carp',
    'Kursa':     'Small Carp',
    'Derhwa':    'Small Carp',
    'Bhula':     'Small Carp',
    'Kauwa':     'Needlefish',
    'Kotra':     'Gourami',
    'Pathra':    'Invasive Species',
  };

  static const Map<String, Color> categoryColor = {
    'Premium Medicinal': Color(0xFFF5C842),
    'Prized Catfish':    Color(0xFF0D7A6E),
    'Snakehead':         Color(0xFFFF6B47),
    'Major Carp':        Color(0xFF00FF88),
    'Spiny Eel':         Color(0xFF7BA8B8),
    'Small Carp':        Color(0xFF7BA8B8),
    'Needlefish':        Color(0xFF10C9B1),
    'Gourami':           Color(0xFF10C9B1),
    'Invasive Species':  Color(0xFFFF6B47),
  };
}
