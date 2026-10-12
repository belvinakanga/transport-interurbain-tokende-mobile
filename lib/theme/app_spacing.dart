/// Échelle d'espacement et de rayons de Tokende.
///
/// Toutes les marges, paddings et arrondis de l'interface se prennent ici.
/// Une valeur absente de l'échelle est une valeur à discuter, pas à inventer
/// sur place : c'est ce qui a produit les 46 nuances de couleurs différentes
/// dans l'ancien code.
class AppSpacing {
  const AppSpacing._();

  /// 4 — séparation de deux éléments collés (icône et son libellé).
  static const double xxs = 4;

  /// 8 — intérieur d'un petit composant.
  static const double xs = 8;

  /// 12 — entre deux lignes d'un même bloc.
  static const double sm = 12;

  /// 16 — respiration par défaut à l'intérieur d'une carte.
  static const double md = 16;

  /// 20 — marge horizontale des écrans.
  static const double lg = 20;

  /// 24 — entre deux blocs liés.
  static const double xl = 24;

  /// 32 — entre deux sections.
  static const double xxl = 32;

  /// 40 — avant une action finale.
  static const double xxxl = 40;

  /// Marge horizontale standard d'un écran.
  static const double margeEcran = 20;
}

/// Rayons d'arrondi.
///
/// Trois paliers suffisent : un composant qui réclame un quatrième rayon est
/// en général un composant mal découpé.
class AppRadius {
  const AppRadius._();

  /// 10 — puces, petites étiquettes.
  static const double sm = 10;

  /// 14 — boutons secondaires, champs de saisie.
  static const double md = 14;

  /// 18 — boutons principaux, cartes.
  static const double lg = 18;

  /// 28 — grandes surfaces (feuilles, vignettes de logo).
  static const double xl = 28;

  /// Cercle parfait.
  static const double pleinRond = 999;
}

/// Hauteurs de contrôles tactiles.
///
/// Le minimum recommandé pour une cible tactile est 44 px ; aucune valeur
/// de cette classe ne descend en dessous.
class AppSize {
  const AppSize._();

  /// 46 — bouton secondaire, puce cliquable.
  static const double controleCompact = 46;

  /// 56 — bouton principal, champ de saisie.
  static const double controle = 56;

  /// 44 — plus petite cible tactile acceptable.
  static const double cibleTactileMin = 44;
}
