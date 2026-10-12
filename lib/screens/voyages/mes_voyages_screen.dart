import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../avis/avis_screen.dart';
import '../../config/app_config.dart';
import '../../utils/format_trajet.dart';
import '../../widgets/tk/tk.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MesVoyagesScreen extends StatefulWidget {
  final int initialTabIndex;

  const MesVoyagesScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<MesVoyagesScreen> createState() => _MesVoyagesScreenState();
}

class _MesVoyagesScreenState extends State<MesVoyagesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color primaryColor = Color(0xFF0A2A66);
  static const Color orangeColor = Color(0xFFFF6B00);
  static const Color backgroundColor = Color(0xFFF8F9FB);

  static const String baseUrl =
      'http://127.0.0.1:8000/api';

  static const FlutterSecureStorage storage =
  FlutterSecureStorage();

  bool _loadingReservations = true;
  bool _loadingAchats = true;
  bool _payingReservation = false;

  String? _reservationError;
  String? _achatError;

  List<Map<String, dynamic>> _reservations = [];
  List<Map<String, dynamic>> _filteredReservations = [];
  List<Map<String, dynamic>> _achats = [];
  List<Map<String, dynamic>> _filteredAchats = [];

  final TextEditingController _searchController =
  TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1).toInt(),
    );

    _loadReservations();
    _loadAchats();
  }

  @override
  void didUpdateWidget(covariant MesVoyagesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // L'écran reste monté dans la PageView de l'accueil : un raccourci qui
    // demande un autre onglet doit déplacer le TabController existant.
    if (widget.initialTabIndex != oldWidget.initialTabIndex) {
      final cible = widget.initialTabIndex.clamp(0, 1);

      if (_tabController.index != cible) {
        _tabController.animateTo(cible);
      }
    }
  }

  Future<void> _reloadAll() async {
    await Future.wait([
      _loadReservations(),
      _loadAchats(),
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

// ============================================================
// TOKEN
// ============================================================

  Future<String?> _getToken() async {
    return storage.read(
      key: 'auth_token',
    );
  }

// ============================================================
// RÉSERVATIONS
// ============================================================

  Future<void> _loadReservations() async {
    if (!mounted) return;

    setState(() {
      _loadingReservations = true;
      _reservationError = null;
    });

    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Session expirée.',
        );
      }

      final response = await http.get(
        Uri.parse(
          '$baseUrl/reservations',
        ),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final decoded =
      jsonDecode(response.body);

      if (response.statusCode == 200) {
        final list = decoded is List
            ? decoded
            : decoded['data'] ??
            decoded['reservations'] ??
            [];

        if (!mounted) return;

        setState(() {
          _reservations =
          List<Map<String, dynamic>>.from(
            list,
          );

          _filteredReservations =
          List<Map<String, dynamic>>.from(
            list,
          );

          _filteredReservations = List<Map<String, dynamic>>.from(
            _reservations,
          );

          _loadingReservations = false;
        });

        return;
      }

      throw Exception(
        decoded['message'] ??
            'Erreur lors du chargement des réservations.',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingReservations = false;

        _reservationError =
            e
                .toString()
                .replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

// ============================================================
// ACHATS
// ============================================================

  Future<void> _loadAchats() async {
    if (!mounted) return;

    setState(() {
      _loadingAchats = true;
      _achatError = null;
    });

    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Session expirée.',
        );
      }

      final response = await http.get(
        Uri.parse(
          '$baseUrl/achats',
        ),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final decoded =
      jsonDecode(response.body);

      if (response.statusCode == 200) {
        final dynamic rawList = decoded is List
            ? decoded
            : decoded['data'] ??
            decoded['achats'] ??
            [];

        final list = rawList is List
            ? rawList
            : (rawList is Map && rawList['data'] is List)
            ? rawList['data']
            : (rawList is Map && rawList['achats'] is List)
            ? rawList['achats']
            : [];

        if (!mounted) return;

        setState(() {
          _achats =
          List<Map<String, dynamic>>.from(
            list,
          );

          _filteredAchats = List<Map<String, dynamic>>.from(
            _achats,
          );

          _loadingAchats = false;
        });

        return;
      }

      throw Exception(
        decoded['message'] ??
            'Erreur lors du chargement des achats.',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingAchats = false;

        _achatError =
            e
                .toString()
                .replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

// ============================================================
// PAIEMENT
// ============================================================

  Future<void> _payReservation(
      Map<String, dynamic> reservation,
      ) async {
    final id = reservation['id'];

    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Confirmer le paiement',
        ),
        content: const Text(
          'Voulez-vous payer cette réservation ?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
                  context,
                  false,
                ),
            child: const Text(
              'Annuler',
            ),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(
                  context,
                  true,
                ),
            style:
            ElevatedButton.styleFrom(
              backgroundColor:
              orangeColor,
              foregroundColor:
              Colors.white,
            ),
            child: const Text(
              'Payer',
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (mounted) {
      setState(() {
        _payingReservation = true;
      });
    }

    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Session expirée.',
        );
      }

      final response = await http.post(
        Uri.parse(
          '$baseUrl/reservations/$id/payer',
        ),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final decoded =
      jsonDecode(response.body);

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          decoded['message'] ??
              'Échec du paiement.',
        );
      }

      _showMessage(
        decoded['message'] ??
            'Paiement effectué.',
        isError: false,
      );

      await _loadReservations();
      await _loadAchats();
    } catch (e) {
      _showMessage(
        e
            .toString()
            .replaceFirst(
          'Exception: ',
          '',
        ),
        isError: true,
      );
    }

    if (mounted) {
      setState(() {
        _payingReservation = false;
      });
    }
  }

// ============================================================
// ANNULATION
// ============================================================

  Future<void> _cancelReservation(
      Map<String, dynamic> reservation,
      ) async {
    final id = reservation['id'];

    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Annuler ?',
        ),
        content: const Text(
          'Voulez-vous vraiment annuler cette réservation ?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
                  context,
                  false,
                ),
            child: const Text(
              'Non',
            ),
          ),
          ElevatedButton(
            style:
            ElevatedButton.styleFrom(
              backgroundColor:
              Colors.red,
              foregroundColor:
              Colors.white,
            ),
            onPressed: () =>
                Navigator.pop(
                  context,
                  true,
                ),
            child: const Text(
              'Oui',
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Session expirée.',
        );
      }

      final response = await http.post(
        Uri.parse(
          '$baseUrl/reservations/$id/annuler',
        ),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final decoded =
      jsonDecode(response.body);

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          decoded['message'] ??
              'Impossible d’annuler.',
        );
      }

      _showMessage(
        decoded['message'] ??
            'Réservation annulée.',
        isError: false,
      );

      await _loadReservations();
    } catch (e) {
      _showMessage(
        e
            .toString()
            .replaceFirst(
          'Exception: ',
          '',
        ),
        isError: true,
      );
    }
  }

