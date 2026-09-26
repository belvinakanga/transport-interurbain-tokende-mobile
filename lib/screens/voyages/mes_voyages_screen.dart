import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../avis/avis_screen.dart';

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
        elevation: 0,
        title: const Text(
          'Mes voyages',
          style: TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller:
          _tabController,
          indicatorColor:
          orangeColor,
          indicatorWeight: 3,
          labelColor:
          Colors.white,
          unselectedLabelColor:
          Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(
                Icons.bookmark_outline,
              ),
              text: 'Réservations',
            ),
            Tab(
              icon: Icon(
                Icons.confirmation_num_outlined,
              ),
              text: 'Achats',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReservationsTab(),
                _buildAchatsTab(),
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

  Widget _buildSearchBar() {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.fromLTRB(
        16,
        14,
        16,
        8,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Rechercher un voyage, une agence, une destination...',
          prefixIcon: const Icon(
            Icons.search,
            color: primaryColor,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            onPressed: _clearSearch,
            icon: const Icon(Icons.clear),
            tooltip: 'Effacer',
          )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: orangeColor,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

// ============================================================
// ONGLET RÉSERVATIONS
// ============================================================

  Widget _buildReservationsTab() {
    if (_loadingReservations) {
      return const Center(
        child: CircularProgressIndicator(
          color: orangeColor,
        ),
      );
    }

    if (_reservationError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _reservationError!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_filteredReservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 50,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isEmpty
                  ? 'Aucune réservation'
                  : 'Aucune réservation trouvée',
              style: const TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: orangeColor,
      onRefresh: _loadReservations,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredReservations.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _buildReservationCard(
            _filteredReservations[index],
          );
        },
      ),
    );
  }


// ============================================================
// CARTE RÉSERVATION
// ============================================================

  Widget _buildReservationCard(
      Map<String, dynamic> reservation,
      ) {
    final trip =
    _trip(reservation);

    final agency =
    _agency(reservation);

    final agencyName =
        agency?['nom_agence']
            ?.toString() ??
            agency?['nom']
                ?.toString() ??
            agency?['name']
                ?.toString() ??
            '-';

    final depart =
        trip?['depart']
            ?.toString() ??
            '-';

    final arrivee =
        trip?['arrivee']
            ?.toString() ??
            '-';

    final date =
    _tripDate(
      reservation,
    );

    final heure =
    _tripTime(
      reservation,
    );

    final sieges =
    _reservationSeats(
      reservation,
    );

    final montant =
    _reservationAmount(
      reservation,
    );

    final statut =
        reservation['statut']
            ?.toString() ??
            'En attente';

    final voyageurs =
    _passengerNames(
      reservation,
    );

    return Card(
      margin:
      const EdgeInsets.only(
        bottom: 16,
      ),
      elevation: 3,
      shape:
      RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(
          18,
        ),
      ),
      child: Padding(
        padding:
        const EdgeInsets.all(
          18,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.directions_bus,
                  color:
                  orangeColor,
                  size: 28,
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    agencyName,
                    style:
                    const TextStyle(
                      color:
                      primaryColor,
                      fontWeight:
                      FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                _statusBadge(
                  statut,
                ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),

            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color:
                  primaryColor,
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Text(
                    '$depart → $arrivee',
                    style:
                    const TextStyle(
                      fontWeight:
                      FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 8,
            ),

            Row(
              children: [
                const Icon(
                  Icons
                      .calendar_today_outlined,
                  size: 18,
                  color:
                  Colors.grey,
                ),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  '$date • $heure',
                ),
              ],
            ),

// ====================================================
// VOYAGEURS
// ====================================================

            if (voyageurs.isNotEmpty) ...[
              const Divider(
                height: 30,
              ),

              Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.people_outline,
                    color:
                    primaryColor,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Voyageur(s)',
                          style:
                          TextStyle(
                            color:
                            Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        ...voyageurs.map(
                              (nom) => Padding(
                            padding:
                            const EdgeInsets.only(
                              bottom: 3,
                            ),
                            child: Text(
                              '• $nom',
                              style:
                              const TextStyle(
                                color:
                                primaryColor,
                                fontWeight:
                                FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            const Divider(
              height: 30,
            ),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Siège',
                        style:
                        TextStyle(
                          color:
                          Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        sieges.isEmpty
                            ? '-'
                            : sieges.join(
                          ', ',
                        ),
                        style:
                        const TextStyle(
                          color:
                          primaryColor,
                          fontWeight:
                          FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Montant',
                        style:
                        TextStyle(
                          color:
                          Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        montant,
                        style:
                        const TextStyle(
                          color:
                          orangeColor,
                          fontWeight:
                          FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (statut
                .toLowerCase()
                .contains('attente')) ...[
              const SizedBox(
                height: 16,
              ),

              SizedBox(
                width:
                double.infinity,
                child:
                ElevatedButton(
                  onPressed:
                  _payingReservation
                      ? null
                      : () =>
                      _payReservation(
                        reservation,
                      ),
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    orangeColor,
                    foregroundColor:
                    Colors.white,
                  ),
                  child:
                  const Text(
                    'Payer',
                  ),
                ),
              ),

              TextButton(
                onPressed:
                    () =>
                    _cancelReservation(
                      reservation,
                    ),
                child:
                const Text(
                  'Annuler la réservation',
                  style:
                  TextStyle(
                    color:
                    Colors.red,
                  ),
                ),
              ),
            ],

            if (statut
                .toLowerCase()
                .contains('annul')) ...[
              const SizedBox(
                height: 12,
              ),

              SizedBox(
                width:
                double.infinity,
                child:
                OutlinedButton.icon(
                  onPressed:
                      () =>
                      _deleteReservation(
                        reservation,
                      ),
                  icon:
                  const Icon(
                    Icons.delete,
                    color:
                    Colors.red,
                  ),
                  label:
                  const Text(
                    'Supprimer la réservation',
                    style:
                    TextStyle(
                      color:
                      Colors.red,
                    ),
                  ),
                  style:
                  OutlinedButton.styleFrom(
                    side:
                    const BorderSide(
                      color:
                      Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

// ============================================================
// ONGLET ACHATS
// ============================================================

  Widget _buildAchatsTab() {
    if (_loadingAchats) {
      return const Center(
        child: CircularProgressIndicator(
          color: orangeColor,
        ),
      );
    }

    if (_achatError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _achatError!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_filteredAchats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 50,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isEmpty
                  ? 'Aucun achat'
                  : 'Aucun achat trouvé',
              style: const TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: _loadAchats,
                icon: const Icon(Icons.refresh),
                label: const Text('Actualiser'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: const BorderSide(
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: orangeColor,
      onRefresh: _loadAchats,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredAchats.length,
        itemBuilder: (context, index) {
          return _buildAchatCard(
            _filteredAchats[index],
          );
        },
      ),
    );
  }


// ============================================================
// CARTE ACHAT
// ============================================================

  Widget _buildAchatCard(
      Map<String, dynamic> achat,
      ) {
    final reservation =
    achat['reservation'];

    Map<String, dynamic>? trip;

    if (reservation is Map &&
        reservation['trajet'] is Map) {
      trip =
      Map<String, dynamic>.from(
        reservation['trajet'],
      );
    } else {
      trip = _trip(
        achat,
      );
    }

    Map<String, dynamic>? agency;

    if (trip != null &&
        trip['agence'] is Map) {
      agency =
      Map<String, dynamic>.from(
        trip['agence'],
      );
    } else {
      agency = _agency(
        achat,
      );
    }

    final agencyName =
        agency?['nom_agence']
            ?.toString() ??
            agency?['nom']
                ?.toString() ??
            agency?['name']
                ?.toString() ??
            '-';

    final depart =
        trip?['depart']
            ?.toString() ??
            '-';

    final arrivee =
        trip?['arrivee']
            ?.toString() ??
            '-';

    final date =
        trip?['date_depart']
            ?.toString() ??
            '-';

    final heure =
        trip?['heure_depart']
            ?.toString() ??
            '-';

    final prix =
    _amountFromAchat(
      achat,
    );

    final sieges =
    reservation is Map
        ? _reservationSeats(
      Map<String, dynamic>.from(
        reservation,
      ),
    )
        : _achatSeats(
      achat,
    );

    final voyageurs =
    reservation is Map
        ? _passengerNames(
      Map<String, dynamic>.from(
        reservation,
      ),
    )
        : _passengerNames(
      achat,
    );

    return Card(
      margin:
      const EdgeInsets.only(
        bottom: 16,
      ),
      elevation: 3,
      shape:
      RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(
          18,
        ),
      ),
      child: Padding(
        padding:
        const EdgeInsets.all(
          18,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.confirmation_num,
                  color:
                  orangeColor,
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    agencyName,
                    style:
                    const TextStyle(
                      color:
                      primaryColor,
                      fontWeight:
                      FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                const Icon(
                  Icons.check_circle,
                  color:
                  Colors.green,
                ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),

            Text(
              '$depart → $arrivee',
              style:
              const TextStyle(
                fontWeight:
                FontWeight.w600,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              '$date • $heure',
            ),

            if (voyageurs.isNotEmpty) ...[
              const Divider(
                height: 30,
              ),

              Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.people_outline,
                    color:
                    primaryColor,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Voyageur(s)',
                          style:
                          TextStyle(
                            color:
                            Colors.grey,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        ...voyageurs.map(
                              (nom) => Text(
                            '• $nom',
                            style:
                            const TextStyle(
                              color:
                              primaryColor,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            const Divider(
              height: 30,
            ),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Siège',
                        style:
                        TextStyle(
                          color:
                          Colors.grey,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        sieges.isEmpty
                            ? '-'
                            : sieges.join(
                          ', ',
                        ),
                        style:
                        const TextStyle(
                          color:
                          primaryColor,
                          fontWeight:
                          FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Montant',
                        style:
                        TextStyle(
                          color:
                          Colors.grey,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        prix,
                        style:
                        const TextStyle(
                          color:
                          orangeColor,
                          fontWeight:
                          FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
                  // ====================================================
// BOUTON BILLET
// ====================================================

    const SizedBox(height: 18),

    SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
    onPressed: () => _showTicket(achat),
    icon: const Icon(
    Icons.confirmation_num_outlined,
    ),
    label: const Text(
    'Voir mon billet',
    ),
    style: ElevatedButton.styleFrom(
    backgroundColor: orangeColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(
    vertical: 14,
    ),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
    ),
    ),
    ),
    ),

// ====================================================
// BOUTON AVIS
// ====================================================

    const SizedBox(height: 12),

    SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
    onPressed: () {
    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (_) => const AvisScreen(),
    ),
    );
    },
    icon: const Icon(
    Icons.star_outline,
    ),
    label: const Text(
    'Donner mon avis',
    ),
    style: OutlinedButton.styleFrom(
    foregroundColor: primaryColor,
    side: const BorderSide(
    color: primaryColor,
    ),
    padding: const EdgeInsets.symmetric(
    vertical: 14,
    ),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
    ),
    ),
    ),
    ),
          ],
        ),
      ),
    );
  }


  // ============================================================
  // BADGE STATUT
// ============================================================


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

    final depart = trip?['depart']?.toString() ?? '-';
    final arrivee = trip?['arrivee']?.toString() ?? '-';
    final date = trip?['date_depart']?.toString() ?? '-';
    final heure = trip?['heure_depart']?.toString() ?? '-';

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

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 720),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                22, 14, 22, 28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3EA),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.confirmation_num_outlined,
                          color: orangeColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Billet de voyage',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              agencyName,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FB),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$depart → $arrivee',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: primaryColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '$date • $heure',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  _ticketInfoRow(
                    Icons.person_outline,
                    'Voyageur',
                    voyageurs.isEmpty
                        ? '-'
                        : voyageurs.join(', '),
                  ),

                  _ticketInfoRow(
                    Icons.event_seat_outlined,
                    'Siège(s)',
                    sieges.isEmpty
                        ? '-'
                        : sieges.join(', '),
                  ),

                  _ticketInfoRow(
                    Icons.confirmation_num_outlined,
                    'N° billet',
                    numero,
                  ),

                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8F2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFFE0C7),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Code billet',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SelectableText(
                          qrCode,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Présentez ce code lors du contrôle.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pop(sheetContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orangeColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Fermer',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

    ScaffoldMessenger.of(
      context,
    )
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content:
          Text(message),
          behavior:
          SnackBarBehavior.floating,
          backgroundColor:
          isError
              ? Colors.red
              : Colors.green,
        ),
      );
  }
}