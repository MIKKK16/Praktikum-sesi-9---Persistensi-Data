// Semua logika penyimpanan dipisah dari UI (AI Challenge, checklist no. 3).
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/pizza.dart';

class LocalStorageService {
  static const _counterKey = 'appCounter';
  static const _tokenKey = 'userToken';
  static const _pizzaFileName = 'pizzas.json';

  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  // ---------------------------------------------------------------- JSON ---

  /// Membaca asset JSON lalu mengubahnya menjadi List<Pizza>.
  /// Tidak pernah melempar exception: JSON korup menghasilkan list kosong.
  Future<List<Pizza>> loadPizzasFromAsset(String assetPath) async {
    try {
      final raw = await rootBundle.loadString(assetPath);
      return parsePizzas(raw);
    } catch (_) {
      return [];
    }
  }

  /// String JSON -> List<Pizza>. Elemen yang bukan Map dilewati.
  List<Pizza> parsePizzas(String source) {
    try {
      final decoded = jsonDecode(source);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(Pizza.fromJson)
          .toList();
    } on FormatException {
      // JSON rusak (misalnya kurung kurawal hilang).
      return [];
    }
  }

  /// List<Pizza> -> String JSON (toJson per item, lalu jsonEncode sekali).
  String convertToJson(List<Pizza> pizzas) {
    return jsonEncode(pizzas.map((p) => p.toJson()).toList());
  }

  // --------------------------------------------------- SharedPreferences ---

  Future<int> getAppCounter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_counterKey) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> saveAppCounter(int value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_counterKey, value);
    } catch (_) {
      // Gagal menyimpan counter tidak boleh membuat aplikasi crash.
    }
  }

  /// Baca counter, tambah 1, simpan, kembalikan nilai baru (Praktikum 4).
  Future<int> incrementAppCounter() async {
    final next = await getAppCounter() + 1;
    await saveAppCounter(next);
    return next;
  }

  Future<void> resetPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (_) {}
  }

  // -------------------------------------------------------- path_provider ---

  Future<String> getDocumentsPath() async =>
      (await getApplicationDocumentsDirectory()).path;

  Future<String> getTempPath() async =>
      (await getTemporaryDirectory()).path;

  // ------------------------------------------------------- File (dart:io) ---

  Future<File> _pizzaFile() async {
    final dir = await getDocumentsPath();
    return File('$dir/$_pizzaFileName');
  }

  /// Menulis daftar pizza sebagai JSON ke file. true bila berhasil.
  Future<bool> writePizzaFile(List<Pizza> pizzas) async {
    try {
      final file = await _pizzaFile();
      await file.writeAsString(convertToJson(pizzas));
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Membaca file pizza. Mengembalikan list kosong bila file belum ada/rusak.
  Future<List<Pizza>> readPizzaFile() async {
    try {
      final file = await _pizzaFile();
      if (!await file.exists()) return [];
      return parsePizzas(await file.readAsString());
    } catch (_) {
      return [];
    }
  }

  // -------------------------------------------------------- Secure storage ---

  Future<bool> saveUserToken(String token) async {
    try {
      await _secure.write(key: _tokenKey, value: token);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String> getUserToken() async {
    try {
      return await _secure.read(key: _tokenKey) ?? '';
    } catch (_) {
      return '';
    }
  }
}
