import 'package:flutter/material.dart';

import '../../widgets/tk/tk.dart';

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
        TkToast.erreur(
          context,
          'Veuillez compléter les informations du passager ${i + 1}.',
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
      backgroundColor: AppColors.fond(context),

      body: SafeArea(
        child: Column(
          children: [

            _enTete(),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.margeEcran,
                  AppSpacing.xs,
                  AppSpacing.margeEcran,
                  AppSpacing.lg,
                ),
                children: [

                  _rappelVoyage(),

                  const SizedBox(height: AppSpacing.xl),

                  Text(
                    widget.travelers == 1
                        ? 'Renseignez les informations du passager.'
                        : 'Renseignez les informations de chaque passager.',
                    style: AppText.corps(context),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  for (var i = 0; i < widget.travelers; i++) ...[
                    if (i > 0) const SizedBox(height: AppSpacing.sm),
                    _cartePassager(i),
                  ],
                ],
              ),
            ),

            _barreAction(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EN-TÊTE
  // ============================================================

  Widget _enTete() {
    return Padding(
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
              'Informations voyageurs',
              style: AppText.sousTitre(context),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RAPPEL DU VOYAGE
  // ============================================================

  Widget _rappelVoyage() {
    return TkCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.agency,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.corpsFort(context).copyWith(fontSize: 15),
                ),
              ),
              Text(
                widget.price,
                style: AppText.corpsFort(context).copyWith(
                  fontSize: 17,
                  color: AppColors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          Divider(height: 1, color: AppColors.inactifTheme(context)),

          const SizedBox(height: AppSpacing.sm),

          Row(
            children: [
              Expanded(
                child: _borne(
                  'Départ',
                  widget.departure,
                  widget.departureTime,
                ),
              ),

              Icon(
                Icons.arrow_forward_rounded,
                size: 15,
                color: AppColors.secondaire(context),
              ),

              Expanded(
                child: _borne(
                  'Arrivée',
                  widget.destination,
                  widget.arrivalTime,
                  alignerADroite: true,
                ),
              ),
            ],
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
                widget.departureDate,
                style: AppText.petit(context).copyWith(fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _borne(
    String intitule,
    String ville,
    String heure, {
    bool alignerADroite = false,
  }) {
    final alignement = alignerADroite
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: alignement,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(intitule.toUpperCase(), style: AppText.label(context)),
        const SizedBox(height: 2),
        Text(
          ville,
          overflow: TextOverflow.ellipsis,
          textAlign: alignerADroite ? TextAlign.right : TextAlign.left,
          style: AppText.corpsFort(context).copyWith(fontSize: 15),
        ),
        Text(
          heure,
          style: AppText.petit(context).copyWith(fontSize: 13),
        ),
      ],
    );
  }

  // ============================================================
  // CARTE PASSAGER
  // ============================================================

  Widget _cartePassager(int index) {
    final seatNumber = widget.selectedSeats[index];

    return TkCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.orangeDoux(context),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.orange,
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.xs),

              Expanded(
                child: Text(
                  'Passager ${index + 1}',
                  style: AppText.corpsFort(context).copyWith(fontSize: 15),
                ),
              ),

              TkChip(
                libelle: 'Siège $seatNumber',
                ton: TkChipTon.accent,
                icone: Icons.event_seat_outlined,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          TkField(
            label: 'Prénom',
            placeholder: 'Entrez le prénom',
            controller: firstNameControllers[index],
            iconeGauche: Icons.person_outline_rounded,
          ),

          const SizedBox(height: AppSpacing.sm),

          TkField(
            label: 'Nom',
            placeholder: 'Entrez le nom',
            controller: lastNameControllers[index],
            iconeGauche: Icons.badge_outlined,
          ),

          const SizedBox(height: AppSpacing.sm),

          TkField(
            label: 'Email ou numéro de téléphone',
            placeholder: 'Ex. 06 XX XX XX XX ou nom@email.com',
            controller: contactControllers[index],
            iconeGauche: Icons.contact_mail_outlined,
          ),

          const SizedBox(height: AppSpacing.xs),

          Text(
            'Utilisé pour recevoir les informations relatives au voyage.',
            style: AppText.petit(context).copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BARRE D'ACTION
  // ============================================================

  Widget _barreAction() {
    return Container(
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
      child: TkButton(
        libelle: 'Continuer',
        icone: Icons.arrow_forward_rounded,
        onPressed: continueToSummary,
      ),
    );
  }
}
