import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';

/// Un départ à venir, qu'il provienne d'une réservation ou d'un achat direct.
class ProchainVoyage {
  final String reference;
  final String depart;
  final String arrivee;
  final String nomAgence;
  final String adresseAgence;
  final DateTime dateHeureDepart;
  final String statut;
  final int nombrePlaces;

  /// Trajet brut, pour les libellés de date calculés par le backend.
  final Map<String, dynamic>? trajet;

  /// Numéro du billet émis, s'il existe déjà.
  final String? numeroBillet;

  /// Code du QR, émis en même temps que le billet.
  final String? qrCode;

  final List<String> voyageurs;
  final List<int> sieges;

  const ProchainVoyage({
    required this.reference,
    required this.depart,
    required this.arrivee,
    required this.nomAgence,
    required this.adresseAgence,
    required this.dateHeureDepart,
    required this.statut,
    required this.nombrePlaces,
    required this.trajet,
    required this.numeroBillet,
    required this.qrCode,
    required this.voyageurs,
    required this.sieges,
  });

  /// Vrai quand un billet a été émis et peut donc être présenté.
  bool get aUnBillet => (numeroBillet ?? '').isNotEmpty;

  /// Construit un voyage à partir d'une réservation renvoyée par l'API.
  ///
  /// Renvoie `null` si la charge utile n'a pas de trajet exploitable : mieux
  /// vaut ignorer une ligne incomplète que faire planter l'accueil.
  static ProchainVoyage? depuisJson(Map<String, dynamic> json) {
    // Un achat direct porte son trajet soit en racine, soit via sa réservation.
    final reservation = json['reservation'] as Map<String, dynamic>?;
    final trajet = (json['trajet'] ?? reservation?['trajet'])
        as Map<String, dynamic>?;

    if (trajet == null) return null;

    final quand = _lireDateHeure(
      trajet['date_depart']?.toString(),
      trajet['heure_depart']?.toString(),
    );

    if (quand == null) return null;

    final agence = trajet['agence'] as Map<String, dynamic>?;

    final billet = _premierBillet(json, reservation);

    return ProchainVoyage(
      reference: (json['reference_reservation'] ??
              json['reference'] ??
              reservation?['reference_reservation'] ??
              '')
          .toString(),
      depart: (trajet['depart'] ?? '').toString(),
      arrivee: (trajet['arrivee'] ?? '').toString(),
      nomAgence: (agence?['nom_agence'] ?? '').toString(),
      adresseAgence: (agence?['adresse'] ?? '').toString(),
      dateHeureDepart: quand,
      statut: (json['statut'] ?? reservation?['statut'] ?? '').toString(),
      nombrePlaces: int.tryParse(
            (json['nombre_places'] ?? reservation?['nombre_places'] ?? 1)
                .toString(),
          ) ??
          1,
      trajet: trajet,
      numeroBillet: billet?['numero_billet']?.toString(),
      qrCode: billet?['qr_code']?.toString(),
      voyageurs: _nomsVoyageurs(json, reservation),
      sieges: _numerosSieges(json, reservation),
    );
  }

  /// Premier billet émis pour cette réservation, s'il existe.
  static Map<String, dynamic>? _premierBillet(
    Map<String, dynamic> json,
    Map<String, dynamic>? reservation,
  ) {
    for (final source in [json, reservation]) {
      final brut = source?['billets'];

      if (brut is List) {
        for (final element in brut) {
          if (element is Map) return Map<String, dynamic>.from(element);
        }
      }

      // Laravel peut encapsuler la liste dans « data ».
      if (brut is Map && brut['data'] is List) {
        for (final element in brut['data'] as List) {
          if (element is Map) return Map<String, dynamic>.from(element);
        }
      }
    }

    return null;
  }

