import 'package:flutter/material.dart';

import '../../widgets/tk/tk.dart';

import '../booking/seat_selection_screen.dart';

class TripDetailsScreen extends StatelessWidget {
  // ============================================================
  // INFORMATIONS DU TRAJET
  // ============================================================

  final int trajetId;

  final String agency;
  final String departure;
  final String destination;

  final String departureTime;
  final String arrivalTime;

  final String duration;
  final String price;
  final String rating;

  // Date réelle du départ
  final DateTime departureDate;

  final int travelers;

  const TripDetailsScreen({
    super.key,

    required this.trajetId,

    required this.agency,
    required this.departure,
    required this.destination,

    required this.departureTime,
    required this.arrivalTime,

    required this.duration,
    required this.price,
    required this.rating,

    required this.departureDate,

    required this.travelers,
  });

  // ============================================================
  // FORMATER LA DATE
  // ============================================================

  String get formattedDate {
    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];

    return '${departureDate.day} '
        '${months[departureDate.month - 1]} '
        '${departureDate.year}';
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

            _enTete(context),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.margeEcran,
                  AppSpacing.xs,
                  AppSpacing.margeEcran,
                  AppSpacing.lg,
                ),
                children: [
                  _carteItineraire(context),

                  const SizedBox(height: AppSpacing.md),

                  _carteInformations(context),

                  const SizedBox(height: AppSpacing.md),

                  _cartePrix(context),
                ],
              ),
            ),

            _barreAction(context),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EN-TÊTE
  // ============================================================

  Widget _enTete(BuildContext context) {
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
              'Détails du trajet',
              style: AppText.sousTitre(context),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ITINÉRAIRE
  // ============================================================

  Widget _carteItineraire(BuildContext context) {
    return TkCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(agency, style: AppText.corpsFort(context).copyWith(fontSize: 15)),

          const SizedBox(height: AppSpacing.md),

          // Les horaires portent l'heure à gauche et la ville à droite :
          // c'est l'ordre dans lequel on lit un départ.
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
              height: 26,
              color: AppColors.inactifTheme(context),
            ),
          ),

          _etape(
            context,
            heure: arrivalTime,
            ville: destination,
            icone: Icons.place_rounded,
          ),
        ],
      ),
    );
  }

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
            style: AppText.corpsFort(context).copyWith(fontSize: 18),
          ),
        ),

        Expanded(
          child: Text(
            ville,
            overflow: TextOverflow.ellipsis,
            style: AppText.corps(context).copyWith(fontSize: 16),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INFORMATIONS
  // ============================================================

  Widget _carteInformations(BuildContext context) {
    final lignes = <(String, String)>[
      ('Date', formattedDate),
      (
        'Voyageurs',
        travelers == 1 ? '1 voyageur' : '$travelers voyageurs',
      ),
      ('Durée', duration),
      ('Service', 'Transport interurbain'),
    ];

    return TkCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informations', style: AppText.label(context)),

          const SizedBox(height: AppSpacing.sm),

          for (var i = 0; i < lignes.length; i++) ...[
            if (i > 0)
              Divider(height: 1, color: AppColors.inactifTheme(context)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      lignes[i].$1,
                      style: AppText.corps(context).copyWith(fontSize: 15),
                    ),
                  ),
                  Text(
                    lignes[i].$2,
                    style: AppText.corpsFort(context).copyWith(fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // PRIX
  // ============================================================

  Widget _cartePrix(BuildContext context) {
    return TkCard(
      accentuee: true,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Prix par voyageur', style: AppText.label(context)),
                const SizedBox(height: 2),
                Text(
                  travelers == 1
                      ? 'Pour 1 voyageur'
                      : 'Pour $travelers voyageurs',
                  style: AppText.petit(context).copyWith(fontSize: 13),
                ),
              ],
            ),
          ),

          Text(
            price,
            style: AppText.titre(context).copyWith(
              fontSize: 24,
              color: AppColors.orange,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTION
  // ============================================================

  /// Barre fixe en bas : le bouton reste atteignable sans faire défiler.
  Widget _barreAction(BuildContext context) {
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
        libelle: 'Choisir mon siège',
        icone: Icons.event_seat_outlined,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SeatSelectionScreen(
                trajetId: trajetId,
                agency: agency,
                departure: departure,
                destination: destination,
                departureDate: formattedDate,
                departureTime: departureTime,
                arrivalTime: arrivalTime,
                price: price,
                travelers: travelers,
              ),
            ),
          );
        },
      ),
    );
  }
}
