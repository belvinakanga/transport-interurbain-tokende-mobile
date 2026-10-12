import 'package:flutter/material.dart';

import '../../utils/format_trajet.dart';
import '../../widgets/tk/tk.dart';

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
    // Délégué à l'utilitaire partagé : la base contient aussi bien
    // « 08:00:00 » que « 07:30 ».
    return FormatTrajet.heureBrute(value) ?? '--:--';
  }

  // ============================================================
  // HEURE D'ARRIVÉE
  // ============================================================

  String getArrivalTime(dynamic trajet) {
    // L'ancienne version lisait `heure_arrivee`, un champ qui n'existe pas :
    // la colonne s'appelle `heure_fin`. Le backend expose désormais une
    // heure d'arrivée calculée, déduite de `heure_fin` ou de la durée.
    if (trajet is Map<String, dynamic>) {
      final calculee = FormatTrajet.heureArrivee(trajet);
      if (calculee != null) return calculee;
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
            _enTeteRecherche(),

            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _trajetsFuture,
                builder: (context, snapshot) {

                  if (snapshot.connectionState == ConnectionState.waiting) {
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

                  if (snapshot.hasError) {
                    return ListView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      children: [
                        TkEmptyState(
                          icone: Icons.wifi_off_rounded,
                          titre: 'Chargement impossible',
                          message: snapshot.error.toString(),
                          libelleAction: 'Réessayer',
                          onAction: reloadTrajets,
                        ),
                      ],
                    );
                  }

                  final trajets = filterTrajets(snapshot.data ?? []);

                  if (trajets.isEmpty) {
                    return RefreshIndicator(
                      color: AppColors.orange,
                      onRefresh: reloadTrajets,
                      child: ListView(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        children: [
                          TkEmptyState(
                            icone: Icons.directions_bus_outlined,
                            titre: 'Aucun trajet disponible',
                            message:
                                'Aucun départ de ${widget.departure} vers '
                                '${widget.destination} à cette date. '
                                'Essayez un autre jour.',
                            libelleAction: 'Modifier ma recherche',
                            onAction: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.orange,
                    onRefresh: reloadTrajets,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.margeEcran,
                        AppSpacing.sm,
                        AppSpacing.margeEcran,
                        AppSpacing.xxl,
                      ),
                      itemCount: trajets.length + 1,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.xxs,
                            ),
                            child: Text(
                              trajets.length > 1
                                  ? '${trajets.length} trajets disponibles'
                                  : '1 trajet disponible',
                              style: AppText.label(context),
                            ),
                          );
                        }

                        return _carteTrajet(trajets[index - 1]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EN-TÊTE
  // ============================================================

  /// Rappelle la recherche en cours et permet de la modifier.
  Widget _enTeteRecherche() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.margeEcran,
        AppSpacing.xs,
        AppSpacing.margeEcran,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              TkIconButton(
                icone: Icons.arrow_back_rounded,
                infobulle: 'Retour',
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: Text(
                  '${widget.departure} → ${widget.destination}',
                  overflow: TextOverflow.ellipsis,
                  style: AppText.sousTitre(context),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          Row(
            children: [
              Icon(
                Icons.event_rounded,
                size: 14,
                color: AppColors.secondaire(context),
              ),
              const SizedBox(width: 5),
              Text(
                formattedDate,
                style: AppText.petit(context).copyWith(fontSize: 13),
              ),

              const SizedBox(width: AppSpacing.sm),

              Icon(
                Icons.person_outline_rounded,
                size: 14,
                color: AppColors.secondaire(context),
              ),
              const SizedBox(width: 5),
              Text(
                widget.travelers == 1
                    ? '1 voyageur'
                    : '${widget.travelers} voyageurs',
                style: AppText.petit(context).copyWith(fontSize: 13),
              ),

              const Spacer(),

              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.orange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Modifier',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CARTE TRAJET
  // ============================================================

  Widget _carteTrajet(dynamic trajet) {
    final trajetId = int.tryParse(trajet['id']?.toString() ?? '');

    final agency = trajet['agence'];

    final agencyName =
        agency != null ? agency['nom_agence']?.toString() : null;

    final agencyAddress =
        agency != null ? agency['adresse']?.toString() : null;

    final departureTime = formatTime(trajet['heure_depart']);
    final arrivalTime = getArrivalTime(trajet);
    final price = formatPrice(trajet['prix']);

    final availableSeats =
        int.tryParse(trajet['places_disponibles']?.toString() ?? '0') ?? 0;

    final totalSeats =
        int.tryParse(trajet['places_totales']?.toString() ?? '0') ?? 0;

    final dateString = trajet['date_depart']?.toString();

    final tripDate =
        DateTime.tryParse(dateString ?? '') ?? widget.departureDate;

    final complet = availableSeats <= 0;

    return TkCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Horaires : l'information décisive, donc la plus grosse.
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                departureTime,
                style: AppText.sousTitre(context).copyWith(fontSize: 22),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: AppColors.secondaire(context),
                ),
              ),

              Text(
                arrivalTime,
                style: AppText.sousTitre(context).copyWith(fontSize: 22),
              ),

              const Spacer(),

              Text(
                price,
                style: AppText.corpsFort(context).copyWith(
                  fontSize: 19,
                  color: AppColors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xs),

          Text(
            agencyName ?? 'Agence partenaire',
            style: AppText.corpsFort(context).copyWith(fontSize: 15),
          ),

          if (agencyAddress != null && agencyAddress.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              agencyAddress,
              overflow: TextOverflow.ellipsis,
              style: AppText.petit(context).copyWith(fontSize: 13),
            ),
          ],

          const SizedBox(height: AppSpacing.sm),

          Divider(height: 1, color: AppColors.inactifTheme(context)),

          const SizedBox(height: AppSpacing.sm),

          Row(
            children: [
              _placesRestantes(availableSeats, totalSeats),

              const Spacer(),

              SizedBox(
                height: AppSize.controleCompact,
                child: ElevatedButton(
                  onPressed: (trajetId == null || complet)
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TripDetailsScreen(
                                trajetId: trajetId,
                                agency: agencyName ?? 'Agence partenaire',
                                departure: widget.departure,
                                destination: widget.destination,
                                departureTime: departureTime,
                                arrivalTime: arrivalTime,
                                duration: 'Transport interurbain',
                                price: price,
                                rating: '—',
                                departureDate: tripDate,
                                travelers: widget.travelers,
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.inactifTheme(context),
                    disabledForegroundColor:
                        AppColors.secondaire(context),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: Text(
                    complet ? 'Complet' : 'Réserver',
                    style: AppText.bouton.copyWith(fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Places restantes, colorées selon la tension : vert au large,
  /// ambre quand il reste peu de sièges, rouge quand c'est complet.
  Widget _placesRestantes(int disponibles, int total) {
    if (total <= 0 && disponibles <= 0) {
      return TkChip(libelle: 'Places inconnues');
    }

    if (disponibles <= 0) {
      return const TkChip(
        libelle: 'Complet',
        ton: TkChipTon.echec,
        icone: Icons.block_rounded,
      );
    }

    final tendu = total > 0 && disponibles <= total * 0.2;

    return TkChip(
      libelle: disponibles > 1
          ? '$disponibles places libres'
          : 'Dernière place',
      ton: tendu ? TkChipTon.attente : TkChipTon.succes,
      icone: Icons.event_seat_outlined,
    );
  }
}
