import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text.dart';

/// Champ de saisie texte.
class TkField extends StatelessWidget {
  final String label;

  final String? placeholder;

  final TextEditingController? controller;

  final bool motDePasse;

  final bool motDePasseVisible;

  final VoidCallback? onBasculerVisibilite;

  final TextInputType? clavier;

  final String? messageErreur;

  final IconData? iconeGauche;

  final String? Function(String?)? validateur;

  final void Function(String)? onChanged;

  const TkField({
    super.key,
    required this.label,
    this.placeholder,
    this.controller,
    this.motDePasse = false,
    this.motDePasseVisible = false,
    this.onBasculerVisibilite,
    this.clavier,
    this.messageErreur,
    this.iconeGauche,
    this.validateur,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final enErreur = messageErreur != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppText.label(context)),

        const SizedBox(height: AppSpacing.xs),

        TextFormField(
          controller: controller,
          obscureText: motDePasse && !motDePasseVisible,
          keyboardType: clavier,
          validator: validateur,
          onChanged: onChanged,
          style: AppText.corpsFort(context),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: AppText.corps(context),
            prefixIcon: iconeGauche == null
                ? null
                : Icon(
                    iconeGauche,
                    size: 20,
                    color: AppColors.secondaire(context),
                  ),
            suffixIcon: !motDePasse
                ? null
                : IconButton(
                    onPressed: onBasculerVisibilite,
                    icon: Icon(
                      motDePasseVisible
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      size: 20,
                    ),
                    color: AppColors.secondaire(context),
                    tooltip: motDePasseVisible
                        ? 'Masquer le mot de passe'
                        : 'Afficher le mot de passe',
                  ),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.fondSombre
                : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            enabledBorder: _bordure(
              enErreur ? AppColors.rouge : AppColors.inactifTheme(context),
            ),
            focusedBorder: _bordure(
              enErreur ? AppColors.rouge : AppColors.orange,
              epaisseur: 1.6,
            ),
            errorBorder: _bordure(AppColors.rouge),
            focusedErrorBorder: _bordure(AppColors.rouge, epaisseur: 1.6),
            errorStyle: const TextStyle(height: 0, fontSize: 0),
          ),
        ),

        if (enErreur) ...[
          const SizedBox(height: AppSpacing.xxs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 15,
                color: AppColors.rouge,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Expanded(
                child: Text(
                  messageErreur!,
                  style: AppText.petit(context).copyWith(
                    color: AppColors.rouge,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  OutlineInputBorder _bordure(Color couleur, {double epaisseur = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: couleur, width: epaisseur),
    );
  }
}
