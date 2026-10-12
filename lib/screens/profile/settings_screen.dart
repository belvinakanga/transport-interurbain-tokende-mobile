import 'package:flutter/material.dart';

import '../../widgets/tk/tk.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
// COULEURS TOKENTE
// ============================================================

const Color primaryColor = Color(0xFF0A2A66);
const Color orangeColor = Color(0xFFFF6B00);
const Color backgroundColor = Color(0xFFF8F9FB);

// ============================================================
// SETTINGS SCREEN
// ============================================================

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

// ============================================================
// STATE
// ============================================================

class _SettingsScreenState
    extends State<SettingsScreen> {

  bool notificationsEnabled = true;
  bool reservationsEnabled = true;
  bool promotionsEnabled = false;

  @override
  void initState() {
    super.initState();

    _loadSettings();
  }

  // ============================================================
  // CHARGER LES PARAMÈTRES
  // ============================================================

  Future<void> _loadSettings() async {
    final prefs =
    await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      notificationsEnabled =
          prefs.getBool(
            'notifications_enabled',
          ) ??
              true;

      reservationsEnabled =
          prefs.getBool(
            'reservations_enabled',
          ) ??
              true;

      promotionsEnabled =
          prefs.getBool(
            'promotions_enabled',
          ) ??
              false;
    });
  }

  // ============================================================
  // ENREGISTRER UNE OPTION
  // ============================================================

  Future<void> _saveBoolean(
      String key,
      bool value,
      ) async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(
      key,
      value,
    );
  }

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  Future<void> _changeNotifications(
      bool value,
      ) async {
    setState(() {
      notificationsEnabled = value;
    });

    await _saveBoolean(
      'notifications_enabled',
      value,
    );

    _showMessage(
      value
          ? 'Les notifications sont activées.'
          : 'Les notifications sont désactivées.',
    );
  }

  // ============================================================
  // NOTIFICATIONS RÉSERVATIONS
  // ============================================================

  Future<void> _changeReservations(
      bool value,
      ) async {
    setState(() {
      reservationsEnabled = value;
    });

    await _saveBoolean(
      'reservations_enabled',
      value,
    );

    _showMessage(
      value
          ? 'Les notifications de réservation sont activées.'
          : 'Les notifications de réservation sont désactivées.',
    );
  }

  // ============================================================
  // PROMOTIONS
  // ============================================================

  Future<void> _changePromotions(
      bool value,
      ) async {
    setState(() {
      promotionsEnabled = value;
    });

    await _saveBoolean(
      'promotions_enabled',
      value,
    );

    _showMessage(
      value
          ? 'Les promotions sont activées.'
          : 'Les promotions sont désactivées.',
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    TkToast.info(context, message);
  }

  // ============================================================
  // RETOUR
  // ============================================================

  void _goBack() {
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }

    Navigator.of(context).pop();
  }

  // ============================================================
  // BUILD
  // ============================================================

  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fond(context),

      body: SafeArea(
        child: Column(
          children: [

            // En-tête
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.margeEcran,
                AppSpacing.xs,
                AppSpacing.margeEcran,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  TkIconButton(
                    icone: Icons.arrow_back_rounded,
                    infobulle: 'Retour',
                    onPressed: _goBack,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Paramètres',
                      style: AppText.sousTitre(context),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.margeEcran,
                  AppSpacing.xs,
                  AppSpacing.margeEcran,
                  AppSpacing.xxl,
                ),
                children: [

                  // ------------------------------------------------
                  // NOTIFICATIONS
                  // ------------------------------------------------

                  const TkSectionHeader(titre: 'Notifications'),

                  TkCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _interrupteur(
                          icone: Icons.notifications_none_rounded,
                          titre: 'Notifications',
                          sousTitre:
                              'Recevoir les notifications de Tokende',
                          valeur: notificationsEnabled,
                          onChanged: _changeNotifications,
                        ),
                        _filet(),
                        _interrupteur(
                          icone: Icons.confirmation_number_outlined,
                          titre: 'Réservations',
                          sousTitre:
                              'Recevoir les notifications concernant vos '
                              'réservations',
                          valeur: reservationsEnabled,
                          onChanged: _changeReservations,
                        ),
                        _filet(),
                        _interrupteur(
                          icone: Icons.local_offer_outlined,
                          titre: 'Promotions',
                          sousTitre:
                              'Recevoir les offres et promotions de Tokende',
                          valeur: promotionsEnabled,
                          onChanged: _changePromotions,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ------------------------------------------------
                  // COMPTE
                  // ------------------------------------------------

                  const TkSectionHeader(titre: 'Compte'),

                  TkCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _lien(
                          icone: Icons.lock_outline_rounded,
                          titre: 'Modifier le mot de passe',
                          sousTitre:
                              'Modifier le mot de passe de votre compte',
                          premiere: true,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ChangePasswordScreen(),
                              ),
                            );
                          },
                        ),
                        _filet(),
                        _lien(
                          icone: Icons.security_outlined,
                          titre: 'Sécurité du compte',
                          sousTitre: 'Gérer la sécurité de votre compte',
                          derniere: true,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SecurityScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ------------------------------------------------
                  // APPLICATION
                  // ------------------------------------------------

                  const TkSectionHeader(titre: 'Application'),

                  TkCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _lien(
                          icone: Icons.info_outline_rounded,
                          titre: 'À propos de Tokende',
                          sousTitre: 'Informations sur l’application',
                          premiere: true,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AboutTokendeScreen(),
                              ),
                            );
                          },
                        ),
                        _filet(),
                        _lien(
                          icone: Icons.description_outlined,
                          titre: 'Conditions d’utilisation',
                          sousTitre:
                              'Consulter les conditions d’utilisation',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const TermsScreen(),
                              ),
                            );
                          },
                        ),
                        _filet(),
                        _lien(
                          icone: Icons.privacy_tip_outlined,
                          titre: 'Politique de confidentialité',
                          sousTitre:
                              'Consulter la politique de confidentialité',
                          derniere: true,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const PrivacyScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // COMPOSANTS DE LISTE
  // ============================================================

  Widget _interrupteur({
    required IconData icone,
    required String titre,
    required String sousTitre,
    required bool valeur,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          _pastille(icone),

          const SizedBox(width: AppSpacing.sm),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titre,
                  style: AppText.corpsFort(context).copyWith(fontSize: 15),
                ),
                Text(
                  sousTitre,
                  style: AppText.petit(context).copyWith(fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.xs),

          Switch(
            value: valeur,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.orange,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: AppColors.inactifTheme(context),
            trackOutlineColor: WidgetStateProperty.resolveWith(
              (etats) => etats.contains(WidgetState.selected)
                  ? AppColors.orange
                  : AppColors.inactifTheme(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _lien({
    required IconData icone,
    required String titre,
    required String sousTitre,
    required VoidCallback onTap,
    bool premiere = false,
    bool derniere = false,
  }) {
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
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              _pastille(icone),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      titre,
                      style: AppText.corpsFort(context).copyWith(
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      sousTitre,
                      style: AppText.petit(context).copyWith(fontSize: 13),
                    ),
                  ],
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

  Widget _pastille(IconData icone) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.orangeDoux(context),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Icon(icone, size: 19, color: AppColors.orange),
    );
  }

  Widget _filet() {
    return Padding(
      padding: const EdgeInsets.only(left: 68),
      child: Divider(height: 1, color: AppColors.inactifTheme(context)),
    );
  }
}

// ============================================================
// PAGE : MODIFIER LE MOT DE PASSE
// ============================================================

class ChangePasswordScreen
    extends StatefulWidget {
  const ChangePasswordScreen({
    super.key,
  });

  @override
  State<ChangePasswordScreen>
  createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends State<ChangePasswordScreen> {

  final currentPasswordController =
  TextEditingController();

  final newPasswordController =
  TextEditingController();

  final confirmPasswordController =
  TextEditingController();

  bool hideCurrent = true;
  bool hideNew = true;
  bool hideConfirm = true;

  @override
  void dispose() {
    currentPasswordController
        .dispose();

    newPasswordController.dispose();

    confirmPasswordController
        .dispose();

    super.dispose();
  }

  void _changePassword() {
    final current =
    currentPasswordController
        .text
        .trim();

    final newPassword =
    newPasswordController
        .text
        .trim();

    final confirmation =
    confirmPasswordController
        .text
        .trim();

    if (current.isEmpty ||
        newPassword.isEmpty ||
        confirmation.isEmpty) {
      _showMessage(
        'Veuillez remplir tous les champs.',
      );

      return;
    }

    if (newPassword.length < 8) {
      _showMessage(
        'Le nouveau mot de passe doit contenir au moins 8 caractères.',
      );

      return;
    }

    if (newPassword !=
        confirmation) {
      _showMessage(
        'Les deux nouveaux mots de passe ne correspondent pas.',
      );

      return;
    }

    _showMessage(
      'La modification du mot de passe sera connectée à Laravel prochainement.',
    );
  }

  void _showMessage(
      String message,
      ) {
    TkToast.info(context, message);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fond(context),

      body: SafeArea(
        child: Column(
          children: [

            _enTetePage(context, 'Modifier le mot de passe'),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.margeEcran,
                  AppSpacing.xs,
                  AppSpacing.margeEcran,
                  AppSpacing.xxl,
                ),
                children: [

                  TkField(
                    label: 'Mot de passe actuel',
                    placeholder: 'Votre mot de passe actuel',
                    controller: currentPasswordController,
                    motDePasse: true,
                    motDePasseVisible: !hideCurrent,
                    onBasculerVisibilite: () {
                      setState(() {
                        hideCurrent = !hideCurrent;
                      });
                    },
                    iconeGauche: Icons.lock_outline_rounded,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  TkField(
                    label: 'Nouveau mot de passe',
                    placeholder: 'Au moins 8 caractères',
                    controller: newPasswordController,
                    motDePasse: true,
                    motDePasseVisible: !hideNew,
                    onBasculerVisibilite: () {
                      setState(() {
                        hideNew = !hideNew;
                      });
                    },
                    iconeGauche: Icons.lock_reset_rounded,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  TkField(
                    label: 'Confirmer le mot de passe',
                    placeholder: 'Retapez le nouveau mot de passe',
                    controller: confirmPasswordController,
                    motDePasse: true,
                    motDePasseVisible: !hideConfirm,
                    onBasculerVisibilite: () {
                      setState(() {
                        hideConfirm = !hideConfirm;
                      });
                    },
                    iconeGauche: Icons.lock_reset_rounded,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  TkButton(
                    libelle: 'Modifier le mot de passe',
                    onPressed: _changePassword,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EN-TÊTE PARTAGÉ DES SOUS-PAGES
// ============================================================

/// Barre de titre commune aux pages secondaires des paramètres.
Widget _enTetePage(BuildContext context, String titre) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.margeEcran,
      AppSpacing.xs,
      AppSpacing.margeEcran,
      AppSpacing.sm,
    ),
    child: Row(
      children: [
        TkIconButton(
          icone: Icons.arrow_back_rounded,
          infobulle: 'Retour',
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(titre, style: AppText.sousTitre(context)),
        ),
      ],
    ),
  );
}

// ============================================================
// PAGE : SÉCURITÉ DU COMPTE
// ============================================================

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final points = <(IconData, String, String)>[
      (
        Icons.verified_user_outlined,
        'Votre compte est protégé',
        'Vos informations personnelles sont protégées et accessibles '
            'uniquement depuis votre compte.',
      ),
      (
        Icons.lock_outline_rounded,
        'Mot de passe',
        'Utilisez un mot de passe suffisamment sécurisé et évitez de le '
            'partager.',
      ),
      (
        Icons.logout_rounded,
        'Déconnexion',
        'Pensez à vous déconnecter lorsque vous utilisez Tokende sur un '
            'appareil partagé.',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.fond(context),
      body: SafeArea(
        child: Column(
          children: [
            _enTetePage(context, 'Sécurité du compte'),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.margeEcran,
                  AppSpacing.xs,
                  AppSpacing.margeEcran,
                  AppSpacing.xxl,
                ),
                itemCount: points.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final (icone, titre, texte) = points[index];

                  return TkCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.orangeDoux(context),
                            borderRadius:
                                BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Icon(
                            icone,
                            size: 19,
                            color: AppColors.orange,
                          ),
                        ),

                        const SizedBox(width: AppSpacing.sm),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                titre,
                                style: AppText.corpsFort(context)
                                    .copyWith(fontSize: 15),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                texte,
                                style: AppText.petit(context)
                                    .copyWith(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PAGE : À PROPOS
// ============================================================

class AboutTokendeScreen extends StatelessWidget {
  const AboutTokendeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fond(context),
      body: SafeArea(
        child: Column(
          children: [
            _enTetePage(context, 'À propos de Tokende'),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.margeEcran,
                  AppSpacing.xs,
                  AppSpacing.margeEcran,
                  AppSpacing.xxl,
                ),
                children: [

                  Center(
                    child: Column(
                      children: [
                        // Le vrai logo plutôt qu'une icône générique :
                        // c'est la page qui présente l'application.
                        Image.asset(
                          'assets/images/transparent-logo.png',
                          width: 150,
                          height: 98,
                          fit: BoxFit.contain,
                        ),

                        const SizedBox(height: AppSpacing.md),

                        Text('Tokende', style: AppText.titre(context)),

                        const SizedBox(height: 2),

                        Text(
                          'Transport interurbain',
                          style: AppText.corps(context),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  TkCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notre application',
                          style: AppText.corpsFort(context)
                              .copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          'Tokende facilite la recherche, la réservation et '
                          'l’achat de trajets interurbains.',
                          style: AppText.corps(context),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  TkCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Text('Version', style: AppText.label(context)),
                        const Spacer(),
                        Text(
                          '1.0.0',
                          style: AppText.corpsFort(context)
                              .copyWith(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PAGE : CONDITIONS D'UTILISATION
// ============================================================

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LegalPage(
      title: 'Conditions d’utilisation',
      content: '''
En utilisant Tokende, vous acceptez les présentes conditions d’utilisation.

Tokende permet aux voyageurs de consulter les trajets proposés par les agences de transport, d’effectuer des réservations et de réaliser des achats.

Les informations fournies lors de l’utilisation de l’application doivent être exactes.

Le voyageur est responsable des informations communiquées lors de ses réservations et achats.

Les conditions propres à chaque agence de transport peuvent également s’appliquer.
''',
    );
  }
}

// ============================================================
// PAGE : CONFIDENTIALITÉ
// ============================================================

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LegalPage(
      title: 'Politique de confidentialité',
      content: '''
Tokende accorde une grande importance à la protection de vos données personnelles.

Les informations nécessaires à votre compte peuvent être utilisées pour permettre votre authentification, faciliter vos réservations et gérer vos achats.

Vos informations personnelles ne doivent pas être utilisées à d’autres fins que celles nécessaires au fonctionnement du service.

Vous pouvez demander la modification de vos informations personnelles depuis votre profil.
''',
    );
  }
}

// ============================================================
// GABARIT DES PAGES LÉGALES
// ============================================================

class _LegalPage extends StatelessWidget {
  const _LegalPage({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    // Le texte est découpé en paragraphes pour pouvoir les espacer :
    // un bloc unique de huit lignes est illisible sur mobile.
    final paragraphes = content
        .trim()
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.fond(context),
      body: SafeArea(
        child: Column(
          children: [
            _enTetePage(context, title),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.margeEcran,
                  AppSpacing.xs,
                  AppSpacing.margeEcran,
                  AppSpacing.xxl,
                ),
                itemCount: paragraphes.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) => Text(
                  paragraphes[index],
                  style: AppText.corps(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
