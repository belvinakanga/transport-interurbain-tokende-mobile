import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Échelle typographique de Tokende.
///
/// Chaque style porte sa couleur par défaut, adaptée au thème courant, pour
/// qu'un écran n'ait jamais à recomposer un `TextStyle` à la main.
class AppText {
  const AppText._();

  /// 34 — titre d'ouverture d'un écran d'accueil ou de résultat.
  static TextStyle display(BuildContext context) => TextStyle(
        fontSize: 34,
        height: 1.12,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
        color: AppColors.titre(context),
      );

  /// 28 — titre d'écran.
  static TextStyle titre(BuildContext context) => TextStyle(
        fontSize: 28,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: AppColors.titre(context),
      );

  /// 20 — titre de section ou de carte.
  static TextStyle sousTitre(BuildContext context) => TextStyle(
        fontSize: 20,
        height: 1.3,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: AppColors.titre(context),
      );

  /// 16 — texte courant.
  static TextStyle corps(BuildContext context) => TextStyle(
        fontSize: 16,
        height: 1.55,
        fontWeight: FontWeight.w400,
        color: AppColors.secondaire(context),
      );

  /// 16, appuyé — valeur saisie, nom de ville, montant.
  static TextStyle corpsFort(BuildContext context) => TextStyle(
        fontSize: 16,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: AppColors.titre(context),
      );

  /// 14 — texte d'appoint, aide sous un champ.
  static TextStyle petit(BuildContext context) => TextStyle(
        fontSize: 14,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: AppColors.secondaire(context),
      );

  /// 12 en capitales — intitulé de champ, en-tête de section.
  static TextStyle label(BuildContext context) => TextStyle(
        fontSize: 12,
        height: 1.3,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: AppColors.secondaire(context),
      );

  /// 16, demi-gras blanc — libellé posé dans un bouton plein.
  static const TextStyle bouton = TextStyle(
    fontSize: 16,
    height: 1.2,
    fontWeight: FontWeight.w600,
  );
}
