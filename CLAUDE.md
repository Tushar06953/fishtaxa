# FishTaxa — CLAUDE.md

> **FOR CLAUDE CODE: Read this file and immediately start building. No prompts needed.**
> Last updated: 2025 | Model Version: v1 | Species: 26 | Platform: Android (Flutter)

---

## 🤖 CLAUDE CODE — START HERE

**Read this entire file first, then execute the build plan without asking.**

### ✅ Already in the project (DO NOT recreate):
- `assets/model/labels.txt` — 45 class labels, one per line
- `assets/db/species.db` — pre-seeded SQLite, all 26 verified North Indian river species (Sec 1 + 3 from Matsya label verification) with full data

### ⏳ Not yet placed (build around it):
- `assets/model/fish_classifier_v1.tflite` — owner will drop this file in later

### ⚠️ TFLITE MODEL RULE — CRITICAL:
```
IF assets/model/fish_classifier_v1.tflite EXISTS:
    → Use real TFLite inference (InferenceService with Interpreter)

IF assets/model/fish_classifier_v1.tflite DOES NOT EXIST:
    → Use MockInferenceService that returns realistic fake predictions
    → App must fully work, all screens must be navigable
    → NO demo mode banners, NO warnings shown to user — app looks fully functional
    → When model is later dropped in, InferenceService auto-activates
    → No code changes needed when model is added
```

Implement this check in `InferenceService.initialize()`:
```dart
static Future<void> initialize() async {
  try {
    _interpreter = await Interpreter.fromAsset(
      'assets/model/fish_classifier_v1.tflite',
    );
    _useMock = false;
  } catch (_) {
    _useMock = true; // silent fallback — no UI warning shown
  }
  final labelStr = await rootBundle.loadString('assets/model/labels.txt');
  _labels = labelStr.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
}
```

**Mock predictions** (rotate through these when `_useMock == true` — shown silently, no banner):
```dart
static final _mockResults = [
  PredictionResult(label: 'Rohu',     speciesId: 17, confidence: 0.94),
  PredictionResult(label: 'Tengra',   speciesId: 19, confidence: 0.89),
  PredictionResult(label: 'Mangur',   speciesId: 12, confidence: 0.91),
  PredictionResult(label: 'Sinhi',    speciesId: 18, confidence: 0.87),
  PredictionResult(label: 'Pothiya',  speciesId: 25, confidence: 0.82),
];
```
Rotate through these on each call so different scans return different species.

### Your job:
Build **everything** in `lib/`, `pubspec.yaml`, and `AndroidManifest.xml` from scratch.

---

## 🚀 BUILD PLAN — Execute every step in order

```
STEP 1  →  Create all directories in lib/
STEP 2  →  Write pubspec.yaml
STEP 3  →  Write android/app/src/main/AndroidManifest.xml
STEP 4  →  Write android/app/build.gradle (minSdk 21, targetSdk 34)
STEP 5  →  Write lib/core/constants/app_constants.dart
STEP 6  →  Write lib/core/theme/app_theme.dart
STEP 7  →  Write lib/shared/models/species.dart
STEP 8  →  Write lib/shared/models/scan_result.dart
STEP 9  →  Write lib/shared/services/species_database.dart
STEP 10 →  Write lib/shared/services/image_preprocessor.dart
STEP 11 →  Write lib/shared/services/image_quality_validator.dart
STEP 12 →  Write lib/shared/services/inference_service.dart  ← mock fallback
STEP 13 →  Write lib/shared/providers/species_db_provider.dart
STEP 14 →  Write lib/shared/providers/history_provider.dart
STEP 15 →  Write lib/features/scan/providers/camera_provider.dart
STEP 16 →  Write lib/features/scan/providers/inference_provider.dart
STEP 17 →  Write lib/features/species_guide/providers/guide_filter_provider.dart
STEP 18 →  Write lib/core/router/app_router.dart
STEP 19 →  Write lib/main.dart
STEP 20 →  Write all 9 screens + widgets (full UI — no stubs)
STEP 21 →  Run: flutter pub get
STEP 22 →  Run: flutter pub run build_runner build --delete-conflicting-outputs
STEP 23 →  Run: flutter analyze → fix ALL errors
STEP 24 →  Run: flutter build apk --release
```

---

## 1. Project Overview

**FishTaxa** is an offline-first Flutter mobile application that identifies Indian fish species from photos using on-device AI. It works completely without internet.

**Users:** Fishermen · Fish vendors · Fisheries enforcement officers · Seafood markets

**Output per scan:** Species name (EN/HI/TA/BN) · Scientific name · Legal status · Market price · Health advisory

**Tagline:** *"Photograph your catch. Know everything. Even offline."*

