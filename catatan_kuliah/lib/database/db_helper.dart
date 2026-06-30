import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/note.dart';

class DbHelper {
  static const String baseUrl = 'http://192.168.43.24/catatan_kuliah_api/api.php';

  Future<Map<String, dynamic>> register(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        body: jsonEncode({
          'action': 'register',
          'username': username,
          'password': password, 
        }),
        headers: {'Content-Type': 'application/json'},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        body: jsonEncode({
          'action': 'login',
          'username': username,
          'password': password,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<int?> getUserId(String username) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        body: jsonEncode({
          'action': 'get_user_id',
          'username': username,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return data['user_id'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

//buatcrud
  Future<Map<String, dynamic>> addNote(Note note) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        body: jsonEncode({
          'action': 'add_note',
          'user_id': note.userId,
          'mata_kuliah': note.mataKuliah,
          'dosen': note.dosen,
          'judul': note.judul,
          'materi': note.materi,
          'tanggal': note.tanggal,
          'kategori': note.kategori,
          'hari': note.hari,
          'jam': note.jam,
          'is_favorite': note.isFavorite ? 1 : 0,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<List<Note>> getNotes(int userId) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        body: jsonEncode({
          'action': 'get_notes',
          'user_id': userId,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List notesData = data['notes'] ?? [];
        return notesData.map((n) => Note.fromJson(n)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> updateNote(Note note) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        body: jsonEncode({
          'action': 'update_note',
          'id': note.id,
          'mata_kuliah': note.mataKuliah,
          'dosen': note.dosen,
          'judul': note.judul,
          'materi': note.materi,
          'tanggal': note.tanggal,
          'kategori': note.kategori,
          'hari': note.hari,
          'jam': note.jam,
          'is_favorite': note.isFavorite ? 1 : 0,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteNote(int id) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        body: jsonEncode({
          'action': 'delete_note',
          'id': id,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

//buat searching notes
  Future<List<Note>> searchNotes(int userId, String keyword) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        body: jsonEncode({
          'action': 'search_notes',
          'user_id': userId,
          'keyword': keyword,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List notesData = data['notes'] ?? [];
        return notesData.map((n) => Note.fromJson(n)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}