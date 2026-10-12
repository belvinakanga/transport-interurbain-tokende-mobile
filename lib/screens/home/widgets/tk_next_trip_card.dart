import 'package:flutter/material.dart';
import '../../../services/prochain_voyage_service.dart';
import '../../../utils/format_trajet.dart';
import '../../../widgets/tk/tk.dart';

/// Carte « prochain départ » de l'accueil.
///
/// Trois états sont possibles et tous les trois sont dessinés : en cours de
/// chargement, aucun voyage, un voyage. Un écran d'accueil qui n'affiche rien
/// pendant que la requête tourne passe pour un écran cassé.
class TkNextTripCard extends StatelessWidget {
  final ProchainVoyage? voyage;

  final bool enChargement;

  /// Appelé par le bouton de la carte lorsqu'un voyage est présent.
  final VoidCallback? onVoirBillet;

  /// Libellé du bouton principal.
  ///
  /// Un billet n'est émis qu'après paiement : promettre « Voir mon billet »
  /// sur une réservation en attente mène à une impasse.
  final String libelleAction;

  /// Appelé par l'état vide, pour lancer une recherche.
  final VoidCallback? onChercher;

  const TkNextTripCard({
    super.key,
    required this.voyage,
    this.enChargement = false,
    this.onVoirBillet,
    this.onChercher,
    this.libelleAction = 'Voir mon billet',
  });

  @override
  Widget build(BuildContext context) {
    if (enChargement) return const _CarteSquelette();

    if (voyage == null) {
      return TkCard(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xs,
        ),
        child: TkEmptyState(
          icone: Icons.explore_outlined,
          titre: 'Aucun voyage prévu',
          message:
              'Cherchez un trajet et votre prochain départ apparaîtra ici.',
          libelleAction: 'Chercher un trajet',
          onAction: onChercher,
        ),
      );
    }

    return _CarteVoyage(
      voyage: voyage!,
      onVoirBillet: onVoirBillet,
      libelleAction: libelleAction,
    );
  }
}

/// La carte renseignée : bleu nuit plein, texte clair.
class _CarteVoyage extends StatelessWidget {
  final ProchainVoyage voyage;
  final VoidCallback? onVoirBillet;
  final String libelleAction;

  const _CarteVoyage({
    required this.voyage,
    required this.libelleAction,
    this.onVoirBillet,
  });

  @override
  Widget build(BuildContext context) {
    // Même mise en forme que partout ailleurs dans l'application.
    final quand = '${FormatTrajet.dateDepuisDateTime(voyage.dateHeureDepart)}'
        ' · ${FormatTrajet.heureDepuisDateTime(voyage.dateHeureDepart)}';

    final joursRestants = _joursAvantDepart();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bleuNuit,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Expanded(
                child: Text(
                  'PROCHAIN DÉPART',
                  style: AppText.label(context).copyWith(
                    color: Colors.white70,
                  ),
                ),
              ),
              if (joursRestants != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    joursRestants,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          _ligneVille(voyage.depart, Icons.trip_origin_rounded),

          Padding(
            padding: const EdgeInsets.only(left: 7),
            child: Container(
              width: 2,
              height: 22,
              color: Colors.white24,
            ),
          ),

          _ligneVille(voyage.arrivee, Icons.place_rounded),

          const SizedBox(height: AppSpacing.md),

          Divider(color: Colors.white.withValues(alpha: 0.14), height: 1),

          const SizedBox(height: AppSpacing.md),

          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            children: [
              _detail(Icons.event_rounded, quand),
              if (voyage.reference.isNotEmpty)
                _detail(Icons.confirmation_number_outlined, voyage.reference),
              _detail(
                Icons.person_outline_rounded,
                voyage.nombrePlaces > 1
                    ? '${voyage.nombrePlaces} places'
                    : '1 place',
              ),
            ],
          ),

          if (voyage.nomAgence.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            _detail(Icons.business_outlined, voyage.nomAgence),
          ],

          const SizedBox(height: AppSpacing.lg),

          SizedBox(
            width: double.infinity,
            height: AppSize.controleCompact,
            child: ElevatedButton(
              onPressed: onVoirBillet,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: Text(libelleAction, style: AppText.bouton),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ligneVille(String ville, IconData icone) {
    return Row(
      children: [
        Icon(icone, size: 16, color: AppColors.orange),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            ville,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _detail(IconData icone, String texte) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 14, color: Colors.white54),
        const SizedBox(width: 5),
        Text(
          texte,
          style: const TextStyle(
            fontSize: 13,
            height: 1.3,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  /// « Aujourd'hui », « Demain », ou « Dans N jours ».
  String? _joursAvantDepart() {
    final maintenant = DateTime.now();
    final aujourdhui = DateTime(maintenant.year, maintenant.month, maintenant.day);

    final jourDepart = DateTime(
      voyage.dateHeureDepart.year,
      voyage.dateHeureDepart.month,
      voyage.dateHeureDepart.day,
    );

    final ecart = jourDepart.difference(aujourdhui).inDays;

    if (ecart < 0) return null;
    if (ecart == 0) return "AUJOURD'HUI";
    if (ecart == 1) return 'DEMAIN';
    if (ecart <= 30) return 'DANS $ecart JOURS';

    return null;
  }
}

/// Bloc gris animé pendant le chargement, aux dimensions de la vraie carte.
class _CarteSquelette extends StatelessWidget {
  const _CarteSquelette();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 232,
      decoration: BoxDecoration(
        color: AppColors.inactifTheme(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.secondaire(context),
            ),
          ),
        ),
      ),
    );
  }
}
