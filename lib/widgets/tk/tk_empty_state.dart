import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text.dart';
import 'tk_button.dart';

/// État vide : aucune réservation, aucun résultat, aucun billet.
///
/// Reprend la pastille orange de l'onboarding, en plus petit, pour qu'un
/// écran sans contenu reste un écran dessiné et non un écran cassé.
class TkEmptyState extends StatelessWidget {
  final IconData icone;

  final String titre;

  final String message;

  /// Libellé de l'action proposée. Sans lui, aucun bouton n'est affiché.
  final String? libelleAction;

  final VoidCallback? onAction;

  const TkEmptyState({
    super.key,
    required this.icone,
    required this.titre,
    required this.message,
    this.libelleAction,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppColors.orangeDoux(context),
              shape: BoxShape.circle,
            ),
            child: Icon(icone, size: 34, color: AppColors.orange),
          ),

          const SizedBox(height: AppSpacing.lg),

          Text(
            titre,
            textAlign: TextAlign.center,
            style: AppText.sousTitre(context),
          ),

          const SizedBox(height: AppSpacing.xs),

          Text(
            message,
            textAlign: TextAlign.center,
            style: AppText.corps(context),
          ),

          if (libelleAction != null) ...[
            const SizedBox(height: AppSpacing.xl),
            TkButton(
              libelle: libelleAction!,
              onPressed: onAction,
              variante: TkButtonVariante.tonal,
              pleineLargeur: false,
            ),
          ],
        ],
      ),
    );
  }
}
