import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Surface de contenu.
///
/// Séparée du fond par un filet 1 px, jamais par une ombre portée : les
/// ombres de l'ancien code empilaient des cartes flottantes sans donner de
/// hiérarchie réelle.
class TkCard extends StatelessWidget {
  final Widget child;

  final EdgeInsetsGeometry? padding;

  /// Rend la carte cliquable, avec l'effet d'appui associé.
  final VoidCallback? onTap;

  /// Teinte la carte en orange atténué — pour une carte qui doit ressortir.
  final bool accentuee;

  const TkCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.accentuee = false,
  });

  @override
  Widget build(BuildContext context) {
    final sombre = Theme.of(context).brightness == Brightness.dark;

    final fond = accentuee
        ? AppColors.orangeDoux(context)
        : (sombre ? AppColors.fondSombre : Colors.white);

    final bordure = accentuee
        ? AppColors.orange.withValues(alpha: 0.35)
        : AppColors.inactifTheme(context);

    final rayon = BorderRadius.circular(AppRadius.lg);

    final contenu = Padding(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      child: child,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: fond,
        borderRadius: rayon,
        border: Border.all(color: bordure),
      ),
      child: onTap == null
          ? contenu
          : Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onTap,
                borderRadius: rayon,
                child: contenu,
              ),
            ),
    );
  }
}
