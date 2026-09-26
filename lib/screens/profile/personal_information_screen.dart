import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({
    super.key,
  });

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState
    extends State<PersonalInformationScreen> {
  // ============================================================
  // COULEURS TOKENDE
  // ============================================================

  static const Color primaryColor = Color(0xFF0A2A66);
  static const Color orangeColor = Color(0xFFFF6B00);
  static const Color backgroundColor = Color(0xFFF8F9FB);

  // ============================================================
  // STOCKAGE SÉCURISÉ
  // ============================================================

  static const FlutterSecureStorage _storage =
  FlutterSecureStorage();

  // ============================================================
  // URL API LARAVEL
  // ============================================================

  String get apiBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }

    // Android Emulator
    return 'http://10.0.2.2:8000/api';
  }

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _nameController =
  TextEditingController();

  final TextEditingController _emailController =
  TextEditingController();

  // ============================================================
  // ÉTATS
  // ============================================================

  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;

  String? _errorMessage;

  // ============================================================
  // INITIALISATION
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadUserInformation();
  }

  // ============================================================
  // RÉCUPÉRER LES INFORMATIONS DEPUIS LARAVEL
  // ============================================================

  Future<void> _loadUserInformation() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final token = await _storage.read(
        key: 'auth_token',
      );

      if (token == null || token.isEmpty) {
        throw Exception(
          'Votre session a expiré. Veuillez vous reconnecter.',
        );
      }

      final response = await http.get(
        Uri.parse('$apiBaseUrl/me'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final user = data['user'] ?? data;

        _nameController.text =
            (user['name'] ?? '').toString();

        _emailController.text =
            (user['email'] ?? '').toString();

        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        return;
      }

      if (response.statusCode == 401) {
        throw Exception(
          'Votre session a expiré. Veuillez vous reconnecter.',
        );
      }

      String message =
          'Impossible de récupérer vos informations.';

      try {
        final data = jsonDecode(response.body);

        if (data['message'] != null) {
          message = data['message'].toString();
        }
      } catch (_) {}

      throw Exception(message);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst(
          'Exception: ',
          '',
        );
      });
    }
  }

  // ============================================================
  // ACTIVER LA MODIFICATION
  // ============================================================

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  // ============================================================
  // ANNULER LES MODIFICATIONS
  // ============================================================

  Future<void> _cancelEditing() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isEditing = false;
    });

    await _loadUserInformation();
  }

  // ============================================================
  // ENREGISTRER LES MODIFICATIONS
  // ============================================================

  Future<void> _saveInformation() async {
    FocusScope.of(context).unfocus();

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    // ----------------------------------------------------------
    // VÉRIFICATION DU NOM
    // ----------------------------------------------------------

    if (name.isEmpty) {
      _showMessage(
        'Veuillez renseigner votre nom complet.',
        isError: true,
      );
      return;
    }

    // ----------------------------------------------------------
    // VÉRIFICATION DE L'E-MAIL
    // ----------------------------------------------------------

    if (email.isEmpty) {
      _showMessage(
        'Veuillez renseigner votre adresse e-mail.',
        isError: true,
      );
      return;
    }

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(email)) {
      _showMessage(
        'Veuillez entrer une adresse e-mail valide.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final token = await _storage.read(
        key: 'auth_token',
      );

      if (token == null || token.isEmpty) {
        throw Exception(
          'Votre session a expiré. Veuillez vous reconnecter.',
        );
      }

      // ========================================================
      // PATCH /api/profile
      // ========================================================

      final response = await http.patch(
        Uri.parse('$apiBaseUrl/profile'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
        }),
      );

      // ========================================================
      // SUCCÈS
      // ========================================================

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final user = data['user'];

        if (user != null) {
          _nameController.text =
              (user['name'] ?? name).toString();

          _emailController.text =
              (user['email'] ?? email).toString();
        }

        if (!mounted) return;

        setState(() {
          _isSaving = false;
          _isEditing = false;
        });

        _showMessage(
          data['message'] ??
              'Profil mis à jour avec succès.',
        );

        return;
      }

      // ========================================================
      // ERREUR 422
      // ========================================================

      if (response.statusCode == 422) {
        String message =
            'Les informations saisies sont invalides.';

        try {
          final data = jsonDecode(response.body);

          if (data['errors'] != null) {
            final errors = data['errors'] as Map;

            final messages = <String>[];

            for (final value in errors.values) {
              if (value is List && value.isNotEmpty) {
                messages.add(
                  value.first.toString(),
                );
              }
            }

            if (messages.isNotEmpty) {
              message = messages.join('\n');
            }
          } else if (data['message'] != null) {
            message = data['message'].toString();
          }
        } catch (_) {}

        throw Exception(message);
      }

      // ========================================================
      // ERREUR 401
      // ========================================================

      if (response.statusCode == 401) {
        throw Exception(
          'Votre session a expiré. Veuillez vous reconnecter.',
        );
      }

      // ========================================================
      // AUTRE ERREUR
      // ========================================================

      String message =
          'Une erreur est survenue lors de la modification.';

      try {
        final data = jsonDecode(response.body);

        if (data['message'] != null) {
          message = data['message'].toString();
        }
      } catch (_) {}

      throw Exception(message);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
        isError: true,
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
      String message, {
        bool isError = false,
      }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
        isError ? Colors.red.shade700 : primaryColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ============================================================
  // CHAMP DE TEXTE
  // ============================================================

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: primaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 9),

        TextField(
          controller: controller,
          enabled: _isEditing && !_isSaving,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: primaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
            ),

            prefixIcon: Icon(
              icon,
              color: _isEditing
                  ? orangeColor
                  : Colors.grey.shade600,
            ),

            filled: true,

            fillColor: _isEditing
                ? Colors.white
                : Colors.grey.shade100,

            contentPadding:
            const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 17,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: orangeColor,
                width: 1.5,
              ),
            ),

            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // ========================================================
      // BARRE DU HAUT
      // ========================================================

      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 30,
          ),
          onPressed: () {
            if (_isEditing) {
              _cancelEditing();
            } else {
              Navigator.pop(context);
            }
          },
        ),

        title: const Text(
          'Informations personnelles',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          if (!_isLoading && !_isEditing)
            IconButton(
              tooltip: 'Modifier',
              icon: const Icon(
                Icons.edit_outlined,
                size: 27,
              ),
              onPressed: _startEditing,
            ),

          if (_isEditing)
            IconButton(
              tooltip: 'Annuler',
              icon: const Icon(
                Icons.close,
                size: 30,
              ),
              onPressed:
              _isSaving ? null : _cancelEditing,
            ),
        ],
      ),

      // ========================================================
      // CONTENU
      // ========================================================

      body: SafeArea(
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(
            color: orangeColor,
          ),
        )
            : _errorMessage != null
            ? _buildErrorState()
            : _buildContent(),
      ),
    );
  }

  // ============================================================
  // CONTENU
  // ============================================================

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        20,
        30,
        20,
        35,
      ),
      children: [
        // ======================================================
        // PHOTO / AVATAR
        // ======================================================

        Center(
          child: Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 62,
                ),
              ),

              if (_isEditing)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: orangeColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 35),

        // ======================================================
        // INFORMATIONS
        // ======================================================

        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            children: [
              // ------------------------------------------------
              // NOM COMPLET
              // ------------------------------------------------

              _buildField(
                label: 'Nom complet',
                hint: 'Votre nom complet',
                controller: _nameController,
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 24),

              // ------------------------------------------------
              // E-MAIL
              // ------------------------------------------------

              _buildField(
                label: 'Adresse e-mail',
                hint: 'Votre adresse e-mail',
                controller: _emailController,
                icon: Icons.email_outlined,
                keyboardType:
                TextInputType.emailAddress,
              ),
            ],
          ),
        ),

        // ======================================================
        // BOUTONS DE MODIFICATION
        // ======================================================

        if (_isEditing) ...[
          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed:
              _isSaving ? null : _saveInformation,
              style: ElevatedButton.styleFrom(
                backgroundColor: orangeColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                Colors.grey.shade400,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(17),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
                  : const Text(
                'Enregistrer les modifications',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton(
              onPressed:
              _isSaving ? null : _cancelEditing,
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: const BorderSide(
                  color: primaryColor,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(17),
                ),
              ),
              child: const Text(
                'Annuler',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],

        const SizedBox(height: 25),

        // ======================================================
        // INFORMATION
        // ======================================================

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E8),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                color: orangeColor,
                size: 25,
              ),

              SizedBox(width: 12),

              Expanded(
                child: Text(
                  'Ces informations sont utilisées pour '
                      'faciliter vos réservations et vos achats '
                      'sur Tokende.',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ÉTAT ERREUR
  // ============================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEEE),
                borderRadius:
                BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.cloud_off_outlined,
                color: Colors.red,
                size: 40,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Impossible de récupérer vos informations',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primaryColor,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              _errorMessage ??
                  'Une erreur est survenue.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _loadUserInformation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: orangeColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Réessayer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();

    super.dispose();
  }
}