import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text.dart';

/// Détail d'un montant à payer.
///
/// Affiche le prix des billets, les frais de service et le total, au lieu
/// d'un total sec. Le voyageur voyait auparavant le seul prix de l'agence,
/// inférieur à la somme réellement débitée.
///
/// Les frais sont nommés « frais de service » : leur répartition entre
/// Tokende et l'agence est interne et ne regarde pas le voyageur.
class TkMontantDetail extends StatelessWidget {
  /// Prix unitaire pratiqué par l'agence.
  final double prixUnitaire;

  /// Frais de service pour un billet.
  final double fraisParBillet;

  final int nombreBillets;

  const TkMontantDetail({
    super.key,
    required this.prixUnitaire,
    required this.fraisParBillet,
    required this.nombreBillets,
  });

  double get _base => prixUnitaire * nombreBillets;
  double get _frais => fraisParBillet * nombreBillets;
  double get total => _base + _frais;

  /// « 30 200 FCFA » — espace fine insécable entre les milliers.
  static String formater(double montant) {
    final entier = montant.round().toString();
    final tampon = StringBuffer();

    for (var i = 0; i < entier.length; i++) {
      if (i > 0 && (entier.length - i) % 3 == 0) tampon.write(' ');
      tampon.write(entier[i]);
    }

    return '$tampon FCFA';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ligne(
          context,
          'Billets',
          '$nombreBillets × ${formater(prixUnitaire)}',
          formater(_base),
        ),

        const SizedBox(height: AppSpacing.xs),

        _ligne(
          context,
          'Frais de service',
          '$nombreBillets × ${formater(fraisParBillet)}',
          formater(_frais),
        ),

        const SizedBox(height: AppSpacing.sm),

        Divider(height: 1, color: AppColors.inactifTheme(context)),

        const SizedBox(height: AppSpacing.sm),

        Row(
          children: [
            Text(
              'Total à payer',
              style: AppText.corpsFort(context).copyWith(fontSize: 15),
            ),
            const Spacer(),
            Text(
              formater(total),
              style: AppText.titre(context).copyWith(
                fontSize: 22,
                color: AppColors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _ligne(
    BuildContext context,
    String libelle,
    String detail,
    String montant,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                libelle,
                style: AppText.corps(context).copyWith(fontSize: 14),
              ),
              Text(
                detail,
                style: AppText.petit(context).copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
        Text(
          montant,
          style: AppText.corpsFort(context).copyWith(fontSize: 15),
        ),
      ],
    );
  }
}
