import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Nature d'un état affiché par une puce.
enum TkChipTon { neutre, succes, attente, echec, accent }

/// Puce d'état — statut de réservation, de paiement, de billet.
///
/// Un cas important côté Tokende : les statuts sont enregistrés avec des
/// casses variables selon le code qui les écrit (« Confirmée », « payée »,
/// « en attente »). [TkChip.statut] normalise avant de décider du ton, pour
/// qu'un statut ne finisse jamais en puce grise par accident.
class TkChip extends StatelessWidget {
  final String libelle;

  final TkChipTon ton;

  final IconData? icone;

  const TkChip({
    super.key,
    required this.libelle,
    this.ton = TkChipTon.neutre,
    this.icone,
  });

  /// Construit la puce à partir d'un statut brut venu de l'API.
  factory TkChip.statut(String? statutBrut) {
    final s = (statutBrut ?? '').trim().toLowerCase();

    switch (s) {
      case 'payée':
      case 'payee':
      case 'payé':
      case 'paye':
        return const TkChip(
          libelle: 'Payée',
          ton: TkChipTon.succes,
          icone: Icons.check_circle_rounded,
        );

      case 'confirmée':
      case 'confirmee':
        return const TkChip(
          libelle: 'Confirmée',
          ton: TkChipTon.succes,
          icone: Icons.check_circle_rounded,
        );

      case 'en attente':
      case 'pending':
        return const TkChip(
          libelle: 'En attente',
          ton: TkChipTon.attente,
          icone: Icons.schedule_rounded,
        );

      case 'annulée':
      case 'annulee':
      case 'échoué':
      case 'echoue':
      case 'failed':
        return TkChip(
          libelle: s == 'failed' || s.startsWith('éch') || s.startsWith('ech')
              ? 'Échoué'
              : 'Annulée',
          ton: TkChipTon.echec,
          icone: Icons.cancel_rounded,
        );

      default:
        final affiche = s.isEmpty
            ? 'Inconnu'
            : s[0].toUpperCase() + s.substring(1);
        return TkChip(libelle: affiche);
    }
  }

  Color _encre(BuildContext context) {
    switch (ton) {
      case TkChipTon.succes:
        return AppColors.vert;
      case TkChipTon.attente:
        return AppColors.ambre;
      case TkChipTon.echec:
        return AppColors.rouge;
      case TkChipTon.accent:
        return AppColors.orange;
      case TkChipTon.neutre:
        return AppColors.secondaire(context);
    }
  }

  Color _fond(BuildContext context) {
    switch (ton) {
      case TkChipTon.succes:
        return AppColors.vertDoux(context);
      case TkChipTon.attente:
        return AppColors.ambreDoux(context);
      case TkChipTon.echec:
        return AppColors.rougeDoux(context);
      case TkChipTon.accent:
        return AppColors.orangeDoux(context);
      case TkChipTon.neutre:
        return AppColors.inactifTheme(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final encre = _encre(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: _fond(context),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone != null) ...[
            Icon(icone, size: 13, color: encre),
            const SizedBox(width: AppSpacing.xxs),
          ],
          Text(
            libelle,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: encre,
            ),
          ),
        ],
      ),
    );
  }
}
