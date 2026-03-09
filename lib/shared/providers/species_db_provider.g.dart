// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'species_db_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allSpeciesHash() => r'e5efa32cc536c6d97a5a5a5e89db0438845b5848';

/// See also [allSpecies].
@ProviderFor(allSpecies)
final allSpeciesProvider = AutoDisposeFutureProvider<List<Species>>.internal(
  allSpecies,
  name: r'allSpeciesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allSpeciesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllSpeciesRef = AutoDisposeFutureProviderRef<List<Species>>;
String _$speciesByIdHash() => r'764ff4e18212e7233338ead26c367ffc74ce62a8';

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

/// See also [speciesById].
@ProviderFor(speciesById)
const speciesByIdProvider = SpeciesByIdFamily();

/// See also [speciesById].
class SpeciesByIdFamily extends Family<AsyncValue<Species?>> {
  /// See also [speciesById].
  const SpeciesByIdFamily();

  /// See also [speciesById].
  SpeciesByIdProvider call(
    int id,
  ) {
    return SpeciesByIdProvider(
      id,
    );
  }

  @override
  SpeciesByIdProvider getProviderOverride(
    covariant SpeciesByIdProvider provider,
  ) {
    return call(
      provider.id,
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
  String? get name => r'speciesByIdProvider';
}

/// See also [speciesById].
class SpeciesByIdProvider extends AutoDisposeFutureProvider<Species?> {
  /// See also [speciesById].
  SpeciesByIdProvider(
    int id,
  ) : this._internal(
          (ref) => speciesById(
            ref as SpeciesByIdRef,
            id,
          ),
          from: speciesByIdProvider,
          name: r'speciesByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$speciesByIdHash,
          dependencies: SpeciesByIdFamily._dependencies,
          allTransitiveDependencies:
              SpeciesByIdFamily._allTransitiveDependencies,
          id: id,
        );

  SpeciesByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  Override overrideWith(
    FutureOr<Species?> Function(SpeciesByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SpeciesByIdProvider._internal(
        (ref) => create(ref as SpeciesByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Species?> createElement() {
    return _SpeciesByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SpeciesByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SpeciesByIdRef on AutoDisposeFutureProviderRef<Species?> {
  /// The parameter `id` of this provider.
  int get id;
}

class _SpeciesByIdProviderElement
    extends AutoDisposeFutureProviderElement<Species?> with SpeciesByIdRef {
  _SpeciesByIdProviderElement(super.provider);

  @override
  int get id => (origin as SpeciesByIdProvider).id;
}

String _$speciesSearchHash() => r'572d11167e77222431d65dfecea861cfe5b3fe55';

/// See also [speciesSearch].
@ProviderFor(speciesSearch)
const speciesSearchProvider = SpeciesSearchFamily();

/// See also [speciesSearch].
class SpeciesSearchFamily extends Family<AsyncValue<List<Species>>> {
  /// See also [speciesSearch].
  const SpeciesSearchFamily();

  /// See also [speciesSearch].
  SpeciesSearchProvider call(
    String q,
  ) {
    return SpeciesSearchProvider(
      q,
    );
  }

  @override
  SpeciesSearchProvider getProviderOverride(
    covariant SpeciesSearchProvider provider,
  ) {
    return call(
      provider.q,
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
  String? get name => r'speciesSearchProvider';
}

/// See also [speciesSearch].
class SpeciesSearchProvider extends AutoDisposeFutureProvider<List<Species>> {
  /// See also [speciesSearch].
  SpeciesSearchProvider(
    String q,
  ) : this._internal(
          (ref) => speciesSearch(
            ref as SpeciesSearchRef,
            q,
          ),
          from: speciesSearchProvider,
          name: r'speciesSearchProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$speciesSearchHash,
          dependencies: SpeciesSearchFamily._dependencies,
          allTransitiveDependencies:
              SpeciesSearchFamily._allTransitiveDependencies,
          q: q,
        );

  SpeciesSearchProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.q,
  }) : super.internal();

  final String q;

  @override
  Override overrideWith(
    FutureOr<List<Species>> Function(SpeciesSearchRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SpeciesSearchProvider._internal(
        (ref) => create(ref as SpeciesSearchRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        q: q,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Species>> createElement() {
    return _SpeciesSearchProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SpeciesSearchProvider && other.q == q;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, q.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SpeciesSearchRef on AutoDisposeFutureProviderRef<List<Species>> {
  /// The parameter `q` of this provider.
  String get q;
}

class _SpeciesSearchProviderElement
    extends AutoDisposeFutureProviderElement<List<Species>>
    with SpeciesSearchRef {
  _SpeciesSearchProviderElement(super.provider);

  @override
  String get q => (origin as SpeciesSearchProvider).q;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
