import 'package:flutter/material.dart';

import '../auth/login_screen.dart';
import 'onboarding_model.dart';
import 'onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int currentPage = 0;

  final List<OnboardingModel> pages = [
    OnboardingModel(
      image: 'assets/images/onboarding/trajet.jpg',
      title: 'Trouvez votre trajet',
      description:
      'Recherchez facilement les meilleures agences et les trajets disponibles partout au Congo.',
    ),
    OnboardingModel(
      image: 'assets/images/onboarding/reservation.jpg',
      title: 'Réservez et achetez',
      description:
      'Choisissez votre siège, payez en toute sécurité et recevez votre billet électronique instantanément.',
    ),
    OnboardingModel(
      image: 'assets/images/onboarding/voyage.jpg',
      title: 'Voyagez en toute confiance',
      description:
      'Présentez votre billet électronique et profitez d’un voyage simple, rapide et sécurisé.',
    ),
  ];

  // Passer à la page suivante
  void nextPage() {
    if (currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Sur la dernière page :
      // aller vers la connexion
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    }
  }

  // Revenir à la page précédente
  void previousPage() {
    if (currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  // Ignorer l'onboarding et aller directement à la connexion
  void skip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            // =========================
            // INDICATEUR / IGNORER
            // =========================
            Padding(
              padding: const EdgeInsets.only(
                left: 28,
                right: 20,
                top: 10,
              ),
              child: Row(
                children: [
                  Text(
                    'Page ${currentPage + 1}/${pages.length}',
                    style: const TextStyle(
                      color: Color(0xFF0A2A66),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Spacer(),

                  TextButton(
                    onPressed: skip,
                    child: const Text(
                      'Ignorer',
                      style: TextStyle(
                        color: Color(0xFFFF6B00),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // =========================
            // BARRE DE PROGRESSION
            // =========================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (currentPage + 1) / pages.length,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFF6B00),
                  ),
                ),
              ),
            ),

            // =========================
            // PAGES ONBOARDING
            // =========================
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingPage(
                    data: pages[index],
                  );
                },
              ),
            ),

            // =========================
            // INDICATEURS
            // =========================
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                    (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: currentPage == index ? 28 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: currentPage == index
                          ? const Color(0xFFFF6B00)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            // =========================
            // BOUTONS
            // =========================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                children: [
                  // PRÉCÉDENT
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                      currentPage == 0 ? null : previousPage,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(
                          double.infinity,
                          58,
                        ),
                        side: BorderSide(
                          color: currentPage == 0
                              ? Colors.grey.shade300
                              : const Color(0xFF0A2A66),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Précédent',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: currentPage == 0
                              ? Colors.grey
                              : const Color(0xFF0A2A66),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // SUIVANT / COMMENCER
                  Expanded(
                    child: ElevatedButton(
                      onPressed: nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B00),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(
                          double.infinity,
                          58,
                        ),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        currentPage == pages.length - 1
                            ? 'Commencer'
                            : 'Suivant',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}