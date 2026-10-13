import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../services/tarif_service.dart';
import '../../widgets/tk/tk.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../home/home_screen.dart';
import 'payment_screen.dart';

class BookingSummaryScreen extends StatelessWidget {
  final int trajetId;

  final String agency;
  final String departure;
  final String destination;

  final String departureDate;
  final String departureTime;
  final String arrivalTime;

  final String price;

  final int travelers;

  final List<int> selectedSeats;

  final List<Map<String, dynamic>> passengers;

  static const FlutterSecureStorage _storage =
  FlutterSecureStorage();

  const BookingSummaryScreen({
    super.key,
    required this.trajetId,
    required this.agency,
    required this.departure,
    required this.destination,
    required this.departureDate,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.travelers,
    required this.selectedSeats,
    required this.passengers,
  });

  // ============================================================
  // URL API
  // ============================================================

  String get apiBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }

    return 'http://10.0.2.2:8000/api';
  }

  // ============================================================
  // DATE DU DÉPART
  // ============================================================

  DateTime? get departureDateTime {
    final parsed = DateTime.tryParse(
      '$departureDate $departureTime',
    );

    if (parsed != null) {
      return parsed;
    }

    final months = <String, int>{
      'janvier': 1,
      'février': 2,
      'fevrier': 2,
      'mars': 3,
      'avril': 4,
      'mai': 5,
      'juin': 6,
      'juillet': 7,
      'août': 8,
      'aout': 8,
      'septembre': 9,
      'octobre': 10,
      'novembre': 11,
      'décembre': 12,
      'decembre': 12,
    };

    final match = RegExp(
      r'^(\d{1,2})\s+([a-zA-Zéèêëàâîïôûùüç]+)\s+(\d{4})$',
      caseSensitive: false,
    ).firstMatch(
      departureDate.trim().toLowerCase(),
    );

    if (match == null) {
      return null;
    }

    final day = int.tryParse(match.group(1)!);
    final monthName = match.group(2)!;
    final year = int.tryParse(match.group(3)!);

    final month = months[monthName];

    if (day == null || month == null || year == null) {
      return null;
    }

    final timeParts = departureTime.split(':');

    final hour = int.tryParse(
      timeParts.isNotEmpty ? timeParts[0] : '0',
    ) ??
        0;

    final minute = int.tryParse(
      timeParts.length > 1 ? timeParts[1] : '0',
    ) ??
        0;

    return DateTime(
      year,
      month,
      day,
      hour,
      minute,
    );
  }

  // ============================================================
  // RÈGLE DES 72 HEURES
  // ============================================================
  //
  // IMPORTANT :
  //
  // Cette règle concerne UNIQUEMENT la réservation.
  //
  // >= 72 heures :
  //     Réservation possible
  //
  // < 72 heures :
  //     Réservation impossible
  //     Achat direct toujours possible
  //
  // ============================================================

  bool get reservationPossible {
    final departure = departureDateTime;

    if (departure == null) {
      return false;
    }

    final difference =
    departure.difference(DateTime.now());

    return difference.inSeconds >=
        const Duration(hours: 72).inSeconds;
  }

  // ============================================================
  // TOTAL
  // ============================================================

  /// Prix de l'agence, extrait de la chaîne reçue (« 15 000 FCFA »).
  double _prixUnitaire() {
    final nettoye = price
        .replaceAll('FCFA', '')
        .replaceAll('\u202F', '')
        .replaceAll(' ', '')
        .replaceAll(',', '');

    return double.tryParse(nettoye) ?? 0;
  }

  /// Total réellement débité, frais de service compris.
  ///
  /// Les messages de confirmation annonçaient auparavant le seul prix de
  /// l'agence, soit moins que la somme réellement prélevée.
  String get totalAvecFrais {
    final frais = TarifService.fraisParBillet * travelers;

    return TkMontantDetail.formater(_prixUnitaire() * travelers + frais);
  }


  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fond(context),

      body: SafeArea(
        child: Column(
          children: [

            // En-tête
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.margeEcran,
                AppSpacing.xs,
                AppSpacing.margeEcran,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  TkIconButton(
                    icone: Icons.arrow_back_rounded,
                    infobulle: 'Retour',
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Récapitulatif',
                      style: AppText.sousTitre(context),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.margeEcran,
                  AppSpacing.xs,
                  AppSpacing.margeEcran,
                  AppSpacing.lg,
                ),
                children: [

                  Text(
                    'Vérifiez votre voyage',
                    style: AppText.titre(context),
                  ),

                  const SizedBox(height: AppSpacing.xxs),

                  Text(
                    'Vérifiez les informations avant de choisir votre '
                    'mode de paiement.',
                    style: AppText.corps(context),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ----------------------------------------------
                  // TRAJET
                  // ----------------------------------------------

                  const TkSectionHeader(titre: 'Trajet'),

                  TkCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          agency,
                          style: AppText.corpsFort(context)
                              .copyWith(fontSize: 15),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        _etape(
                          context,
                          heure: departureTime,
                          ville: departure,
                          icone: Icons.trip_origin_rounded,
                        ),

                        Padding(
                          padding: const EdgeInsets.only(left: 7),
                          child: Container(
                            width: 2,
                            height: 22,
                            color: AppColors.inactifTheme(context),
                          ),
                        ),

                        _etape(
                          context,
                          heure: arrivalTime,
                          ville: destination,
                          icone: Icons.place_rounded,
                        ),

                        const SizedBox(height: AppSpacing.md),

                        Divider(
                          height: 1,
                          color: AppColors.inactifTheme(context),
                        ),

                        const SizedBox(height: AppSpacing.sm),

                        Row(
                          children: [
                            Icon(
                              Icons.event_rounded,
                              size: 14,
                              color: AppColors.secondaire(context),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Départ : $departureDate',
                              style: AppText.petit(context)
                                  .copyWith(fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ----------------------------------------------
                  // PASSAGERS
                  // ----------------------------------------------

                  TkSectionHeader(
                    titre: passengers.length > 1
                        ? 'Passagers et sièges'
                        : 'Passager et siège',
                  ),

                  for (var i = 0; i < passengers.length; i++) ...[
                    if (i > 0) const SizedBox(height: AppSpacing.xs),
                    _cartePassager(context, passengers[i], i),
                  ],

                  const SizedBox(height: AppSpacing.xl),

                  // ----------------------------------------------
                  // MONTANT
                  // ----------------------------------------------

                  const TkSectionHeader(titre: 'Montant'),

                  TkCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    // Le tarif vient du serveur ; le repli local évite une
                    // ligne de frais vide le temps de la réponse.
                    child: FutureBuilder<double>(
                      future: TarifService.charger(),
                      initialData: TarifService.fraisParBillet,
                      builder: (context, instantane) {
                        return TkMontantDetail(
                          prixUnitaire: _prixUnitaire(),
                          fraisParBillet:
                              instantane.data ?? TarifService.fraisParDefaut,
                          nombreBillets: travelers,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Mention de sécurité : elle rassure juste avant le
                  // paiement, pas en bas de page après les boutons.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 14,
                        color: AppColors.secondaire(context),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Paiement sécurisé',
                        style: AppText.petit(context).copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ----------------------------------------------------
            // ACTIONS
            // ----------------------------------------------------

            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.margeEcran,
                AppSpacing.sm,
                AppSpacing.margeEcran,
                AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.fond(context),
                border: Border(
                  top: BorderSide(color: AppColors.inactifTheme(context)),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  TkButton(
                    libelle: 'Acheter maintenant',
                    icone: Icons.shopping_bag_outlined,
                    onPressed: () => _showPurchaseConfirmation(context),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  TkButton(
                    libelle: 'Réserver',
                    variante: TkButtonVariante.tonal,
                    onPressed: () => _handleReservation(context),
                  ),

                  // La règle des 72 heures est annoncée ici plutôt que
                  // découverte au clic sur « Réserver ».
                  if (!reservationPossible) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'La réservation sans paiement n’est possible que '
                      'plus de 72 h avant le départ.',
                      textAlign: TextAlign.center,
                      style: AppText.petit(context).copyWith(fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BLOCS D'AFFICHAGE
  // ============================================================

  Widget _etape(
    BuildContext context, {
    required String heure,
    required String ville,
    required IconData icone,
  }) {
    return Row(
      children: [
        Icon(icone, size: 15, color: AppColors.orange),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 62,
          child: Text(
            heure,
            style: AppText.corpsFort(context).copyWith(fontSize: 17),
          ),
        ),
        Expanded(
          child: Text(
            ville,
            overflow: TextOverflow.ellipsis,
            style: AppText.corps(context).copyWith(fontSize: 15),
          ),
        ),
      ],
    );
  }


  Widget _cartePassager(
    BuildContext context,
    Map<String, dynamic> passenger,
    int index,
  ) {
    final prenom = passenger['prenom']?.toString() ?? '';
    final nom = passenger['nom']?.toString() ?? '';
    final telephone = passenger['telephone']?.toString() ?? '';
    final email = passenger['email']?.toString() ?? '';
    final siege = passenger['siege']?.toString() ?? '';

    final nomComplet = '$prenom $nom'.trim();

    return TkCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.orangeDoux(context),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.orange,
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.xs),

              Expanded(
                child: Text(
                  nomComplet.isEmpty ? 'Passager ${index + 1}' : nomComplet,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.corpsFort(context).copyWith(fontSize: 15),
                ),
              ),

              if (siege.isNotEmpty)
                TkChip(
                  libelle: 'Siège $siege',
                  ton: TkChipTon.accent,
                  icone: Icons.event_seat_outlined,
                ),
            ],
          ),

          if (telephone.isNotEmpty || email.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),

            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Wrap(
                spacing: AppSpacing.md,
                runSpacing: 4,
                children: [
                  if (telephone.isNotEmpty)
                    _contactPassager(
                      context,
                      Icons.phone_outlined,
                      telephone,
                    ),
                  if (email.isNotEmpty)
                    _contactPassager(
                      context,
                      Icons.mail_outline_rounded,
                      email,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _contactPassager(
    BuildContext context,
    IconData icone,
    String texte,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 13, color: AppColors.secondaire(context)),
        const SizedBox(width: 4),
        Text(
          texte,
          style: AppText.petit(context).copyWith(fontSize: 12),
        ),
      ],
    );
  }

  // ============================================================
  // RÉSERVATION
  // ============================================================

  Future<void> _handleReservation(
      BuildContext context,
      ) async {
    if (!reservationPossible) {
      _showReservationUnavailable(context);
      return;
    }

    _showReservationConfirmation(context);
  }

  // ============================================================
  // RÉSERVATION IMPOSSIBLE
  // ============================================================

  void _showReservationUnavailable(
      BuildContext context,
      ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(20),
          ),

          icon: const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFFF6B00),
            size: 45,
          ),

          title: const Text(
            'Réservation impossible',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF0A2A66),
              fontWeight: FontWeight.bold,
            ),
          ),

          content: const Text(
            'Vous êtes dans les 72 heures '
                'précédant le départ.\n\n'
                'La réservation est donc impossible. '
                'Vous pouvez uniquement acheter votre billet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              height: 1.5,
            ),
          ),

          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF0A2A66),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Fermer'),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // CONFIRMATION RÉSERVATION
  // ============================================================

  void _showReservationConfirmation(
      BuildContext context,
      ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(20),
          ),

          icon: const Icon(
            Icons.event_available_outlined,
            color: Color(0xFF0A2A66),
            size: 45,
          ),

          title: const Text(
            'Confirmer la réservation',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF0A2A66),
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Text(
            'Vous êtes sur le point de réserver '
                '$travelers '
                '${travelers > 1 ? 'places' : 'place'} '
                'pour un montant de $totalAvecFrais '
                  '(frais de service compris).\n\n'
                'Voulez-vous confirmer votre réservation ?',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              height: 1.5,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Annuler'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _createReservation(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFF0A2A66),
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // CRÉER RÉSERVATION
  // ============================================================

  Future<void> _createReservation(
      BuildContext context,
      ) async {
    _showLoadingDialog(
      context,
      'Création de votre réservation...',
    );

    try {
      final token =
      await _storage.read(key: 'auth_token');

      if (token == null || token.isEmpty) {
        if (!context.mounted) return;

        Navigator.pop(context);

        _showErrorDialog(
          context,
          'Vous devez être connecté pour '
              'effectuer une réservation.',
        );

        return;
      }

      final voyageurs =
      passengers.map((passenger) {
        return {
          'prenom':
          passenger['prenom']?.toString() ?? '',
          'nom':
          passenger['nom']?.toString() ?? '',
          'email':
          passenger['email']?.toString(),
          'telephone':
          passenger['telephone']?.toString(),
          'siege':
          int.tryParse(
            passenger['siege']?.toString() ?? '',
          ) ??
              0,
        };
      }).toList();

      final response = await http.post(
        Uri.parse(
          '$apiBaseUrl/reservations',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'trajet_id': trajetId,
          'nombre_places': travelers,
          'sieges': selectedSeats,
          'voyageurs': voyageurs,
        }),
      );

      if (!context.mounted) return;

      Navigator.pop(context);

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        _showReservationSuccess(
          context,
          response.body,
        );

        return;
      }

      String message =
          'La réservation n’a pas pu être effectuée.';

      try {
        final data = jsonDecode(response.body);

        if (data is Map &&
            data['message'] != null) {
          message =
              data['message'].toString();
        }
      } catch (_) {}

      _showErrorDialog(
        context,
        message,
      );
    } catch (e) {
      if (!context.mounted) return;

      Navigator.pop(context);

      _showErrorDialog(
        context,
        'Impossible de contacter le serveur Laravel.\n\n'
            'Vérifiez que Laravel est démarré.',
      );
    }
  }

  // ============================================================
  // SUCCÈS RÉSERVATION
  // ============================================================

  void _showReservationSuccess(
      BuildContext context,
      String responseBody,
      ) {
    int? reservationId;

    try {
      final data = jsonDecode(responseBody);

      if (data is Map &&
          data['data'] is Map) {
        reservationId = int.tryParse(
          data['data']['id']?.toString() ?? '',
        );
      }
    } catch (_) {}

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(20),
          ),

          icon: const Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 55,
          ),

          title: const Text(
            'Réservation confirmée',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF0A2A66),
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Text(
            reservationId != null
                ? 'Votre réservation a été enregistrée '
                'avec succès.\n\n'
                'Réservation N° $reservationId\n\n'
                'Vous pouvez maintenant retrouver '
                'votre réservation dans « Mes voyages » '
                'et effectuer le paiement lorsque vous '
                'êtes prêt.'
                : 'Votre réservation a été enregistrée '
                'avec succès.\n\n'
                'Vous pouvez maintenant retrouver '
                'votre réservation dans « Mes voyages » '
                'et effectuer le paiement lorsque vous '
                'êtes prêt.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              height: 1.5,
            ),
          ),

          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const HomeScreen(
                        initialIndex: 2,
                      ),
                    ),
                        (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF0A2A66),
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Voir mes réservations',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // CONFIRMATION ACHAT DIRECT
  // ============================================================

  void _showPurchaseConfirmation(
      BuildContext context,
      ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(20),
          ),

          icon: const Icon(
            Icons.payment_outlined,
            color: Color(0xFFFF6B00),
            size: 45,
          ),

          title: const Text(
            'Confirmer l’achat',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF0A2A66),
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Text(
            'Vous êtes sur le point de payer '
                '$totalAvecFrais pour votre billet, '
                  'frais de service compris.\n\n'
                'Voulez-vous continuer ?',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              height: 1.5,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Annuler'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                // ==================================================
                // IMPORTANT :
                //
                // L'achat direct est toujours possible,
                // même dans les 72 heures.
                //
                // Aucune réservation n'est créée ici.
                // ==================================================

                _goToPayment(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFFFF6B00),
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // PAIEMENT / ACHAT DIRECT
  // ============================================================
  //
  // IMPORTANT :
  //
  // Achat direct :
  //
  // ❌ aucun POST /reservations
  // ❌ aucune réservation temporaire
  // ❌ aucun reservation_id créé ici
  //
  // On ouvre directement PaymentScreen.
  //
  // MAIS :
  // Les informations des passagers saisies dans
  // Informations voyageurs sont transmises.
  //
  // ============================================================

  Future<void> _goToPayment(
      BuildContext context,
      ) async {
    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          trajetId: trajetId,

          // Achat direct :
          // aucune réservation.
          reservationId: null,

          // Indique à PaymentScreen
          // qu'il s'agit d'un achat direct.
          isPurchase: true,

          // Informations du voyage
          agency: agency,
          departure: departure,
          destination: destination,
          departureTime: departureTime,
          arrivalTime: arrivalTime,
          price: price,
          travelers: travelers,
          selectedSeats: selectedSeats,

          // =====================================================
          // CORRECTION IMPORTANTE
          // =====================================================
          //
          // On transmet les informations saisies
          // dans "Informations voyageurs".
          //
          // Ainsi PaymentScreen pourra ensuite
          // les envoyer à Laravel lors de l'achat.
          //
          passengers: passengers,
        ),
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  void _showLoadingDialog(
      BuildContext context,
      String message,
      ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          content: Row(
            children: [
              const SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Text(message),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // ERREUR
  // ============================================================

  void _showErrorDialog(
      BuildContext context,
      String message,
      ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(20),
          ),

          icon: const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 45,
          ),

          title: const Text(
            'Une erreur est survenue',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF0A2A66),
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              height: 1.5,
            ),
          ),

          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF0A2A66),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Fermer'),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // PASSAGER
  // ============================================================

}