// ============================================================
// SUPPRESSION
// ============================================================

  Future<void> _deleteReservation(
      Map<String, dynamic> reservation,
      ) async {
    final id = reservation['id'];

    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Supprimer la réservation',
        ),
        content: const Text(
          'Cette réservation sera supprimée définitivement. Continuer ?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
                  context,
                  false,
                ),
            child: const Text(
              'Annuler',
            ),
          ),
          ElevatedButton(
            style:
            ElevatedButton.styleFrom(
              backgroundColor:
              Colors.red,
            ),
            onPressed: () =>
                Navigator.pop(
                  context,
                  true,
                ),
            child: const Text(
              'Supprimer',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Session expirée.',
        );
      }

      final response = await http.delete(
        Uri.parse(
          '$baseUrl/reservations/$id',
        ),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final decoded =
      jsonDecode(response.body);

      if (response.statusCode == 200) {
        _showMessage(
          decoded['message'] ??
              'Réservation supprimée.',
          isError: false,
        );

        await _loadReservations();
      } else {
        _showMessage(
          decoded['message'] ??
              'Impossible de supprimer.',
          isError: true,
        );
      }
    } catch (e) {
      _showMessage(
        e
            .toString()
            .replaceFirst(
          'Exception: ',
          '',
        ),
        isError: true,
      );
    }
  }

