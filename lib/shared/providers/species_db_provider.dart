import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/species.dart';
import '../services/species_database.dart';

part 'species_db_provider.g.dart';

@riverpod
Future<List<Species>> allSpecies(AllSpeciesRef ref) =>
    SpeciesDatabase.instance.getAll();

@riverpod
Future<Species?> speciesById(SpeciesByIdRef ref, int id) =>
    SpeciesDatabase.instance.getById(id);

@riverpod
Future<List<Species>> speciesSearch(SpeciesSearchRef ref, String q) =>
    SpeciesDatabase.instance.search(q);
