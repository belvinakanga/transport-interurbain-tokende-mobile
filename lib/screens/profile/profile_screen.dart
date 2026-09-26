import 'package:flutter/material.dart';

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

  // ============================================================
  // COULEURS TOKENDE
  // ============================================================

  static const Color primaryColor = Color(0xFF0A2A66);
  static const Color orangeColor = Color(0xFFFF6B00);
  static const Color backgroundColor = Color(0xFFF8F9FB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // ========================================================
      // EN-TÊTE
      // ========================================================

      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,

        automaticallyImplyLeading: false,

        title: const Text(
          'Mon profil',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ========================================================
      // CONTENU
      // ========================================================

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            25,
            20,
            30,
          ),
          children: [
            // ====================================================
            // INFORMATIONS PERSONNELLES
            // ====================================================

            _buildProfileItem(
              icon: Icons.person_outline,
              title: 'Informations personnelles',
              onTap: onPersonalInformation,
            ),

            const SizedBox(height: 16),

            // ====================================================
            // MES VOYAGES
            // ====================================================

            _buildProfileItem(
              icon: Icons.confirmation_num_outlined,
              title: 'Mes voyages',
              onTap: onMesVoyages,
            ),

            const SizedBox(height: 16),

            // ====================================================
            // PARAMÈTRES
            // ====================================================

            _buildProfileItem(
              icon: Icons.settings_outlined,
              title: 'Paramètres',
              onTap: onSettings,
            ),

            const SizedBox(height: 16),

            // ====================================================
            // AIDE & ASSISTANCE
            // ====================================================

            _buildProfileItem(
              icon: Icons.help_outline,
              title: 'Aide & assistance',
              onTap: onHelp,
            ),

            const SizedBox(height: 35),

            // ====================================================
            // DÉCONNEXION
            // ====================================================

            _buildProfileItem(
              icon: Icons.logout,
              title: 'Se déconnecter',
              onTap: onLogout,
              isLogout: true,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ÉLÉMENT DU PROFIL
  // ============================================================

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),

        child: Container(
          width: double.infinity,
          height: 82,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),

          child: Row(
            children: [
              // ==================================================
              // ICÔNE
              // ==================================================

              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: isLogout
                      ? const Color(0xFFFFEEEE)
                      : const Color(0xFFFFF3EA),
                  borderRadius: BorderRadius.circular(17),
                ),

                child: Icon(
                  icon,
                  color: isLogout
                      ? Colors.red
                      : orangeColor,
                  size: 30,
                ),
              ),

              const SizedBox(width: 20),

              // ==================================================
              // TITRE
              // ==================================================

              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isLogout
                        ? Colors.red
                        : primaryColor,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // ==================================================
              // FLÈCHE
              // ==================================================

              Icon(
                Icons.chevron_right,
                color: isLogout
                    ? Colors.red.shade300
                    : Colors.grey.shade500,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}