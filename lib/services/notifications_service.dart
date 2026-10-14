import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';

/// Une notification reçue par l'utilisateur.
class NotificationTokende {
  final int id;
  final String type;
  final String titre;
  final String corps;
  final Map<String, dynamic> donnees;
  final bool lue;
  final DateTime? recueLe;

  const NotificationTokende({
    required this.id,
    required this.type,
    required this.titre,
    required this.corps,
    required this.donnees,
    required this.lue,
    required this.recueLe,
  });

  static NotificationTokende? depuisJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! int) return null;

    final brut = json['donnees'];

    return NotificationTokende(
      id: id,
      type: (json['type'] ?? 'info').toString(),
      titre: (json['titre'] ?? '').toString(),
      corps: (json['corps'] ?? '').toString(),
      donnees: brut is Map<String, dynamic> ? brut : const {},
      lue: json['lue'] == true,
      recueLe: DateTime.tryParse((json['created_at'] ?? '').toString()),
    );
  }

  /// Identifiant de la conversation à ouvrir, s'il y en a une.
  int? get conversationId {
    final valeur = donnees['conversation_id'];
    if (valeur is int) return valeur;
    return int.tryParse(valeur?.toString() ?? '');
  }
}

/// Notifications de l'utilisateur connecté.
///
/// Elles viennent de la base du serveur, pas de Firebase : une alerte push
/// peut ne jamais arriver — téléphone éteint, autorisation refusée — alors
/// que la notification, elle, doit rester consultable.
class NotificationsService {
  const NotificationsService._();

  static const _stockage = FlutterSecureStorage();

  static Future<Map<String, String>> _entetes() async {
    final jeton = await _stockage.read(key: 'auth_token');

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (jeton != null) 'Authorization': 'Bearer $jeton',
    };
  }

  /// Liste des notifications, les plus récentes d'abord.
  static Future<List<NotificationTokende>> charger() async {
    final reponse = await http
        .get(
          Uri.parse('${AppConfig.baseUrl}/notifications'),
          headers: await _entetes(),
        )
        .timeout(const Duration(seconds: 15));

    if (reponse.statusCode != 200) return const [];

    final corps = jsonDecode(reponse.body);
    final liste = corps is Map ? corps['notifications'] : null;

    if (liste is! List) return const [];

    return [
      for (final element in liste)
        if (element is Map<String, dynamic>)
          ?NotificationTokende.depuisJson(element),
    ];
  }

  /// Nombre de notifications non lues. Renvoie 0 en cas d'échec.
  static Future<int> compterNonLues() async {
    try {
      final reponse = await http
          .get(
            Uri.parse('${AppConfig.baseUrl}/notifications/compteur'),
            headers: await _entetes(),
          )
          .timeout(const Duration(seconds: 10));

      if (reponse.statusCode != 200) return 0;

      final valeur = jsonDecode(reponse.body)['non_lues'];

      return valeur is num ? valeur.toInt() : 0;
    } catch (_) {
      // Une pastille absente vaut mieux qu'un écran en erreur.
      return 0;
    }
  }

  static Future<void> marquerLue(int id) async {
    await http.patch(
      Uri.parse('${AppConfig.baseUrl}/notifications/$id/lue'),
      headers: await _entetes(),
    );
  }

  static Future<void> toutMarquerLu() async {
    await http.post(
      Uri.parse('${AppConfig.baseUrl}/notifications/tout-lu'),
      headers: await _entetes(),
    );
  }

  /// Déclare l'appareil au serveur pour recevoir les alertes push.
  static Future<void> enregistrerAppareil(
    String jetonPush,
    String plateforme,
  ) async {
    await http.post(
      Uri.parse('${AppConfig.baseUrl}/appareils'),
      headers: await _entetes(),
      body: jsonEncode({
        'jeton_push': jetonPush,
        'plateforme': plateforme,
      }),
    );
  }

  /// Oublie l'appareil : à appeler à la déconnexion, sinon l'utilisateur
  /// suivant recevrait les notifications du précédent.
  static Future<void> oublierAppareil(String jetonPush) async {
    await http.delete(
      Uri.parse('${AppConfig.baseUrl}/appareils'),
      headers: await _entetes(),
      body: jsonEncode({'jeton_push': jetonPush}),
    );
  }
}
