import 'package:flutter/foundation.dart';

class AppConfig {
  /// Adresse de l'API Laravel selon la plateforme.
  static String get baseUrl {
    // Chrome / Web
    if (kIsWeb) {
      return "http://127.0.0.1:8000/api";
    }

    // Émulateur Android
    return "http://10.0.2.2:8000/api";
  }

  /// Racine du site, sans le préfixe `/api`.
  ///
  /// Sert aux liens destinés à un navigateur — la page publique d'un
  /// billet, par exemple — qui ne passent pas par l'API.
  static String get siteUrl {
    return baseUrl.replaceFirst(RegExp(r'/api/?$'), '');
  }

  /// Page publique d'un billet, encodée dans son QR code.
  static String urlBillet(String qrCode) {
    return '$siteUrl/billet/$qrCode';
  }
}
