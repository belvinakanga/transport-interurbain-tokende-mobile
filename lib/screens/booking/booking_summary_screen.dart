import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  String get totalAmount {
    return _calculateTotal();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0A2A66),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Récapitulatif',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              color: Color(0xFFFF6B00),
              size: 55,
            ),

            const SizedBox(height: 12),

            const Text(
              'Vérifiez votre voyage',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF0A2A66),
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Vérifiez les informations avant de choisir '
                  'entre la réservation et l’achat.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // TRAJET
            // ==================================================

            _buildCard(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trajet',
                    style: TextStyle(
                      color: Color(0xFF0A2A66),
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3EB),
                          borderRadius:
                          BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.directions_bus_rounded,
                          color: Color(0xFFFF6B00),
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          agency,
                          style: const TextStyle(
                            color: Color(0xFF0A2A66),
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              departureTime,
                              style: const TextStyle(
                                color: Color(0xFF0A2A66),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              departure,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons.arrow_forward,
                        color: Color(0xFFFF6B00),
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.end,
                          children: [
                            Text(
                              arrivalTime,
                              style: const TextStyle(
                                color: Color(0xFF0A2A66),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              destination,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: Color(0xFFFF6B00),
                        size: 18,
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: Text(
                          'Départ : $departureDate',
                          style: const TextStyle(
                            color: Color(0xFF0A2A66),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // ==================================================
            // PASSAGERS
            // ==================================================

            _buildCard(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Passagers et sièges',
                    style: TextStyle(
                      color: Color(0xFF0A2A66),
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  for (int i = 0;
                  i < passengers.length;
                  i++) ...[
                    _buildPassengerCard(
                      passenger: passengers[i],
                      index: i,
                    ),

                    if (i < passengers.length - 1)
                      const SizedBox(height: 15),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 15),

            // ==================================================
            // PRIX
            // ==================================================

            _buildCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Prix par voyageur',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      Text(
                        price,
                        style: const TextStyle(
                          color: Color(0xFF0A2A66),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),
                  const Divider(),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Nombre de voyageurs',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      Text(
                        '$travelers',
                        style: const TextStyle(
                          color: Color(0xFF0A2A66),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),
                  const Divider(),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Total à payer',
                          style: TextStyle(
                            color: Color(0xFF0A2A66),
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Text(
                        totalAmount,
                        style: const TextStyle(
                          color: Color(0xFFFF6B00),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // RÉSERVER
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  _handleReservation(context);
                },
                icon: const Icon(
                  Icons.event_available_outlined,
                ),
                label: const Text(
                  'Réserver',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF0A2A66),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ==================================================
            // ACHETER
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showPurchaseConfirmation(context);
                },
                icon: const Icon(
                  Icons.payment_outlined,
                ),
                label: const Text(
                  'Acheter',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFFFF6B00),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            Row(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 15,
                  color: Colors.grey.shade600,
                ),

                const SizedBox(width: 5),

                const Text(
                  'Paiement sécurisé',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
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
                'pour un montant de $totalAmount.\n\n'
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
                '$totalAmount pour votre billet.\n\n'
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

  Widget _buildPassengerCard({
    required Map<String, dynamic> passenger,
    required int index,
  }) {
    final prenom =
        passenger['prenom']?.toString() ?? '';

    final nom =
        passenger['nom']?.toString() ?? '';

    final telephone =
        passenger['telephone']?.toString() ?? '';

    final email =
        passenger['email']?.toString() ?? '';

    final siege =
        passenger['siege']?.toString() ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3EB),
                  borderRadius:
                  BorderRadius.circular(10),
                ),

                child: const Icon(
                  Icons.person,
                  color: Color(0xFFFF6B00),
                  size: 21,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  'Passager ${index + 1}',
                  style: const TextStyle(
                    color: Color(0xFF0A2A66),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xFF0A2A66),
                  borderRadius:
                  BorderRadius.circular(8),
                ),

                child: Text(
                  'Siège $siege',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          _buildDetailRow(
            Icons.badge_outlined,
            'Nom complet',
            '$prenom $nom',
          ),

          const SizedBox(height: 10),

          _buildDetailRow(
            Icons.phone_outlined,
            'Téléphone',
            telephone,
          ),

          if (email.trim().isNotEmpty) ...[
            const SizedBox(height: 10),

            _buildDetailRow(
              Icons.email_outlined,
              'E-mail',
              email,
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // LIGNE DÉTAIL
  // ============================================================

  Widget _buildDetailRow(
      IconData icon,
      String title,
      String value,
      ) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFFFF6B00),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF0A2A66),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CALCUL TOTAL
  // ============================================================

  String _calculateTotal() {
    final cleanPrice = price
        .replaceAll('FCFA', '')
        .replaceAll(' ', '')
        .replaceAll(',', '');

    final priceValue =
        int.tryParse(cleanPrice) ?? 0;

    final total =
        priceValue * travelers;

    final formatted =
    total.toString();

    final buffer =
    StringBuffer();

    for (int i = 0;
    i < formatted.length;
    i++) {
      if (i > 0 &&
          (formatted.length - i) % 3 == 0) {
        buffer.write(' ');
      }

      buffer.write(formatted[i]);
    }

    return '${buffer.toString()} FCFA';
  }

  // ============================================================
  // CARD
  // ============================================================

  Widget _buildCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.05,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: child,
    );
  }
}