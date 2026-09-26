import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ============================================================
  // URL DE L'API LARAVEL
  // ============================================================

  static const String baseUrl =
      'http://127.0.0.1:8000/api';

  // ============================================================
  // RÉCUPÉRER LES TRAJETS
  // ============================================================

  static Future<List<dynamic>> getTrajets() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/trajets'),
        headers: {
          'Accept': 'application/json',
        },
      );

      // ========================================================
      // SUCCÈS
      // ========================================================

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          return data;
        }

        throw Exception(
          'Le serveur a renvoyé un format inattendu.',
        );
      }

      // ========================================================
      // ERREUR SERVEUR
      // ========================================================

      throw Exception(
        'Erreur serveur : ${response.statusCode}',
      );
    } catch (e) {
      // ========================================================
      // ERREUR DE CONNEXION
      // ========================================================

      throw Exception(
        'Impossible de contacter le serveur Laravel : $e',
      );
    }
  }
}