import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/tk/tk.dart';
import '../auth/login_screen.dart';
import 'onboarding_model.dart';
import 'onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  /// Clé mémorisant que l'utilisateur a déjà parcouru l'onboarding.
  static const String cleOnboardingVu = 'onboarding_vu';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int pageCourante = 0;

  static const List<OnboardingModel> pages = [
    OnboardingModel(
      icone: Icons.travel_explore_rounded,
      titre: 'Trouvez votre trajet',
      description:
          'Recherchez facilement les meilleures agences et les trajets '
          'disponibles partout au Congo.',
    ),
    OnboardingModel(
      icone: Icons.confirmation_number_rounded,
      titre: 'Réservez et achetez',
      description:
          'Choisissez votre siège, payez en toute sécurité et recevez votre '
          'billet électronique instantanément.',
    ),
    OnboardingModel(
      icone: Icons.verified_rounded,
      titre: 'Voyagez en confiance',
      description:
          'Présentez votre billet électronique et profitez d’un voyage '
          'simple, rapide et sécurisé.',
    ),
  ];

  bool get estDerniserePage => pageCourante == pages.length - 1;

  /// Mémorise que l'onboarding a été vu, puis ouvre la connexion.
  Future<void> _terminer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(OnboardingScreen.cleOnboardingVu, true);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  void _pageSuivante() {
    if (estDerniserePage) {
      _terminer();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _pagePrecedente() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
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
      backgroundColor: AppColors.fond(context),

      body: SafeArea(
        child: Column(
          children: [

            // ----------------------------------------------------------------
            // BARRE HAUTE : retour discret + Ignorer
            // ----------------------------------------------------------------
            SizedBox(
              height: 62,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                child: Row(
                  children: [

                    // Flèche retour : occupe sa place même page 1, pour que
                    // le bouton Ignorer ne se déplace pas d'une page à l'autre.
                    AnimatedOpacity(
                      opacity: pageCourante == 0 ? 0 : 1,
                      duration: const Duration(milliseconds: 200),
                      child: TkIconButton(
                        icone: Icons.arrow_back_rounded,
                        onPressed:
                            pageCourante == 0 ? null : _pagePrecedente,
                        infobulle: 'Précédent',
                      ),
                    ),

                    const Spacer(),

                    TkButton(
                      libelle: 'Ignorer',
                      onPressed: _terminer,
                      variante: TkButtonVariante.tonal,
                      pleineLargeur: false,
                    ),
                  ],
                ),
              ),
            ),

            // ----------------------------------------------------------------
            // PAGES
            // ----------------------------------------------------------------
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() => pageCourante = index);
                },
                itemBuilder: (context, index) {
                  return OnboardingPage(data: pages[index]);
                },
              ),
            ),

            // ----------------------------------------------------------------
            // BAS : points + bouton unique
            // ----------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: List.generate(pages.length, (index) {
                      final actif = pageCourante == index;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.only(right: AppSpacing.xxs + 2),
                        width: actif ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: actif
                              ? AppColors.orange
                              : AppColors.inactifTheme(context),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  TkButton(
                    libelle: estDerniserePage ? 'Commencer' : 'Suivant',
                    onPressed: _pageSuivante,
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
