import 'package:flutter/material.dart';

/// Contenu d'une page d'onboarding.
class OnboardingModel {
  /// Icône affichée dans la pastille orange.
  final IconData icone;

  final String titre;

  final String description;

  const OnboardingModel({
    required this.icone,
    required this.titre,
    required this.description,
  });
}
