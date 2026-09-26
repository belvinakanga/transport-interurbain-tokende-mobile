import 'package:flutter/material.dart';

import '../booking/seat_selection_screen.dart';

class TripDetailsScreen extends StatelessWidget {
  // ============================================================
  // INFORMATIONS DU TRAJET
  // ============================================================

  final int trajetId;

  final String agency;
  final String departure;
  final String destination;

  final String departureTime;
  final String arrivalTime;

  final String duration;
  final String price;
  final String rating;

  // Date réelle du départ
  final DateTime departureDate;

  final int travelers;

  const TripDetailsScreen({
    super.key,

    required this.trajetId,

    required this.agency,
    required this.departure,
    required this.destination,

    required this.departureTime,
    required this.arrivalTime,

    required this.duration,
    required this.price,
    required this.rating,

    required this.departureDate,

    required this.travelers,
  });

  // ============================================================
  // FORMATER LA DATE
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

    return '${departureDate.day} '
        '${months[departureDate.month - 1]} '
        '${departureDate.year}';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),

        // ========================================================
        // APP BAR
        // ========================================================

        appBar: AppBar(
          backgroundColor: const Color(0xFF0A2A66),
          foregroundColor: Colors.white,
          elevation: 0,

          title: const Text(
            'Détails du trajet',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // ========================================================
        // BODY
        // ========================================================

        body: SingleChildScrollView(
          child: Column(
            children: [

            // ====================================================
            // EN-TÊTE DU TRAJET
            // ====================================================

            Container(
            width: double.infinity,

            padding: const EdgeInsets.all(20),

            decoration: const BoxDecoration(
              color: Color(0xFF0A2A66),

              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),

            child: Column(
              children: [

                // ==================================================
                // AGENCE
                // ==================================================

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [
                    Container(
                      width: 55,
                      height: 55,

                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3EB),

                        borderRadius:
                        BorderRadius.circular(16),
                      ),

                      child: const Icon(
                        Icons.directions_bus_rounded,

                        color:
                        Color(0xFFFF6B00),

                        size: 32,
                      ),
                    ),

                    const SizedBox(width: 15),

                    Flexible(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [
                          Text(
                            agency,

                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Row(
                            children: [
                              const Icon(
                                Icons.star,

                                color: Colors.amber,

                                size: 18,
                              ),

                              const SizedBox(width: 4),

                              Text(
                                rating,

                                style:
                                const TextStyle(
                                  color:
                                  Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // ==================================================
                // DATE
                // ==================================================

                Text(
                  formattedDate,

                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ====================================================
          // ITINÉRAIRE
          // ====================================================

          _buildSection(
            child: Column(
              children: [

                const Align(
                  alignment:
                  Alignment.centerLeft,

                  child: Text(
                    'Itinéraire',

                    style: TextStyle(
                      color:
                      Color(0xFF0A2A66),

                      fontSize: 20,

                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Row(
                  children: [

                    // ==================================================
                    // DÉPART
                    // ==================================================

                    Column(
                      children: [
                        Text(
                          departureTime,

                          style:
                          const TextStyle(
                            color:
                            Color(0xFF0A2A66),

                            fontSize: 25,

                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        SizedBox(
                          width: 90,

                          child: Text(
                            departure,

                            textAlign:
                            TextAlign.center,

                            style:
                            const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ==================================================
                    // LIGNE
                    // ==================================================

                    Expanded(
                      child: Column(
                        children: [

                          Text(
                            duration,

                            style:
                            const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [

                              const Expanded(
                                child: Divider(
                                  color:
                                  Color(0xFFDDDDDD),
                                ),
                              ),

                              Container(
                                width: 11,
                                height: 11,

                                decoration:
                                const BoxDecoration(
                                  color:
                                  Color(0xFFFF6B00),

                                  shape:
                                  BoxShape.circle,
                                ),
                              ),

                              const Expanded(
                                child: Divider(
                                  color:
                                  Color(0xFFDDDDDD),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ==================================================
                    // ARRIVÉE
                    // ==================================================

                    Column(
                      children: [
                        Text(
                          arrivalTime,

                          style:
                          const TextStyle(
                            color:
                            Color(0xFF0A2A66),

                            fontSize: 25,

                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        SizedBox(
                          width: 90,

                          child: Text(
                            destination,

                            textAlign:
                            TextAlign.center,

                            style:
                            const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),
              // ====================================================
              // INFORMATIONS DU VOYAGE
              // ====================================================

              _buildSection(
                child: Column(
                  children: [

                    const Align(
                      alignment:
                      Alignment.centerLeft,

                      child: Text(
                        'Informations du voyage',

                        style: TextStyle(
                          color:
                          Color(0xFF0A2A66),

                          fontSize: 20,

                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // DATE
                    _buildInfoRow(
                      Icons.calendar_today_outlined,

                      'Date',

                      formattedDate,
                    ),

                    // VOYAGEURS
                    _buildInfoRow(
                      Icons.people_outline,

                      'Voyageurs',

                      travelers == 1
                          ? '1 voyageur'
                          : '$travelers voyageurs',
                    ),

                    // DURÉE
                    _buildInfoRow(
                      Icons.access_time,

                      'Durée',

                      duration,
                    ),

                    // SERVICE
                    _buildInfoRow(
                      Icons.verified_outlined,

                      'Service',

                      'Transport interurbain',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // ====================================================
              // PRIX
              // ====================================================

              _buildSection(
                child: Row(
                  children: [

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: const [
                          Text(
                            'Prix par voyageur',

                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),

                          SizedBox(height: 5),

                          Text(
                            'Tarif du trajet',

                            style: TextStyle(
                              color:
                              Color(0xFF0A2A66),

                              fontSize: 16,

                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      price,

                      style: const TextStyle(
                        color:
                        Color(0xFFFF6B00),

                        fontSize: 22,

                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ====================================================
              // BOUTON CHOISIR MON SIÈGE
              // ====================================================

              Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child: SizedBox(
                  width: double.infinity,

                  height: 58,

                  child: ElevatedButton.icon(
                    onPressed: () {

                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) =>
                              SeatSelectionScreen(

                                // ==========================================
                                // ID DU TRAJET
                                // ==========================================

                                trajetId:
                                trajetId,

                                // ==========================================
                                // TRAJET
                                // ==========================================

                                agency:
                                agency,

                                departure:
                                departure,

                                destination:
                                destination,

                                // ==========================================
                                // DATE
                                // ==========================================

                                departureDate:
                                formattedDate,

                                // ==========================================
                                // HORAIRES
                                // ==========================================

                                departureTime:
                                departureTime,

                                arrivalTime:
                                arrivalTime,

                                // ==========================================
                                // PRIX
                                // ==========================================

                                price:
                                price,

                                // ==========================================
                                // VOYAGEURS
                                // ==========================================

                                travelers:
                                travelers,
                              ),
                        ),
                      );
                    },

                    icon: const Icon(
                      Icons.event_seat_outlined,
                    ),

                    label: const Text(
                      'Choisir mon siège',

                      style: TextStyle(
                        fontSize: 17,

                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFFFF6B00),

                      foregroundColor:
                      Colors.white,

                      elevation: 3,

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
    );
  }

  // ============================================================
  // CONSTRUIRE UNE SECTION
  // ============================================================

  Widget _buildSection({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,

      margin:
      const EdgeInsets.symmetric(
        horizontal: 20,
      ),

      padding:
      const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withOpacity(0.05),

            blurRadius: 12,

            offset:
            const Offset(0, 4),
          ),
        ],
      ),

      child: child,
    );
  }

  // ============================================================
  // LIGNE D'INFORMATION
  // ============================================================

  Widget _buildInfoRow(
      IconData icon,
      String title,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 16,
      ),

      child: Row(
        children: [

          Icon(
            icon,

            color:
            const Color(0xFFFF6B00),

            size: 23,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              title,

              style:
              const TextStyle(
                color: Colors.grey,

                fontSize: 14,
              ),
            ),
          ),

          Flexible(
            child: Text(
              value,

              textAlign:
              TextAlign.right,

              style:
              const TextStyle(
                color:
                Color(0xFF0A2A66),

                fontWeight:
                FontWeight.w600,

                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}