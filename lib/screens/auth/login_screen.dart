import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../home/home_screen.dart';
import 'register_screen.dart';
import '../../config/app_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ============================================================
  // FORMULAIRE
  // ============================================================

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  // ============================================================
  // STOCKAGE SÉCURISÉ
  // ============================================================

  final FlutterSecureStorage _storage =
  const FlutterSecureStorage();

  // ============================================================
  // ÉTAT
  // ============================================================

  bool _isLoading = false;
  bool _obscurePassword = true;

  // ============================================================
  // COULEURS TOKende
  // ============================================================

  static const Color primaryColor = Color(0xFF0A2A66);
  static const Color orangeColor = Color(0xFFFF6B00);

  // ============================================================
// API LARAVEL
// ============================================================

  static String get _baseUrl => AppConfig.baseUrl;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // CONNEXION LARAVEL
  // ============================================================

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      debugPrint('LOGIN STATUS : ${response.statusCode}');
      debugPrint('LOGIN RESPONSE : ${response.body}');

      final Map<String, dynamic> data =
      jsonDecode(response.body);

      // ========================================================
      // CONNEXION RÉUSSIE
      // ========================================================

      if (response.statusCode == 200) {
        final String? token = data['token'];

        if (token == null || token.isEmpty) {
          _showMessage(
            'Connexion réussie, mais aucun token n’a été reçu.',
            isError: true,
          );
          return;
        }

        // ======================================================
        // SAUVEGARDE DU TOKEN
        // ======================================================

        await _storage.write(
          key: 'auth_token',
          value: token,
        );

        // ======================================================
        // SAUVEGARDE DES INFORMATIONS UTILISATEUR
        // ======================================================

        final user = data['user'];

        if (user != null) {
          await _storage.write(
            key: 'user_id',
            value: user['id']?.toString() ?? '',
          );

          await _storage.write(
            key: 'user_name',
            value: user['name']?.toString() ?? '',
          );

          await _storage.write(
            key: 'user_email',
            value: user['email']?.toString() ?? '',
          );

          await _storage.write(
            key: 'user_role',
            value: user['role']?.toString() ?? '',
          );
        }

        if (!mounted) return;

        _showMessage(
          'Connexion réussie !',
          isError: false,
        );

        await Future.delayed(
          const Duration(milliseconds: 500),
        );

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );

        return;
      }

      // ========================================================
      // ERREUR LARAVEL
      // ========================================================

      String message = 'Email ou mot de passe incorrect.';

      if (data['message'] != null) {
        message = data['message'].toString();
      }

      // ========================================================
      // ERREURS DE VALIDATION
      // ========================================================

      if (data['errors'] != null) {
        final errors =
        data['errors'] as Map<String, dynamic>;

        if (errors.containsKey('email')) {
          final emailErrors = errors['email'];

          if (emailErrors is List &&
              emailErrors.isNotEmpty) {
            message = emailErrors.first.toString();
          }
        }
      }

      _showMessage(
        message,
        isError: true,
      );
    } catch (e) {
      debugPrint('ERREUR LOGIN : $e');

      _showMessage(
        'Impossible de contacter le serveur Laravel.\n'
            'Vérifie que Laravel est démarré.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
      String message, {
        required bool isError,
      }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        backgroundColor:
        isError ? Colors.red.shade700 : primaryColor,
      ),
    );
  }

  // ============================================================
  // MOT DE PASSE OUBLIÉ
  // ============================================================

  void _forgotPassword() {
    _showMessage(
      'La récupération du mot de passe sera ajoutée prochainement.',
      isError: false,
    );
  }

  // ============================================================
  // INSCRIPTION
  // ============================================================

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RegisterScreen(),
      ),
    );
  }

  // ============================================================
  // STYLE DES CHAMPS
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,

      prefixIcon: Icon(
        icon,
        color: primaryColor,
      ),

      suffixIcon: suffixIcon,

      filled: true,
      fillColor: Colors.white,

      labelStyle: TextStyle(
        color: Colors.grey.shade700,
      ),

      hintStyle: TextStyle(
        color: Colors.grey.shade500,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: orangeColor,
          width: 2,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 17,
      ),
    );
  }

  // ============================================================
  // CARTE DE CONNEXION
  // ============================================================

  Widget _buildLoginCard(double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(
        30,
        30,
        30,
        24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Bienvenue sur Tokende',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primaryColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Connectez-vous à votre compte',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 28),

            // ==================================================
            // EMAIL
            // ==================================================

            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                label: 'E-mail',
                hint: 'Entrez votre adresse e-mail',
                icon: Icons.email_outlined,
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Veuillez entrer votre e-mail';
                }

                if (!value.contains('@')) {
                  return 'Veuillez entrer un e-mail valide';
                }

                return null;
              },
            ),

            const SizedBox(height: 17),

            // ==================================================
            // MOT DE PASSE
            // ==================================================

            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) {
                if (!_isLoading) {
                  _login();
                }
              },
              decoration: _inputDecoration(
                label: 'Mot de passe',
                hint: 'Entrez votre mot de passe',
                icon: Icons.lock_outline,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword =
                      !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: primaryColor,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre mot de passe';
                }

                return null;
              },
            ),

            // ==================================================
            // MOT DE PASSE OUBLIÉ
            // ==================================================

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed:
                _isLoading ? null : _forgotPassword,
                child: const Text(
                  'Mot de passe oublié ?',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 4),

            // ==================================================
            // BOUTON CONNEXION
            // ==================================================

            SizedBox(
              height: 58,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: orangeColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                  orangeColor.withValues(alpha: 0.55),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : const Text(
                  'Se connecter',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // INSCRIPTION
            // ==================================================

            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Vous n’avez pas encore de compte ?',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
                TextButton(
                  onPressed:
                  _isLoading ? null : _goToRegister,
                  child: const Text(
                    'Créer un compte',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INTERFACE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double screenWidth = constraints.maxWidth;
          final double screenHeight = constraints.maxHeight;

          // ====================================================
          // RESPONSIVE
          // ====================================================

          final bool isDesktop = screenWidth >= 900;

          final double cardWidth = isDesktop
              ? (screenWidth * 0.36)
              .clamp(430.0, 560.0)
              : (screenWidth - 32).clamp(
            0.0,
            560.0,
          );

          return Stack(
            children: [
              // ==================================================
              // IMAGE DE FOND
              // ==================================================

              Positioned.fill(
                child: Image.asset(
                  'assets/images/tokende_bus_login.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),

              // ==================================================
              // VOILE TRÈS LÉGER
              // ==================================================

              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(
                    alpha: 0.08,
                  ),
                ),
              ),

              // ==================================================
              // CONTENU
              // ==================================================

              SafeArea(
                child: isDesktop
                    ? Stack(
                  children: [
                    // ======================================
                    // LOGO / NOM EN HAUT
                    // ======================================

                    Positioned(
                      top: 28,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          const Text(
                            'Tokende',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 6),

                          Container(
                            width: 75,
                            height: 4,
                            decoration: BoxDecoration(
                              color: orangeColor,
                              borderRadius:
                              BorderRadius.circular(10),
                            ),
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            'Voyagez simplement, voyagez sereinement.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ======================================
                    // CARTE À GAUCHE
                    // ======================================

                    Positioned(
                      left: 35,
                      top: 185,
                      bottom: 35,
                      child: SingleChildScrollView(
                        child: _buildLoginCard(cardWidth),
                      ),
                    ),

                    // ======================================
                    // PIED DE PAGE
                    // ======================================

                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 14,
                      child: Text(
                        'Tokende • Transport interurbain',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 7,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
                    : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: screenHeight - 48,
                    ),
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        // ================================
                        // NOM TOKende
                        // ================================

                        const Text(
                          'Tokende',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 6),

                        Container(
                          width: 65,
                          height: 4,
                          decoration: BoxDecoration(
                            color: orangeColor,
                            borderRadius:
                            BorderRadius.circular(10),
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'Voyagez simplement, voyagez sereinement.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 7,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        _buildLoginCard(cardWidth),

                        const SizedBox(height: 18),

                        const Text(
                          'Tokende • Transport interurbain',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 7,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
