import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../auth/login_screen.dart';
import '../voyages/mes_voyages_screen.dart';
import 'widgets/home_search_card.dart';
import 'widgets/quick_service_card.dart';

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

  void _onNavigationItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

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
      backgroundColor: lightBackground,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              // ==================================================
              // HEADER
              // ==================================================

              Container(
                width: double.infinity,

                padding:
                const EdgeInsets.fromLTRB(
                  20,
                  25,
                  20,
                  30,
                ),

                decoration:
                const BoxDecoration(
                  color: primaryColor,

                  borderRadius:
                  BorderRadius.only(
                    bottomLeft:
                    Radius.circular(30),

                    bottomRight:
                    Radius.circular(30),
                  ),
                ),

                child: Column(
                  children: [

                    Row(
                      children: [

                        // AVATAR

                        const CircleAvatar(
                          radius: 25,

                          backgroundColor:
                          Colors.white,

                          child: Icon(
                            Icons.person,
                            color:
                            primaryColor,
                          ),
                        ),

                        const SizedBox(
                          width: 15,
                        ),

                        // NOM

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                            children: [

                              const Text(
                                'Bonjour 👋',

                                style:
                                TextStyle(
                                  color:
                                  Colors.white70,

                                  fontSize: 15,
                                ),
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Text(
                                _isLoadingUser
                                    ? '...'
                                    : _userName,

                                maxLines: 1,

                                overflow:
                                TextOverflow
                                    .ellipsis,

                                style:
                                const TextStyle(
                                  color:
                                  Colors.white,

                                  fontSize: 24,

                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // NOTIFICATIONS

                        IconButton(
                          onPressed: () {
                            ScaffoldMessenger
                                .of(context)
                                .hideCurrentSnackBar();

                            ScaffoldMessenger
                                .of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Les notifications seront disponibles prochainement.',
                                ),
                              ),
                            );
                          },

                          icon: const Icon(
                            Icons
                                .notifications_none,

                            color:
                            Colors.white,

                            size: 30,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    const Text(
                      'Réservez vos trajets en toute simplicité',

                      textAlign:
                      TextAlign.center,

                      style:
                      TextStyle(
                        color:
                        Colors.white,

                        fontSize: 18,

                        fontWeight:
                        FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              // ==================================================
              // RECHERCHE
              // ==================================================

              const HomeSearchCard(),

              const SizedBox(
                height: 30,
              ),

              // ==================================================
              // SERVICES RAPIDES
              // ==================================================

              Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child: Row(
                  children: [

                    // MES BILLETS

                    Expanded(
                      child:
                      QuickServiceCard(
                        icon: Icons
                            .confirmation_number_outlined,

                        iconColor:
                        Colors.blue,

                        backgroundColor:
                        const Color(
                          0xFFEAF2FF,
                        ),

                        title:
                        'Mes billets',

                        onTap: () {
                          _openMesVoyages(1);
                        },
                      ),
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    // RÉSERVATIONS

                    Expanded(
                      child:
                      QuickServiceCard(
                        icon: Icons
                            .book_online_outlined,

                        iconColor:
                        Colors.orange,

                        backgroundColor:
                        const Color(
                          0xFFFFF3E8,
                        ),

                        title:
                        'Réservations',

                        onTap: () {
                          _openMesVoyages(0);
                        },
                      ),
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    // COLIS

                    Expanded(
                      child:
                      QuickServiceCard(
                        icon: Icons
                            .local_shipping_outlined,

                        iconColor:
                        Colors.green,

                        backgroundColor:
                        const Color(
                          0xFFE8F8EE,
                        ),

                        title:
                        'Colis',

                        onTap: () {
                          _showComingSoon(
                            'Le service colis sera disponible prochainement.',
                          );
                        },
                      ),
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    // SUPPORT

                    Expanded(
                      child:
                      QuickServiceCard(
                        icon:
                        Icons.support_agent,

                        iconColor:
                        Colors.purple,

                        backgroundColor:
                        const Color(
                          0xFFF4ECFF,
                        ),

                        title:
                        'Support',

                        onTap: () {
                          _showComingSoon(
                            'Le support sera disponible prochainement.',
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              // ==================================================
              // SECTION INFORMATIVE
              // ==================================================

              Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child: Container(
                  width: double.infinity,

                  padding:
                  const EdgeInsets.all(20),

                  decoration:
                  BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color:
                        Colors.black
                            .withValues(
                          alpha: 0.05,
                        ),

                        blurRadius: 12,

                        offset:
                        const Offset(
                          0,
                          4,
                        ),
                      ),
                    ],
                  ),

                  child: Row(
                    children: [

                      Container(
                        width: 50,
                        height: 50,

                        decoration:
                        BoxDecoration(
                          color:
                          const Color(
                            0xFFFFF3EB,
                          ),

                          borderRadius:
                          BorderRadius
                              .circular(
                            14,
                          ),
                        ),

                        child: const Icon(
                          Icons
                              .verified_user_outlined,

                          color:
                          orangeColor,

                          size: 27,
                        ),
                      ),

                      const SizedBox(
                        width: 14,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                          children: [

                            const Text(
                              'Voyagez en toute confiance',

                              style:
                              TextStyle(
                                color:
                                primaryColor,

                                fontSize: 15,

                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 5,
                            ),

                            Text(
                              'Réservez votre siège et retrouvez facilement vos voyages.',

                              style:
                              TextStyle(
                                color:
                                Colors.grey
                                    .shade600,

                                fontSize: 12,

                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // RECHERCHE
  // ============================================================

  Widget _buildSearchPage() {
    return Scaffold(
      backgroundColor:
      lightBackground,

      appBar: AppBar(
        backgroundColor:
        primaryColor,

        foregroundColor:
        Colors.white,

        elevation: 0,

        title: const Text(
          'Rechercher un trajet',

          style: TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child:
        SingleChildScrollView(
          padding:
          const EdgeInsets.only(
            top: 20,
            bottom: 30,
          ),

          child:
          const HomeSearchCard(),
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

  void _openMesVoyages(
      int tabIndex,
      ) {
    setState(() {
      _currentIndex = 2;
    });
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

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible de terminer la déconnexion.',
          ),

          behavior:
          SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // MESSAGE TEMPORAIRE
  // ============================================================

  void _showComingSoon(
      String message,
      ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content:
          Text(message),

          behavior:
          SnackBarBehavior.floating,

          duration:
          const Duration(
            seconds: 3,
          ),
        ),
      );
  }

  // ============================================================
  // BUILD PRINCIPAL
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      lightBackground,

      body: IndexedStack(
        index:
        _currentIndex,

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
            initialTabIndex:
            widget
                .initialVoyagesTabIndex,
          ),

          // ======================================================
          // PROFIL
          // ======================================================

          _buildProfilePage(),
        ],
      ),

      // ========================================================
      // BARRE DE NAVIGATION
      // ========================================================

      bottomNavigationBar:
      NavigationBar(
        selectedIndex:
        _currentIndex,

        onDestinationSelected:
        _onNavigationItemTapped,

        backgroundColor:
        Colors.white,

        indicatorColor:
        const Color(
          0xFFFFF3EB,
        ),

        elevation: 8,

        destinations: [

          // ====================================================
          // ACCUEIL
          // ====================================================

          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,

              color:
              Colors.grey.shade700,
            ),

            selectedIcon:
            const Icon(
              Icons.home,

              color:
              orangeColor,
            ),

            label:
            'Accueil',
          ),

          // ====================================================
          // RECHERCHER
          // ====================================================

          NavigationDestination(
            icon: Icon(
              Icons.search_outlined,

              color:
              Colors.grey.shade700,
            ),

            selectedIcon:
            const Icon(
              Icons.search,

              color:
              orangeColor,
            ),

            label:
            'Rechercher',
          ),

          // ====================================================
          // MES VOYAGES
          // ====================================================

          NavigationDestination(
            icon: Icon(
              Icons
                  .confirmation_number_outlined,

              color:
              Colors.grey.shade700,
            ),

            selectedIcon:
            const Icon(
              Icons.confirmation_number,

              color:
              orangeColor,
            ),

            label:
            'Mes voyages',
          ),

          // ====================================================
          // PROFIL
          // ====================================================

          NavigationDestination(
            icon: Icon(
              Icons.person_outline,

              color:
              Colors.grey.shade700,
            ),

            selectedIcon:
            const Icon(
              Icons.person,

              color:
              orangeColor,
            ),

            label:
            'Profil',
          ),
        ],
      ),
    );
  }
}