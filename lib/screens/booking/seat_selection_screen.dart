import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'passenger_information_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  // ============================================================
  // INFORMATIONS DU TRAJET
  // ============================================================

  final int trajetId;

  final String agency;
  final String departure;
  final String destination;

  final String departureDate;

  final String departureTime;
  final String arrivalTime;
  final String price;

  final int travelers;

  const SeatSelectionScreen({
    super.key,
    required this.trajetId,
    required this.agency,
    required this.departure,
    required this.destination,
    required this.departureDate,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.travelers,
  });

  @override
  State<SeatSelectionScreen> createState() =>
      _SeatSelectionScreenState();
}

class _SeatSelectionScreenState
    extends State<SeatSelectionScreen> {

  // ============================================================
  // COULEURS INTERGO
  // ============================================================

  static const Color primaryColor =
  Color(0xFF0A2A66);

  static const Color orangeColor =
  Color(0xFFFF6B00);

  static const Color backgroundColor =
  Color(0xFFF8F9FB);


  // ============================================================
  // API
  // ============================================================

  static const String baseUrl =
      'http://127.0.0.1:8000/api';


  // ============================================================
  // STOCKAGE TOKEN
  // ============================================================

  static const FlutterSecureStorage storage =
  FlutterSecureStorage();


  // ============================================================
  // SIÈGES SÉLECTIONNÉS
  // ============================================================

  final Set<int> selectedSeats = {};


  // ============================================================
  // SIÈGES RÉCUPÉRÉS DEPUIS LARAVEL
  // ============================================================

  List<Map<String, dynamic>> seats = [];

  bool isLoading = true;

  String? errorMessage;

  int placesTotales = 0;

  int placesDisponibles = 0;


  // ============================================================
  // RÉCUPÉRER LE TOKEN
  // ============================================================

  Future<String?> _getToken() async {
    return storage.read(
      key: 'auth_token',
    );
  }


  // ============================================================
  // INITIALISATION
  // ============================================================

  @override
  void initState() {
    super.initState();

    loadSeats();
  }


  // ============================================================
  // RÉCUPÉRER LES SIÈGES DEPUIS LARAVEL
  // ============================================================

  Future<void> loadSeats() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // ==========================================================
      // TOKEN
      // ==========================================================

      final token = await _getToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Session expirée. Veuillez vous reconnecter.',
        );
      }


      // ==========================================================
      // REQUÊTE API
      // ==========================================================

      final url =
          '$baseUrl/trajets/${widget.trajetId}/sieges';

      debugPrint(
        '====================================================',
      );

      debugPrint(
        'CHARGEMENT DES SIÈGES',
      );

      debugPrint(
        'URL : $url',
      );


      final response = await http.get(

        Uri.parse(url),

        headers: {

          'Accept':
          'application/json',

          'Authorization':
          'Bearer $token',

        },

      );


      // ==========================================================
      // DEBUG
      // ==========================================================

      debugPrint(
        'STATUS : ${response.statusCode}',
      );

      debugPrint(
        'BODY : ${response.body}',
      );


      debugPrint(
        '====================================================',
      );


      // ==========================================================
      // 401
      // ==========================================================

      if (response.statusCode == 401) {
        throw Exception(
          'Session non autorisée. '
              'Veuillez vous reconnecter.',
        );
      }


      // ==========================================================
      // AUTRES ERREURS
      // ==========================================================

      if (response.statusCode != 200) {
        throw Exception(
          'Erreur serveur : '
              '${response.statusCode}',
        );
      }


      // ==========================================================
      // DÉCODAGE
      // ==========================================================

      final data =
      jsonDecode(response.body);


      if (data is! Map<String, dynamic>) {
        throw Exception(
          'Format de réponse inattendu.',
        );
      }


      // ==========================================================
      // SIÈGES
      // ==========================================================

      final rawSeats =
      data['sieges'];


      if (rawSeats is! List) {
        throw Exception(
          'Les sièges sont absents de la réponse.',
        );
      }


      final loadedSeats =
      rawSeats
          .whereType<Map>()
          .map(
            (seat) =>
        Map<String, dynamic>.from(
          seat,
        ),
      )
          .toList();


      // ==========================================================
      // MISE À JOUR
      // ==========================================================

      if (!mounted) return;


      setState(() {
        seats =
            loadedSeats;


        placesTotales =
            data['places_totales'] ??
                loadedSeats.length;


        placesDisponibles =
            data['places_disponibles'] ??
                loadedSeats
                    .where(
                      (seat) =>
                  seat['statut'] ==
                      'disponible',
                )
                    .length;


        isLoading =
        false;
      });
    }

    catch (e) {
      debugPrint(
        'ERREUR CHARGEMENT SIÈGES : $e',
      );


      if (!mounted) return;


      setState(() {
        isLoading =
        false;


        errorMessage =
        'Impossible de récupérer les sièges.\n\n$e';
      });
    }
  }


  // ============================================================
  // VÉRIFIER SI LE SIÈGE EST INDISPONIBLE
  // ============================================================

  bool isSeatUnavailable(int seatNumber,) {
    final seat =
    seats.firstWhere(
          (seat) =>
      seat['numero_siege'] ==
          seatNumber,
      orElse: () => {},
    );


    if (seat.isEmpty) {
      return true;
    }


    return seat['statut'] !=
        'disponible';
  }


  // ============================================================
  // SÉLECTIONNER / DÉSÉLECTIONNER
  // ============================================================

  void toggleSeat(int seatNumber,) {
    if (isSeatUnavailable(
      seatNumber,
    )) {
      return;
    }


    setState(() {
      // ========================================================
      // DÉSÉLECTION
      // ========================================================

      if (selectedSeats.contains(
        seatNumber,
      )) {
        selectedSeats.remove(
          seatNumber,
        );

        return;
      }


      // ========================================================
      // AJOUT
      // ========================================================

      if (selectedSeats.length <
          widget.travelers) {
        selectedSeats.add(
          seatNumber,
        );
      }

      else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(

          SnackBar(

            content: Text(

              widget.travelers == 1
                  ? 'Vous devez choisir 1 siège.'
                  : 'Vous devez choisir '
                  '${widget.travelers} sièges.',

            ),

            backgroundColor:
            primaryColor,

          ),

        );
      }
    });
  }


  // ============================================================
  // CONTINUER
  // ============================================================

  void continueToPassengerInformation() {
    if (selectedSeats.length !=
        widget.travelers) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        SnackBar(

          content: Text(

            widget.travelers == 1
                ? 'Veuillez sélectionner 1 siège.'
                : 'Veuillez sélectionner '
                '${widget.travelers} sièges.',

          ),

          backgroundColor:
          primaryColor,

        ),

      );

      return;
    }


    // ==========================================================
    // LISTE TRIÉE
    // ==========================================================

    final selectedSeatList =
    selectedSeats.toList()
      ..sort();


    // ==========================================================
    // PASSAGE INFORMATIONS PASSAGERS
    // ==========================================================

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>
            PassengerInformationScreen(

              trajetId:
              widget.trajetId,

              agency:
              widget.agency,

              departure:
              widget.departure,

              destination:
              widget.destination,

              departureDate:
              widget.departureDate,

              departureTime:
              widget.departureTime,

              arrivalTime:
              widget.arrivalTime,

              price:
              widget.price,

              travelers:
              widget.travelers,

              selectedSeats:
              selectedSeatList,

            ),

      ),

    );
  }


  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context,) {
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

        title: const Text(

          'Choix du siège',

          style: TextStyle(

            fontWeight:
            FontWeight.bold,

          ),

        ),

      ),


      // ========================================================
      // CONTENU
      // ========================================================

      body: Column(

        children: [

          // ======================================================
          // INFORMATIONS TRAJET
          // ======================================================

          Container(

            width:
            double.infinity,

            padding:
            const EdgeInsets.all(20),

            color:
            primaryColor,

            child: Column(

              children: [

                Text(

                  widget.agency,

                  textAlign:
                  TextAlign.center,

                  style:
                  const TextStyle(

                    color:
                    Colors.white,

                    fontSize:
                    20,

                    fontWeight:
                    FontWeight.bold,

                  ),

                ),


                const SizedBox(
                  height: 8,
                ),


                // DATE

                Row(

                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [

                    const Icon(

                      Icons.calendar_today_outlined,

                      color:
                      Colors.white70,

                      size:
                      15,

                    ),


                    const SizedBox(
                      width: 6,
                    ),


                    Text(

                      widget.departureDate,

                      style:
                      const TextStyle(

                        color:
                        Colors.white70,

                        fontSize:
                        13,

                        fontWeight:
                        FontWeight.w600,

                      ),

                    ),

                  ],

                ),


                const SizedBox(
                  height: 10,
                ),


                // TRAJET

                Row(

                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [

                    Flexible(

                      child: Text(

                        widget.departure,

                        textAlign:
                        TextAlign.center,

                        style:
                        const TextStyle(

                          color:
                          Colors.white,

                          fontSize:
                          15,

                          fontWeight:
                          FontWeight.w600,

                        ),

                      ),

                    ),


                    const Padding(

                      padding:
                      EdgeInsets.symmetric(
                        horizontal: 12,
                      ),

                      child: Icon(

                        Icons.arrow_forward,

                        color:
                        Colors.white70,

                        size:
                        18,

                      ),

                    ),


                    Flexible(

                      child: Text(

                        widget.destination,

                        textAlign:
                        TextAlign.center,

                        style:
                        const TextStyle(

                          color:
                          Colors.white,

                          fontSize:
                          15,

                          fontWeight:
                          FontWeight.w600,

                        ),

                      ),

                    ),

                  ],

                ),


                const SizedBox(
                  height: 8,
                ),


                Text(

                  '${widget.departureTime} - '
                      '${widget.arrivalTime}',

                  style:
                  const TextStyle(

                    color:
                    Colors.white70,

                    fontSize:
                    14,

                  ),

                ),

              ],

            ),

          ),


          // ======================================================
          // CONTENU PRINCIPAL
          // ======================================================

          Expanded(

            child:

            isLoading

                ? _buildLoading()

                : errorMessage != null

                ? _buildError()

                : _buildSeatContent(),

          ),


          // ======================================================
          // BOUTON CONTINUER
          // ======================================================

          if (
          !isLoading &&
              errorMessage == null
          )

            _buildContinueButton(),

        ],

      ),

    );
  }


  // ============================================================
  // CHARGEMENT
  // ============================================================

  Widget _buildLoading() {
    return const Center(

      child: Column(

        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [

          CircularProgressIndicator(

            color:
            orangeColor,

          ),


          SizedBox(
            height: 15,
          ),


          Text(

            'Chargement des sièges...',

            style:
            TextStyle(

              color:
              Colors.grey,

              fontSize:
              14,

            ),

          ),

        ],

      ),

    );
  }


  // ============================================================
  // ERREUR
  // ============================================================

  Widget _buildError() {
    return Center(

      child: Padding(

        padding:
        const EdgeInsets.all(25),

        child: Column(

          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            const Icon(

              Icons.error_outline,

              color:
              Colors.redAccent,

              size:
              55,

            ),


            const SizedBox(
              height: 15,
            ),


            const Text(

              'Impossible de charger les sièges',

              textAlign:
              TextAlign.center,

              style:
              TextStyle(

                color:
                primaryColor,

                fontSize:
                18,

                fontWeight:
                FontWeight.bold,

              ),

            ),


            const SizedBox(
              height: 10,
            ),


            Text(

              errorMessage ?? '',

              textAlign:
              TextAlign.center,

              style:
              const TextStyle(

                color:
                Colors.grey,

                fontSize:
                13,

              ),

            ),


            const SizedBox(
              height: 20,
            ),


            ElevatedButton.icon(

              onPressed:
              loadSeats,

              icon:
              const Icon(
                Icons.refresh,
              ),

              label:
              const Text(
                'Réessayer',
              ),

              style:
              ElevatedButton.styleFrom(

                backgroundColor:
                orangeColor,

                foregroundColor:
                Colors.white,

              ),

            ),

          ],

        ),

      ),

    );
  }


  // ============================================================
  // CONTENU SIÈGES
  // ============================================================

  Widget _buildSeatContent() {
    return SingleChildScrollView(

      padding:
      const EdgeInsets.all(20),

      child: Column(

        children: [

          const Text(

            'Choisissez votre siège',

            style:
            TextStyle(

              color:
              primaryColor,

              fontSize:
              22,

              fontWeight:
              FontWeight.bold,

            ),

          ),


          const SizedBox(
            height: 8,
          ),


          Text(

            widget.travelers == 1

                ? 'Sélectionnez 1 siège'

                : 'Sélectionnez '
                '${widget.travelers} sièges',

            style:
            const TextStyle(

              color:
              Colors.grey,

              fontSize:
              14,

            ),

          ),


          const SizedBox(
            height: 10,
          ),


          Text(

            '$placesDisponibles siège(s) disponible(s) '
                'sur $placesTotales',

            style:
            const TextStyle(

              color:
              primaryColor,

              fontSize:
              13,

              fontWeight:
              FontWeight.w600,

            ),

          ),


          const SizedBox(
            height: 25,
          ),


          // ======================================================
          // LÉGENDE
          // ======================================================

          Wrap(

            alignment:
            WrapAlignment.center,

            spacing:
            15,

            runSpacing:
            8,

            children: [

              _buildLegend(

                color:
                Colors.white,

                borderColor:
                primaryColor,

                label:
                'Disponible',

              ),


              _buildLegend(

                color:
                orangeColor,

                borderColor:
                orangeColor,

                label:
                'Sélectionné',

              ),


              _buildLegend(

                color:
                Colors.grey.shade300,

                borderColor:
                Colors.grey.shade300,

                label:
                'Occupé',

              ),

            ],

          ),


          const SizedBox(
            height: 30,
          ),


          // ======================================================
          // BUS
          // ======================================================

          Container(

            padding:
            const EdgeInsets.all(20),

            decoration:
            BoxDecoration(

              color:
              Colors.white,

              borderRadius:
              BorderRadius.circular(25),

              boxShadow: [

                BoxShadow(

                  color:
                  Colors.black
                      .withOpacity(0.06),

                  blurRadius:
                  15,

                  offset:
                  const Offset(
                    0,
                    5,
                  ),

                ),

              ],

            ),

            child: Column(

              children: [

                // =================================================
                // CONDUCTEUR
                // =================================================

                Container(

                  width:
                  double.infinity,

                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 12,
                  ),

                  decoration:
                  BoxDecoration(

                    color:
                    const Color(
                      0xFFF1F3F7,
                    ),

                    borderRadius:
                    BorderRadius.circular(
                      12,
                    ),

                  ),

                  child:
                  const Row(

                    mainAxisAlignment:
                    MainAxisAlignment.center,

                    children: [

                      Icon(

                        Icons
                            .airline_seat_recline_normal,

                        color:
                        primaryColor,

                      ),


                      SizedBox(
                        width: 8,
                      ),


                      Text(

                        'Conducteur',

                        style:
                        TextStyle(

                          color:
                          primaryColor,

                          fontWeight:
                          FontWeight.bold,

                        ),

                      ),

                    ],

                  ),

                ),


                const SizedBox(
                  height: 25,
                ),


                // =================================================
                // SIÈGES
                // =================================================

                GridView.builder(

                  shrinkWrap:
                  true,

                  physics:
                  const NeverScrollableScrollPhysics(),

                  itemCount:
                  seats.length,

                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(

                    crossAxisCount:
                    4,

                    crossAxisSpacing:
                    12,

                    mainAxisSpacing:
                    14,

                    childAspectRatio:
                    1,

                  ),

                  itemBuilder:
                      (context, index) {
                    final seat =
                    seats[index];


                    final seatNumber =
                        int.tryParse(
                          seat[
                          'numero_siege'
                          ].toString(),
                        ) ??
                            0;


                    final isSelected =
                    selectedSeats
                        .contains(
                      seatNumber,
                    );


                    final isUnavailable =
                        seat['statut'] !=
                            'disponible';


                    return _buildSeat(

                      seatNumber,

                      isSelected,

                      isUnavailable,

                    );
                  },

                ),

              ],

            ),

          ),


          const SizedBox(
            height: 25,
          ),


          // ======================================================
          // RÉSUMÉ
          // ======================================================

          Container(

            width:
            double.infinity,

            padding:
            const EdgeInsets.all(18),

            decoration:
            BoxDecoration(

              color:
              Colors.white,

              borderRadius:
              BorderRadius.circular(
                18,
              ),

            ),

            child:
            Row(

              children: [

                const Icon(

                  Icons.event_seat_outlined,

                  color:
                  orangeColor,

                  size:
                  28,

                ),


                const SizedBox(
                  width: 12,
                ),


                Expanded(

                  child:
                  Column(

                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      const Text(

                        'Sièges sélectionnés',

                        style:
                        TextStyle(

                          color:
                          Colors.grey,

                          fontSize:
                          13,

                        ),

                      ),


                      const SizedBox(
                        height: 4,
                      ),


                      Text(

                        selectedSeats.isEmpty

                            ? 'Aucun siège'

                            : (selectedSeats.toList()
                          ..sort())
                            .map(
                              (seat) =>
                          'Siège $seat',
                        )
                            .join(', '),

                        style:
                        const TextStyle(

                          color:
                          primaryColor,

                          fontWeight:
                          FontWeight.bold,

                        ),

                      ),

                    ],

                  ),

                ),

              ],

            ),

          ),


          const SizedBox(
            height: 20,
          ),

        ],

      ),

    );
  }


  // ============================================================
  // BOUTON CONTINUER
  // ============================================================

  Widget _buildContinueButton() {
    final canContinue =
        selectedSeats.length ==
            widget.travelers;


    return Container(

      padding:
      const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20,
      ),

      decoration:
      BoxDecoration(

        color:
        Colors.white,

        boxShadow: [

          BoxShadow(

            color:
            Colors.black
                .withOpacity(0.08),

            blurRadius:
            12,

            offset:
            const Offset(
              0,
              -3,
            ),

          ),

        ],

      ),

      child:
      SizedBox(

        width:
        double.infinity,

        height:
        55,

        child:
        ElevatedButton.icon(

          onPressed:
          canContinue
              ? continueToPassengerInformation
              : null,

          icon:
          const Icon(
            Icons.arrow_forward,
          ),

          label:
          const Text(

            'Continuer',

            style:
            TextStyle(

              fontSize:
              17,

              fontWeight:
              FontWeight.bold,

            ),

          ),

          style:
          ElevatedButton.styleFrom(

            backgroundColor:
            orangeColor,

            disabledBackgroundColor:
            Colors.grey.shade300,

            foregroundColor:
            Colors.white,

            disabledForegroundColor:
            Colors.grey.shade600,

            shape:
            RoundedRectangleBorder(

              borderRadius:
              BorderRadius.circular(
                16,
              ),

            ),

          ),

        ),

      ),

    );
  }


  // ============================================================
  // SIÈGE
  // ============================================================

  Widget _buildSeat(int seatNumber,

      bool isSelected,

      bool isUnavailable,) {
    Color backgroundColor;


    if (isUnavailable) {
      backgroundColor =
          Colors.grey.shade300;
    }

    else if (isSelected) {
      backgroundColor =
          orangeColor;
    }

    else {
      backgroundColor =
          Colors.white;
    }


    return GestureDetector(

      onTap:
      isUnavailable
          ? null
          : () =>
          toggleSeat(
            seatNumber,
          ),

      child:
      Container(

        decoration:
        BoxDecoration(

          color:
          backgroundColor,

          borderRadius:
          BorderRadius.circular(
            12,
          ),

          border:
          Border.all(

            color:

            isUnavailable

                ? Colors.grey.shade300

                : isSelected

                ? orangeColor

                : primaryColor,

            width:
            1.5,

          ),

        ),

        child:
        Center(

          child:
          Column(

            mainAxisAlignment:
            MainAxisAlignment.center,

            children: [

              Icon(

                Icons.event_seat,

                size:
                23,

                color:

                isUnavailable

                    ? Colors.grey

                    : isSelected

                    ? Colors.white

                    : primaryColor,

              ),


              const SizedBox(
                height: 2,
              ),


              Text(

                '$seatNumber',

                style:
                TextStyle(

                  color:

                  isUnavailable

                      ? Colors.grey

                      : isSelected

                      ? Colors.white

                      : primaryColor,

                  fontWeight:
                  FontWeight.bold,

                  fontSize:
                  12,

                ),

              ),

            ],

          ),

        ),

      ),

    );
  }


  // ============================================================
  // LÉGENDE
  // ============================================================

  Widget _buildLegend({

    required Color color,

    required Color borderColor,

    required String label,

  }) {
    return Row(

      mainAxisSize:
      MainAxisSize.min,

      children: [

        Container(

          width:
          18,

          height:
          18,

          decoration:
          BoxDecoration(

            color:
            color,

            borderRadius:
            BorderRadius.circular(
              5,
            ),

            border:
            Border.all(

              color:
              borderColor,

            ),

          ),

        ),


        const SizedBox(
          width: 5,
        ),


        Text(

          label,

          style:
          const TextStyle(

            fontSize:
            11,

            color:
            Colors.grey,

          ),

        ),

      ],

    );
  }
}