  static List<String> _nomsVoyageurs(
    Map<String, dynamic> json,
    Map<String, dynamic>? reservation,
  ) {
    final noms = <String>[];

    for (final source in [json, reservation]) {
      final brut = source?['voyageurs'];
      if (brut is! List) continue;

      for (final element in brut) {
        if (element is! Map) continue;

        final prenom = (element['prenom'] ?? '').toString().trim();
        final nom = (element['nom'] ?? '').toString().trim();
        final complet = '$prenom $nom'.trim();

        if (complet.isNotEmpty) noms.add(complet);
      }

      if (noms.isNotEmpty) break;
    }

    return noms;
  }

  static List<int> _numerosSieges(
    Map<String, dynamic> json,
    Map<String, dynamic>? reservation,
  ) {
    final numeros = <int>[];

    for (final source in [json, reservation]) {
      final brut = source?['sieges'];
      if (brut is! List) continue;

      for (final element in brut) {
        final valeur = element is Map
            ? element['numero_siege'] ?? element['numero']
            : element;

        final n = int.tryParse(valeur?.toString() ?? '');
        if (n != null) numeros.add(n);
      }

      if (numeros.isNotEmpty) break;
    }

    numeros.sort();
    return numeros;
  }

  /// Assemble `date_depart` (2026-10-12) et `heure_depart` (08:00:00).
  static DateTime? _lireDateHeure(String? date, String? heure) {
    if (date == null || date.isEmpty) return null;

    final jour = DateTime.tryParse(date);
    if (jour == null) return null;

    if (heure == null || heure.isEmpty) return jour;

    final morceaux = heure.split(':');
    final h = int.tryParse(morceaux.elementAtOrNull(0) ?? '') ?? 0;
    final m = int.tryParse(morceaux.elementAtOrNull(1) ?? '') ?? 0;

    return DateTime(jour.year, jour.month, jour.day, h, m);
  }

  /// Un voyage annulé ne doit pas être présenté comme le prochain départ.
  bool get estAnnule {
    final s = statut.trim().toLowerCase();
    return s == 'annulée' || s == 'annulee' || s == 'cancelled';
  }
}

/// Récupère le prochain départ de l'utilisateur.
///
/// Aucun endpoint dédié n'existe côté Laravel : le service interroge
/// `/reservations` et `/achats`, qui sont déjà filtrés par utilisateur,
/// puis retient le départ futur le plus proche.
class ProchainVoyageService {
  final FlutterSecureStorage _storage;

  ProchainVoyageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<ProchainVoyage?> charger() async {
    final token = await _storage.read(key: 'auth_token');

    if (token == null || token.isEmpty) return null;

    final entetes = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final reponses = await Future.wait([
      _lire('${AppConfig.baseUrl}/reservations', entetes),
      _lire('${AppConfig.baseUrl}/achats', entetes),
    ]);

    final maintenant = DateTime.now();

    final candidats = reponses
        .expand((liste) => liste)
        .map(ProchainVoyage.depuisJson)
        .nonNulls
        .where((v) => !v.estAnnule)
        .where((v) => v.dateHeureDepart.isAfter(maintenant))
        .toList()
      ..sort((a, b) => a.dateHeureDepart.compareTo(b.dateHeureDepart));

    return candidats.firstOrNull;
  }

  /// Lit une liste JSON en tolérant les deux formes rencontrées sur l'API :
  /// `{"data": [...]}` et un tableau nu.
  Future<List<Map<String, dynamic>>> _lire(
    String url,
    Map<String, String> entetes,
  ) async {
    try {
      final reponse = await http
          .get(Uri.parse(url), headers: entetes)
          .timeout(const Duration(seconds: 12));

      if (reponse.statusCode != 200) return const [];

      final decode = jsonDecode(reponse.body);

      final liste = decode is Map<String, dynamic>
          ? decode['data']
          : decode;

      if (liste is! List) return const [];

      return liste.whereType<Map<String, dynamic>>().toList();
    } catch (_) {
      // L'accueil doit s'afficher même sans réseau : on renvoie une liste vide
      // plutôt que de propager l'erreur.
      return const [];
    }
  }
}
