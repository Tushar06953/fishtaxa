// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inference_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$inferenceHash() => r'85281563f5777b89500510102f14322db8f8af80';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [inference].
@ProviderFor(inference)
const inferenceProvider = InferenceFamily();

/// See also [inference].
class InferenceFamily extends Family<AsyncValue<List<PredictionResult>>> {
  /// See also [inference].
  const InferenceFamily();

  /// See also [inference].
  InferenceProvider call(
    String imagePath,
  ) {
    return InferenceProvider(
      imagePath,
    );
  }

  @override
  InferenceProvider getProviderOverride(
    covariant InferenceProvider provider,
  ) {
    return call(
      provider.imagePath,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'inferenceProvider';
}

/// See also [inference].
class InferenceProvider
    extends AutoDisposeFutureProvider<List<PredictionResult>> {
  /// See also [inference].
  InferenceProvider(
    String imagePath,
  ) : this._internal(
          (ref) => inference(
            ref as InferenceRef,
            imagePath,
          ),
          from: inferenceProvider,
          name: r'inferenceProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$inferenceHash,
          dependencies: InferenceFamily._dependencies,
          allTransitiveDependencies: InferenceFamily._allTransitiveDependencies,
          imagePath: imagePath,
        );

  InferenceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.imagePath,
  }) : super.internal();

  final String imagePath;

  @override
  Override overrideWith(
    FutureOr<List<PredictionResult>> Function(InferenceRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: InferenceProvider._internal(
        (ref) => create(ref as InferenceRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        imagePath: imagePath,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<PredictionResult>> createElement() {
    return _InferenceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InferenceProvider && other.imagePath == imagePath;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, imagePath.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin InferenceRef on AutoDisposeFutureProviderRef<List<PredictionResult>> {
  /// The parameter `imagePath` of this provider.
  String get imagePath;
}

class _InferenceProviderElement
    extends AutoDisposeFutureProviderElement<List<PredictionResult>>
    with InferenceRef {
  _InferenceProviderElement(super.provider);

  @override
  String get imagePath => (origin as InferenceProvider).imagePath;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