**Hard constraints:**
- Zero internet — no API calls, ever
- Target: mid-range Android (4 GB RAM, Android 5.0+)
- Inference < 800 ms once model is placed
- Scan-to-result < 2 seconds
- App size < 40 MB

---

## 2. System Architecture

```
Camera Capture
      ↓
Image Quality Validation
(brightness check — reject too dark / overexposed)
      ↓
Image Preprocessing
(resize 224×224, normalize pixels to [-1.0, 1.0])
      ↓
InferenceService.predict(imagePath)
  ├── IF model file exists → real TFLite (MobileNetV3-Small INT8)
  └── IF model file missing → MockInferenceService (silent fallback, no UI warning)
      ↓
Top-3 Predictions (sorted by confidence)
      ↓
SQLite Species Lookup (by speciesId from labelToId map)
      ↓
Save ScanResult to Hive
      ↓
Result Screen UI
```

---

## 3. Tech Stack

| Layer | Package | Version |
|---|---|---|
| UI Framework | flutter | SDK |
| State Management | flutter_riverpod | ^2.5.1 |
| Riverpod Codegen | riverpod_annotation | ^2.3.5 |
| Navigation | go_router | ^13.2.0 |
| Species DB | sqflite | ^2.3.3 |
| Scan History | hive + hive_flutter | ^2.2.3 |
| ML Inference | tflite_flutter | ^0.10.4 |
| Camera | camera | ^0.10.5 |
| Gallery | image_picker | ^1.1.2 |
| Preferences | shared_preferences | ^2.2.3 |
| Animations | flutter_animate | ^4.5.0 |
| Fonts | google_fonts | ^6.2.1 |
| Image processing | image | ^4.1.3 |
| Path utils | path_provider + path | ^2.1.3 / ^1.9.0 |
| Crypto | crypto | ^3.0.3 |

**Dev:** build_runner ^2.4.9 · riverpod_generator ^2.4.0 · hive_generator ^2.0.1

---

## 4. pubspec.yaml

```yaml
name: fishtaxa
description: Offline AI fish species identification for India
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  go_router: ^13.2.0
  sqflite: ^2.3.3
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  camera: ^0.10.5
  image_picker: ^1.1.2
  tflite_flutter: ^0.10.4
  google_fonts: ^6.2.1
  flutter_animate: ^4.5.0
  shared_preferences: ^2.2.3
  image: ^4.1.3
  path_provider: ^2.1.3
  path: ^1.9.0
  crypto: ^3.0.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.9
  riverpod_generator: ^2.4.0
  hive_generator: ^2.0.1
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/model/labels.txt
    - assets/db/species.db
    - assets/images/placeholder/fish.png
    # NOTE: fish_classifier_v1.tflite is intentionally omitted here until placed
    # When owner adds the file, add this line:
    # - assets/model/fish_classifier_v1.tflite
```

---

## 5. Android Setup

