import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

/// Référentiel des villes desservies, lu depuis l'API.
///
/// La liste était écrite en dur dans l'application : une ville ajoutée par
/// une agence depuis le back-office restait invisible aux voyageurs. Elle
/// vient maintenant du serveur, avec repli local si le réseau manque.
class VillesService {
  /// Villes connues avant l'existence du référentiel côté serveur.
  ///
  /// Sert uniquement de repli : sans réseau, le sélecteur reste utilisable.
  static const List<String> villesParDefaut = [
    'Brazzaville',
    'Pointe-Noire',
    'Dolisie',
    'Nkayi',
    'Oyo',
    'Ouesso',
    'Impfondo',
  ];

  /// Cache mémoire : la liste bouge rarement, inutile de la redemander
  /// à chaque ouverture du sélecteur.
  static List<String>? _cache;

  /// Vide le cache, pour forcer une relecture.
  static void viderCache() => _cache = null;

  /// Liste des villes, du serveur si possible.
  static Future<List<String>> charger() async {
    final enCache = _cache;
    if (enCache != null) return enCache;

    try {
      final reponse = await http
          .get(
            Uri.parse('${AppConfig.baseUrl}/villes'),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (reponse.statusCode == 200) {
        final decode = jsonDecode(reponse.body);

        final brut = decode is Map<String, dynamic>
            ? decode['data']
            : decode;

        if (brut is List) {
          final villes = brut
              .map((v) => v?.toString().trim() ?? '')
              .where((v) => v.isNotEmpty)
              .toList();

          if (villes.isNotEmpty) {
            _cache = villes;
            return villes;
          }
        }
      }
    } catch (_) {
      // Réseau indisponible : on retombe sur la liste intégrée.
    }

    return villesParDefaut;
  }
}
