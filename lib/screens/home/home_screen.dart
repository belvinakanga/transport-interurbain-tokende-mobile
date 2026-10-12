import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../auth/login_screen.dart';
import '../voyages/mes_voyages_screen.dart';
import 'widgets/home_search_card.dart';
import 'widgets/tk_next_trip_card.dart';
import '../../services/prochain_voyage_service.dart';
import '../../config/app_config.dart';
import '../../utils/format_trajet.dart';
import '../../widgets/tk/tk.dart';

import '../profile/profile_screen.dart';
import '../profile/personal_information_screen.dart';
import '../profile/settings_screen.dart';
import '../profile/help_support_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  // 0 = Accueil
  // 1 = Rechercher
  // 2 = Mes voyages
  // 3 = Profil
  final int initialVoyagesTabIndex;

  const HomeScreen({
    super.key,
    this.initialIndex = 0,
    this.initialVoyagesTabIndex = 0,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;

  // ============================================================
  // INFORMATIONS UTILISATEUR
  // ============================================================

  String _userName = 'Belvina';

  bool _isLoadingUser = true;

  // ============================================================
  // COULEURS TOKENTE
  // ============================================================

  static const Color primaryColor =
  Color(0xFF0A2A66);

  static const Color orangeColor =
  Color(0xFFFF6B00);

  static const Color lightBackground =
  Color(0xFFF8F9FB);

  // ============================================================
  // STOCKAGE
  // ============================================================

  static const FlutterSecureStorage _storage =
  FlutterSecureStorage();

  // ============================================================
  // URL API LARAVEL
  // ============================================================

  // ============================================================
  // PROCHAIN DÉPART
  //
  // Déduit côté application à partir de /reservations et /achats, qui sont
  // déjà filtrés par utilisateur. Aucun endpoint n'a été ajouté au backend.
  // Le Future est créé à la déclaration pour ne pas avoir à modifier
  // initState().
  // ============================================================

  /// Onglet ouvert dans « Mes voyages » : 0 Réservations, 1 Achats.
  late int _voyagesTabIndex = widget.initialVoyagesTabIndex;

  /// Pilote le glissement horizontal entre les quatre onglets.
  late final PageController _pageController =
      PageController(initialPage: _currentIndex);

  final ProchainVoyageService _serviceProchainVoyage =
      ProchainVoyageService();

  late Future<ProchainVoyage?> _futureProchainVoyage =
      _serviceProchainVoyage.charger();

  String get apiBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }

    // Android Emulator
    return 'http://10.0.2.2:8000/api';
  }

  // ============================================================
  // INITIALISATION
  // ============================================================

  @override
  void initState() {
    super.initState();

    _currentIndex =
        widget.initialIndex.clamp(0, 3);

    _loadUserInformation();
  }

  // ============================================================
  // RÉCUPÉRER LE NOM DEPUIS LARAVEL
  // ============================================================

  Future<void> _loadUserInformation() async {
    try {
      final token = await _storage.read(
        key: 'auth_token',
      );

      if (token == null || token.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoadingUser = false;
          });
        }

        return;
      }

      final response = await http.get(
        Uri.parse('$apiBaseUrl/me'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final user =
            data['user'] ?? data;

        final name =
        user['name']?.toString().trim();

        if (name != null && name.isNotEmpty) {
          await _storage.write(
            key: 'user_name',
            value: name,
          );

          if (!mounted) return;

          setState(() {
            _userName = name;
            _isLoadingUser = false;
          });

          return;
        }
      }

      // ----------------------------------------------------------
      // Si Laravel ne renvoie pas le nom
      // ----------------------------------------------------------

      final storedName =
      await _storage.read(
        key: 'user_name',
      );

      if (storedName != null &&
          storedName.isNotEmpty) {
        if (!mounted) return;

        setState(() {
          _userName = storedName;
          _isLoadingUser = false;
        });

        return;
      }

      if (!mounted) return;

      setState(() {
        _isLoadingUser = false;
      });
    } catch (_) {
      // ----------------------------------------------------------
      // En cas d'erreur réseau
      // ----------------------------------------------------------

      try {
        final storedName =
        await _storage.read(
          key: 'user_name',
        );

        if (storedName != null &&
            storedName.isNotEmpty) {
          if (!mounted) return;

          setState(() {
            _userName = storedName;
            _isLoadingUser = false;
          });

          return;
        }
      } catch (_) {}

      if (!mounted) return;

      setState(() {
        _isLoadingUser = false;
      });
    }
  }

  // ============================================================
  // CHANGEMENT DE PAGE
  // ============================================================

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavigationItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // L'appui et le glissement pilotent la même vue : on anime le PageView
    // pour que les deux restent cohérents.
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }

    // Lorsque l'utilisateur revient sur Accueil,
    // on recharge son nom.
    if (index == 0) {
      _loadUserInformation();
    }
  }

  // ============================================================
  // ACCUEIL
  // ============================================================

  Widget _buildHomePage() {
    return Scaffold(
      backgroundColor: AppColors.fond(context),

      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.orange,
          onRefresh: _rafraichirAccueil,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.margeEcran,
              AppSpacing.xs,
              AppSpacing.margeEcran,
              // Place réservée à la barre flottante.
              108,
            ),
            children: [

              _enTeteAccueil(),

              const SizedBox(height: AppSpacing.xl),

              _carteProchainVoyage(),

              const SizedBox(height: AppSpacing.md),

              _boutonNouvelleRecherche(),

              const SizedBox(height: AppSpacing.xxl),

              const TkSectionHeader(titre: 'Raccourcis'),

              _grilleRaccourcis(),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // EN-TÊTE
  // ------------------------------------------------------------

  Widget _enTeteAccueil() {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.orangeDoux(context),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_rounded,
            color: AppColors.orange,
            size: 22,
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Bonjour', style: AppText.petit(context)),
              Text(
                _isLoadingUser ? '…' : _userName,
                overflow: TextOverflow.ellipsis,
                style: AppText.corpsFort(context).copyWith(fontSize: 18),
              ),
            ],
          ),
        ),

        TkIconButton(
          icone: Icons.notifications_none_rounded,
          infobulle: 'Notifications',
          onPressed: () {
            _showComingSoon(
              'Les notifications seront disponibles prochainement.',
            );
          },
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // PROCHAIN DÉPART
  // ------------------------------------------------------------

  Widget _carteProchainVoyage() {
    return FutureBuilder<ProchainVoyage?>(
      future: _futureProchainVoyage,
      builder: (context, snapshot) {
        final enCours =
            snapshot.connectionState == ConnectionState.waiting;

        final voyage = snapshot.data;

        return TkNextTripCard(
          voyage: voyage,
          enChargement: enCours,
          libelleAction: (voyage?.aUnBillet ?? false)
              ? 'Voir mon billet'
              : 'Voir ma réservation',
          onVoirBillet: voyage == null
              ? null
              : () => _ouvrirBillet(voyage),
          onChercher: () => _onNavigationItemTapped(1),
        );
      },
    );
  }

  /// Ouvre le billet du prochain départ.
  ///
  /// Tant qu'aucun billet n'a été émis — réservation non encore payée —
  /// on bascule sur « Mes voyages » plutôt que d'afficher un billet vide.
  void _ouvrirBillet(ProchainVoyage voyage) {
    if (!voyage.aUnBillet) {
      _openMesVoyages(0);
      return;
    }

    final qr = voyage.qrCode ?? '-';

    TkBilletSheet.afficher(
      context,
      urlPublique: AppConfig.urlBillet(qr),
      billet: BilletAffichage(
        numero: voyage.numeroBillet ?? '-',
        qrCode: qr,
        agence: voyage.nomAgence,
        adresseAgence: voyage.adresseAgence,
        depart: voyage.depart,
        arrivee: voyage.arrivee,
        date: FormatTrajet.date(voyage.trajet) ??
            FormatTrajet.dateDepuisDateTime(voyage.dateHeureDepart),
        heure: FormatTrajet.heureDepart(voyage.trajet) ??
            FormatTrajet.heureDepuisDateTime(voyage.dateHeureDepart),
        voyageurs: voyage.voyageurs,
        sieges: voyage.sieges,
      ),
    );
  }

  /// Relance la requête du prochain départ et recharge le nom affiché.
  Future<void> _rafraichirAccueil() async {
    final future = _serviceProchainVoyage.charger();

    setState(() {
      _futureProchainVoyage = future;
    });

    await Future.wait([
      future,
      _loadUserInformation(),
    ]);
  }

  // ------------------------------------------------------------
  // RECHERCHE REPLIÉE
  // ------------------------------------------------------------

  Widget _boutonNouvelleRecherche() {
    return TkCard(
      onTap: () => _onNavigationItemTapped(1),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 20,
            color: AppColors.orange,
          ),

          const SizedBox(width: AppSpacing.sm),

          Expanded(
            child: Text(
              'Chercher un nouveau trajet',
              style: AppText.corpsFort(context),
            ),
          ),

          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: AppColors.secondaire(context),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // RACCOURCIS
  // ------------------------------------------------------------

  Widget _grilleRaccourcis() {
    final raccourcis = <_Raccourci>[
      _Raccourci(
        icone: Icons.confirmation_number_outlined,
        libelle: 'Mes billets',
        onTap: () => _openMesVoyages(1),
      ),
      _Raccourci(
        icone: Icons.event_note_outlined,
        libelle: 'Réservations',
        onTap: () => _openMesVoyages(0),
      ),
      _Raccourci(
        icone: Icons.headset_mic_outlined,
        libelle: 'Assistance',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const HelpSupportScreen(),
            ),
          );
        },
      ),
    ];

    // Trois colonnes, trois raccourcis : une rangée pleine, sans troncature.
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.sm,
      mainAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1,
      children: [
        for (final r in raccourcis)
          TkCard(
            onTap: r.onTap,
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.orangeDoux(context),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    r.icone,
                    size: 20,
                    color: AppColors.orange,
                  ),
                ),

                const SizedBox(height: AppSpacing.xs),

                Text(
                  r.libelle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.petit(context).copyWith(
                    fontSize: 13,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                    color: AppColors.titre(context),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ============================================================
  // RECHERCHE
  // ============================================================

  Widget _buildSearchPage() {
    return Scaffold(
      backgroundColor: AppColors.fond(context),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: AppSpacing.md,
            // Place réservée à la barre flottante.
            bottom: 108,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.margeEcran,
                  0,
                  AppSpacing.margeEcran,
                  AppSpacing.md,
                ),
                child: Text(
                  'Où allez-vous ?',
                  style: AppText.titre(context),
                ),
              ),

              const HomeSearchCard(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PROFIL
  // ============================================================

  Widget _buildProfilePage() {
    return ProfileScreen(
      onPersonalInformation:
          () async {
        await Navigator.push(
          context,

          MaterialPageRoute(
            builder: (_) =>
            const PersonalInformationScreen(),
          ),
        );

        await _loadUserInformation();

        if (!mounted) return;

        setState(() {});
      },

      // NE PAS TOUCHER :
      // Mes voyages fonctionne déjà.

      onMesVoyages: () {
        _onNavigationItemTapped(2);
      },

      onSettings: () {
        Navigator.push(
          context,

          MaterialPageRoute(
            builder: (_) =>
            const SettingsScreen(),
          ),
        );
      },

      onHelp: () {
        Navigator.push(
          context,

          MaterialPageRoute(
            builder: (_) =>
            const HelpSupportScreen(),
          ),
        );
      },

      onLogout: () {
        _logout();
      },
    );
  }

  // ============================================================
  // OUVRIR MES VOYAGES
  // ============================================================

  /// Ouvre « Mes voyages » sur l'onglet demandé.
  ///
  /// 0 = Réservations, 1 = Achats. Le paramètre était ignoré jusqu'ici :
  /// tous les raccourcis arrivaient sur l'onglet par défaut.
  void _openMesVoyages(int tabIndex) {
    setState(() {
      _voyagesTabIndex = tabIndex.clamp(0, 1);
    });

    _onNavigationItemTapped(2);
  }

  // ============================================================
  // DÉCONNEXION
  // ============================================================

  Future<void> _logout() async {
    final confirmed =
    await showDialog<bool>(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
          Colors.white,

          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
              22,
            ),
          ),

          title: const Text(
            'Se déconnecter',

            style: TextStyle(
              color:
              primaryColor,

              fontWeight:
              FontWeight.bold,
            ),
          ),

          content: const Text(
            'Voulez-vous vraiment vous déconnecter de votre compte Tokende ?',

            style: TextStyle(
              color:
              Colors.black87,

              fontSize: 15,

              height: 1.4,
            ),
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },

              child:
              const Text(
                'Annuler',

                style:
                TextStyle(
                  color:
                  primaryColor,

                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },

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
                    12,
                  ),
                ),
              ),

              child:
              const Text(
                'Se déconnecter',

                style:
                TextStyle(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _storage.delete(
        key: 'auth_token',
      );

      await _storage.delete(
        key: 'user_id',
      );

      await _storage.delete(
        key: 'user_name',
      );

      await _storage.delete(
        key: 'user_email',
      );

      await _storage.delete(
        key: 'user_role',
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,

        MaterialPageRoute(
          builder: (_) =>
          const LoginScreen(),
        ),

            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      TkToast.erreur(
        context,
        'Impossible de terminer la déconnexion.',
      );
    }
  }

  // ============================================================
  // MESSAGE TEMPORAIRE
  // ============================================================

  void _showComingSoon(
      String message,
      ) {
    TkToast.attente(context, message);
  }

  // ============================================================
  // BUILD PRINCIPAL
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor: AppColors.fond(context),

      // La barre flotte au-dessus du contenu : celui-ci passe dessous
      // quand on fait défiler, d'où l'absence de bottomNavigationBar.
      extendBody: true,

      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          if (index == _currentIndex) return;

          setState(() => _currentIndex = index);

          // Même rafraîchissement que sur un appui d'onglet.
          if (index == 0) _loadUserInformation();
        },

        children: [

          // ======================================================
          // ACCUEIL
          // ======================================================

          _buildHomePage(),

          // ======================================================
          // RECHERCHE
          // ======================================================

          _buildSearchPage(),

          // ======================================================
          // MES VOYAGES
          //
          // ON NE TOUCHE PAS À CET ÉCRAN.
          // ======================================================

          MesVoyagesScreen(
            initialTabIndex: _voyagesTabIndex,
          ),

          // ======================================================
          // PROFIL
          // ======================================================

          _buildProfilePage(),
        ],
      ),

      // ========================================================
      // BARRE DE NAVIGATION FLOTTANTE
      // ========================================================

      floatingActionButton: _barreNavigation(),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
    );
  }
  // ============================================================
  // BARRE DE NAVIGATION
  // ============================================================

  Widget _barreNavigation() {
    final sombre = Theme.of(context).brightness == Brightness.dark;

    const destinations = <(IconData, IconData, String)>[
      (Icons.home_outlined, Icons.home_rounded, 'Accueil'),
      (Icons.search_rounded, Icons.search_rounded, 'Rechercher'),
      (
        Icons.confirmation_number_outlined,
        Icons.confirmation_number_rounded,
        'Mes voyages',
      ),
      (Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: sombre
              ? AppColors.fondSombre
              : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.pleinRond),
          border: Border.all(color: AppColors.inactifTheme(context)),
          // Seule ombre de l'application : la barre flotte au-dessus du
          // contenu qui défile dessous, il lui faut un décollement réel.
          boxShadow: [
            BoxShadow(
              color: AppColors.bleuNuit.withValues(
                alpha: sombre ? 0.45 : 0.10,
              ),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < destinations.length; i++)
              _ongletNavigation(
                index: i,
                icone: destinations[i].$1,
                iconeActive: destinations[i].$2,
                libelle: destinations[i].$3,
              ),
          ],
        ),
      ),
    );
  }

  /// Un onglet de la barre.
  ///
  /// L'onglet actif s'élargit pour afficher son libellé ; les autres se
  /// réduisent à leur icône. Le libellé reste donc lisible sans encombrer
  /// la barre, et l'animation suit le glissement.
  Widget _ongletNavigation({
    required int index,
    required IconData icone,
    required IconData iconeActive,
    required String libelle,
  }) {
    final actif = _currentIndex == index;

    return Semantics(
      selected: actif,
      button: true,
      label: libelle,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onNavigationItemTapped(index),
          borderRadius: BorderRadius.circular(AppRadius.pleinRond),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            height: 46,
            padding: EdgeInsets.symmetric(
              horizontal: actif ? AppSpacing.md : AppSpacing.sm + 2,
            ),
            decoration: BoxDecoration(
              color: actif
                  ? AppColors.orangeDoux(context)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.pleinRond),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  actif ? iconeActive : icone,
                  size: 21,
                  color: actif
                      ? AppColors.orange
                      : AppColors.secondaire(context),
                ),

                // Le libellé apparaît en s'élargissant, sans à-coup.
                AnimatedSize(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  child: actif
                      ? Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Text(
                            libelle,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.orange,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

/// Description d'un raccourci de l'accueil.
class _Raccourci {
  final IconData icone;
  final String libelle;
  final VoidCallback onTap;

  const _Raccourci({
    required this.icone,
    required this.libelle,
    required this.onTap,
  });
}
