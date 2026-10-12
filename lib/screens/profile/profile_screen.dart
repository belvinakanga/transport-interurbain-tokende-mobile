import 'package:flutter/material.dart';

import '../../widgets/tk/tk.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.onPersonalInformation,
    required this.onMesVoyages,
    required this.onSettings,
    required this.onHelp,
    required this.onLogout,
  });

  // ============================================================
  // ACTIONS
  // ============================================================

  final VoidCallback onPersonalInformation;
  final VoidCallback onMesVoyages;
  final VoidCallback onSettings;
  final VoidCallback onHelp;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fond(context),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.margeEcran,
            AppSpacing.md,
            AppSpacing.margeEcran,
            // Place réservée à la barre flottante.
            108,
          ),
          children: [

            Text('Mon profil', style: AppText.titre(context)),

            const SizedBox(height: AppSpacing.xl),

            // Les entrées sont groupées dans une seule carte séparée par des
            // filets, au lieu de cinq cartes flottantes espacées de 16 px :
            // elles forment une liste, pas cinq objets indépendants.
            TkCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _entree(
                    context,
                    icone: Icons.person_outline_rounded,
                    titre: 'Informations personnelles',
                    onTap: onPersonalInformation,
                    premiere: true,
                  ),
                  _filet(context),
                  _entree(
                    context,
                    icone: Icons.confirmation_number_outlined,
                    titre: 'Mes voyages',
                    onTap: onMesVoyages,
                  ),
                  _filet(context),
                  _entree(
                    context,
                    icone: Icons.settings_outlined,
                    titre: 'Paramètres',
                    onTap: onSettings,
                  ),
                  _filet(context),
                  _entree(
                    context,
                    icone: Icons.help_outline_rounded,
                    titre: 'Aide & assistance',
                    onTap: onHelp,
                    derniere: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // La déconnexion est détachée du groupe et teintée en rouge :
            // c'est la seule action de cet écran qui sort de l'application.
            TkCard(
              padding: EdgeInsets.zero,
              onTap: onLogout,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.rougeDoux(context),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        Icons.logout_rounded,
                        size: 19,
                        color: AppColors.rouge,
                      ),
                    ),

                    const SizedBox(width: AppSpacing.sm),

                    Expanded(
                      child: Text(
                        'Se déconnecter',
                        style: AppText.corpsFort(context).copyWith(
                          fontSize: 15,
                          color: AppColors.rouge,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ENTRÉE DE LISTE
  // ============================================================

  Widget _entree(
    BuildContext context, {
    required IconData icone,
    required String titre,
    required VoidCallback onTap,
    bool premiere = false,
    bool derniere = false,
  }) {
    // Les coins ne s'arrondissent qu'aux extrémités, pour que l'effet
    // d'appui ne déborde pas de la carte.
    final rayon = BorderRadius.vertical(
      top: Radius.circular(premiere ? AppRadius.lg : 0),
      bottom: Radius.circular(derniere ? AppRadius.lg : 0),
    );

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: rayon,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.orangeDoux(context),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icone, size: 19, color: AppColors.orange),
              ),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: Text(
                  titre,
                  style: AppText.corpsFort(context).copyWith(fontSize: 15),
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.secondaire(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filet(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 68),
      child: Divider(
        height: 1,
        color: AppColors.inactifTheme(context),
      ),
    );
  }
}
