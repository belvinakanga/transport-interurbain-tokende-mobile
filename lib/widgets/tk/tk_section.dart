import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_text.dart';

/// En-tête de section : un intitulé, éventuellement une action à droite.
class TkSectionHeader extends StatelessWidget {
  final String titre;

  final String? libelleAction;

  final VoidCallback? onAction;

  const TkSectionHeader({
    super.key,
    required this.titre,
    this.libelleAction,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              titre.toUpperCase(),
              style: AppText.label(context),
            ),
          ),
          if (libelleAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                libelleAction!,
                style: AppText.petit(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
