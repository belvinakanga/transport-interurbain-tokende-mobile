import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/tk/tk.dart';
import '../auth/login_screen.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late final AnimationController _controleur;
  late final Animation<double> _apparition;
  late final Animation<double> _echelle;

  @override
  void initState() {
    super.initState();

    _controleur = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _apparition = CurvedAnimation(
      parent: _controleur,
      curve: Curves.easeOut,
    );

    _echelle = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(
        parent: _controleur,
        curve: Curves.easeOutCubic,
      ),
    );

    _controleur.forward();

    _demarrer();
  }

  /// Laisse le splash visible, puis oriente vers l'onboarding uniquement
  /// si l'utilisateur ne l'a jamais parcouru.
  Future<void> _demarrer() async {
    final attente = Future<void>.delayed(const Duration(milliseconds: 2200));
    final prefs = await SharedPreferences.getInstance();

    final dejaVu =
        prefs.getBool(OnboardingScreen.cleOnboardingVu) ?? false;

    await attente;

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, _, _) =>
            dejaVu ? const LoginScreen() : const OnboardingScreen(),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fond(context),

      body: SafeArea(
        child: Column(
          children: [

            const Spacer(flex: 3),

            FadeTransition(
              opacity: _apparition,
              child: ScaleTransition(
                scale: _echelle,
                child: Column(
                  children: [

                    // Logo transparent : plus besoin de la carte blanche
                    // qui masquait le fond opaque de l'ancien fichier.
                    Image.asset(
                      'assets/images/transparent-logo.png',
                      width: 168,
                      height: 110,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    Text(
                      'Tokende',
                      style: AppText.display(context).copyWith(
                        fontSize: 40,
                        letterSpacing: -1.2,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // Filet orange : rappel de marque, sans dégradé.
                    Container(
                      width: 44,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxxl,
                      ),
                      child: Text(
                        'Réservez, achetez et voyagez en toute confiance.',
                        textAlign: TextAlign.center,
                        style: AppText.petit(context).copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(flex: 4),

            // Indicateur de chargement sobre
            FadeTransition(
              opacity: _apparition,
              child: SizedBox(
                width: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    backgroundColor: AppColors.inactifTheme(context),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.orange,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }
}
