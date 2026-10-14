import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'notifications_service.dart';

/// Réception des notifications push.
///
/// Firebase ne fait que transporter l'alerte. La notification elle-même est
/// enregistrée côté serveur et reste consultable dans l'application : c'est
/// [NotificationsService] qui la lit.
///
/// Séparer les deux évite qu'une alerte perdue — téléphone éteint,
/// autorisation refusée, jeton périmé — fasse disparaître l'information.
class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Dernier jeton connu, conservé pour pouvoir l'oublier à la déconnexion.
  static String? _jeton;

  static String? get jeton => _jeton;

  /// Prévient l'application qu'une notification vient d'arriver, pour
  /// rafraîchir la pastille sans attendre.
  static final ValueNotifier<int> compteurNonLues = ValueNotifier<int>(0);

  static Future<void> initialize() async {
    final autorisation = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('Notifications : ${autorisation.authorizationStatus}');

    // Une alerte reçue pendant que l'application est ouverte doit mettre la
    // pastille à jour : l'utilisateur voit le badge bouger en direct.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Notification reçue : ${message.notification?.title}');
      rafraichirCompteur();
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      rafraichirCompteur();
    });

    _messaging.onTokenRefresh.listen(_enregistrer);
  }

  /// Déclare l'appareil au serveur. À appeler **après** la connexion :
  /// avant, la requête partirait sans jeton d'authentification.
  static Future<void> enregistrerAupresDuServeur() async {
    try {
      final jeton = await _messaging.getToken();

      if (jeton != null) await _enregistrer(jeton);
    } catch (e) {
      // Sans Firebase configuré, l'application reste utilisable : seules
      // les alertes hors application manquent.
      debugPrint('Jeton push indisponible : $e');
    }

    await rafraichirCompteur();
  }

  static Future<void> _enregistrer(String jeton) async {
    _jeton = jeton;

    try {
      await NotificationsService.enregistrerAppareil(
        jeton,
        defaultTargetPlatform.name,
      );
    } catch (e) {
      debugPrint('Appareil non enregistré : $e');
    }
  }

  /// Oublie l'appareil : sans cela, l'utilisateur suivant recevrait les
  /// notifications du précédent.
  static Future<void> oublier() async {
    final jeton = _jeton;
    if (jeton == null) return;

    try {
      await NotificationsService.oublierAppareil(jeton);
    } catch (_) {
      // Rien à faire : la déconnexion ne doit pas échouer pour autant.
    }

    _jeton = null;
    compteurNonLues.value = 0;
  }

  /// Relit le nombre de notifications non lues.
  static Future<void> rafraichirCompteur() async {
    compteurNonLues.value = await NotificationsService.compterNonLues();
  }
}
