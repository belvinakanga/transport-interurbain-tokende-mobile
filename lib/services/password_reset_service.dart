import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

/// Erreur renvoyée par l'API de réinitialisation, porteuse d'un message
/// affichable tel quel à l'utilisateur.
class PasswordResetException implements Exception {
  final String message;

  const PasswordResetException(this.message);

  @override
  String toString() => message;
}

/// Appels à l'API de réinitialisation du mot de passe.
///
/// Trois étapes côté Laravel : demander un code, le vérifier, puis définir
/// le nouveau mot de passe.
class PasswordResetService {
  static const Duration _delai = Duration(seconds: 20);

  static Map<String, String> get _entetes => const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  /// Demande l'envoi d'un code à l'adresse indiquée.
  ///
  /// Renvoie la durée de validité annoncée par le serveur, en minutes.
  Future<int> demanderCode(String email) async {
    final reponse = await _envoyer(
      '/forgot-password',
      {'email': email.trim()},
    );

    final validite = reponse['validite_minutes'];

    return int.tryParse(validite?.toString() ?? '') ?? 15;
  }

  /// Vérifie le code sans encore changer le mot de passe.
  Future<void> verifierCode({
    required String email,
    required String code,
  }) async {
    await _envoyer('/verify-reset-code', {
      'email': email.trim(),
      'code': code.trim(),
    });
  }

  /// Définit le nouveau mot de passe.
  Future<String> reinitialiser({
    required String email,
    required String code,
    required String motDePasse,
    required String confirmation,
  }) async {
    final reponse = await _envoyer('/reset-password', {
      'email': email.trim(),
      'code': code.trim(),
      'password': motDePasse,
      'password_confirmation': confirmation,
    });

    return reponse['message']?.toString() ??
        'Mot de passe mis à jour.';
  }

  // ----------------------------------------------------------------

  Future<Map<String, dynamic>> _envoyer(
    String chemin,
    Map<String, dynamic> corps,
  ) async {
    final http.Response reponse;

    try {
      reponse = await http
          .post(
            Uri.parse('${AppConfig.baseUrl}$chemin'),
            headers: _entetes,
            body: jsonEncode(corps),
          )
          .timeout(_delai);
    } catch (_) {
      throw const PasswordResetException(
        'Connexion au serveur impossible. Vérifiez votre réseau.',
      );
    }

    Map<String, dynamic> donnees = {};

    try {
      final decode = jsonDecode(reponse.body);
      if (decode is Map<String, dynamic>) donnees = decode;
    } catch (_) {
      // Corps non JSON : on retombe sur un message générique plus bas.
    }

    if (reponse.statusCode >= 200 && reponse.statusCode < 300) {
      return donnees;
    }

    throw PasswordResetException(_messageErreur(donnees, reponse.statusCode));
  }

  /// Extrait le message le plus utile de la réponse d'erreur.
  ///
  /// Laravel renvoie `errors` en 422 ; on préfère le premier message de
  /// champ, plus précis que le message global.
  String _messageErreur(Map<String, dynamic> donnees, int code) {
    final erreurs = donnees['errors'];

    if (erreurs is Map && erreurs.isNotEmpty) {
      for (final valeur in erreurs.values) {
        if (valeur is List && valeur.isNotEmpty) {
          return valeur.first.toString();
        }
        if (valeur is String && valeur.isNotEmpty) return valeur;
      }
    }

    final message = donnees['message']?.toString();

    if (message != null && message.isNotEmpty) return message;

    if (code == 429) {
      return 'Trop de tentatives. Patientez avant de réessayer.';
    }

    return 'Une erreur est survenue. Réessayez.';
  }
}
