import 'package:flutter/material.dart';

import '../../../services/villes_service.dart';
import '../../../widgets/tk/tk.dart';

import '../../search/search_results_screen.dart';

class HomeSearchCard extends StatefulWidget {
  const HomeSearchCard({super.key});

  @override
  State<HomeSearchCard> createState() => _HomeSearchCardState();
}

class _HomeSearchCardState extends State<HomeSearchCard> {
  String? departure;
  String? destination;
  DateTime? departureDate;
  int travelers = 1;

  /// Villes proposées, lues depuis le référentiel du serveur.
  ///
  /// Les agences ajoutent leurs villes depuis le back-office : la liste
  /// ne peut plus être figée dans l'application. En attendant la réponse,
  /// on affiche le repli intégré plutôt qu'un sélecteur vide.
  List<String> cities = VillesService.villesParDefaut;

  @override
  void initState() {
    super.initState();
    _chargerVilles();
  }

  Future<void> _chargerVilles() async {
    final villes = await VillesService.charger();

    if (!mounted) return;

    setState(() => cities = villes);
  }

  // ============================================================
  // CHOISIR LE DÉPART
  // ============================================================

  Future<void> chooseDeparture() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return _CitySelector(
          title: 'Lieu de départ',
          cities: cities,
          selectedCity: departure,
        );
      },
    );

    if (result != null) {
      setState(() {
        departure = result;

        // Si la destination est identique au départ,
        // on la réinitialise.
        if (destination == departure) {
          destination = null;
        }
      });
    }
  }

  // ============================================================
  // CHOISIR LA DESTINATION
  // ============================================================

  Future<void> chooseDestination() async {
    final availableCities =
    cities.where((city) => city != departure).toList();

    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return _CitySelector(
          title: 'Destination',
          cities: availableCities,
          selectedCity: destination,
        );
      },
    );

    if (result != null) {
      setState(() {
        destination = result;
      });
    }
  }

  // ============================================================
  // INVERSER DÉPART / DESTINATION
  // ============================================================

  void swapLocations() {
    if (departure == null && destination == null) {
      return;
    }

    setState(() {
      final temporary = departure;
      departure = destination;
      destination = temporary;
    });
  }

  // ============================================================
  // CHOISIR LA DATE
  // ============================================================

  Future<void> chooseDate() async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: departureDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      helpText: 'Choisir la date de départ',
      cancelText: 'Annuler',
      confirmText: 'Valider',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0A2A66),
              secondary: Color(0xFFFF6B00),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        departureDate = selectedDate;
      });
    }
  }

  // ============================================================
  // CHOISIR LE NOMBRE DE VOYAGEURS
  // ============================================================

  Future<void> chooseTravelers() async {
    int temporaryTravelers = travelers;

    final result = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                25,
                20,
                25,
                30,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'Nombre de voyageurs',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A2A66),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: temporaryTravelers > 1
                            ? () {
                          setModalState(() {
                            temporaryTravelers--;
                          });
                        }
                            : null,
                        icon: const Icon(
                          Icons.remove_circle_outline,
                        ),
                        color: const Color(0xFF0A2A66),
                        iconSize: 38,
                      ),

                      const SizedBox(width: 25),

                      Text(
                        '$temporaryTravelers',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B00),
                        ),
                      ),

                      const SizedBox(width: 25),

                      IconButton(
                        onPressed: temporaryTravelers < 10
                            ? () {
                          setModalState(() {
                            temporaryTravelers++;
                          });
                        }
                            : null,
                        icon: const Icon(
                          Icons.add_circle_outline,
                        ),
                        color: const Color(0xFF0A2A66),
                        iconSize: 38,
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          temporaryTravelers,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B00),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'Valider',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        travelers = result;
      });
    }
  }

  // ============================================================
  // RECHERCHER
  // ============================================================

  void searchTrips() {
    if (departure == null) {
      _showMessage(
        'Veuillez choisir le lieu de départ.',
      );
      return;
    }

    if (destination == null) {
      _showMessage(
        'Veuillez choisir la destination.',
      );
      return;
    }

    if (departureDate == null) {
      _showMessage(
        'Veuillez choisir la date de départ.',
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultsScreen(
          departure: departure!,
          destination: destination!,
          departureDate: departureDate!,
          travelers: travelers,
        ),
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    // Ces messages signalent un champ manquant : ce sont des erreurs de
    // saisie, pas de simples informations.
    TkToast.erreur(context, message);
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String get formattedDate {
    if (departureDate == null) {
      return 'Choisir une date';
    }

    final day = departureDate!.day.toString().padLeft(2, '0');
    final month = departureDate!.month.toString().padLeft(2, '0');
    final year = departureDate!.year;

    return '$day/$month/$year';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.margeEcran,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          TkCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Column(
              children: [

                _ligne(
                  icone: Icons.trip_origin_rounded,
                  intitule: 'Départ',
                  valeur: departure,
                  valeurParDefaut: 'Choisir le lieu de départ',
                  onTap: chooseDeparture,
                ),

                // Le bouton d'inversion chevauche le filet qui sépare les
                // deux villes : sa position dit ce qu'il échange.
                SizedBox(
                  height: 1,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Divider(
                        height: 1,
                        color: AppColors.inactifTheme(context),
                      ),
                      Positioned(
                        right: 0,
                        top: -18,
                        child: _boutonInversion(),
                      ),
                    ],
                  ),
                ),

                _ligne(
                  icone: Icons.place_rounded,
                  intitule: 'Destination',
                  valeur: destination,
                  valeurParDefaut: 'Choisir la destination',
                  onTap: chooseDestination,
                ),

                Divider(
                  height: 1,
                  color: AppColors.inactifTheme(context),
                ),

                // Date et voyageurs tiennent sur une seule ligne : tous deux
                // ont une valeur par défaut évidente, ils n'ont pas à peser
                // autant que le choix des villes.
                Row(
                  children: [
                    Expanded(
                      child: _ligne(
                        icone: Icons.event_rounded,
                        intitule: 'Date',
                        valeur:
                            departureDate == null ? null : formattedDate,
                        valeurParDefaut: 'Choisir une date',
                        onTap: chooseDate,
                        compact: true,
                      ),
                    ),

                    Container(
                      width: 1,
                      height: 34,
                      color: AppColors.inactifTheme(context),
                    ),

                    Expanded(
                      child: _ligne(
                        icone: Icons.person_outline_rounded,
                        intitule: 'Voyageurs',
                        valeur: travelers == 1
                            ? '1 voyageur'
                            : '$travelers voyageurs',
                        valeurParDefaut: '1 voyageur',
                        onTap: chooseTravelers,
                        compact: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          TkButton(
            libelle: 'Rechercher un trajet',
            onPressed: searchTrips,
            icone: Icons.search_rounded,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOUTON D'INVERSION
  // ============================================================

  Widget _boutonInversion() {
    return Material(
      color: AppColors.orangeDoux(context),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: swapLocations,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            Icons.swap_vert_rounded,
            size: 20,
            color: AppColors.orange,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LIGNE DE SÉLECTION
  // ============================================================

  /// Intitulé au-dessus, valeur en dessous.
  ///
  /// Quand [valeur] vaut `null`, [valeurParDefaut] s'affiche en gris :
  /// l'utilisateur voit d'un coup d'œil ce qu'il lui reste à renseigner.
  Widget _ligne({
    required IconData icone,
    required String intitule,
    required String? valeur,
    required String valeurParDefaut,
    required VoidCallback onTap,
    bool compact = false,
  }) {
    final renseigne = valeur != null && valeur.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: compact ? AppSpacing.sm : AppSpacing.md,
          horizontal: AppSpacing.xxs,
        ),
        child: Row(
          children: [
            Icon(icone, size: 18, color: AppColors.orange),

            const SizedBox(width: AppSpacing.sm),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    intitule.toUpperCase(),
                    style: AppText.label(context).copyWith(fontSize: 11),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    renseigne ? valeur : valeurParDefaut,
                    overflow: TextOverflow.ellipsis,
                    style: renseigne
                        ? AppText.corpsFort(context).copyWith(fontSize: 15)
                        : AppText.corps(context).copyWith(fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// SÉLECTEUR DE VILLE
// ==================================================================

class _CitySelector extends StatelessWidget {
  final String title;
  final List<String> cities;
  final String? selectedCity;

  const _CitySelector({
    required this.title,
    required this.cities,
    required this.selectedCity,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          20,
          15,
          20,
          20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              title,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A2A66),
              ),
            ),

            const SizedBox(height: 15),

            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: cities.length,
                itemBuilder: (context, index) {
                  final city = cities[index];
                  final isSelected = city == selectedCity;

                  return ListTile(
                    onTap: () {
                      Navigator.pop(context, city);
                    },
                    leading: CircleAvatar(
                      backgroundColor: isSelected
                          ? const Color(0xFFFFF3EB)
                          : const Color(0xFFF3F5F8),
                      child: Icon(
                        Icons.location_on_outlined,
                        color: isSelected
                            ? const Color(0xFFFF6B00)
                            : const Color(0xFF0A2A66),
                      ),
                    ),
                    title: Text(
                      city,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: const Color(0xFF0A2A66),
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                      Icons.check_circle,
                      color: Color(0xFFFF6B00),
                    )
                        : const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
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
}