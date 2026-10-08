import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Demander l'autorisation de recevoir les notifications
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint(
      'Autorisation notifications : ${settings.authorizationStatus}',
    );

    // Récupérer le token FCM de l'appareil
    try {
      final token = await _messaging.getToken();

      debugPrint('========================================');
      debugPrint('FCM TOKEN :');
      debugPrint(token);
      debugPrint('========================================');
    } catch (e) {
      debugPrint('Erreur récupération FCM Token : $e');
    }

    // Écouter les changements de token
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('Nouveau FCM TOKEN : $newToken');
    });

    // Notification reçue lorsque l'application est ouverte
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('========================================');
      debugPrint('NOTIFICATION REÇUE');
      debugPrint('Titre : ${message.notification?.title}');
      debugPrint('Message : ${message.notification?.body}');
      debugPrint('========================================');
    });
  }
}