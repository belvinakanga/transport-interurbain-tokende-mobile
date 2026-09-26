import 'package:flutter/material.dart';

import 'booking_summary_screen.dart';

class PassengerInformationScreen extends StatefulWidget {
  // ============================================================
  // INFORMATIONS DU TRAJET
  // ============================================================

  final int trajetId;

  final String agency;
  final String departure;
  final String destination;

  // Date du départ nécessaire pour la règle des 72 heures
  final String departureDate;

  final String departureTime;
  final String arrivalTime;
  final String price;

  // ============================================================
  // VOYAGEURS ET SIÈGES
  // ============================================================

  final int travelers;
  final List<int> selectedSeats;

  const PassengerInformationScreen({
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
  });

  @override
  State<PassengerInformationScreen> createState() =>
      _PassengerInformationScreenState();
}

class _PassengerInformationScreenState
    extends State<PassengerInformationScreen> {
  // ============================================================
  // CONTRÔLEURS
  // ============================================================

  late List<TextEditingController> firstNameControllers;
  late List<TextEditingController> lastNameControllers;

  // Un seul champ pour email OU téléphone
  late List<TextEditingController> contactControllers;

  // ============================================================
  // INITIALISATION
  // ============================================================

  @override
  void initState() {
    super.initState();

    firstNameControllers = List.generate(
      widget.travelers,
          (_) => TextEditingController(),
    );

    lastNameControllers = List.generate(
      widget.travelers,
          (_) => TextEditingController(),
    );

    contactControllers = List.generate(
      widget.travelers,
          (_) => TextEditingController(),
    );
  }

  // ============================================================
  // LIBÉRER LES CONTRÔLEURS
  // ============================================================

  @override
  void dispose() {
    for (final controller in firstNameControllers) {
      controller.dispose();
    }

    for (final controller in lastNameControllers) {
      controller.dispose();
    }

    for (final controller in contactControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  bool validateInformation() {
    for (int i = 0; i < widget.travelers; i++) {
      final prenom =
      firstNameControllers[i].text.trim();

      final nom =
      lastNameControllers[i].text.trim();

      final contact =
      contactControllers[i].text.trim();

      if (prenom.isEmpty ||
          nom.isEmpty ||
          contact.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Veuillez compléter les informations du passager ${i + 1}.',
            ),
            backgroundColor: const Color(0xFF0A2A66),
            behavior: SnackBarBehavior.floating,
          ),
        );

        return false;
      }
    }

    return true;
  }

  // ============================================================
  // DÉTERMINER EMAIL OU TÉLÉPHONE
  // ============================================================

  bool isEmail(String value) {
    return value.contains('@');
  }

  // ============================================================
  // CONTINUER VERS LE RÉCAPITULATIF
  // ============================================================

  void continueToSummary() {
    if (!validateInformation()) {
      return;
    }

    final passengers =
    <Map<String, dynamic>>[];

    for (int i = 0; i < widget.travelers; i++) {
      final contact =
      contactControllers[i].text.trim();

      String email = '';
      String telephone = '';

      if (isEmail(contact)) {
        email = contact;
      } else {
        telephone = contact;
      }

      passengers.add({
        'prenom':
        firstNameControllers[i].text.trim(),

        'nom':
        lastNameControllers[i].text.trim(),

        'telephone':
        telephone,

        'email':
        email,

        'siege':
        widget.selectedSeats[i],
      });
    }

    // ==========================================================
    // OUVRIR LE RÉCAPITULATIF
    // ==========================================================

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingSummaryScreen(
          // ID DU TRAJET
          trajetId: widget.trajetId,

          // TRAJET
          agency: widget.agency,
          departure: widget.departure,
          destination: widget.destination,

          // DATE DU DÉPART
          departureDate: widget.departureDate,

          // HORAIRES
          departureTime: widget.departureTime,
          arrivalTime: widget.arrivalTime,

          // PRIX
          price: widget.price,

          // VOYAGEURS
          travelers: widget.travelers,

          // SIÈGES
          selectedSeats: widget.selectedSeats,

          // PASSAGERS
          passengers: passengers,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        backgroundColor: const Color(0xFF0A2A66),
        foregroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Informations voyageurs',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                24,
                24,
                24,
                30,
              ),

              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1150,
                  ),

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [
                      // ==================================================
                      // RÉSUMÉ DU TRAJET
                      // ==================================================

                      _buildTripHeader(),

                      const SizedBox(height: 30),

                      // ==================================================
                      // TITRE
                      // ==================================================

                      const Text(
                        'Informations des voyageurs',
                        style: TextStyle(
                          color: Color(0xFF0A2A66),
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 7),

                      Text(
                        widget.travelers == 1
                            ? 'Renseignez les informations du passager.'
                            : 'Renseignez les informations de chaque passager.',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 22),

                      // ==================================================
                      // CARTES PASSAGERS
                      // ==================================================

                      LayoutBuilder(
                        builder: (
                            context,
                            constraints,
                            ) {
                          final isWide =
                              constraints.maxWidth >= 760;

                          if (isWide) {
                            return _buildWidePassengerGrid();
                          }

                          return _buildMobilePassengerList();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ==========================================================
          // BARRE DU BAS
          // ==========================================================

          _buildBottomBar(),
        ],
      ),
    );
  }

  // ============================================================
  // EN-TÊTE TRAJET
  // ============================================================

  Widget _buildTripHeader() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(20),

        border: Border.all(
          color: const Color(0xFFE5EAF2),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        children: [
          // ==========================================================
          // AGENCE
          // ==========================================================

          Row(
            children: [
              Container(
                width: 46,
                height: 46,

                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3EB),
                  borderRadius:
                  BorderRadius.circular(13),
                ),

                child: const Icon(
                  Icons.directions_bus_rounded,
                  color: Color(0xFFFF6B00),
                  size: 26,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    Text(
                      widget.agency,
                      style: const TextStyle(
                        color: Color(0xFF0A2A66),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 3),

                    const Text(
                      'Votre voyage',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3EB),
                  borderRadius:
                  BorderRadius.circular(10),
                ),

                child: Text(
                  widget.price,
                  style: const TextStyle(
                    color: Color(0xFFFF6B00),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          const Divider(
            height: 1,
          ),

          const SizedBox(height: 20),

          // ==========================================================
          // DATE
          // ==========================================================

          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: Color(0xFFFF6B00),
                size: 18,
              ),

              const SizedBox(width: 8),

              const Text(
                'Date de départ : ',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),

              Expanded(
                child: Text(
                  widget.departureDate,
                  style: const TextStyle(
                    color: Color(0xFF0A2A66),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ==========================================================
          // DÉPART → ARRIVÉE
          // ==========================================================

          Row(
            children: [
              // DÉPART
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'DÉPART',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      widget.departure,
                      style: const TextStyle(
                        color: Color(0xFF0A2A66),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      widget.departureTime,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // FLÈCHE
              Container(
                width: 48,
                height: 48,

                decoration: BoxDecoration(
                  color: const Color(0xFFF2F5FA),
                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.arrow_forward,
                  color: Color(0xFF0A2A66),
                  size: 21,
                ),
              ),

              // ARRIVÉE
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.end,

                  children: [
                    const Text(
                      'ARRIVÉE',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      widget.destination,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Color(0xFF0A2A66),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      widget.arrivalTime,
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
        ],
      ),
    );
  }

  // ============================================================
  // GRILLE PASSAGERS — GRAND ÉCRAN
  // ============================================================

  Widget _buildWidePassengerGrid() {
    return Wrap(
      spacing: 20,
      runSpacing: 20,

      children: List.generate(
        widget.travelers,
            (index) {
          return SizedBox(
            width: 555,
            child: _buildPassengerCard(index),
          );
        },
      ),
    );
  }

  // ============================================================
  // LISTE PASSAGERS — MOBILE
  // ============================================================

  Widget _buildMobilePassengerList() {
    return Column(
      children: List.generate(
        widget.travelers,
            (index) {
          return Padding(
            padding: const EdgeInsets.only(
              bottom: 18,
            ),

            child: _buildPassengerCard(index),
          );
        },
      ),
    );
  }

  // ============================================================
  // CARTE PASSAGER
  // ============================================================

  Widget _buildPassengerCard(
      int index,
      ) {
    final seatNumber =
    widget.selectedSeats[index];

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(20),

        border: Border.all(
          color: const Color(0xFFE5EAF2),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          // ========================================================
          // HEADER PASSAGER
          // ========================================================

          Row(
            children: [
              Container(
                width: 44,
                height: 44,

                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FA),
                  borderRadius:
                  BorderRadius.circular(12),
                ),

                child: const Icon(
                  Icons.person_outline,
                  color: Color(0xFF0A2A66),
                  size: 25,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Passager ${index + 1}',
                      style: const TextStyle(
                        color: Color(0xFF0A2A66),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 3),

                    const Text(
                      'Informations personnelles',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // SIÈGE
              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3EB),
                  borderRadius:
                  BorderRadius.circular(10),
                ),

                child: Row(
                  mainAxisSize:
                  MainAxisSize.min,

                  children: [
                    const Icon(
                      Icons.event_seat_outlined,
                      color: Color(0xFFFF6B00),
                      size: 17,
                    ),

                    const SizedBox(width: 5),

                    Text(
                      'Siège $seatNumber',
                      style: const TextStyle(
                        color: Color(0xFFFF6B00),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ========================================================
          // PRÉNOM
          // ========================================================

          _buildTextField(
            controller:
            firstNameControllers[index],

            label: 'Prénom',

            hint: 'Entrez le prénom',

            icon: Icons.person_outline,
          ),

          const SizedBox(height: 15),

          // ========================================================
          // NOM
          // ========================================================

          _buildTextField(
            controller:
            lastNameControllers[index],

            label: 'Nom',

            hint: 'Entrez le nom',

            icon: Icons.badge_outlined,
          ),

          const SizedBox(height: 15),

          // ========================================================
          // EMAIL OU TÉLÉPHONE
          // ========================================================

          _buildTextField(
            controller:
            contactControllers[index],

            label:
            'Email ou numéro de téléphone',

            hint:
            'Ex. 06 XX XX XX XX ou nom@email.com',

            icon:
            Icons.contact_mail_outlined,

            keyboardType:
            TextInputType.text,
          ),

          const SizedBox(height: 12),

          // ========================================================
          // TEXTE D'AIDE
          // ========================================================

          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              const Icon(
                Icons.info_outline,
                color: Colors.grey,
                size: 14,
              ),

              const SizedBox(width: 6),

              const Expanded(
                child: Text(
                  'Utilisé pour recevoir les informations relatives au voyage.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
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
  // CHAMP
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF26344D),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 7),

        TextField(
          controller: controller,

          keyboardType: keyboardType,

          decoration: InputDecoration(
            hintText: hint,

            prefixIcon: Icon(
              icon,
              color: const Color(0xFF0A2A66),
              size: 20,
            ),

            filled: true,

            fillColor:
            const Color(0xFFF8F9FB),

            contentPadding:
            const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),

            border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(12),

              borderSide:
              BorderSide.none,
            ),

            enabledBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(12),

              borderSide:
              const BorderSide(
                color: Color(0xFFE3E8F0),
              ),
            ),

            focusedBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(12),

              borderSide:
              const BorderSide(
                color: Color(0xFFFF6B00),
                width: 1.5,
              ),
            ),

            hintStyle: const TextStyle(
              color: Color(0xFF9AA3B2),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BARRE INFÉRIEURE
  // ============================================================

  Widget _buildBottomBar() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(
        24,
        14,
        24,
        20,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),

      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1150,
          ),

          child: Row(
            children: [
              // ==================================================
              // TOTAL
              // ==================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      _calculateTotal(),
                      style: const TextStyle(
                        color: Color(0xFF0A2A66),
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              // ==================================================
              // BOUTON CONTINUER
              // ==================================================

              SizedBox(
                height: 53,

                child: ElevatedButton.icon(
                  onPressed:
                  continueToSummary,

                  icon: const Icon(
                    Icons.arrow_forward,
                    size: 19,
                  ),

                  label: const Text(
                    'Continuer',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFFFF6B00),

                    foregroundColor:
                    Colors.white,

                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 28,
                    ),

                    elevation: 0,

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CALCUL DU TOTAL
  // ============================================================

  String _calculateTotal() {
    final cleanPrice = widget.price
        .replaceAll('FCFA', '')
        .replaceAll(' ', '')
        .replaceAll(',', '');

    final priceValue =
        int.tryParse(cleanPrice) ?? 0;

    final total =
        priceValue * widget.travelers;

    final formatted =
    total.toString();

    final buffer =
    StringBuffer();

    for (
    int i = 0;
    i < formatted.length;
    i++
    ) {
      if (
      i > 0 &&
          (formatted.length - i) % 3 == 0) {
        buffer.write(' ');
      }

      buffer.write(formatted[i]);
    }

    return '${buffer.toString()} FCFA';
  }
}