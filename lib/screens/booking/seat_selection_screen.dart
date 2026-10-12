import 'dart:convert';

import 'package:flutter/material.dart';

import '../../widgets/tk/tk.dart';
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
        TkToast.attente(
          context,
          widget.travelers == 1
              ? 'Vous devez choisir 1 siège.'
              : 'Vous devez choisir ${widget.travelers} sièges.',
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
      TkToast.attente(
        context,
        widget.travelers == 1
            ? 'Veuillez sélectionner 1 siège.'
            : 'Veuillez sélectionner ${widget.travelers} sièges.',
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fond(context),

      body: SafeArea(
        child: Column(
          children: [

            _enTete(),

            Expanded(
              child: isLoading
                  ? _chargement()
                  : errorMessage != null
                      ? _etatErreur()
                      : _contenuSieges(),
            ),

            if (!isLoading && errorMessage == null) _barreAction(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EN-TÊTE
  // ============================================================

  Widget _enTete() {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choisissez votre siège',
                  style: AppText.sousTitre(context),
                ),
                Text(
                  '${widget.departure} → ${widget.destination}',
                  overflow: TextOverflow.ellipsis,
                  style: AppText.petit(context).copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _etatErreur() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        TkEmptyState(
          icone: Icons.event_seat_outlined,
          titre: 'Plan des sièges indisponible',
          message: errorMessage ?? 'Une erreur est survenue.',
          libelleAction: 'Réessayer',
          onAction: loadSeats,
        ),
      ],
    );
  }

  // ============================================================
  // CONTENU
  // ============================================================

  Widget _contenuSieges() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.margeEcran,
        AppSpacing.xs,
        AppSpacing.margeEcran,
        AppSpacing.lg,
      ),
      children: [

        // Consigne et disponibilité réunies en une ligne.
        Row(
          children: [
            Expanded(
              child: Text(
                widget.travelers == 1
                    ? 'Sélectionnez 1 siège'
                    : 'Sélectionnez ${widget.travelers} sièges',
                style: AppText.corpsFort(context).copyWith(fontSize: 15),
              ),
            ),
            TkChip(
              libelle: '$placesDisponibles / $placesTotales libres',
              ton: placesDisponibles > 0
                  ? TkChipTon.succes
                  : TkChipTon.echec,
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        _legende(),

        const SizedBox(height: AppSpacing.md),

        _plan(),

        const SizedBox(height: AppSpacing.md),

        _recapSelection(),
      ],
    );
  }

  // ============================================================
  // LÉGENDE
  // ============================================================

  Widget _legende() {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      children: [
        _pointLegende('Disponible', null),
        _pointLegende('Sélectionné', AppColors.orange),
        _pointLegende('Occupé', AppColors.inactifTheme(context)),
      ],
    );
  }

  Widget _pointLegende(String libelle, Color? couleur) {
    final sombre = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: couleur ?? (sombre ? AppColors.fondSombre : Colors.white),
            borderRadius: BorderRadius.circular(4),
            border: couleur == null
                ? Border.all(color: AppColors.inactifTheme(context))
                : null,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          libelle,
          style: AppText.petit(context).copyWith(fontSize: 12),
        ),
      ],
    );
  }

  // ============================================================
  // PLAN DU BUS
  // ============================================================

  Widget _plan() {
    return TkCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [

          // Repère du conducteur : sans lui, le plan n'a pas de sens
          // de lecture et on ne sait pas où est l'avant du bus.
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.inactifTheme(context),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.airline_seat_recline_normal_rounded,
                      size: 14,
                      color: AppColors.secondaire(context),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Conducteur',
                      style: AppText.petit(context).copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: seats.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final seat = seats[index];

              final seatNumber =
                  int.tryParse(seat['numero_siege'].toString()) ?? 0;

              final isSelected = selectedSeats.contains(seatNumber);
              final isUnavailable = seat['statut'] != 'disponible';

              return _siege(seatNumber, isSelected, isUnavailable);
            },
          ),
        ],
      ),
    );
  }

  Widget _siege(int numero, bool selectionne, bool indisponible) {
    final sombre = Theme.of(context).brightness == Brightness.dark;

    final Color fond;
    final Color encre;
    final Color bordure;

    if (indisponible) {
      fond = AppColors.inactifTheme(context);
      encre = AppColors.secondaire(context);
      bordure = AppColors.inactifTheme(context);
    } else if (selectionne) {
      fond = AppColors.orange;
      encre = Colors.white;
      bordure = AppColors.orange;
    } else {
      fond = sombre ? AppColors.fondSombre : Colors.white;
      encre = AppColors.titre(context);
      bordure = AppColors.inactifTheme(context);
    }

    return Material(
      color: fond,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: indisponible ? null : () => toggleSeat(numero),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: bordure,
              width: selectionne ? 1.6 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                indisponible
                    ? Icons.close_rounded
                    : Icons.event_seat_rounded,
                size: 17,
                color: encre,
              ),
              const SizedBox(height: 2),
              Text(
                '$numero',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: encre,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // RÉCAPITULATIF
  // ============================================================

  Widget _recapSelection() {
    final liste = selectedSeats.toList()..sort();

    return TkCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Text('Sièges choisis', style: AppText.label(context)),

          const SizedBox(width: AppSpacing.sm),

          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: liste.isEmpty
                  ? Text(
                      'Aucun siège',
                      style: AppText.corps(context).copyWith(fontSize: 14),
                    )
                  : Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 5,
                      runSpacing: 5,
                      children: [
                        for (final s in liste)
                          TkChip(
                            libelle: '$s',
                            ton: TkChipTon.accent,
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BARRE D'ACTION
  // ============================================================

  Widget _barreAction() {
    final complet = selectedSeats.length == widget.travelers;

    final manquants = widget.travelers - selectedSeats.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.margeEcran,
        AppSpacing.sm,
        AppSpacing.margeEcran,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.fond(context),
        border: Border(
          top: BorderSide(color: AppColors.inactifTheme(context)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // Dit ce qu'il manque, plutôt que de désactiver le bouton
          // sans explication.
          if (!complet)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(
                manquants > 0
                    ? 'Encore $manquants siège${manquants > 1 ? 's' : ''} '
                        'à choisir'
                    : 'Vous avez choisi trop de sièges',
                style: AppText.petit(context).copyWith(fontSize: 13),
              ),
            ),

          TkButton(
            libelle: 'Continuer',
            icone: Icons.arrow_forward_rounded,
            onPressed: complet ? continueToPassengerInformation : null,
          ),
        ],
      ),
    );
  }
}
