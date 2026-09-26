import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../widgets/app_logo.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController =
  TextEditingController();

  final TextEditingController phoneController =
  TextEditingController();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  final TextEditingController confirmPasswordController =
  TextEditingController();

  final FlutterSecureStorage _storage =
  const FlutterSecureStorage();

  bool acceptTerms = false;
  bool isLoading = false;

  /*
  |--------------------------------------------------------------------------
  | URL API LARAVEL
  |--------------------------------------------------------------------------
  */

  static const String baseUrl =
      'http://127.0.0.1:8000/api';

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  /*
  |--------------------------------------------------------------------------
  | INSCRIPTION
  |--------------------------------------------------------------------------
  */

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez accepter les conditions d'utilisation.",
          ),
        ),
      );

      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),

        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },

        body: jsonEncode({
          'name': fullNameController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text,
          'password_confirmation':
          confirmPasswordController.text,
        }),
      );

      debugPrint(
        'REGISTER STATUS: ${response.statusCode}',
      );

      debugPrint(
        'REGISTER RESPONSE: ${response.body}',
      );

      final Map<String, dynamic> data =
      jsonDecode(response.body);

      /*
      |--------------------------------------------------------------------------
      | INSCRIPTION RÉUSSIE
      |--------------------------------------------------------------------------
      */

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final String? token = data['token'];

        if (token == null || token.isEmpty) {
          _showMessage(
            'Compte créé, mais aucun token n’a été reçu.',
            isError: true,
          );

          return;
        }

        /*
        |--------------------------------------------------------------------------
        | STOCKER LE TOKEN SANCTUM
        |--------------------------------------------------------------------------
        */

        await _storage.write(
          key: 'auth_token',
          value: token,
        );

        /*
        |--------------------------------------------------------------------------
        | STOCKER LES INFORMATIONS UTILISATEUR
        |--------------------------------------------------------------------------
        */

        final user = data['user'];

        if (user != null) {
          await _storage.write(
            key: 'user_id',
            value: user['id'].toString(),
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
            value: user['role']?.toString() ?? 'voyageur',
          );
        }

        if (!mounted) return;

        _showMessage(
          'Compte créé avec succès !',
          isError: false,
        );

        await Future.delayed(
          const Duration(milliseconds: 500),
        );

        if (!mounted) return;

        /*
        |--------------------------------------------------------------------------
        | REDIRECTION VERS L'ACCUEIL
        |--------------------------------------------------------------------------
        */

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
              (route) => false,
        );

        return;
      }

      /*
      |--------------------------------------------------------------------------
      | ERREURS LARAVEL
      |--------------------------------------------------------------------------
      */

      String message =
          'Impossible de créer le compte.';

      if (data['message'] != null) {
        message = data['message'].toString();
      }

      /*
      |--------------------------------------------------------------------------
      | ERREURS DE VALIDATION
      |--------------------------------------------------------------------------
      */

      if (data['errors'] != null) {
        final errors =
        data['errors'] as Map<String, dynamic>;

        if (errors.isNotEmpty) {
          final firstError =
              errors.values.first;

          if (firstError is List &&
              firstError.isNotEmpty) {
            message = firstError.first.toString();
          } else {
            message = firstError.toString();
          }
        }
      }

      _showMessage(
        message,
        isError: true,
      );
    } catch (e) {
      debugPrint(
        'ERREUR REGISTER : $e',
      );

      _showMessage(
        'Impossible de contacter le serveur Laravel.\n'
            'Vérifie que Laravel est démarré.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /*
  |--------------------------------------------------------------------------
  | MESSAGE
  |--------------------------------------------------------------------------
  */

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
      ),
    );
  }

  /*
  |--------------------------------------------------------------------------
  | INTERFACE
  |--------------------------------------------------------------------------
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF8F9FB),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor:
        const Color(0xFF0A2A66),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 20,
          ),

          child: Form(
            key: _formKey,

            child: Column(
              children: [

                /*
                |--------------------------------------------------------------------------
                | LOGO
                |--------------------------------------------------------------------------
                */

                const AppLogo(
                  size: 110,
                ),

                const SizedBox(
                  height: 20,
                ),

                /*
                |--------------------------------------------------------------------------
                | TITRE
                |--------------------------------------------------------------------------
                */

                const Text(
                  "Créer un compte",

                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A2A66),
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                const Text(
                  "Rejoignez Tokende et réservez vos voyages en quelques clics.",

                  textAlign:
                  TextAlign.center,

                  style: TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),

                const SizedBox(
                  height: 35,
                ),

                /*
                |--------------------------------------------------------------------------
                | NOM COMPLET
                |--------------------------------------------------------------------------
                */

                CustomTextField(
                  controller:
                  fullNameController,

                  hintText:
                  "Nom complet",

                  prefixIcon:
                  Icons.person_outline,

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return "Veuillez saisir votre nom.";
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 18,
                ),

                /*
                |--------------------------------------------------------------------------
                | TÉLÉPHONE
                |--------------------------------------------------------------------------
                */

                CustomTextField(
                  controller:
                  phoneController,

                  hintText:
                  "Téléphone",

                  keyboardType:
                  TextInputType.phone,

                  prefixIcon:
                  Icons.phone_outlined,

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return "Veuillez saisir votre numéro.";
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 18,
                ),

                /*
                |--------------------------------------------------------------------------
                | EMAIL
                |--------------------------------------------------------------------------
                */

                CustomTextField(
                  controller:
                  emailController,

                  hintText:
                  "Adresse e-mail",

                  keyboardType:
                  TextInputType.emailAddress,

                  prefixIcon:
                  Icons.email_outlined,

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return "Veuillez saisir votre e-mail.";
                    }

                    if (!value.contains('@')) {
                      return "Veuillez saisir un e-mail valide.";
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 18,
                ),

                /*
                |--------------------------------------------------------------------------
                | MOT DE PASSE
                |--------------------------------------------------------------------------
                */

                CustomTextField(
                  controller:
                  passwordController,

                  hintText:
                  "Mot de passe",

                  prefixIcon:
                  Icons.lock_outline,

                  isPassword:
                  true,

                  validator: (value) {
                    if (value == null ||
                        value.length < 6) {
                      return "Minimum 6 caractères.";
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 18,
                ),

                /*
                |--------------------------------------------------------------------------
                | CONFIRMATION MOT DE PASSE
                |--------------------------------------------------------------------------
                */

                CustomTextField(
                  controller:
                  confirmPasswordController,

                  hintText:
                  "Confirmer le mot de passe",

                  prefixIcon:
                  Icons.lock_outline,

                  isPassword:
                  true,

                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return "Veuillez confirmer votre mot de passe.";
                    }

                    if (value !=
                        passwordController.text) {
                      return "Les mots de passe ne correspondent pas.";
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 20,
                ),

                /*
                |--------------------------------------------------------------------------
                | CONDITIONS
                |--------------------------------------------------------------------------
                */

                CheckboxListTile(
                  value: acceptTerms,

                  activeColor:
                  const Color(0xFFFF6B00),

                  controlAffinity:
                  ListTileControlAffinity.leading,

                  contentPadding:
                  EdgeInsets.zero,

                  onChanged: isLoading
                      ? null
                      : (value) {
                    setState(() {
                      acceptTerms =
                          value ?? false;
                    });
                  },

                  title: const Text(
                    "J'accepte les conditions d'utilisation.",

                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                /*
                |--------------------------------------------------------------------------
                | BOUTON
                |--------------------------------------------------------------------------
                */

                SizedBox(
                  width: double.infinity,
                  height: 52,

                  child: isLoading
                      ? const Center(
                    child:
                    CircularProgressIndicator(),
                  )
                      : CustomButton(
                    text:
                    "Créer un compte",

                    onPressed:
                    register,
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                /*
                |--------------------------------------------------------------------------
                | RETOUR CONNEXION
                |--------------------------------------------------------------------------
                */

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [

                    const Text(
                      "Vous avez déjà un compte ? ",

                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),

                    GestureDetector(
                      onTap: isLoading
                          ? null
                          : () {
                        Navigator.pop(
                          context,
                        );
                      },

                      child: const Text(
                        "Se connecter",

                        style: TextStyle(
                          color:
                          Color(0xFFFF6B00),

                          fontWeight:
                          FontWeight.bold,

                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}