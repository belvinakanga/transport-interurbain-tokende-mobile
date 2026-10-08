import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SupportService {
  // ⚠️ Remplace cette URL uniquement si ton URL API actuelle est différente.
  static const String baseUrl =
      'http://192.168.1.84:8000/api';

  Future<String?> _getToken() async {
    const storage = FlutterSecureStorage();

    return storage.read(
      key: 'auth_token',
    );
  }

  Future<Map<String, String>> _headers() async {
    final token = await _getToken();

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ------------------------------------------------------------
  // RÉCUPÉRER LES CONVERSATIONS
  // ------------------------------------------------------------

  Future<List<dynamic>> getConversations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/support/conversations'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data['conversations'] ?? [];
    }

    throw Exception(
      'Impossible de récupérer les conversations.',
    );
  }

  // ------------------------------------------------------------
  // CRÉER UNE NOUVELLE CONVERSATION
  // ------------------------------------------------------------

  Future<Map<String, dynamic>> createConversation({
    required String subject,
    required String message,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/support/conversations'),
      headers: await _headers(),
      body: jsonEncode({
        'subject': subject,
        'message': message,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Erreur ${response.statusCode}: ${response.body}',
    );
  }

  // ------------------------------------------------------------
  // RÉCUPÉRER UNE CONVERSATION
  // ------------------------------------------------------------

  Future<Map<String, dynamic>> getConversation(
      int conversationId,
      ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/support/conversations/$conversationId',
      ),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data['conversation'];
    }

    throw Exception(
      'Impossible de récupérer la conversation.',
    );
  }

  // ------------------------------------------------------------
  // ENVOYER UN MESSAGE
  // ------------------------------------------------------------

  Future<Map<String, dynamic>> sendMessage({
    required int conversationId,
    required String message,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/support/conversations/$conversationId/messages',
      ),
      headers: await _headers(),
      body: jsonEncode({
        'message': message,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);

      return data['message'];
    }

    throw Exception(
      'Erreur ${response.statusCode}: ${response.body}',
    );
  }
}