// ============================================================
// RECHERCHE
// ============================================================

  void _onSearchChanged(String value) {
    final query = value.trim().toLowerCase();

    setState(() {
      _searchQuery = query;

      if (query.isEmpty) {
        _filteredReservations =
        List<Map<String, dynamic>>.from(
          _reservations,
        );

        _filteredAchats =
        List<Map<String, dynamic>>.from(
          _achats,
        );

        return;
      }

      _filteredReservations = _reservations.where((reservation) {
        return _matchesSearch(reservation, isAchat: false, query: query);
      }).toList();

      _filteredAchats = _achats.where((achat) {
        return _matchesSearch(achat, isAchat: true, query: query);
      }).toList();
    });
  }

  bool _matchesSearch(
      Map<String, dynamic> item, {
        required bool isAchat,
        required String query,
      }) {
    final trip = _trip(item);
    final agency = _agency(item);

    String reservationPassengerText =
    _passengerNames(item).join(' ');

    String seatText = '';

    if (isAchat) {
      seatText = _achatSeats(item).join(' ');
    } else {
      seatText = _reservationSeats(item).join(' ');
    }

    final searchText = [
      agency?['nom_agence'],
      agency?['nom'],
      agency?['name'],
      trip?['depart'],
      trip?['arrivee'],
      trip?['date_depart'],
      trip?['heure_depart'],
      item['id'],
      item['statut'],
      item['montant'],
      item['total'],
      reservationPassengerText,
      seatText,
    ].where((value) => value != null).join(' ').toLowerCase();

    return searchText.contains(query);
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
  }


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
            _enTete(),
            _barreRecherche(),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ongletReservations(),
                  _ongletAchats(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EN-TÊTE ET ONGLETS
  // ============================================================

  Widget _enTete() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.margeEcran,
        AppSpacing.md,
        AppSpacing.margeEcran,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mes voyages', style: AppText.titre(context)),

          const SizedBox(height: AppSpacing.md),

          // Onglets posés sur un rail gris plutôt que sous une barre bleue :
          // l'écran garde un seul fond et le contenu commence plus haut.
          Container(
            height: 44,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.inactifTheme(context),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.fondSombre
                    : Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              labelColor: AppColors.orange,
              unselectedLabelColor: AppColors.secondaire(context),
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Réservations'),
                Tab(text: 'Achats'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BARRE DE RECHERCHE
  // ============================================================

  Widget _barreRecherche() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.margeEcran,
        AppSpacing.sm,
        AppSpacing.margeEcran,
        AppSpacing.xs,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        textInputAction: TextInputAction.search,
        style: AppText.corpsFort(context).copyWith(fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Ville, agence, destination…',
          hintStyle: AppText.corps(context).copyWith(fontSize: 15),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: AppColors.secondaire(context),
          ),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: AppColors.secondaire(context),
                  tooltip: 'Effacer',
                ),
          filled: true,
          fillColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.fondSombre
              : Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(color: AppColors.inactifTheme(context)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(
              color: AppColors.orange,
              width: 1.5,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(color: AppColors.inactifTheme(context)),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ONGLET RÉSERVATIONS
  // ============================================================

  Widget _ongletReservations() {
    if (_loadingReservations) return _chargement();

    if (_reservationError != null) {
      return _erreur(_reservationError!, _loadReservations);
    }

    if (_filteredReservations.isEmpty) {
      return _vide(
        icone: _searchQuery.isEmpty
            ? Icons.event_note_outlined
            : Icons.search_off_rounded,
        titre: _searchQuery.isEmpty
            ? 'Aucune réservation'
            : 'Aucun résultat',
        message: _searchQuery.isEmpty
            ? 'Vos réservations apparaîtront ici une fois un trajet réservé.'
            : 'Aucune réservation ne correspond à « $_searchQuery ».',
        libelleAction: _searchQuery.isEmpty ? null : 'Effacer la recherche',
        onAction: _searchQuery.isEmpty ? null : _clearSearch,
      );
    }

    return RefreshIndicator(
      color: AppColors.orange,
      onRefresh: _loadReservations,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.margeEcran,
          AppSpacing.sm,
          AppSpacing.margeEcran,
          // Place réservée à la barre flottante.
          108,
        ),
        itemCount: _filteredReservations.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) =>
            _carteReservation(_filteredReservations[index]),
      ),
    );
  }

  // ============================================================
  // ONGLET ACHATS
  // ============================================================

  Widget _ongletAchats() {
    if (_loadingAchats) return _chargement();

    if (_achatError != null) return _erreur(_achatError!, _loadAchats);

    if (_filteredAchats.isEmpty) {
      return _vide(
        icone: _searchQuery.isEmpty
            ? Icons.confirmation_number_outlined
            : Icons.search_off_rounded,
        titre: _searchQuery.isEmpty ? 'Aucun achat' : 'Aucun résultat',
        message: _searchQuery.isEmpty
            ? 'Vos billets achetés apparaîtront ici.'
            : 'Aucun achat ne correspond à « $_searchQuery ».',
        libelleAction: _searchQuery.isEmpty ? null : 'Effacer la recherche',
        onAction: _searchQuery.isEmpty ? null : _clearSearch,
      );
    }

    return RefreshIndicator(
      color: AppColors.orange,
      onRefresh: _loadAchats,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.margeEcran,
          AppSpacing.sm,
          AppSpacing.margeEcran,
          // Place réservée à la barre flottante.
          108,
        ),
        itemCount: _filteredAchats.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) => _carteAchat(_filteredAchats[index]),
      ),
    );
  }

  // ============================================================
  // ÉTATS TRANSVERSES
  // ============================================================

  Widget _chargement() {
    return const Center(
      child: SizedBox(
        width: 26,
        height: 26,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          color: AppColors.orange,
        ),
      ),
    );
  }

  Widget _erreur(String message, Future<void> Function() onReessayer) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        TkEmptyState(
          icone: Icons.wifi_off_rounded,
          titre: 'Chargement impossible',
          message: message,
          libelleAction: 'Réessayer',
          onAction: onReessayer,
        ),
      ],
    );
  }

  Widget _vide({
    required IconData icone,
    required String titre,
    required String message,
    String? libelleAction,
    VoidCallback? onAction,
  }) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        TkEmptyState(
          icone: icone,
          titre: titre,
          message: message,
          libelleAction: libelleAction,
          onAction: onAction,
        ),
      ],
    );
  }

  // ============================================================
  // CARTE RÉSERVATION
  // ============================================================

  Widget _carteReservation(Map<String, dynamic> reservation) {
    final trip = _trip(reservation);
    final agency = _agency(reservation);

    final agencyName = agency?['nom_agence']?.toString() ??
        agency?['nom']?.toString() ??
        agency?['name']?.toString() ??
        '-';

    final depart = trip?['depart']?.toString() ?? '-';
    final arrivee = trip?['arrivee']?.toString() ?? '-';

    final sieges = _reservationSeats(reservation);
    final montant = _reservationAmount(reservation);
    final voyageurs = _passengerNames(reservation);

    final statut = reservation['statut']?.toString() ?? 'En attente';
    final s = statut.toLowerCase();

    final estAnnulee = s.contains('annul');

    // Une réservation confirmée par l'agence donne droit au billet au même
    // titre qu'une réservation payée : les deux ouvrent le billet et l'avis.
    final estHonoree =
        s == 'payée' || s == 'payé' || s.startsWith('confirm');

    // « En attente » ne vaut que si la réservation n'est ni honorée ni
    // annulée, sinon un statut comme « paiement en attente de validation »
    // afficherait les deux jeux de boutons.
    final estEnAttente =
        !estHonoree && !estAnnulee && s.contains('attente');

    return TkCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          _trajetEtStatut(
            depart: depart,
            arrivee: arrivee,
            statut: statut,
          ),

          const SizedBox(height: AppSpacing.sm),

          _detailsVoyage(
            agence: agencyName,
            trajet: trip,
            sieges: sieges,
            montant: montant,
            voyageurs: voyageurs,
          ),

          if (estEnAttente) ...[
            const SizedBox(height: AppSpacing.md),
            TkButton(
              libelle: 'Payer maintenant',
              onPressed: _payingReservation
                  ? null
                  : () => _payReservation(reservation),
              enChargement: _payingReservation,
            ),
            const SizedBox(height: AppSpacing.xs),
            TkButton(
              libelle: 'Annuler la réservation',
              onPressed: () => _cancelReservation(reservation),
              variante: TkButtonVariante.tonal,
            ),
          ],

          if (estAnnulee) ...[
            const SizedBox(height: AppSpacing.md),
            TkButton(
              libelle: 'Supprimer la réservation',
              onPressed: () => _deleteReservation(reservation),
              variante: TkButtonVariante.tonal,
            ),
          ],

          if (estHonoree) ...[
            const SizedBox(height: AppSpacing.md),
            TkButton(
              libelle: 'Voir mon billet',
              onPressed: () => _showTicket({'reservation': reservation}),
              icone: Icons.confirmation_number_outlined,
            ),
            const SizedBox(height: AppSpacing.xs),
            TkButton(
              libelle: 'Donner mon avis',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AvisScreen()),
                );
              },
              variante: TkButtonVariante.tonal,
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // CARTE ACHAT
  // ============================================================

  Widget _carteAchat(Map<String, dynamic> achat) {
    final reservation = achat['reservation'];

    Map<String, dynamic>? trip;
    if (reservation is Map && reservation['trajet'] is Map) {
      trip = Map<String, dynamic>.from(reservation['trajet']);
    } else {
      trip = _trip(achat);
    }

    Map<String, dynamic>? agency;
    if (trip != null && trip['agence'] is Map) {
      agency = Map<String, dynamic>.from(trip['agence']);
    } else {
      agency = _agency(achat);
    }

    final agencyName = agency?['nom_agence']?.toString() ??
        agency?['nom']?.toString() ??
        agency?['name']?.toString() ??
        '-';

    final depart = trip?['depart']?.toString() ?? '-';
    final arrivee = trip?['arrivee']?.toString() ?? '-';
    final prix = _amountFromAchat(achat);

    final sieges = reservation is Map
        ? _reservationSeats(Map<String, dynamic>.from(reservation))
        : _achatSeats(achat);

    final voyageurs = reservation is Map
        ? _passengerNames(Map<String, dynamic>.from(reservation))
        : _passengerNames(achat);

    return TkCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          _trajetEtStatut(
            depart: depart,
            arrivee: arrivee,
            statut: null,
          ),

          const SizedBox(height: AppSpacing.sm),

          _detailsVoyage(
            agence: agencyName,
            trajet: trip,
            sieges: sieges,
            montant: prix,
            voyageurs: voyageurs,
          ),

          const SizedBox(height: AppSpacing.md),

          TkButton(
            libelle: 'Voir mon billet',
            onPressed: () => _showTicket(achat),
            icone: Icons.confirmation_number_outlined,
          ),

          const SizedBox(height: AppSpacing.xs),

          TkButton(
            libelle: 'Donner mon avis',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AvisScreen()),
              );
            },
            variante: TkButtonVariante.tonal,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BLOCS PARTAGÉS PAR LES DEUX CARTES
  // ============================================================

  /// Villes de départ et d'arrivée, puce de statut à droite.
  Widget _trajetEtStatut({
    required String depart,
    required String arrivee,
    required String? statut,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ville(depart, Icons.trip_origin_rounded),
              Padding(
                padding: const EdgeInsets.only(left: 7),
                child: Container(
                  width: 2,
                  height: 14,
                  color: AppColors.inactifTheme(context),
                ),
              ),
              _ville(arrivee, Icons.place_rounded),
            ],
          ),
        ),

        if (statut != null) ...[
          const SizedBox(width: AppSpacing.xs),
          TkChip.statut(statut),
        ],
      ],
    );
  }

  Widget _ville(String nom, IconData icone) {
    return Row(
      children: [
        Icon(icone, size: 15, color: AppColors.orange),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            nom,
            overflow: TextOverflow.ellipsis,
            style: AppText.corpsFort(context).copyWith(fontSize: 17),
          ),
        ),
      ],
    );
  }

  /// Agence, date, heure, sièges, montant, voyageurs.
  ///
  /// Le montant est mis en avant : c'est l'information que l'utilisateur
  /// cherche en premier sur une liste de voyages.
  Widget _detailsVoyage({
    required String agence,
    required Map<String, dynamic>? trajet,
    required List<int> sieges,
    required String montant,
    required List<String> voyageurs,
  }) {
    // Dates et heures viennent du backend, qui normalise les formats
    // hétérogènes de la base ; on n'affiche que ce qui existe réellement.
    final quand = FormatTrajet.dateEtHeure(trajet);
    final arrivee = FormatTrajet.heureArrivee(trajet);
    final duree = FormatTrajet.duree(trajet);

    final lignes = <(IconData, String)>[
      (Icons.business_outlined, agence),
      if (quand != null) (Icons.event_rounded, quand),
      if (arrivee != null)
        (Icons.flag_outlined, 'Arrivée $arrivee'),
      if (duree != null) (Icons.schedule_rounded, duree),
      if (sieges.isNotEmpty)
        (
          Icons.event_seat_outlined,
          sieges.length > 1
              ? 'Sièges ${sieges.join(', ')}'
              : 'Siège ${sieges.first}',
        ),
      if (voyageurs.isNotEmpty)
        (
          Icons.person_outline_rounded,
          voyageurs.length > 2
              ? '${voyageurs.take(2).join(', ')} +${voyageurs.length - 2}'
              : voyageurs.join(', '),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: AppSpacing.md, color: AppColors.inactifTheme(context)),

        Wrap(
          spacing: AppSpacing.md,
          runSpacing: 6,
          children: [
            for (final (icone, texte) in lignes)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icone,
                    size: 14,
                    color: AppColors.secondaire(context),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    texte,
                    style: AppText.petit(context).copyWith(fontSize: 13),
                  ),
                ],
              ),
          ],
        ),

        const SizedBox(height: AppSpacing.sm),

        Row(
          children: [
            Text('Montant', style: AppText.label(context)),
            const Spacer(),
            Text(
              montant,
              style: AppText.corpsFort(context).copyWith(
                fontSize: 18,
                color: AppColors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }


  // ============================================================
  // BILLET
  // ============================================================

  Map<String, dynamic>? _firstTicket(
      Map<String, dynamic> achat,
      ) {
    // ============================================================
    // 1. Billets dans la réservation
    // ============================================================

    final reservation = achat['reservation'];

    if (reservation is Map) {
      final reservationMap =
      Map<String, dynamic>.from(reservation);

      dynamic raw = reservationMap['billets'];

      // Laravel peut renvoyer directement une liste de billets.
      if (raw is List && raw.isNotEmpty) {
        for (final item in raw) {
          if (item is Map) {
            return Map<String, dynamic>.from(item);
          }
        }
      }

      // Laravel peut renvoyer un objet contenant "data".
      if (raw is Map) {
        final data = raw['data'];

        if (data is List && data.isNotEmpty) {
          for (final item in data) {
            if (item is Map) {
              return Map<String, dynamic>.from(item);
            }
          }
        }

        // Billet renvoyé directement comme objet.
        return Map<String, dynamic>.from(raw);
      }

      // Cas où un seul billet est présent.
      final billet = reservationMap['billet'];

      if (billet is Map) {
        return Map<String, dynamic>.from(billet);
      }
    }

    // ============================================================
    // 2. Billets directement dans l'achat
    // ============================================================

    dynamic raw = achat['billets'];

    if (raw is List && raw.isNotEmpty) {
      for (final item in raw) {
        if (item is Map) {
          return Map<String, dynamic>.from(item);
        }
      }
    }

    if (raw is Map) {
      final data = raw['data'];

      if (data is List && data.isNotEmpty) {
        for (final item in data) {
          if (item is Map) {
            return Map<String, dynamic>.from(item);
          }
        }
      }

      return Map<String, dynamic>.from(raw);
    }

    // ============================================================
    // 3. Un seul billet directement dans l'achat
    // ============================================================

    final billet = achat['billet'];

    if (billet is Map) {
      return Map<String, dynamic>.from(billet);
    }

    return null;
  }

  void _showTicket(Map<String, dynamic> achat) {
    final ticket = _firstTicket(achat);

    if (ticket == null) {
      _showMessage(
        'Le billet n’est pas encore disponible. Actualisez les achats après le paiement.',
        isError: true,
      );
      return;
    }

    final reservation =
    achat['reservation'] is Map
        ? Map<String, dynamic>.from(achat['reservation'])
        : <String, dynamic>{};

    final trip =
    reservation['trajet'] is Map
        ? Map<String, dynamic>.from(reservation['trajet'])
        : _trip(achat);

    final agency =
    trip != null && trip['agence'] is Map
        ? Map<String, dynamic>.from(trip['agence'])
        : _agency(achat);

    final agencyName =
        agency?['nom_agence']?.toString() ??
            agency?['nom']?.toString() ??
            agency?['name']?.toString() ??
            'Tokende';
    final agencyAddress =
        agency?['adresse']?.toString() ?? '';

    final depart = trip?['depart']?.toString() ?? '-';
    final arrivee = trip?['arrivee']?.toString() ?? '-';
    // Même source que les cartes : les libellés calculés par le backend.
    final date = FormatTrajet.date(trip) ?? '-';
    final heure = FormatTrajet.heureDepart(trip) ?? '-';

    final voyageurs = reservation.isNotEmpty
        ? _passengerNames(reservation)
        : _passengerNames(achat);

    final sieges = reservation.isNotEmpty
        ? _reservationSeats(reservation)
        : _achatSeats(achat);

    final numero =
        ticket['numero_billet']?.toString() ?? '-';

    final qrCode =
        ticket['qr_code']?.toString() ?? '-';

    // Le billet est rendu par le composant partagé : l'accueil ouvre
    // exactement le même, depuis la carte « prochain départ ».
    TkBilletSheet.afficher(
      context,
      urlPublique: AppConfig.urlBillet(qrCode),
      billet: BilletAffichage(
        numero: numero,
        qrCode: qrCode,
        agence: agencyName,
        adresseAgence: agencyAddress,
        depart: depart,
        arrivee: arrivee,
        date: date,
        heure: heure,
        voyageurs: voyageurs,
        sieges: sieges,
      ),
    );
  }

  Widget _ticketInfoRow(
      IconData icon,
      String label,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: primaryColor,
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(
      String statut,
      ) {
    final lower =
    statut.toLowerCase();

    Color color;
    Color background;

    if (lower ==
        'payée' ||
        lower ==
            'payé') {
      color =
          Colors.green;
      background =
      const Color(
        0xFFEAF7EE,
      );
    } else if (lower
        .contains('annul')) {
      color =
          Colors.red;
      background =
      const Color(
        0xFFFFEEEE,
      );
    } else {
      color =
          orangeColor;
      background =
      const Color(
        0xFFFFF3EB,
      );
    }

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration:
      BoxDecoration(
        color:
        background,
        borderRadius:
        BorderRadius.circular(
          20,
        ),
      ),
      child: Text(
        statut,
        style:
        TextStyle(
          color:
          color,
          fontWeight:
          FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

// ============================================================
// EXTRAIRE LE TRAJET
// ============================================================

  Map<String, dynamic>? _trip(
      Map<String, dynamic> object,
      ) {
    final value =
    object['trajet'];

    if (value is Map) {
      return Map<String, dynamic>.from(
        value,
      );
    }

    return null;
  }

// ============================================================
// EXTRAIRE L'AGENCE
// ============================================================

  Map<String, dynamic>? _agency(
      Map<String, dynamic> object,
      ) {
    final trip =
    _trip(object);

    if (trip != null &&
        trip['agence'] is Map) {
      return Map<String, dynamic>.from(
        trip['agence'],
      );
    }

    if (object['agence'] is Map) {
      return Map<String, dynamic>.from(
        object['agence'],
      );
    }

    return null;
  }

// ============================================================
// EXTRAIRE LES NOMS DES VOYAGEURS
// ============================================================

  List<String> _passengerNames(
      Map<String, dynamic> object,
      ) {
    dynamic raw;

    raw =
        object['voyageurs'] ??
            object['passagers'] ??
            object['passenger'] ??
            object['voyageur'] ??
            object['passager'];

    if (raw == null &&
        object['reservation'] is Map) {
      final reservation =
      Map<String, dynamic>.from(
        object['reservation'],
      );

      raw =
          reservation['voyageurs'] ??
              reservation['passagers'] ??
              reservation['passenger'] ??
              reservation['voyageur'] ??
              reservation['passager'];
    }

    // Si aucun voyageur n'est directement présent, on utilise
    // le titulaire de la réservation / le compte connecté.
    // Laravel renvoie généralement ce compte dans reservation.user.
    if (raw == null && object['user'] is Map) {
      raw = object['user'];
    }

    if (raw == null && object['reservation'] is Map) {
      final reservation =
      Map<String, dynamic>.from(object['reservation']);

      if (reservation['user'] is Map) {
        raw = reservation['user'];
      }
    }

    if (raw == null) {
      return [];
    }

    final List<String> names = [];

// ==========================================================
// CAS 1 : LISTE DE VOYAGEURS
// ==========================================================

    if (raw is List) {
      for (final item in raw) {
        final name =
        _extractPassengerName(
          item,
        );

        if (name != null &&
            name.isNotEmpty) {
          names.add(name);
        }
      }
    }

// ==========================================================
// CAS 2 : UN SEUL VOYAGEUR
// ==========================================================

    else {
      final name =
      _extractPassengerName(
        raw,
      );

      if (name != null &&
          name.isNotEmpty) {
        names.add(name);
      }
    }

    return names
        .toSet()
        .toList();
  }

// ============================================================
// EXTRAIRE UN NOM
// ============================================================

  String? _extractPassengerName(
      dynamic item,
      ) {
    if (item is String) {
      return item.trim();
    }

    if (item is! Map) {
      return null;
    }

    final map =
    Map<String, dynamic>.from(
      item,
    );

    final prenom =
        map['prenom'] ??
            map['first_name'] ??
            map['firstname'] ??
            '';

    final nom =
        map['nom'] ??
            map['last_name'] ??
            map['lastname'] ??
            '';

    final fullName =
        map['name'] ??
            map['full_name'] ??
            map['nom_complet'] ??
            map['username'] ??
            map['display_name'];

    if (prenom.toString().trim().isNotEmpty ||
        nom.toString().trim().isNotEmpty) {
      return '${prenom.toString().trim()} '
          '${nom.toString().trim()}'
          .trim();
    }

    if (fullName != null &&
        fullName.toString().trim().isNotEmpty) {
      return fullName
          .toString()
          .trim();
    }

    return null;
  }

// ============================================================
// DATE
// ============================================================

  String _tripDate(
      Map<String, dynamic> object,
      ) {
    final trip =
    _trip(object);

    final value =
        trip?['date_depart'] ??
            object['date_depart'];

    if (value == null) {
      return '-';
    }

    return _formatDate(
      value.toString(),
    );
  }

// ============================================================
// HEURE
// ============================================================

  String _tripTime(
      Map<String, dynamic> object,
      ) {
    final trip =
    _trip(object);

    return trip?['heure_depart']
        ?.toString() ??
        object['heure_depart']
            ?.toString() ??
        '-';
  }

// ============================================================
// FORMATER DATE
// ============================================================

  String _formatDate(
      String value,
      ) {
    if (value.contains('T')) {
      return value.split('T').first;
    }

    if (value.contains(' ')) {
      return value.split(' ').first;
    }

    return value;
  }

// ============================================================
// SIÈGES RÉSERVATION
// ============================================================

  List<int> _reservationSeats(
      Map<String, dynamic> reservation,
      ) {
    final raw =
    reservation['sieges'];

    if (raw is! List) {
      return [];
    }

    return raw
        .whereType<Map>()
        .map(
          (e) =>
      e['numero_siege'],
    )
        .whereType<num>()
        .map(
          (e) => e.toInt(),
    )
        .toList();
  }

// ============================================================
// SIÈGES ACHAT
// ============================================================

  List<int> _achatSeats(
      Map<String, dynamic> achat,
      ) {
    final raw =
    achat['sieges'];

    if (raw is! List) {
      return [];
    }

    return raw
        .whereType<Map>()
        .map(
          (e) =>
      e['numero_siege'],
    )
        .whereType<num>()
        .map(
          (e) => e.toInt(),
    )
        .toList();
  }

// ============================================================
// MONTANT RÉSERVATION
// ============================================================

  String _reservationAmount(
      Map<String, dynamic> reservation,
      ) {
    final montant =
    reservation['montant'];

    if (montant != null) {
      return _formatMoney(
        montant,
      );
    }

    final trip =
    _trip(reservation);

    final prix =
        double.tryParse(
          trip?['prix']
              ?.toString() ??
              '0',
        ) ??
            0;

    final places =
        int.tryParse(
          reservation[
          'nombre_places']
              ?.toString() ??
              '1',
        ) ??
            1;

    return _formatMoney(
      prix * places,
    );
  }

// ============================================================
// MONTANT ACHAT
// ============================================================

  String _amountFromAchat(
      Map<String, dynamic> achat,
      ) {
    return _formatMoney(
      achat['montant'] ??
          achat['total'] ??
          achat['prix'] ??
          0,
    );
  }

// ============================================================
// FORMAT MONNAIE
// ============================================================

  String _formatMoney(
      dynamic value,
      ) {
    final number =
        double.tryParse(
          value.toString(),
        ) ??
            0;

    final formatted =
    number.round().toString();

    final buffer =
    StringBuffer();

    for (
    int i = 0;
    i < formatted.length;
    i++
    ) {
      if (i > 0 &&
          (formatted.length - i) %
              3 ==
              0) {
        buffer.write(
          ' ',
        );
      }

      buffer.write(
        formatted[i],
      );
    }

    return '${buffer.toString()} FCFA';
  }

// ============================================================
// MESSAGE
// ============================================================

  void _showMessage(
    String message, {
    required bool isError,
  }) {
    if (!mounted) return;

    TkToast.selonErreur(context, message, erreur: isError);
  }
}