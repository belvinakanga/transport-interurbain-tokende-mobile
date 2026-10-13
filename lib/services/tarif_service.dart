import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

/// Frais de service appliqués à chaque billet.
///
/// Lus sur le serveur plutôt qu'écrits en dur : le tarif peut changer sans
/// nouvelle version de l'application, et l'écran ne peut plus annoncer un
/// total différent de celui qui sera débité.
///
/// Même principe que [VillesService] : une seule lecture, mise en cache,
/// avec un repli local pour que l'écran reste utilisable hors ligne.
class TarifService {
  const TarifService._();

  /// Valeur de repli, alignée sur `TOKENDE_FRAIS_PAR_BILLET` côté serveur.
  ///
  /// Sert uniquement si l'API est injoignable : mieux vaut afficher le
  /// tarif courant que masquer la ligne de frais.
  static const double fraisParDefaut = 100;

  static double? _cache;

  /// Dernière valeur connue, sans appel réseau.
  static double get fraisParBillet => _cache ?? fraisParDefaut;

  static void viderCache() => _cache = null;

  /// Récupère le tarif. Renvoie le repli en cas d'échec.
  static Future<double> charger() async {
    if (_cache != null) return _cache!;

    try {
      final reponse = await http
          .get(
            Uri.parse('${AppConfig.baseUrl}/tarification'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (reponse.statusCode == 200) {
        final corps = jsonDecode(reponse.body);
        final valeur = corps is Map ? corps['frais_service_par_billet'] : null;

        if (valeur is num) {
          _cache = valeur.toDouble();
          return _cache!;
        }
      }
    } catch (_) {
      // Réseau indisponible : on garde le repli.
    }

    return fraisParDefaut;
  }
}
