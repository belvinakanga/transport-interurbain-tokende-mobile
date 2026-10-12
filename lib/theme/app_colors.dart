import 'package:flutter/material.dart';

/// Palette Tokende.
///
/// Source unique des couleurs de l'application : aucune valeur hexadécimale
/// ne doit être écrite en dur dans les écrans.
class AppColors {
  const AppColors._();

  /// Orange Tokende — couleur d'action (boutons, accents, état actif).
  static const Color orange = Color(0xFFFF6B00);

  /// Bleu nuit Tokende — couleur des titres et du texte fort.
  static const Color bleuNuit = Color(0xFF0A2A66);

  /// Fond des écrans en mode clair.
  static const Color fondClair = Color(0xFFFFFFFF);

  /// Fond des écrans en mode sombre.
  static const Color fondSombre = Color(0xFF101828);

  /// Texte secondaire (descriptions) en mode clair.
  static const Color texteSecondaire = Color(0xFF667085);

  /// Texte secondaire en mode sombre.
  static const Color texteSecondaireSombre = Color(0xFF98A2B3);

  /// Éléments inactifs : points de pagination, bordures discrètes.
  static const Color inactif = Color(0xFFE4E7EC);

  /// Éléments inactifs en mode sombre.
  static const Color inactifSombre = Color(0xFF344054);

  /// Titre adapté au thème courant.
  static Color titre(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : bleuNuit;
  }

  /// Texte secondaire adapté au thème courant.
  static Color secondaire(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? texteSecondaireSombre
        : texteSecondaire;
  }

  /// Couleur des éléments inactifs adaptée au thème courant.
  static Color inactifTheme(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? inactifSombre
        : inactif;
  }

  // --------------------------------------------------------------------
  // Couleurs sémantiques
  //
  // Distinctes de l'orange de marque : l'orange signifie « action », ces
  // trois-là signifient « état ». Les confondre rend les statuts illisibles.
  // --------------------------------------------------------------------

  /// Succès — réservation payée, paiement confirmé.
  static const Color vert = Color(0xFF11805A);

  /// Attente — réservation en attente, paiement en cours.
  static const Color ambre = Color(0xFFB4690E);

  /// Échec — paiement refusé, réservation annulée, erreur de saisie.
  static const Color rouge = Color(0xFFC0392B);

  /// Fond atténué d'un état de succès.
  static Color vertDoux(BuildContext context) => vert.withValues(
        alpha: Theme.of(context).brightness == Brightness.dark ? 0.22 : 0.10,
      );

  /// Fond atténué d'un état d'attente.
  static Color ambreDoux(BuildContext context) => ambre.withValues(
        alpha: Theme.of(context).brightness == Brightness.dark ? 0.22 : 0.10,
      );

  /// Fond atténué d'un état d'échec.
  static Color rougeDoux(BuildContext context) => rouge.withValues(
        alpha: Theme.of(context).brightness == Brightness.dark ? 0.22 : 0.09,
      );

  /// Orange atténué : fond des boutons secondaires (retour, ignorer).
  ///
  /// Même famille que le bouton principal, mais en retrait pour ne pas
  /// entrer en concurrence avec l'action principale.
  static Color orangeDoux(BuildContext context) {
    return orange.withValues(
      alpha: Theme.of(context).brightness == Brightness.dark ? 0.20 : 0.11,
    );
  }

  /// Fond d'écran adapté au thème courant.
  static Color fond(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? fondSombre
        : fondClair;
  }
}
