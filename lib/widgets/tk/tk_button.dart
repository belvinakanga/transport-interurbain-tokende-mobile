import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text.dart';

/// Niveaux d'importance d'un bouton.
///
/// La hiérarchie passe par l'intensité de l'orange, jamais par la forme :
/// les trois variantes partagent le même arrondi et la même absence d'ombre.
enum TkButtonVariante {
  /// Orange plein. Une seule action principale par écran.
  principal,

  /// Orange à 11 % de fond, texte orange. Actions de second rang.
  tonal,

  /// Contour seul. Action neutre ou destructive encadrée.
  contour,
}

/// Bouton standard de Tokende.
class TkButton extends StatelessWidget {
  final String libelle;

  final VoidCallback? onPressed;

  final TkButtonVariante variante;

  /// Icône facultative, posée à droite du libellé.
  final IconData? icone;

  /// Occupe toute la largeur disponible. Vrai par défaut : sur mobile, un
  /// bouton principal pleine largeur est plus facile à viser.
  final bool pleineLargeur;

  /// Remplace le contenu par un indicateur de chargement et bloque l'appui.
  final bool enChargement;

  const TkButton({
    super.key,
    required this.libelle,
    required this.onPressed,
    this.variante = TkButtonVariante.principal,
    this.icone,
    this.pleineLargeur = true,
    this.enChargement = false,
  });

  bool get _estPrincipal => variante == TkButtonVariante.principal;

  Color _fond(BuildContext context) {
    switch (variante) {
      case TkButtonVariante.principal:
        return AppColors.orange;
      case TkButtonVariante.tonal:
        return AppColors.orangeDoux(context);
      case TkButtonVariante.contour:
        return Colors.transparent;
    }
  }

  Color _encre(BuildContext context) {
    return _estPrincipal ? Colors.white : AppColors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final actif = onPressed != null && !enChargement;

    final hauteur =
        _estPrincipal ? AppSize.controle : AppSize.controleCompact;

    final rayon = _estPrincipal ? AppRadius.lg : AppRadius.md;

    return Opacity(
      opacity: actif ? 1 : 0.45,
      child: SizedBox(
        width: pleineLargeur ? double.infinity : null,
        height: hauteur,
        child: ElevatedButton(
          onPressed: actif ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _fond(context),
            foregroundColor: _encre(context),
            disabledBackgroundColor: _fond(context),
            disabledForegroundColor: _encre(context),
            elevation: 0,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
            ),
            side: variante == TkButtonVariante.contour
                ? BorderSide(color: AppColors.orange, width: 1.5)
                : BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(rayon),
            ),
          ),
          child: enChargement
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _encre(context),
                    ),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        libelle,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.bouton,
                      ),
                    ),
                    if (icone != null) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Icon(icone, size: 18),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

/// Bouton carré ne portant qu'une icône — retour, fermeture, action d'en-tête.
class TkIconButton extends StatelessWidget {
  final IconData icone;

  final VoidCallback? onPressed;

  final String? infobulle;

  final TkButtonVariante variante;

  const TkIconButton({
    super.key,
    required this.icone,
    required this.onPressed,
    this.infobulle,
    this.variante = TkButtonVariante.tonal,
  });

  @override
  Widget build(BuildContext context) {
    final fond = variante == TkButtonVariante.principal
        ? AppColors.orange
        : AppColors.orangeDoux(context);

    final encre = variante == TkButtonVariante.principal
        ? Colors.white
        : AppColors.orange;

    return SizedBox(
      width: AppSize.controleCompact,
      height: AppSize.controleCompact,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: fond,
          foregroundColor: encre,
          disabledBackgroundColor: fond,
          disabledForegroundColor: encre,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: Tooltip(
          message: infobulle ?? '',
          child: Icon(icone, size: 20),
        ),
      ),
    );
  }
}