### AndroidManifest.xml

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
<uses-feature android:name="android.hardware.camera" android:required="false" />
```

### android/app/build.gradle

```gradle
android {
    compileSdkVersion 34
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

---

## 6. Full Project File Structure

```
fishtaxa/
├── CLAUDE.md
├── pubspec.yaml
├── assets/
│   ├── model/
│   │   ├── labels.txt                        ✅ already here
│   │   └── fish_classifier_v1.tflite         ⏳ owner will add later
│   ├── db/
│   │   └── species.db                        ✅ already here
│   └── images/placeholder/
│       └── fish.png                          ← create a simple placeholder
├── android/
│   └── app/src/main/AndroidManifest.xml
└── lib/
    ├── main.dart
    ├── core/
    │   ├── constants/app_constants.dart
    │   ├── theme/app_theme.dart
    │   └── router/
    │       ├── app_router.dart
    │       └── app_router.g.dart              ← generated
    ├── shared/
    │   ├── models/
    │   │   ├── species.dart
    │   │   ├── scan_result.dart
    │   │   └── scan_result.g.dart             ← generated
    │   ├── providers/
    │   │   ├── species_db_provider.dart
    │   │   ├── species_db_provider.g.dart     ← generated
    │   │   ├── history_provider.dart
    │   │   └── history_provider.g.dart        ← generated
    │   └── services/
    │       ├── species_database.dart
    │       ├── inference_service.dart          ← mock fallback built-in
    │       ├── image_preprocessor.dart
    │       └── image_quality_validator.dart
    └── features/
        ├── splash/screens/splash_screen.dart
        ├── home/
        │   ├── screens/home_screen.dart
        │   └── widgets/
        │       ├── offline_badge.dart
        │       ├── action_card.dart
        │       └── recent_scan_tile.dart
        ├── scan/
        │   ├── screens/
        │   │   ├── scan_screen.dart
        │   │   └── processing_screen.dart
        │   ├── providers/
        │   │   ├── camera_provider.dart
        │   │   ├── camera_provider.g.dart     ← generated
        │   │   ├── inference_provider.dart
        │   │   └── inference_provider.g.dart  ← generated
        │   └── widgets/
        │       └── scan_frame_overlay.dart
        ├── result/screens/result_screen.dart
        ├── species_guide/
        │   ├── screens/
        │   │   ├── species_guide_screen.dart
        │   │   └── species_detail_screen.dart
        │   ├── providers/
        │   │   ├── guide_filter_provider.dart
        │   │   └── guide_filter_provider.g.dart ← generated
        │   └── widgets/
        │       └── species_card.dart
        ├── history/screens/history_screen.dart
        └── settings/screens/settings_screen.dart
```

---

## 7. Design System

### AppColors

```dart
class AppColors {
  static const deep        = Color(0xFF050D1A); // darkest bg
  static const navy        = Color(0xFF081428); // scaffold bg
  static const ocean       = Color(0xFF0A2140); // card surface
  static const teal        = Color(0xFF0D7A6E); // primary CTA
  static const tealBright  = Color(0xFF10C9B1); // gradient end
  static const biolum      = Color(0xFF00FFE5); // accent / badge
  static const coral       = Color(0xFFFF6B47); // protected / error
  static const gold        = Color(0xFFF5C842); // price display
  static const sand        = Color(0xFFF0E6D3); // light text
  static const textPrimary = Color(0xFFE8F4F8);
  static const textMuted   = Color(0xFF7BA8B8);
  static const permitted   = Color(0xFF00FF88); // legal green
}
```

### Typography
- **Headings / Display:** `GoogleFonts.syne(fontWeight: FontWeight.w700)`
- **Body / Labels:** `GoogleFonts.dmSans()`
- **Theme mode:** Dark only — `ThemeMode.dark`

---

## 8. Navigation (GoRouter)

```
/                     → SplashScreen          (initialLocation, no nav bar)
/home                 → HomeScreen            (shell tab 0)
/guide                → SpeciesGuideScreen    (shell tab 1)
/guide/:id            → SpeciesDetailScreen   (pushed, no shell)
/history              → HistoryScreen         (shell tab 2)
/settings             → SettingsScreen        (shell tab 3)
/scan                 → ScanScreen            (full screen, no nav bar)
/scan/processing      → ProcessingScreen      (extra: {'imagePath': String})
/scan/result          → ResultScreen          (extra: {'resultId': String})
```

Bottom nav order: **Home · Guide · History · Settings**

Use `ShellRoute` to wrap the 4 tab screens. ScanScreen and its children are outside the shell.

---

## 9. SQLite Species Database

### Schema

```sql
CREATE TABLE species (
  id                  INTEGER PRIMARY KEY,
  common_name_en      TEXT NOT NULL,
  scientific_name     TEXT NOT NULL,
  name_hindi          TEXT,
  name_tamil          TEXT,
  name_bengali        TEXT,
  legal_status        TEXT CHECK(legal_status IN ('permitted','protected','seasonal')),
  price_min_kg        INTEGER,
  price_max_kg        INTEGER,
  habitat             TEXT CHECK(habitat IN ('marine','freshwater','brackish')),
  health_advisory     TEXT,
  seasonal_ban_months TEXT   -- stored as JSON string e.g. "[6,7,8]"
);
```

### SpeciesDatabase — copy-on-first-run pattern

```dart
// lib/shared/services/species_database.dart
class SpeciesDatabase {
  static Database? _db;
  static SpeciesDatabase instance = SpeciesDatabase._();
  SpeciesDatabase._();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'species.db');
    if (!await File(path).exists()) {
      final data = await rootBundle.load('assets/db/species.db');
      final bytes = data.buffer.asUint8List();
      await File(path).writeAsBytes(bytes, flush: true);
    }
    return openDatabase(path, readOnly: true);
  }

  Future<List<Species>> getAll() async { ... }
  Future<Species?> getById(int id) async { ... }
  Future<List<Species>> search(String q) async { ... }     // search all name fields
  Future<List<Species>> filterByHabitat(String h) async { ... }
  Future<List<Species>> getProtected() async { ... }       // seasonal + protected
  Future<Species?> getByLabel(String label) async {
    final id = InferenceService.labelToId[label];
    if (id == null) return null;
    return getById(id);
  }
}
```

---

## 10. All 45 Species — Complete Reference

### labels.txt line order (index 0–44):

```
0  Rewa         1  Baran        2  Chalwa       3  Kavai        4  Chana
5  Dhol         6  pothiya3     7  Pothiya5     8  Sahura_G     9  chana1
10 Jalkapoor    11 Bhaura       12 Bhula        13 kamalkant    14 kursa
15 Bicket       16 Kauwa        17 pothiya4     18 Basain2      19 Bachba
20 Naini        21 pothiya1     22 Sinhi        23 Tengra       24 Garai
25 Kotra        26 Darhi        27 Gacha        28 Derhwa       29 pothiya
30 Bula         31 Anwa         32 Bhakur       33 Grass        34 Rohu
35 Cheranga     36 kamalkant2   37 pothiya2     38 patiya       39 Dhabal
40 Dhalo        41 Mangur       42 Bami         43 Kanti        44 Pathra
```

### Label → Species ID map (hardcoded in InferenceService):

```dart
static const Map<String, int> labelToId = {
  'rohu': 1,             'catla': 2,            'mrigal': 3,
  'common_carp': 4,      'grass_carp': 5,       'silver_carp': 6,
  'bighead_carp': 7,     'tilapia': 8,          'pangasius': 9,
  'snakehead': 10,       'walking_catfish': 11, 'stinging_catfish': 12,
  'pearl_spot': 13,      'indian_mackerel': 14, 'sardine': 15,
  'anchovy': 16,         'hilsa': 17,           'pomfret_silver': 18,
  'pomfret_black': 19,   'seer_fish': 20,       'tuna_skipjack': 21,
  'tuna_yellowfin': 22,  'kingfish': 23,        'barracuda': 24,
  'red_snapper': 25,     'grouper': 26,         'sea_bass': 27,
  'mullet': 28,          'sole': 29,            'flounder': 30,
  'bombay_duck': 31,     'ribbon_fish': 32,     'horse_mackerel': 33,
  'flying_fish': 34,     'catfish_marine': 35,  'prawns_tiger': 36,
  'prawns_white': 37,    'prawns_pink': 38,     'crab_mud': 39,
  'lobster': 40,         'squid': 41,           'cuttlefish': 42,
};
```

### species.db — all 45 rows (already seeded, for reference):

All 26 species are **North Indian freshwater river fish** (UP/MP/Bihar/Chhattisgarh).

| ID | Label (exact) | Common Name | Scientific Name | Status | Price/kg |
|---|---|---|---|---|---|
| 1 | Rewa | Rewa | Labeo dero | permitted | 80–160 |
| 2 | Baran | Baran / Mahseer | Tor tor | permitted | 200–500 |
| 3 | Chalwa | Chalwa | Barilius bendelisis | permitted | 60–120 |
| 4 | Kavai | Kavai | Notopterus notopterus | permitted | 120–250 |
| 5 | Chana | Chana | Channa punctata | permitted | 80–180 |
| 6 | Dhol | Dhol / Katla | Catla catla | permitted | 130–250 |
| 7 | pothiya3 | Pothiya 3 | Puntius sophore | permitted | 40–80 |
| 8 | Pothiya5 | Pothiya 5 | Puntius ticto | permitted | 40–80 |
| 9 | Sahura_G | Sahura | Cirrhinus reba | permitted | 70–140 |
| 10 | chana1 | Chana 1 / Shol | Channa striata | permitted | 150–280 |
| 11 | Jalkapoor | Jalkapoor | Wallago attu | permitted | 100–200 |
| 12 | Bhaura | Bhaura / Bata | Labeo bata | permitted | 60–130 |
| 13 | Bhula | Bhula | Sperata seenghala | permitted | 120–260 |
| 14 | kamalkant | Kamalkant | Labeo rohita | permitted | 120–220 |
| 15 | kursa | Kursa | Mystus aor | permitted | 80–160 |
| 16 | Bicket | Bicket | Channa marulius | permitted | 100–220 |
| 17 | Kauwa | Kauwa | Aorichthys aor | permitted | 70–140 |
| 18 | pothiya4 | Pothiya 4 | Puntius conchonius | permitted | 40–80 |
| 19 | Basain2 | Basain | Salmostoma bacaila | permitted | 30–70 |
| 20 | Bachba | Bachba / Eel | Anguilla bengalensis | permitted | 150–350 |
| 21 | Naini | Naini / Mrigal | Cirrhinus mrigala | permitted | 100–200 |
| 22 | pothiya1 | Pothiya 1 | Puntius chola | permitted | 40–80 |
| 23 | Sinhi | Sinhi / Singhi | Heteropneustes fossilis | permitted | 140–280 |
| 24 | Tengra | Tengra | Mystus tengara | permitted | 80–200 |
| 25 | Garai | Garai / Mahseer | Tor putitora | permitted | 200–600 |
| 26 | Kotra | Kotra / Rita | Rita rita | permitted | 100–220 |
| 27 | Darhi | Darhi / Goonch | Bagarius bagarius | permitted | 150–300 |
| 28 | Gacha | Gacha | Clupisoma garua | permitted | 80–180 |
| 29 | Derhwa | Derhwa | Labeo dussumieri | permitted | 60–130 |
| 30 | pothiya | Pothiya | Puntius vittatus | permitted | 40–80 |
| 31 | Bula | Bula | Sperata aor | permitted | 100–200 |
| 32 | Anwa | Anwa / Kalbasu | Labeo calbasu | permitted | 80–160 |
| 33 | Bhakur | Bhakur / Katla | Gibelion catla | permitted | 130–250 |
| 34 | Grass | Grass Carp | Ctenopharyngodon idella | permitted | 80–150 |
| 35 | Rohu | Rohu | Labeo rohita | permitted | 120–220 |
| 36 | Cheranga | Cheranga | Cirrhinus cirrhosus | permitted | 80–160 |
| 37 | kamalkant2 | Kamalkant 2 | Labeo rohita | permitted | 120–220 |
| 38 | pothiya2 | Pothiya 2 | Puntius sarana | permitted | 50–100 |
| 39 | patiya | Patiya / Chitol | Chitala chitala | permitted | 150–320 |
| 40 | Dhabal | Dhabal | Labeo gonius | permitted | 70–150 |
| 41 | Dhalo | Dhalo / Hilsa | Hilsa ilisha | **seasonal** | 200–800 |
| 42 | Mangur | Mangur / Magur | Clarias batrachus | permitted | 120–260 |
| 43 | Bami | Bami / Spiny Eel | Mastacembelus armatus | permitted | 100–220 |
| 44 | Kanti | Kanti | Xenentodon cancila | permitted | 60–130 |
| 45 | Pathra | Pathra | Glyptothorax telchitta | permitted | 80–160 |

**Dhalo seasonal ban months:** June, July, August (stored as `[6,7,8]`)

---

## 11. InferenceService — Full Implementation

```dart
// lib/shared/services/inference_service.dart
import 'dart:io';
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
    'Bachba': 1,   'Bami': 2,      'Bhakur': 3,    'Bhaura': 4,
    'Derhwa': 5,   'Gaicha': 6,    'Grass': 7,     'Jalkapoor': 8,
    'Kavai': 9,    'Kauwa': 10,    'Kotra': 11,    'Mangur': 12,
    'Naini': 13,   'Pathra': 14,   'Patiya': 15,   'Rewa': 16,
    'Rohu': 17,    'Sinhi': 18,    'Tengra': 19,   'Chalwa': 20,
    'Kursa': 21,   'Chana': 22,    'Garai': 23,    'Bhula': 24,
    'Pothiya': 25, 'Carp': 26,
  };

  // Mock predictions — rotate on each call
  static final _mockSets = [
    [PredictionResult(label:'Rohu',      speciesId:17, confidence:0.94),
     PredictionResult(label:'Bhakur',    speciesId:3,  confidence:0.04),
     PredictionResult(label:'Naini',     speciesId:13, confidence:0.02)],
    [PredictionResult(label:'Tengra',    speciesId:19, confidence:0.89),
     PredictionResult(label:'Sinhi',     speciesId:18, confidence:0.07),
     PredictionResult(label:'Kursa',     speciesId:21, confidence:0.04)],
    [PredictionResult(label:'Mangur',    speciesId:12, confidence:0.91),
     PredictionResult(label:'Jalkapoor', speciesId:8,  confidence:0.06),
     PredictionResult(label:'Bhula',     speciesId:24, confidence:0.03)],
    [PredictionResult(label:'Garai',     speciesId:23, confidence:0.87),
     PredictionResult(label:'Chana',     speciesId:22, confidence:0.08),
     PredictionResult(label:'Bhaura',    speciesId:4,  confidence:0.05)],
    [PredictionResult(label:'Pothiya',   speciesId:25, confidence:0.92),
     PredictionResult(label:'Chalwa',    speciesId:20, confidence:0.05),
     PredictionResult(label:'Carp',      speciesId:26, confidence:0.03)],
  ];

  static Future<void> initialize() async {
    // Try to load real model — fall back to mock if not present
    try {
      _interpreter = await Interpreter.fromAsset(
          'assets/model/fish_classifier_v1.tflite');
      _useMock = false;
    } catch (_) {
      _useMock = true; // model not placed yet — use mock
    }
    final labelStr = await rootBundle.loadString('assets/model/labels.txt');
    _labels = labelStr
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
  }

  static Future<List<PredictionResult>> predict(String imagePath) async {
    if (_labels == null) await initialize();

    if (_useMock) {
      // Return rotating mock results — silently, no UI indication
      await Future.delayed(const Duration(milliseconds: 800)); // simulate inference
      final result = _mockSets[_mockIndex % _mockSets.length];
      _mockIndex++;
      return result;
    }

    // Real inference
    final input = await ImagePreprocessor.fromPath(imagePath);
    final output = [List.filled(26, 0.0)];
    _interpreter!.run(input, output);

    final probs = output[0];
    final indexed = List.generate(probs.length, (i) => MapEntry(i, probs[i]));
    indexed.sort((a, b) => b.value.compareTo(a.value));

    return indexed.take(topK).map((e) {
      final label = _labels![e.key];
      return PredictionResult(
        label: label,
        speciesId: labelToId[label] ?? 0,
        confidence: e.value,
      );
    }).toList();
  }

  static bool isLowConfidence(List<PredictionResult> results) =>
      results.isEmpty || results.first.confidence < confidenceThreshold;

  static bool get isUsingMock => _useMock; // internal only — never show in UI
}
```

---

## 12. ImagePreprocessor

```dart
// lib/shared/services/image_preprocessor.dart
import 'dart:io';
import 'package:image/image.dart' as img;

class ImagePreprocessor {
  static Future<List<List<List<List<double>>>>> fromPath(String path) async {
    final bytes = await File(path).readAsBytes();
    final original = img.decodeImage(bytes)!;
    final resized = img.copyResize(original, width: 224, height: 224);

    return List.generate(1, (_) =>
      List.generate(224, (y) =>
        List.generate(224, (x) {
          final pixel = resized.getPixel(x, y);
          return [
            (pixel.r / 127.5) - 1.0,
            (pixel.g / 127.5) - 1.0,
            (pixel.b / 127.5) - 1.0,
          ];
        })
      )
    );
  }
}
```

---

## 13. ImageQualityValidator

```dart
// lib/shared/services/image_quality_validator.dart
import 'dart:io';
import 'package:image/image.dart' as img;

class ImageQualityResult {
  final bool isValid;
  final String? reason;
  const ImageQualityResult.valid() : isValid = true, reason = null;
  const ImageQualityResult.invalid(this.reason) : isValid = false;
}

class ImageQualityValidator {
  static Future<ImageQualityResult> validate(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) return const ImageQualityResult.invalid('Cannot read image');

    double total = 0;
    final count = image.width * image.height;
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final p = image.getPixel(x, y);
        total += (p.r * 0.299 + p.g * 0.587 + p.b * 0.114);
      }
    }
    final avg = total / count;
    if (avg < 40.0) return const ImageQualityResult.invalid('Image too dark — please retake');
    if (avg > 230.0) return const ImageQualityResult.invalid('Image overexposed — please retake');
    return const ImageQualityResult.valid();
  }
}
```

---

## 14. Data Models

### Species

```dart
// lib/shared/models/species.dart
enum LegalStatus { permitted, protected, seasonal }
enum Habitat { marine, freshwater, brackish }

class Species {
  final int id;
  final String commonNameEn;
  final String scientificName;
  final String? nameHindi;
  final String? nameTamil;
  final String? nameBengali;
  final LegalStatus legalStatus;
  final int priceMinKg;
  final int priceMaxKg;
  final Habitat habitat;
  final String? healthAdvisory;
  final List<int> seasonalBanMonths;

  const Species({ required this.id, required this.commonNameEn,
    required this.scientificName, this.nameHindi, this.nameTamil,
    this.nameBengali, required this.legalStatus, required this.priceMinKg,
    required this.priceMaxKg, required this.habitat,
    this.healthAdvisory, required this.seasonalBanMonths });

  factory Species.fromMap(Map<String, dynamic> map) => Species(
    id: map['id'],
    commonNameEn: map['common_name_en'],
    scientificName: map['scientific_name'],
    nameHindi: map['name_hindi'],
    nameTamil: map['name_tamil'],
    nameBengali: map['name_bengali'],
    legalStatus: LegalStatus.values.firstWhere(
        (e) => e.name == map['legal_status'],
        orElse: () => LegalStatus.permitted),
    priceMinKg: map['price_min_kg'] ?? 0,
    priceMaxKg: map['price_max_kg'] ?? 0,
    habitat: Habitat.values.firstWhere(
        (e) => e.name == map['habitat'],
        orElse: () => Habitat.marine),
    healthAdvisory: map['health_advisory'],
    seasonalBanMonths: map['seasonal_ban_months'] != null
        ? List<int>.from(jsonDecode(map['seasonal_ban_months']))
        : [],
  );
}
```

### ScanResult (Hive)

```dart
// lib/shared/models/scan_result.dart
import 'package:hive/hive.dart';
part 'scan_result.g.dart';

@HiveType(typeId: 0)
class ScanResult extends HiveObject {
  @HiveField(0) late String id;            // UUID
  @HiveField(1) late String imagePath;
  @HiveField(2) late int speciesId;
  @HiveField(3) late String speciesLabel;
  @HiveField(4) late double confidence;
  @HiveField(5) late DateTime timestamp;
  @HiveField(6) late List<AlternativeMatch> alternatives;
  @HiveField(7) late bool isLowConfidence;
}

@HiveType(typeId: 1)
class AlternativeMatch extends HiveObject {
  @HiveField(0) late String label;
  @HiveField(1) late int speciesId;
  @HiveField(2) late double confidence;
}
```

---

## 15. Riverpod Providers

```dart
// inference_provider.dart
@riverpod
Future<List<PredictionResult>> inference(InferenceRef ref, String imagePath) =>
    InferenceService.predict(imagePath);

// camera_provider.dart
@riverpod
Future<CameraController> cameraController(CameraControllerRef ref) async {
  final cameras = await availableCameras();
  final controller = CameraController(cameras.first, ResolutionPreset.high);
  await controller.initialize();
  ref.onDispose(controller.dispose);
  return controller;
}

// species_db_provider.dart
@riverpod
Future<List<Species>> allSpecies(AllSpeciesRef ref) =>
    SpeciesDatabase.instance.getAll();

@riverpod
Future<Species?> speciesById(SpeciesByIdRef ref, int id) =>
    SpeciesDatabase.instance.getById(id);

@riverpod
Future<List<Species>> speciesSearch(SpeciesSearchRef ref, String q) =>
    SpeciesDatabase.instance.search(q);

// history_provider.dart
@riverpod
class ScanHistory extends _$ScanHistory {
  @override
  List<ScanResult> build() =>
      Hive.box<ScanResult>('scan_history').values.toList().reversed.toList();
  void add(ScanResult r) {
    Hive.box<ScanResult>('scan_history').add(r);
    ref.invalidateSelf();
  }
  void clear() {
    Hive.box<ScanResult>('scan_history').clear();
    ref.invalidateSelf();
  }
}

// guide_filter_provider.dart
enum GuideFilter { all, freshwater, marine, brackish, protected }
final guideFilterProvider = StateProvider<GuideFilter>((_) => GuideFilter.all);
final guideSearchProvider = StateProvider<String>((_) => '');
final filteredSpeciesProvider = Provider<AsyncValue<List<Species>>>((ref) {
  return ref.watch(allSpeciesProvider).whenData((all) {
    var list = all;
    final filter = ref.watch(guideFilterProvider);
    final q = ref.watch(guideSearchProvider).toLowerCase();
    if (filter == GuideFilter.freshwater) list = list.where((s) => s.habitat == Habitat.freshwater).toList();
    if (filter == GuideFilter.marine)     list = list.where((s) => s.habitat == Habitat.marine).toList();
    if (filter == GuideFilter.brackish)   list = list.where((s) => s.habitat == Habitat.brackish).toList();
    if (filter == GuideFilter.protected)  list = list.where((s) => s.legalStatus != LegalStatus.permitted).toList();
    if (q.isNotEmpty) list = list.where((s) =>
      s.commonNameEn.toLowerCase().contains(q) ||
      s.scientificName.toLowerCase().contains(q) ||
      (s.nameHindi?.toLowerCase().contains(q) ?? false) ||
      (s.nameTamil?.toLowerCase().contains(q) ?? false) ||
      (s.nameBengali?.toLowerCase().contains(q) ?? false)
    ).toList();
    return list;
  });
});
```

---

## 16. main.dart

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'shared/models/scan_result.dart';
import 'shared/services/inference_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ScanResultAdapter());
  Hive.registerAdapter(AlternativeMatchAdapter());
  await Hive.openBox<ScanResult>('scan_history');
  await InferenceService.initialize(); // loads real model OR sets mock mode
  runApp(const ProviderScope(child: FishTaxaApp()));
}

