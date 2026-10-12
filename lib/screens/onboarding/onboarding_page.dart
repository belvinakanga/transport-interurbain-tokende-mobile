import 'package:flutter/material.dart';

import '../../widgets/tk/tk.dart';
import 'onboarding_model.dart';

/// Une page d'onboarding : pastille orange, titre, description.
class OnboardingPage extends StatelessWidget {
  final OnboardingModel data;

  const OnboardingPage({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    // La pastille s'adapte à la largeur de l'écran pour ne jamais déborder
    // sur les petits téléphones.
    final largeur = MediaQuery.sizeOf(context).width;
    final taillePastille = (largeur * 0.36).clamp(112.0, 156.0);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Center(
            child: Container(
              width: taillePastille,
              height: taillePastille,
              decoration: const BoxDecoration(
                color: AppColors.orange,
                shape: BoxShape.circle,
              ),
              child: Icon(
                data.icone,
                size: taillePastille * 0.42,
                color: Colors.white,
              ),
            ),
          ),

          SizedBox(height: taillePastille * 0.38),

          Text(data.titre, style: AppText.titre(context)),

          const SizedBox(height: AppSpacing.sm),

          Text(data.description, style: AppText.corps(context)),
        ],
      ),
    );
  }
}
