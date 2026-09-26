import 'package:flutter/material.dart';

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

  final List<String> cities = [
    'Brazzaville',
    'Pointe-Noire',
    'Dolisie',
    'Nkayi',
    'Oyo',
    'Ouesso',
    'Impfondo',
  ];

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0A2A66),
      ),
    );
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
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ======================================================
          // DÉPART
          // ======================================================

          GestureDetector(
            onTap: chooseDeparture,
            child: _buildTile(
              icon: Icons.location_on_outlined,
              title: 'Départ',
              value: departure ?? 'Choisir le lieu de départ',
            ),
          ),

          const Divider(height: 30),

          // ======================================================
          // DESTINATION + BOUTON INVERSION
          // ======================================================

          Stack(
            children: [
              GestureDetector(
                onTap: chooseDestination,
                child: _buildTile(
                  icon: Icons.location_on,
                  title: 'Destination',
                  value:
                  destination ?? 'Choisir la destination',
                ),
              ),

              Positioned(
                right: 0,
                top: 8,
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFFFF3EB),
                  child: IconButton(
                    onPressed: swapLocations,
                    icon: const Icon(
                      Icons.swap_vert,
                      color: Color(0xFFFF6B00),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 30),

          // ======================================================
          // DATE
          // ======================================================

          GestureDetector(
            onTap: chooseDate,
            child: _buildTile(
              icon: Icons.calendar_month_outlined,
              title: 'Date de départ',
              value: formattedDate,
            ),
          ),

          const Divider(height: 30),

          // ======================================================
          // VOYAGEURS
          // ======================================================

          GestureDetector(
            onTap: chooseTravelers,
            child: _buildTile(
              icon: Icons.person_outline,
              title: 'Voyageurs',
              value: travelers == 1
                  ? '1 voyageur'
                  : '$travelers voyageurs',
            ),
          ),

          const SizedBox(height: 25),

          // ======================================================
          // BOUTON RECHERCHE
          // ======================================================

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: searchTrips,
              icon: const Icon(Icons.search),
              label: const Text(
                'Rechercher un trajet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B00),
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TILE
  // ============================================================

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFFFF6B00),
          size: 28,
        ),

        const SizedBox(width: 15),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: value.startsWith('Choisir')
                      ? Colors.grey.shade500
                      : const Color(0xFF0A2A66),
                ),
              ),
            ],
          ),
        ),

        const Icon(
          Icons.chevron_right,
          color: Colors.grey,
        ),
      ],
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