class FishTaxaApp extends ConsumerWidget {
  const FishTaxaApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'FishTaxa',
      theme: AppTheme.dark,
      routerConfig: ref.watch(appRouterProvider),
      debugShowCheckedModeBanner: false,
    );
  }
}
```

---

## 17. Screen Specifications

### SplashScreen (`/`)
- Background `AppColors.navy`, center fish icon + "FishTaxa" in Syne Bold
- Subtitle: "Offline AI · 26 Verified North Indian River Species"
- No demo mode banners — app always looks fully functional
- `flutter_animate` fade+scale 800ms → auto-navigate to `/home` after 2.5s

### HomeScreen (`/home`)

**AppBar:**
- Left: "FishTaxa" in Syne Bold white
- Right: "● OFFLINE" badge in biolum green (blinking dot)

**Greeting card (below AppBar):**
- Time-based greeting:
  - 5am–12pm  → "Good Morning 👋"
  - 12pm–5pm  → "Good Afternoon 👋"
  - 5pm–9pm   → "Good Evening 👋"
  - 9pm–5am   → "Good Night 👋"
- Subtitle line: "Ready to identify your catch?"
- Below subtitle: small teal row → "● Running Offline AI" (green dot + text)
- NO demo mode banner ever

**Action buttons:**
- Full-width teal gradient button → "📷 Scan Fish" → `/scan`
- Full-width outlined button → "🖼 Choose from Gallery" → image_picker → `/scan/processing`

**Recent Scans section:**
- Section title: "Recent Scans"
- If empty → centered card: fish icon + "No scans yet" + "Scan a fish to get started"
- If has scans → last 3 ScanResult tiles: thumbnail + species name + confidence + time ago

### ScanScreen (`/scan`)
- Full-screen `CameraPreview`
- `ScanFrameOverlay` (animated teal corner brackets, CustomPainter)
- Large circular capture button (bottom center)
- Gallery icon (top right)
- Hint: "Point camera at fish"

### ProcessingScreen (`/scan/processing`)
- Shows captured image + pulsing teal animation
- Runs pipeline: quality check → inference → DB lookup → save to Hive → navigate
- On quality fail: show SnackBar message, pop back

### ResultScreen (`/scan/result`)
- Full-width fish image
- Species common name (Syne Bold, large, white)
- Scientific name (italic, muted)
- No demo/mock banners — result screen always looks clean and professional
- Confidence badge: green >80% / gold 60–80% / coral <60%
- Low confidence warning banner if applicable
- Legal status chip: green=permitted / coral=protected / gold=seasonal
- Price: "₹MIN – ₹MAX / kg" in gold
- Regional names: Hindi · Tamil · Bengali
- Health advisory card
- Seasonal ban months highlighted (if any)
- Top-2 alternatives with confidence bars

### SpeciesGuideScreen (`/guide`)
- Search bar + filter chips: All · Freshwater · Marine · Brackish · Protected
- 2-column GridView of SpeciesCard

### SpeciesDetailScreen (`/guide/:id`)
- Same info as ResultScreen (no confidence/alternatives)
- Month calendar grid (highlight banned months)

### HistoryScreen (`/history`)
- ListView, swipe-to-delete, Clear All action
- Empty state: fish icon + "No scans yet"

### SettingsScreen (`/settings`)
- Language selector (EN / हिं / தமி / বাং)
- Voice toggle
- App info: version · model status (real/demo) · **26 species**

---

## 18. When Owner Adds the Model File

When `assets/model/fish_classifier_v1.tflite` is placed:

1. Add this line to `pubspec.yaml` under `flutter: assets:`:
   ```yaml
   - assets/model/fish_classifier_v1.tflite
   ```
2. Run `flutter pub get`
3. Run `flutter build apk --release`

**No code changes needed.** `InferenceService.initialize()` auto-detects the file and switches from mock to real inference.

---

## 19. Error Handling

| Scenario | Response |
|---|---|
| Model file missing | Auto-use mock silently — no banner shown |
| Image too dark/bright | SnackBar on ProcessingScreen, pop back |
| Low confidence (<60%) | Warning banner on ResultScreen |
| Camera permission denied | Show permission dialog |
| Camera failure | Error card + gallery fallback |
| Species not in DB | Show label, mark "Unknown species" |
| Hive error | Catch, clear box, show empty history |

---

## 20. Build Commands

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run                          # debug
flutter build apk --release          # release APK
flutter build appbundle --release    # Play Store
```

---

## 21. Performance Targets

| Metric | Target |
|---|---|
| Cold start | < 2 s |
| Inference (real model) | < 800 ms |
| Scan-to-result | < 2 s |
| DB query | < 50 ms |
| App size | < 40 MB |

---

## 22. Key Design Decisions

| Decision | Choice | Reason |
|---|---|---|
| State | Riverpod | `@riverpod` codegen, no BuildContext |
| Navigation | GoRouter + ShellRoute | Clean bottom nav + deep links |
| History | Hive | Fast key-value, typed adapters |
| Species DB | sqflite | Complex search across 26 species |
| Mock fallback | Built into InferenceService | App works before model is placed |
| Animations | flutter_animate | Declarative `.animate()` |

---

*FishTaxa · Flutter · Riverpod · Offline AI · 26 Verified North Indian River Species · Built for India's 3.5 million fishermen.*
