import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import 'trip_details_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String departure;
  final String destination;
  final DateTime departureDate;
  final int travelers;

  const SearchResultsScreen({
    super.key,
    required this.departure,
    required this.destination,
    required this.departureDate,
    required this.travelers,
  });

  @override
  State<SearchResultsScreen> createState() =>
      _SearchResultsScreenState();
}

class _SearchResultsScreenState
    extends State<SearchResultsScreen> {
  late Future<List<dynamic>> _trajetsFuture;

  @override
  void initState() {
    super.initState();
    _trajetsFuture = ApiService.getTrajets();
  }

  // ============================================================
  // NORMALISER LES TEXTES
  // ============================================================

  String normalizeText(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  // ============================================================
  // DATE AU FORMAT YYYY-MM-DD
  // ============================================================

  String formatDateForApi(DateTime date) {
    final year =
    date.year.toString().padLeft(4, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    final day =
    date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  // ============================================================
  // DATE AFFICHÉE
  // ============================================================

  String get formattedDate {
    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];

    return '${widget.departureDate.day} '
        '${months[widget.departureDate.month - 1]} '
        '${widget.departureDate.year}';
  }

  // ============================================================
  // FORMAT PRIX
  // ============================================================

  String formatPrice(dynamic value) {
    final number =
        double.tryParse(value.toString()) ?? 0;

    final integerValue = number.toInt();

    final text = integerValue.toString();

    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) {
        buffer.write(' ');
      }

      buffer.write(text[i]);
    }

    return '${buffer.toString()} FCFA';
  }

  // ============================================================
  // FORMAT HEURE
  // ============================================================

  String formatTime(dynamic value) {
    if (value == null) {
      return '--:--';
    }

    final time = value.toString();

    if (time.length >= 5) {
      return time.substring(0, 5);
    }

    return time;
  }

  // ============================================================
  // HEURE D'ARRIVÉE
  // ============================================================

  String getArrivalTime(dynamic trajet) {
    if (trajet['heure_arrivee'] != null) {
      return formatTime(
        trajet['heure_arrivee'],
      );
    }

    return '--:--';
  }

  // ============================================================
  // FILTRER LES TRAJETS
  // ============================================================

  List<dynamic> filterTrajets(
      List<dynamic> trajets,
      ) {
    final departureRecherche =
    normalizeText(widget.departure);

    final destinationRecherche =
    normalizeText(widget.destination);

    final dateRecherche =
    formatDateForApi(widget.departureDate);

    return trajets.where((trajet) {
      // ----------------------------------------------------------
      // DÉPART
      // ----------------------------------------------------------

      final departApi = normalizeText(
        trajet['depart']?.toString() ?? '',
      );

      // ----------------------------------------------------------
      // DESTINATION
      // ----------------------------------------------------------

      final arriveeApi = normalizeText(
        trajet['arrivee']?.toString() ?? '',
      );

      // ----------------------------------------------------------
      // DATE
      // ----------------------------------------------------------

      final dateApi =
          trajet['date_depart']
              ?.toString()
              .trim() ??
              '';

      // ----------------------------------------------------------
      // PLACES
      // ----------------------------------------------------------

      final placesDisponibles =
          int.tryParse(
            trajet['places_disponibles']
                ?.toString() ??
                '0',
          ) ??
              0;

      // ----------------------------------------------------------
      // COMPARAISONS
      // ----------------------------------------------------------

      final bonDepart =
          departApi == departureRecherche;

      final bonneDestination =
          arriveeApi ==
              destinationRecherche;

      final bonneDate =
          dateApi == dateRecherche;

      final assezDePlaces =
          placesDisponibles >=
              widget.travelers;

      return bonDepart &&
          bonneDestination &&
          bonneDate &&
          assezDePlaces;
    }).toList();
  }

  // ============================================================
  // RECHARGER
  // ============================================================

  Future<void> reloadTrajets() async {
    setState(() {
      _trajetsFuture =
          ApiService.getTrajets();
    });

    await _trajetsFuture;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF8F9FB),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor:
        const Color(0xFF0A2A66),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Résultats',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ========================================================
      // API
      // ========================================================

      body: FutureBuilder<List<dynamic>>(
        future: _trajetsFuture,

        builder: (context, snapshot) {
          // ====================================================
          // CHARGEMENT
          // ====================================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF6B00),
              ),
            );
          }

          // ====================================================
          // ERREUR
          // ====================================================

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                const EdgeInsets.all(25),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      color:
                      Color(0xFF0A2A66),
                      size: 60,
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Impossible de charger les trajets',
                      textAlign:
                      TextAlign.center,
                      style: TextStyle(
                        color:
                        Color(0xFF0A2A66),
                        fontSize: 20,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      snapshot.error.toString(),
                      textAlign:
                      TextAlign.center,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed:
                      reloadTrajets,
                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(
                          0xFFFF6B00,
                        ),
                        foregroundColor:
                        Colors.white,
                      ),
                      child: const Text(
                        'Réessayer',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ====================================================
          // RÉCUPÉRER LES DONNÉES
          // ====================================================

          final allTrajets =
              snapshot.data ?? [];

          // ====================================================
          // FILTRAGE
          // ====================================================

          final trajets =
          filterTrajets(allTrajets);

          // ====================================================
          // AFFICHAGE
          // ====================================================

          return RefreshIndicator(
            color:
            const Color(0xFFFF6B00),
            onRefresh: reloadTrajets,

            child: SingleChildScrollView(
              physics:
              const AlwaysScrollableScrollPhysics(),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  // ==================================================
                  // RECHERCHE
                  // ==================================================

                  Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      22,
                    ),
                    decoration:
                    const BoxDecoration(
                      color:
                      Color(0xFF0A2A66),
                      borderRadius:
                      BorderRadius.only(
                        bottomLeft:
                        Radius.circular(25),
                        bottomRight:
                        Radius.circular(25),
                      ),
                    ),

                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [
                        const Text(
                          'Votre recherche',
                          style: TextStyle(
                            color:
                            Colors.white70,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.departure,
                                overflow:
                                TextOverflow
                                    .ellipsis,
                                style:
                                const TextStyle(
                                  color:
                                  Colors.white,
                                  fontSize: 20,
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                ),
                              ),
                            ),

                            const Padding(
                              padding:
                              EdgeInsets
                                  .symmetric(
                                horizontal: 8,
                              ),
                              child: Icon(
                                Icons.arrow_forward,
                                color:
                                Colors.white,
                                size: 22,
                              ),
                            ),

                            Expanded(
                              child: Text(
                                widget.destination,
                                textAlign:
                                TextAlign.right,
                                overflow:
                                TextOverflow
                                    .ellipsis,
                                style:
                                const TextStyle(
                                  color:
                                  Colors.white,
                                  fontSize: 20,
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Row(
                          children: [
                            const Icon(
                              Icons
                                  .calendar_today_outlined,
                              color:
                              Colors.white70,
                              size: 17,
                            ),

                            const SizedBox(width: 8),

                            Text(
                              formattedDate,
                              style:
                              const TextStyle(
                                color:
                                Colors.white70,
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(width: 18),

                            const Icon(
                              Icons
                                  .person_outline,
                              color:
                              Colors.white70,
                              size: 18,
                            ),

                            const SizedBox(width: 5),

                            Text(
                              widget.travelers == 1
                                  ? '1 voyageur'
                                  : '${widget.travelers} voyageurs',
                              style:
                              const TextStyle(
                                color:
                                Colors.white70,
                                fontSize: 14,
                              ),
                            ),

                            const Spacer(),

                            TextButton(
                              onPressed: () {
                                Navigator.pop(
                                  context,
                                );
                              },
                              child:
                              const Text(
                                'Modifier',
                                style:
                                TextStyle(
                                  color:
                                  Color(
                                    0xFFFF6B00,
                                  ),
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ==================================================
                  // TITRE
                  // ==================================================

                  const Padding(
                    padding:
                    EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Text(
                      'Trajets disponibles',
                      style: TextStyle(
                        color:
                        Color(0xFF0A2A66),
                        fontSize: 22,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Padding(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Text(
                      trajets.isEmpty
                          ? 'Aucun trajet ne correspond à votre recherche'
                          : '${trajets.length} trajet${trajets.length > 1 ? 's' : ''} disponible${trajets.length > 1 ? 's' : ''}',
                      style:
                      const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ==================================================
                  // AUCUN TRAJET
                  // ==================================================

                  if (trajets.isEmpty)
                    _buildEmptyState(),

                  // ==================================================
                  // TRAJETS
                  // ==================================================

                  ...trajets.map(
                        (trajet) {
                      // ------------------------------------------------
                      // ID DU TRAJET
                      // ------------------------------------------------

                      final trajetId =
                      int.tryParse(
                        trajet['id']
                            ?.toString() ??
                            '',
                      );

                      // ------------------------------------------------
                      // AGENCE
                      // ------------------------------------------------

                      final agency =
                      trajet['agence'];

                      final agencyName =
                      agency != null
                          ? agency[
                      'nom_agence']
                          ?.toString()
                          : null;
                      final agencyAddress =
                      agency != null
                          ? agency['adresse']?.toString()
                          : null;

                      // ------------------------------------------------
                      // HEURE DÉPART
                      // ------------------------------------------------

                      final departureTime =
                      formatTime(
                        trajet[
                        'heure_depart'],
                      );

                      // ------------------------------------------------
                      // HEURE ARRIVÉE
                      // ------------------------------------------------

                      final arrivalTime =
                      getArrivalTime(
                        trajet,
                      );

                      // ------------------------------------------------
                      // PRIX
                      // ------------------------------------------------

                      final price =
                      formatPrice(
                        trajet['prix'],
                      );

                      // ------------------------------------------------
                      // PLACES
                      // ------------------------------------------------

                      final availableSeats =
                          int.tryParse(
                            trajet[
                            'places_disponibles']
                                ?.toString() ??
                                '0',
                          ) ??
                              0;

                      final totalSeats =
                          int.tryParse(
                            trajet[
                            'places_totales']
                                ?.toString() ??
                                '0',
                          ) ??
                              0;

                      // ------------------------------------------------
                      // DATE
                      // ------------------------------------------------

                      final dateString =
                      trajet[
                      'date_depart']
                          ?.toString();

                      final tripDate =
                          DateTime.tryParse(
                            dateString ?? '',
                          ) ??
                              widget
                                  .departureDate;

                      // ------------------------------------------------
                      // CARTE
                      // ------------------------------------------------

                      return _buildTripCard(
                        context: context,
                        trajetId: trajetId,
                        agency: agencyName ?? 'Agence partenaire',
                        agencyAddress: agencyAddress,
                        departureTime: departureTime,
                        arrivalTime: arrivalTime,
                        price: price,
                        availableSeats: availableSeats,
                        totalSeats: totalSeats,
                        tripDate: tripDate,
                      );
                    },
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // MESSAGE AUCUN TRAJET
  // ============================================================

  Widget _buildEmptyState() {
    return Padding(
      padding:
      const EdgeInsets.all(30),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.directions_bus_outlined,
              color: Color(0xFF0A2A66),
              size: 65,
            ),

            const SizedBox(height: 15),

            const Text(
              'Aucun trajet trouvé',
              style: TextStyle(
                color:
                Color(0xFF0A2A66),
                fontSize: 19,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Aucun trajet ne correspond à '
                  '${widget.departure} → '
                  '${widget.destination} '
                  'pour le ${formattedDate}.',
              textAlign:
              TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            OutlinedButton(
              onPressed:
              reloadTrajets,
              style:
              OutlinedButton.styleFrom(
                foregroundColor:
                const Color(
                  0xFF0A2A66,
                ),
              ),
              child: const Text(
                'Actualiser',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CARTE TRAJET
  // ============================================================

  Widget _buildTripCard({
    required BuildContext context,
    required int? trajetId,
    required String agency,
    String? agencyAddress,
    required String departureTime,
    required String arrivalTime,
    required String price,
    required int availableSeats,
    required int totalSeats,
    required DateTime tripDate,
  }) {
    return Container(
      margin:
      const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ),

      padding:
      const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withOpacity(
              0.06,
            ),
            blurRadius: 15,
            offset:
            const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        children: [
          // ========================================================
          // AGENCE
          // ========================================================

          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration:
                BoxDecoration(
                  color:
                  const Color(
                    0xFFFFF3EB,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                ),
                child: const Icon(
                  Icons
                      .directions_bus_rounded,
                  color:
                  Color(0xFFFF6B00),
                  size: 28,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agency,
                      style: const TextStyle(
                        color: Color(0xFF0A2A66),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    if (agencyAddress != null &&
                        agencyAddress.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '📍 Adresse de l’agence : $agencyAddress',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ========================================================
          // PLACES
          // ========================================================

          Align(
            alignment:
            Alignment.centerLeft,
            child: Row(
              children: [
                const Icon(
                  Icons
                      .event_seat_outlined,
                  color:
                  Color(0xFFFF6B00),
                  size: 18,
                ),

                const SizedBox(width: 6),

                Text(
                  '$availableSeats places disponibles',
                  style:
                  const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ========================================================
          // HORAIRES
          // ========================================================

          Row(
            children: [
              // DÉPART
              Column(
                children: [
                  Text(
                    departureTime,
                    style:
                    const TextStyle(
                      color:
                      Color(0xFF0A2A66),
                      fontSize: 22,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  SizedBox(
                    width: 80,
                    child: Text(
                      widget.departure,
                      textAlign:
                      TextAlign.center,
                      style:
                      const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              // LIGNE
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Trajet',
                      style:
                      TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        const Expanded(
                          child: Divider(
                            color:
                            Color(
                              0xFFDDDDDD,
                            ),
                          ),
                        ),

                        Container(
                          width: 9,
                          height: 9,
                          decoration:
                          const BoxDecoration(
                            color:
                            Color(
                              0xFFFF6B00,
                            ),
                            shape:
                            BoxShape.circle,
                          ),
                        ),

                        const Expanded(
                          child: Divider(
                            color:
                            Color(
                              0xFFDDDDDD,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ARRIVÉE
              Column(
                children: [
                  Text(
                    arrivalTime,
                    style:
                    const TextStyle(
                      color:
                      Color(0xFF0A2A66),
                      fontSize: 22,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  SizedBox(
                    width: 80,
                    child: Text(
                      widget.destination,
                      textAlign:
                      TextAlign.center,
                      style:
                      const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          const Divider(),

          const SizedBox(height: 15),

          // ========================================================
          // PRIX + CHOISIR
          // ========================================================

          Row(
            children: [
              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Text(
                    'À partir de',
                    style:
                    TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    price,
                    style:
                    const TextStyle(
                      color:
                      Color(0xFFFF6B00),
                      fontSize: 19,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    '$totalSeats places au total',
                    style:
                    const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: trajetId == null
                    ? null
                    : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          TripDetailsScreen(
                            // =================================================
                            // ID RÉEL DU TRAJET
                            // =================================================

                            trajetId:
                            trajetId,

                            agency:
                            agency,

                            departure:
                            widget
                                .departure,

                            destination:
                            widget
                                .destination,

                            departureTime:
                            departureTime,

                            arrivalTime:
                            arrivalTime,

                            duration:
                            'Transport interurbain',

                            price:
                            price,

                            rating:
                            '—',

                            departureDate:
                            tripDate,

                            travelers:
                            widget
                                .travelers,
                          ),
                    ),
                  );
                },

                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(
                    0xFFFF6B00,
                  ),
                  foregroundColor:
                  Colors.white,
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 22,
                    vertical: 13,
                  ),
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      13,
                    ),
                  ),
                ),

                child: const Text(
                  'Choisir',
                  style: TextStyle(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}