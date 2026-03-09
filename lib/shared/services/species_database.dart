import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/species.dart';
import '../services/inference_service.dart';

class SpeciesDatabase {
  static Database? _db;
  static final SpeciesDatabase instance = SpeciesDatabase._();

  SpeciesDatabase._();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'species.db');
    // Always overwrite from assets so updates are picked up immediately
    final data = await rootBundle.load('assets/db/species.db');
    final bytes = data.buffer.asUint8List();
    await File(path).writeAsBytes(bytes, flush: true);
    return openDatabase(path, readOnly: true);
  }

  Future<List<Species>> getAll() async {
    final db = await database;
    final maps = await db.query('species', orderBy: 'common_name_en ASC');
    return maps.map(Species.fromMap).toList();
  }

  Future<Species?> getById(int id) async {
    final db = await database;
    final maps = await db.query('species', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Species.fromMap(maps.first);
  }

  Future<List<Species>> search(String q) async {
    final db = await database;
    final lower = q.toLowerCase();
    final maps = await db.rawQuery('''
      SELECT * FROM species
      WHERE LOWER(common_name_en) LIKE ?
        OR LOWER(scientific_name) LIKE ?
        OR LOWER(label) LIKE ?
        OR LOWER(other_names) LIKE ?
      ORDER BY common_name_en ASC
    ''', ['%$lower%', '%$lower%', '%$lower%', '%$lower%']);
    return maps.map(Species.fromMap).toList();
  }

  Future<List<Species>> getProtected() async {
    final db = await database;
    final maps = await db.query(
      'species',
      where: "legal_status IN ('protected', 'seasonal')",
      orderBy: 'common_name_en ASC',
    );
    return maps.map(Species.fromMap).toList();
  }

  Future<Species?> getByLabel(String label) async {
    final id = InferenceService.labelToId[label];
    if (id == null) return null;
    return getById(id);
  }
}
