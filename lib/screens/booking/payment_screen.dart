import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../home/home_screen.dart';

class PaymentScreen extends StatefulWidget {
  // ============================================================
  // IDENTIFIANTS BACKEND
  // ============================================================

  final int trajetId;

  final int? reservationId;

  // true  = achat direct
  // false = paiement d'une réservation
  final bool isPurchase;

  // ============================================================
  // INFORMATIONS DU VOYAGE
  // ============================================================

  final String agency;
  final String departure;
  final String destination;
  final String departureTime;
  final String arrivalTime;
  final String price;
  final int travelers;
  final List<int> selectedSeats;

  // ============================================================
  // INFORMATIONS VOYAGEURS
  // ============================================================

  final List<Map<String, dynamic>> passengers;

  const PaymentScreen({
    super.key,
    required this.trajetId,
    this.reservationId,
    this.isPurchase = false,
    required this.agency,
    required this.departure,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.travelers,
    required this.selectedSeats,
    this.passengers = const [],
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // ============================================================
  // STOCKAGE
  // ============================================================

  static const FlutterSecureStorage _storage =
  FlutterSecureStorage();

  // ============================================================
  // ÉTAT
  // ============================================================

  String selectedPaymentMethod = 'mobile_money';

  // OpenPay
  final TextEditingController _phoneController = TextEditingController();
  String _selectedProvider = 'MTN'; // MTN | AIRTEL
  bool _useOpenPay = true;

  bool _isProcessing = false;

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
  // BUILD
  // ============================================================

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0A2A66),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Paiement',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ======================================================
            // TITRE
            // ======================================================

            Text(
              widget.isPurchase
                  ? 'Finalisez votre achat'
                  : 'Finalisez votre réservation',

              style: const TextStyle(
                color: Color(0xFF0A2A66),
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              widget.isPurchase
                  ? 'Finalisez l’achat de votre billet.'
                  : 'Effectuez le paiement de votre réservation.',

              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 25),

            // ======================================================
            // RÉSUMÉ
            // ======================================================

            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    'Résumé',
                    style: TextStyle(
                      color: Color(0xFF0A2A66),
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [

                      const Icon(
                        Icons.directions_bus_rounded,
                        color: Color(0xFFFF6B00),
                        size: 28,
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          widget.agency,
                          style: const TextStyle(
                            color: Color(0xFF0A2A66),
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  _buildInfoRow(
                    Icons.route_outlined,
                    'Trajet',
                    '${widget.departure} → ${widget.destination}',
                  ),

                  _buildInfoRow(
                    Icons.access_time,
                    'Horaire',
                    '${widget.departureTime} - ${widget.arrivalTime}',
                  ),

                  _buildInfoRow(
                    Icons.people_outline,
                    'Voyageurs',
                    widget.travelers == 1
                        ? '1 voyageur'
                        : '${widget.travelers} voyageurs',
                  ),

                  _buildInfoRow(
                    Icons.event_seat_outlined,
                    'Sièges',
                    widget.selectedSeats
                        .map((seat) => 'N° $seat')
                        .join(', '),
                  ),

                  if (widget.reservationId != null)
                    _buildInfoRow(
                      Icons.confirmation_number_outlined,
                      'Réservation',
                      'N° ${widget.reservationId}',
                    ),

                  // ==================================================
                  // VOYAGEURS
                  // ==================================================

                  if (widget.passengers.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Divider(height: 25),

                    const Text(
                      'Voyageurs',
                      style: TextStyle(
                        color: Color(0xFF0A2A66),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ...List.generate(
                      widget.passengers.length,
                          (index) {
                        final passenger =
                        widget.passengers[index];

                        final prenom =
                        _getPassengerString(
                          passenger,
                          [
                            'prenom',
                            'prénom',
                            'firstName',
                            'firstname',
                            'first_name',
                          ],
                        );

                        final nom =
                        _getPassengerString(
                          passenger,
                          [
                            'nom',
                            'lastName',
                            'lastname',
                            'last_name',
                          ],
                        );

                        dynamic siege =
                        passenger['siege'];

                        siege ??=
                        passenger['seat'];

                        siege ??=
                        passenger['seatNumber'];

                        siege ??=
                        passenger['seat_number'];

                        if (siege == null &&
                            index <
                                widget.selectedSeats.length) {
                          siege =
                          widget.selectedSeats[index];
                        }

                        return Padding(
                          padding:
                          const EdgeInsets.only(
                            bottom: 8,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                color:
                                Color(0xFFFF6B00),
                                size: 20,
                              ),

                              const SizedBox(width: 8),

                              Expanded(
                                child: Text(
                                  '$prenom $nom',
                                  style:
                                  const TextStyle(
                                    color:
                                    Color(0xFF0A2A66),
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),
                              ),

                              Text(
                                'Siège $siege',
                                style:
                                const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],

                  const Divider(height: 25),

                  Row(
                    children: [

                      const Expanded(
                        child: Text(
                          'Montant à payer',
                          style: TextStyle(
                            color: Color(0xFF0A2A66),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Text(
                        _calculateTotal(),
                        style: const TextStyle(
                          color: Color(0xFFFF6B00),
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ======================================================
            // MOYEN DE PAIEMENT
            // ======================================================

            const Text(
              'Moyen de paiement',
              style: TextStyle(
                color: Color(0xFF0A2A66),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            _buildPaymentMethod(
              value: 'mobile_money',
              icon: Icons.phone_android,
              title: 'Mobile Money',
              subtitle: 'Payer avec votre téléphone',
            ),

            const SizedBox(height: 12),

            _buildPaymentMethod(
              value: 'card',
              icon: Icons.credit_card_outlined,
              title: 'Carte bancaire',
              subtitle: 'Visa ou Mastercard',
            ),

            const SizedBox(height: 25),

            // ======================================================
            // INFORMATIONS PAIEMENT
            // ======================================================

            if (selectedPaymentMethod == 'mobile_money') ...[
              const Text(
                'Détails Mobile Money (OpenPay)',
                style: TextStyle(
                  color: Color(0xFF0A2A66),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Numéro de téléphone (format 242XXXXXXXXX)',
                  hintText: '242066203420',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('MTN Money'),
                      value: 'MTN',
                      groupValue: _selectedProvider,
                      onChanged: (v) {
                        if (v != null && mounted) setState(() => _selectedProvider = v);
                      },
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Airtel Money'),
                      value: 'AIRTEL',
                      groupValue: _selectedProvider,
                      onChanged: (v) {
                        if (v != null && mounted) setState(() => _selectedProvider = v);
                      },
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],

            if (selectedPaymentMethod == 'card')
              _buildCardPaymentSection(),

            const SizedBox(height: 30),

            // ======================================================
            // BOUTON
            // ======================================================

            SizedBox(
              width: double.infinity,
              height: 58,

              child: ElevatedButton.icon(
                onPressed:
                _isProcessing
                    ? null
                    : _confirmPayment,

                icon: _isProcessing
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
                    : const Icon(
                  Icons.lock_outline,
                ),

                label: Text(
                  _isProcessing
                      ? 'Traitement...'
                      : 'Confirmer le paiement',

                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFFFF6B00),

                  foregroundColor: Colors.white,

                  disabledBackgroundColor:
                  Colors.grey,

                  elevation: 3,

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            const Row(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [

                Icon(
                  Icons.lock_outline,
                  size: 15,
                  color: Colors.grey,
                ),

                SizedBox(width: 5),

                Text(
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
  // MOYEN DE PAIEMENT
  // ============================================================

  Widget _buildPaymentMethod({
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final bool isSelected =
        selectedPaymentMethod == value;

    return GestureDetector(
      onTap: () {
        if (_isProcessing) return;

        setState(() {
          selectedPaymentMethod = value;
        });
      },

      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
          BorderRadius.circular(18),

          border: Border.all(
            color: isSelected
                ? const Color(0xFFFF6B00)
                : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.04,
              ),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: Row(
          children: [

            Container(
              width: 48,
              height: 48,

              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFFF3EB)
                    : const Color(0xFFF1F3F7),

                borderRadius:
                BorderRadius.circular(14),
              ),

              child: Icon(
                icon,
                color: isSelected
                    ? const Color(0xFFFF6B00)
                    : const Color(0xFF0A2A66),
                size: 26,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF0A2A66),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,

              color: isSelected
                  ? const Color(0xFFFF6B00)
                  : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MOBILE MONEY
  // ============================================================

  Widget _buildMobileMoneySection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          const Text(
            'Paiement Mobile Money',
            style: TextStyle(
              color: Color(0xFF0A2A66),
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Saisissez le numéro associé à votre compte.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 18),

          TextField(
            keyboardType:
            TextInputType.phone,

            decoration: InputDecoration(
              labelText:
              'Numéro de téléphone',

              hintText:
              'Ex : 06 123 45 67',

              prefixIcon:
              const Icon(
                Icons.phone_outlined,
                color: Color(0xFFFF6B00),
              ),

              border:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(14),
              ),

              focusedBorder:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(14),

                borderSide:
                const BorderSide(
                  color:
                  Color(0xFFFF6B00),
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CARTE BANCAIRE
  // ============================================================

  Widget _buildCardPaymentSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          const Text(
            'Carte bancaire',
            style: TextStyle(
              color: Color(0xFF0A2A66),
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          TextField(
            keyboardType:
            TextInputType.number,

            decoration: InputDecoration(
              labelText:
              'Numéro de carte',

              hintText:
              '1234 5678 9012 3456',

              prefixIcon:
              const Icon(
                Icons.credit_card_outlined,
                color: Color(0xFFFF6B00),
              ),

              border:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 15),

          Row(
            children: [

              Expanded(
                child: TextField(
                  keyboardType:
                  TextInputType.number,

                  decoration:
                  InputDecoration(
                    labelText:
                    'Expiration',

                    hintText:
                    'MM/AA',

                    border:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: TextField(
                  keyboardType:
                  TextInputType.number,

                  obscureText: true,

                  decoration:
                  InputDecoration(
                    labelText: 'CVV',

                    hintText: '123',

                    border:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONFIRMATION DU PAIEMENT
  // ============================================================

  void _confirmPayment() {
    if (_isProcessing) return;

    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(20),
          ),

          icon: const Icon(
            Icons.payment_outlined,
            color: Color(0xFFFF6B00),
            size: 45,
          ),

          title: const Text(
            'Confirmer le paiement',
            textAlign: TextAlign.center,

            style: TextStyle(
              color: Color(0xFF0A2A66),
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Text(
            'Vous êtes sur le point de payer '
                '${_calculateTotal()} '
                'pour votre '
                '${widget.isPurchase ? 'billet' : 'réservation'}.\n\n'
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
                Navigator.pop(
                  dialogContext,
                );
              },

              child: const Text(
                'Annuler',

                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );

                _processPayment();
              },

              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFFFF6B00),
                foregroundColor:
                Colors.white,
              ),

              child:
              const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // TRAITEMENT DU PAIEMENT
  // ============================================================

  Future<void> _processPayment() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // ========================================================
      // TOKEN
      // ========================================================

      final token =
      await _storage.read(
        key: 'auth_token',
      );

      if (token == null ||
          token.trim().isEmpty) {
        _showError(
          'Votre session a expiré. '
              'Veuillez vous reconnecter.',
        );

        return;
      }
      // ========================================================
      // VALIDATION TÉLÉPHONE (OpenPay)
      // ========================================================

      if (selectedPaymentMethod == 'mobile_money') {
        final phone = _phoneController.text.trim();
        if (phone.isEmpty) {
          _showError('Veuillez saisir votre numéro de téléphone.');
          return;
        }
        if (!phone.startsWith('242') || phone.length < 12) {
          _showError('Numéro invalide. Utiliser le format 242XXXXXXXXX.');
          return;
        }
      }



      // ========================================================
      // DONNÉES
      // ========================================================

      Map<String, dynamic> data;

      // ========================================================
      // ACHAT DIRECT
      // ========================================================

      if (widget.isPurchase) {
        if (widget.trajetId <= 0) {
          _showError(
            'Le trajet sélectionné est invalide.',
          );

          return;
        }

        if (widget.travelers <= 0) {
          _showError(
            'Le nombre de voyageurs est invalide.',
          );

          return;
        }

        if (widget.selectedSeats.length !=
            widget.travelers) {
          _showError(
            'Le nombre de sièges sélectionnés '
                'ne correspond pas au nombre de voyageurs.',
          );

          return;
        }

        // ======================================================
        // VOYAGEURS
        // ======================================================

        if (widget.passengers.length !=
            widget.travelers) {
          _showError(
            'Les informations des voyageurs '
                'sont incomplètes.\n\n'
                'Veuillez revenir à l’étape '
                'Informations voyageurs.',
          );

          return;
        }

        final List<Map<String, dynamic>>
        voyageurs = [];

        for (
        int i = 0;
        i < widget.passengers.length;
        i++
        ) {
          final passenger =
          widget.passengers[i];

          // ----------------------------------------------------
          // PRÉNOM
          // ----------------------------------------------------

          final String prenom =
          _getPassengerString(
            passenger,
            [
              'prenom',
              'prénom',
              'firstName',
              'firstname',
              'first_name',
            ],
          );

          // ----------------------------------------------------
          // NOM
          // ----------------------------------------------------

          final String nom =
          _getPassengerString(
            passenger,
            [
              'nom',
              'lastName',
              'lastname',
              'last_name',
            ],
          );

          // ----------------------------------------------------
          // EMAIL
          // ----------------------------------------------------

          final String email =
          _getPassengerString(
            passenger,
            [
              'email',
              'mail',
            ],
          );

          // ----------------------------------------------------
          // TÉLÉPHONE
          // ----------------------------------------------------

          final String telephone =
          _getPassengerString(
            passenger,
            [
              'telephone',
              'téléphone',
              'phone',
              'phoneNumber',
              'phone_number',
            ],
          );

          // ----------------------------------------------------
          // SIÈGE
          // ----------------------------------------------------

          dynamic siege =
          passenger['siege'];

          siege ??=
          passenger['seat'];

          siege ??=
          passenger['seatNumber'];

          siege ??=
          passenger['seat_number'];

          if (siege == null &&
              i <
                  widget.selectedSeats.length) {
            siege =
            widget.selectedSeats[i];
          }

          // ----------------------------------------------------
          // VÉRIFICATIONS
          // ----------------------------------------------------

          if (prenom.trim().isEmpty) {
            _showError(
              'Le prénom du voyageur '
                  '${i + 1} est manquant.',
            );

            return;
          }

          if (nom.trim().isEmpty) {
            _showError(
              'Le nom du voyageur '
                  '${i + 1} est manquant.',
            );

            return;
          }

          if (siege == null) {
            _showError(
              'Le siège du voyageur '
                  '${i + 1} est manquant.',
            );

            return;
          }

          // ----------------------------------------------------
          // DONNÉES ENVOYÉES À LARAVEL
          // ----------------------------------------------------

          voyageurs.add({
            'prenom':
            prenom.trim(),

            'nom':
            nom.trim(),

            'email':
            email.trim().isEmpty
                ? null
                : email.trim(),

            'telephone':
            telephone.trim().isEmpty
                ? null
                : telephone.trim(),

            'siege':
            int.tryParse(
              siege.toString(),
            ) ??
                siege,
          });
        }

        // ======================================================
        // REQUÊTE ACHAT DIRECT
        // ======================================================

        data = {
          'trajet_id':
          widget.trajetId,

          'nombre_places':
          widget.travelers,

          'sieges':
          widget.selectedSeats,

          // IMPORTANT
          // Les informations saisies dans
          // Informations voyageurs arrivent ici.
          'voyageurs':
          voyageurs,
        };
      }

      // ========================================================
      // PAIEMENT D'UNE RÉSERVATION
      // ========================================================

      else {
        if (widget.reservationId == null) {
          _showError(
            'La réservation est introuvable.',
          );

          return;
        }

        data = {
          'reservation_id':
          widget.reservationId,
        };
      }

      // ========================================================
      // AFFICHAGE DEBUG
      // ========================================================
      //
      // Très utile pendant notre test.
      // On vérifie exactement ce qui part vers Laravel.
      //

      debugPrint(
        '================ ACHAT =================',
      );

      debugPrint(
        const JsonEncoder.withIndent('  ')
            .convert(data),
      );

      debugPrint(
        '=========================================',
      );

      // ========================================================
      // REQUÊTE API
      // ========================================================

      late http.Response response;
      if (selectedPaymentMethod == 'mobile_money') {
        // Appel OpenPay via backend Laravel
        final Map<String, dynamic> openpayPayload = {
          ...data,
          'payment_phone_number': _phoneController.text.trim(),
          'provider': _selectedProvider,
        };
        response = await http.post(
          Uri.parse('$apiBaseUrl/openpay/initiate'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(openpayPayload),
        );
      } else {
        response = await http.post(
          Uri.parse(
            '$apiBaseUrl/achats',
          ),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(data),
        );
      }

      if (!mounted) return;

      // ========================================================
      // DEBUG RÉPONSE LARAVEL
      // ========================================================

      debugPrint(
        '=========== RÉPONSE LARAVEL ============',
      );

      debugPrint(
        'STATUS : ${response.statusCode}',
      );

      debugPrint(
        response.body,
      );

      debugPrint(
        '=========================================',
      );

      // ========================================================
      // SUCCÈS
      // ========================================================

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        _showPaymentSuccess(
          response.body,
        );

        return;
      }

      // ========================================================
      // ERREUR
      // ========================================================

      final message =
      _extractApiMessage(
        response.body,
      );

      _showPurchaseError(
        response.statusCode,
        message,
      );
    }

    // ==========================================================
    // ERREUR RÉSEAU / EXCEPTION
    // ==========================================================

    catch (e, stackTrace) {
      debugPrint(
        '============== EXCEPTION ==============',
      );

      debugPrint(
        e.toString(),
      );

      debugPrint(
        stackTrace.toString(),
      );

      debugPrint(
        '=======================================',
      );

      if (!mounted) return;

      _showError(
        'Impossible de contacter le serveur.\n\n'
            '$e',
      );
    }

    finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // ============================================================
  // RÉCUPÉRER UNE VALEUR VOYAGEUR
  // ============================================================

  String _getPassengerString(
      Map<String, dynamic> passenger,
      List<String> keys,
      ) {
    for (final key in keys) {
      final value =
      passenger[key];

      if (value != null &&
          value
              .toString()
              .trim()
              .isNotEmpty) {
        return value.toString();
      }
    }

    return '';
  }

  // ============================================================
  // EXTRAIRE MESSAGE API
  // ============================================================

  String _extractApiMessage(
      String responseBody,
      ) {
    try {
      final data =
      jsonDecode(responseBody);

      if (data is Map &&
          data['message'] != null) {
        final message =
        data['message']
            .toString()
            .trim();

        if (message.isNotEmpty) {
          return message;
        }
      }

      if (data is Map &&
          data['error'] != null) {
        final error =
        data['error']
            .toString()
            .trim();

        if (error.isNotEmpty) {
          return error;
        }
      }

      // Laravel validation
      if (data is Map &&
          data['errors'] is Map) {
        final errors =
        data['errors'] as Map;

        final messages =
        <String>[];

        for (final entry
        in errors.entries) {
          final value =
              entry.value;

          if (value is List) {
            for (final item
            in value) {
              messages.add(
                item.toString(),
              );
            }
          } else {
            messages.add(
              value.toString(),
            );
          }
        }

        if (messages.isNotEmpty) {
          return messages.join('\n');
        }
      }
    } catch (_) {}

    if (responseBody
        .trim()
        .isNotEmpty) {
      return responseBody;
    }

    return 'L’opération n’a pas pu être effectuée.';
  }

  // ============================================================
  // ERREUR ACHAT
  // ============================================================

  void _showPurchaseError(
      int statusCode,
      String message,
      ) {
    String finalMessage =
        message;

    if (statusCode == 409) {
      finalMessage =
      message.isNotEmpty
          ? message
          : 'Ce siège est déjà réservé ou acheté '
          'par un autre voyageur.\n\n'
          'Veuillez choisir un autre siège.';
    }

    if (statusCode == 422) {
      finalMessage =
      message.isNotEmpty
          ? message
          : 'Les informations envoyées sont invalides.';
    }

    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(20),
          ),

          icon: Icon(
            statusCode == 409
                ? Icons.event_seat_outlined
                : Icons.error_outline,

            color: Colors.red,
            size: 50,
          ),

          title: Text(
            statusCode == 409
                ? 'Billet indisponible'
                : 'Achat impossible',

            textAlign:
            TextAlign.center,

            style: const TextStyle(
              color: Color(0xFF0A2A66),
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Text(
            finalMessage,

            textAlign:
            TextAlign.center,

            style: const TextStyle(
              color: Colors.grey,
              height: 1.5,
            ),
          ),

          actions: [

            SizedBox(
              width: double.infinity,

              child:
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                  );
                },

                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF0A2A66),

                  foregroundColor:
                  Colors.white,
                ),

                child:
                const Text('Fermer'),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // SUCCÈS
  // ============================================================

  void _showPaymentSuccess(
      String responseBody,
      ) {
    String reference = '';

    try {
      final data =
      jsonDecode(responseBody);

      if (data is Map &&
          data['data'] is Map) {
        reference =
            data['data']['reference']
                ?.toString() ??
                '';
      }
    } catch (_) {}

    showDialog(
      context: context,

      barrierDismissible: false,

      builder: (dialogContext) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(20),
          ),

          icon: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 60,
          ),

          title: const Text(
            'Achat confirmé',

            textAlign:
            TextAlign.center,

            style: TextStyle(
              color: Color(0xFF0A2A66),
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Text(
            reference.isNotEmpty
                ? 'Votre achat a été enregistré '
                'avec succès.\n\n'
                'Référence : $reference'
                : 'Votre achat a été enregistré '
                'avec succès.',

            textAlign:
            TextAlign.center,

            style: const TextStyle(
              color: Colors.grey,
              height: 1.5,
            ),
          ),

          actions: [

            Column(
              mainAxisSize:
              MainAxisSize.min,

              children: [

                SizedBox(
                  width: double.infinity,

                  child:
                  ElevatedButton.icon(
                    onPressed: () {

                      Navigator.pop(
                        dialogContext,
                      );

                      Navigator.pushReplacement(
                        context,

                        MaterialPageRoute(
                          builder: (_) =>
                          const HomeScreen(
                            initialIndex: 2,
                            initialVoyagesTabIndex: 1,
                          ),
                        ),
                      );
                    },

                    icon: const Icon(
                      Icons.confirmation_num_outlined,
                    ),

                    label:
                    const Text(
                      'Voir mes achats',
                    ),

                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFFFF6B00),

                      foregroundColor:
                      Colors.white,

                      padding:
                      const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,

                  child:
                  OutlinedButton.icon(
                    onPressed: () {

                      Navigator.pop(
                        dialogContext,
                      );

                      Navigator.popUntil(
                        context,
                            (route) =>
                        route.isFirst,
                      );
                    },

                    icon: const Icon(
                      Icons.home_outlined,
                    ),

                    label:
                    const Text(
                      'Accueil',
                    ),

                    style:
                    OutlinedButton.styleFrom(
                      foregroundColor:
                      const Color(0xFF0A2A66),

                      side:
                      const BorderSide(
                        color:
                        Color(0xFF0A2A66),
                      ),

                      padding:
                      const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // ERREUR GÉNÉRALE
  // ============================================================

  void _showError(
      String message,
      ) {
    if (!mounted) return;

    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(20),
          ),

          icon: const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 50,
          ),

          title: const Text(
            'Erreur',

            textAlign:
            TextAlign.center,

            style: TextStyle(
              color: Color(0xFF0A2A66),
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Text(
            message,

            textAlign:
            TextAlign.center,

            style: const TextStyle(
              color: Colors.grey,
              height: 1.5,
            ),
          ),

          actions: [

            SizedBox(
              width: double.infinity,

              child:
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                  );
                },

                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF0A2A66),

                  foregroundColor:
                  Colors.white,
                ),

                child:
                const Text('Fermer'),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // CALCUL TOTAL
  // ============================================================

  String _calculateTotal() {
    final cleanPrice =
    widget.price
        .replaceAll('FCFA', '')
        .replaceAll(' ', '')
        .replaceAll(',', '');

    final priceValue =
        int.tryParse(
          cleanPrice,
        ) ??
            0;

    final total =
        priceValue *
            widget.travelers;

    final formatted =
    total.toString();

    final buffer =
    StringBuffer();

    for (
    int i = 0;
    i < formatted.length;
    i++
    ) {
      if (i > 0 &&
          (formatted.length - i) %
              3 ==
              0) {
        buffer.write(' ');
      }

      buffer.write(
        formatted[i],
      );
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

      padding:
      const EdgeInsets.all(20),

      decoration:
      BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withValues(
              alpha: 0.05,
            ),

            blurRadius: 12,

            offset:
            const Offset(0, 4),
          ),
        ],
      ),

      child: child,
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _buildInfoRow(
      IconData icon,
      String title,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 12,
      ),

      child: Row(
        children: [

          Icon(
            icon,
            color:
            const Color(0xFFFF6B00),
            size: 22,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,

              style:
              const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),

          Flexible(
            child: Text(
              value,

              textAlign:
              TextAlign.right,

              style:
              const TextStyle(
                color:
                Color(0xFF0A2A66),

                fontWeight:
                FontWeight.w600,

                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}