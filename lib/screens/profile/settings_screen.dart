import 'package:flutter/material.dart';
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

  void _showMessage(
      String message,
      ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior:
          SnackBarBehavior.floating,
          backgroundColor:
          primaryColor,
          duration:
          const Duration(seconds: 2),
        ),
      );
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

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      backgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor:
        primaryColor,

        foregroundColor:
        Colors.white,

        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 30,
          ),

          onPressed: _goBack,
        ),

        title: const Text(
          'Paramètres',

          style: TextStyle(
            fontSize: 28,
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),

      // ========================================================
      // CONTENU
      // ========================================================

      body: SafeArea(
        child: ListView(
          padding:
          const EdgeInsets.fromLTRB(
            20,
            25,
            20,
            40,
          ),

          children: [

            // ==================================================
            // NOTIFICATIONS
            // ==================================================

            _buildSectionTitle(
              icon:
              Icons.notifications_none,
              title:
              'Notifications',
            ),

            const SizedBox(height: 14),

            _buildSwitchItem(
              icon:
              Icons.notifications_none,

              title:
              'Notifications',

              subtitle:
              'Recevoir les notifications de Tokende',

              value:
              notificationsEnabled,

              onChanged:
              _changeNotifications,
            ),

            const SizedBox(height: 14),

            _buildSwitchItem(
              icon:
              Icons.confirmation_num_outlined,

              title:
              'Réservations',

              subtitle:
              'Recevoir les notifications concernant vos réservations',

              value:
              reservationsEnabled,

              onChanged:
              _changeReservations,
            ),

            const SizedBox(height: 14),

            _buildSwitchItem(
              icon:
              Icons.local_offer_outlined,

              title:
              'Promotions',

              subtitle:
              'Recevoir les offres et promotions de Tokende',

              value:
              promotionsEnabled,

              onChanged:
              _changePromotions,
            ),

            const SizedBox(height: 35),

            // ==================================================
            // COMPTE
            // ==================================================

            _buildSectionTitle(
              icon:
              Icons.manage_accounts_outlined,

              title:
              'Compte',
            ),

            const SizedBox(height: 14),

            _buildNavigationItem(
              icon:
              Icons.lock_outline,

              title:
              'Modifier le mot de passe',

              subtitle:
              'Modifier le mot de passe de votre compte',

              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                    const ChangePasswordScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 14),

            _buildNavigationItem(
              icon:
              Icons.security_outlined,

              title:
              'Sécurité du compte',

              subtitle:
              'Gérer la sécurité de votre compte',

              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                    const SecurityScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 35),

            // ==================================================
            // APPLICATION
            // ==================================================

            _buildSectionTitle(
              icon:
              Icons.info_outline,

              title:
              'Application',
            ),

            const SizedBox(height: 14),

            _buildNavigationItem(
              icon:
              Icons.info_outline,

              title:
              'À propos de Tokende',

              subtitle:
              'Informations sur l’application',

              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                    const AboutTokendeScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 14),

            _buildNavigationItem(
              icon:
              Icons.description_outlined,

              title:
              'Conditions d’utilisation',

              subtitle:
              'Consulter les conditions d’utilisation',

              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                    const TermsScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 14),

            _buildNavigationItem(
              icon:
              Icons.privacy_tip_outlined,

              title:
              'Politique de confidentialité',

              subtitle:
              'Consulter notre politique de confidentialité',

              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                    const PrivacyScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TITRE DE SECTION
  // ============================================================

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [

        Container(
          width: 62,
          height: 62,

          decoration:
          BoxDecoration(
            color:
            const Color(0xFFFFF3EA),

            borderRadius:
            BorderRadius.circular(
              18,
            ),
          ),

          child: Icon(
            icon,
            color:
            orangeColor,
            size: 30,
          ),
        ),

        const SizedBox(width: 18),

        Expanded(
          child: Text(
            title,

            style:
            const TextStyle(
              color:
              primaryColor,

              fontSize: 22,

              fontWeight:
              FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SWITCH
  // ============================================================

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>
    onChanged,
  }) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 18,
      ),

      decoration:
      BoxDecoration(
        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(
          24,
        ),
      ),

      child: Row(
        children: [

          Container(
            width: 58,
            height: 58,

            decoration:
            BoxDecoration(
              color:
              const Color(
                0xFFFFF3EA,
              ),

              borderRadius:
              BorderRadius.circular(
                17,
              ),
            ),

            child: Icon(
              icon,

              color:
              orangeColor,

              size: 30,
            ),
          ),

          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,

              children: [

                Text(
                  title,

                  style:
                  const TextStyle(
                    color:
                    primaryColor,

                    fontSize: 18,

                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  subtitle,

                  style: TextStyle(
                    color:
                    Colors.grey
                        .shade500,

                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          Switch(
            value:
            value,

            activeThumbColor:
            orangeColor,

            activeTrackColor:
            orangeColor.withValues(
              alpha: 0.35,
            ),

            onChanged:
            onChanged,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ÉLÉMENT AVEC FLÈCHE
  // ============================================================

  Widget _buildNavigationItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color:
      Colors.transparent,

      child: InkWell(
        borderRadius:
        BorderRadius.circular(
          24,
        ),

        onTap:
        onTap,

        child: Container(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 18,
          ),

          decoration:
          BoxDecoration(
            color:
            Colors.white,

            borderRadius:
            BorderRadius.circular(
              24,
            ),
          ),

          child: Row(
            children: [

              Container(
                width: 58,
                height: 58,

                decoration:
                BoxDecoration(
                  color:
                  const Color(
                    0xFFFFF3EA,
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    17,
                  ),
                ),

                child: Icon(
                  icon,

                  color:
                  orangeColor,

                  size: 30,
                ),
              ),

              const SizedBox(width: 20),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [

                    Text(
                      title,

                      style:
                      const TextStyle(
                        color:
                        primaryColor,

                        fontSize: 18,

                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      subtitle,

                      style:
                      TextStyle(
                        color:
                        Colors.grey
                            .shade500,

                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right,

                color:
                Colors.grey.shade500,

                size: 32,
              ),
            ],
          ),
        ),
      ),
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
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content:
          Text(message),

          backgroundColor:
          primaryColor,
        ),
      );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      backgroundColor,

      appBar: AppBar(
        backgroundColor:
        primaryColor,

        foregroundColor:
        Colors.white,

        title: const Text(
          'Modifier le mot de passe',

          style: TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),

      body: ListView(
        padding:
        const EdgeInsets.all(20),

        children: [

          _buildPasswordField(
            controller:
            currentPasswordController,

            label:
            'Mot de passe actuel',

            obscureText:
            hideCurrent,

            onVisibilityChanged:
                () {
              setState(() {
                hideCurrent =
                !hideCurrent;
              });
            },
          ),

          const SizedBox(height: 18),

          _buildPasswordField(
            controller:
            newPasswordController,

            label:
            'Nouveau mot de passe',

            obscureText:
            hideNew,

            onVisibilityChanged:
                () {
              setState(() {
                hideNew =
                !hideNew;
              });
            },
          ),

          const SizedBox(height: 18),

          _buildPasswordField(
            controller:
            confirmPasswordController,

            label:
            'Confirmer le mot de passe',

            obscureText:
            hideConfirm,

            onVisibilityChanged:
                () {
              setState(() {
                hideConfirm =
                !hideConfirm;
              });
            },
          ),

          const SizedBox(height: 40),

          SizedBox(
            height: 58,

            child:
            ElevatedButton(
              onPressed:
              _changePassword,

              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                orangeColor,

                foregroundColor:
                Colors.white,

                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    18,
                  ),
                ),
              ),

              child: const Text(
                'Modifier le mot de passe',

                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController
    controller,

    required String label,

    required bool obscureText,

    required VoidCallback
    onVisibilityChanged,
  }) {
    return TextField(
      controller:
      controller,

      obscureText:
      obscureText,

      decoration:
      InputDecoration(
        labelText:
        label,

        filled:
        true,

        fillColor:
        Colors.white,

        border:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            20,
          ),

          borderSide:
          BorderSide.none,
        ),

        suffixIcon:
        IconButton(
          onPressed:
          onVisibilityChanged,

          icon: Icon(
            obscureText
                ? Icons
                .visibility_off_outlined
                : Icons
                .visibility_outlined,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PAGE : SÉCURITÉ
// ============================================================

class SecurityScreen
    extends StatelessWidget {
  const SecurityScreen({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      backgroundColor,

      appBar: AppBar(
        backgroundColor:
        primaryColor,

        foregroundColor:
        Colors.white,

        title: const Text(
          'Sécurité du compte',

          style: TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),

      body: ListView(
        padding:
        const EdgeInsets.all(20),

        children: [

          _infoCard(
            icon:
            Icons.lock_outline,

            title:
            'Votre compte est protégé',

            text:
            'Vos informations personnelles sont protégées et accessibles uniquement depuis votre compte.',
          ),

          const SizedBox(height: 18),

          _infoCard(
            icon:
            Icons.password_outlined,

            title:
            'Mot de passe',

            text:
            'Utilisez un mot de passe suffisamment sécurisé et évitez de le partager.',
          ),

          const SizedBox(height: 18),

          _infoCard(
            icon:
            Icons.logout,

            title:
            'Déconnexion',

            text:
            'Pensez à vous déconnecter lorsque vous utilisez Tokende sur un appareil partagé.',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PAGE : À PROPOS
// ============================================================

class AboutTokendeScreen
    extends StatelessWidget {
  const AboutTokendeScreen({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      backgroundColor,

      appBar: AppBar(
        backgroundColor:
        primaryColor,

        foregroundColor:
        Colors.white,

        title: const Text(
          'À propos de Tokende',

          style: TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),

      body: ListView(
        padding:
        const EdgeInsets.all(20),

        children: [

          const SizedBox(height: 20),

          const Icon(
            Icons.directions_bus_outlined,

            color:
            primaryColor,

            size: 80,
          ),

          const SizedBox(height: 20),

          const Center(
            child: Text(
              'Tokende',

              style: TextStyle(
                color:
                primaryColor,

                fontSize: 30,

                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 10),

          const Center(
            child: Text(
              'Transport interurbain',

              style: TextStyle(
                color:
                Colors.grey,

                fontSize: 16,
              ),
            ),
          ),

          const SizedBox(height: 35),

          _infoCard(
            icon:
            Icons.info_outline,

            title:
            'Notre application',

            text:
            'Tokende facilite la recherche, la réservation et l’achat de trajets interurbains.',
          ),

          const SizedBox(height: 18),

          _infoCard(
            icon:
            Icons.verified_outlined,

            title:
            'Version',

            text:
            'Version 1.0.0',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PAGE : CONDITIONS
// ============================================================

class TermsScreen
    extends StatelessWidget {
  const TermsScreen({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return _LegalPage(
      title:
      'Conditions d’utilisation',

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

class PrivacyScreen
    extends StatelessWidget {
  const PrivacyScreen({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return _LegalPage(
      title:
      'Politique de confidentialité',

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
// PAGE JURIDIQUE
// ============================================================

class _LegalPage
    extends StatelessWidget {
  const _LegalPage({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      backgroundColor,

      appBar: AppBar(
        backgroundColor:
        primaryColor,

        foregroundColor:
        Colors.white,

        title: Text(
          title,

          style: const TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),

      body:
      SingleChildScrollView(
        padding:
        const EdgeInsets.all(24),

        child: Text(
          content,

          style:
          const TextStyle(
            color:
            primaryColor,

            fontSize: 16,

            height: 1.7,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CARTE INFORMATION
// ============================================================

Widget _infoCard({
  required IconData icon,
  required String title,
  required String text,
}) {
  return Container(
    padding:
    const EdgeInsets.all(22),

    decoration:
    BoxDecoration(
      color:
      Colors.white,

      borderRadius:
      BorderRadius.circular(
        24,
      ),
    ),

    child: Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [

        Container(
          width: 54,
          height: 54,

          decoration:
          BoxDecoration(
            color:
            const Color(
              0xFFFFF3EA,
            ),

            borderRadius:
            BorderRadius.circular(
              16,
            ),
          ),

          child: Icon(
            icon,

            color:
            orangeColor,

            size: 28,
          ),
        ),

        const SizedBox(width: 18),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment
                .start,

            children: [

              Text(
                title,

                style:
                const TextStyle(
                  color:
                  primaryColor,

                  fontSize: 18,

                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                text,

                style:
                TextStyle(
                  color:
                  Colors.grey
                      .shade600,

                  fontSize: 15,

                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}