import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text.dart';

/// Nature du message affiché.
enum TkToastTon { succes, erreur, attente, info }

/// Messages éphémères de Tokende.
///
/// Remplace les `SnackBar` par défaut, qui arrivaient en bleu nuit plein ou
/// en rouge Material sans rapport avec le reste de l'interface.
///
/// Le ton ne se devine pas : il se déclare. [TkToast.succes], [TkToast.erreur]
/// et [TkToast.info] sont les points d'entrée.
class TkToast {
  const TkToast._();

  /// Affiche un message de réussite.
  static void succes(BuildContext context, String message) =>
      _afficher(context, message, TkToastTon.succes);

  /// Affiche une erreur.
  static void erreur(BuildContext context, String message) =>
      _afficher(context, message, TkToastTon.erreur);

  /// Affiche une information neutre.
  static void info(BuildContext context, String message) =>
      _afficher(context, message, TkToastTon.info);

  /// Affiche une action en attente ou différée.
  static void attente(BuildContext context, String message) =>
      _afficher(context, message, TkToastTon.attente);

  /// Point d'entrée pour le code qui dispose déjà d'un booléen d'erreur.
  static void selonErreur(
    BuildContext context,
    String message, {
    required bool erreur,
  }) {
    _afficher(
      context,
      message,
      erreur ? TkToastTon.erreur : TkToastTon.succes,
    );
  }

  // ----------------------------------------------------------------

  static void _afficher(
    BuildContext context,
    String message,
    TkToastTon ton,
  ) {
    final messager = ScaffoldMessenger.maybeOf(context);

    // Un écran peut être démonté avant que la réponse réseau n'arrive.
    if (messager == null) return;

    messager
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: _Contenu(message: message, ton: ton),

          // Le contenu dessine sa propre surface : la SnackBar elle-même
          // est transparente et sans marge interne.
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          duration: ton == TkToastTon.erreur
              // Une erreur se lit, un succès se constate.
              ? const Duration(seconds: 5)
              : const Duration(seconds: 3),
          dismissDirection: DismissDirection.horizontal,
        ),
      );
  }
}

class _Contenu extends StatelessWidget {
  final String message;
  final TkToastTon ton;

  const _Contenu({required this.message, required this.ton});

  Color _accent(BuildContext context) {
    switch (ton) {
      case TkToastTon.succes:
        return AppColors.vert;
      case TkToastTon.erreur:
        return AppColors.rouge;
      case TkToastTon.attente:
        return AppColors.ambre;
      case TkToastTon.info:
        return AppColors.orange;
    }
  }

  Color _accentDoux(BuildContext context) {
    switch (ton) {
      case TkToastTon.succes:
        return AppColors.vertDoux(context);
      case TkToastTon.erreur:
        return AppColors.rougeDoux(context);
      case TkToastTon.attente:
        return AppColors.ambreDoux(context);
      case TkToastTon.info:
        return AppColors.orangeDoux(context);
    }
  }

  IconData get _icone {
    switch (ton) {
      case TkToastTon.succes:
        return Icons.check_circle_rounded;
      case TkToastTon.erreur:
        return Icons.error_outline_rounded;
      case TkToastTon.attente:
        return Icons.schedule_rounded;
      case TkToastTon.info:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sombre = Theme.of(context).brightness == Brightness.dark;
    final accent = _accent(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: sombre ? AppColors.fondSombre : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.inactifTheme(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Pastille colorée : le ton se lit avant le texte.
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _accentDoux(context),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(_icone, size: 17, color: accent),
          ),

          const SizedBox(width: AppSpacing.sm),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 3),
              child: Text(
                message,
                style: AppText.petit(context).copyWith(
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: AppColors.titre(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
