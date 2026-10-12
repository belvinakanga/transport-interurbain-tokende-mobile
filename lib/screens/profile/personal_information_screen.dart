import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../widgets/tk/tk.dart';
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

    TkToast.selonErreur(context, message, erreur: isError);
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
              child: _isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: AppColors.orange,
                        ),
                      ),
                    )
                  : _errorMessage != null
                      ? _etatErreur()
                      : _contenu(),
            ),
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
            icone: _isEditing
                ? Icons.close_rounded
                : Icons.arrow_back_rounded,
            infobulle: _isEditing ? 'Annuler' : 'Retour',
            onPressed: () {
              if (_isEditing) {
                _cancelEditing();
              } else {
                Navigator.pop(context);
              }
            },
          ),

          const SizedBox(width: AppSpacing.sm),

          Expanded(
            child: Text(
              'Mes informations',
              style: AppText.sousTitre(context),
            ),
          ),

          if (!_isLoading && !_isEditing)
            TkIconButton(
              icone: Icons.edit_outlined,
              infobulle: 'Modifier',
              onPressed: _startEditing,
            ),
        ],
      ),
    );
  }

  // ============================================================
  // CONTENU
  // ============================================================

  Widget _contenu() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.margeEcran,
        AppSpacing.xs,
        AppSpacing.margeEcran,
        AppSpacing.xxl,
      ),
      children: [

        Center(child: _avatar()),

        const SizedBox(height: AppSpacing.xl),

        TkField(
          label: 'Nom complet',
          placeholder: 'Votre nom complet',
          controller: _nameController,
          iconeGauche: Icons.person_outline_rounded,
        ),

        const SizedBox(height: AppSpacing.md),

        TkField(
          label: 'Adresse e-mail',
          placeholder: 'Votre adresse e-mail',
          controller: _emailController,
          clavier: TextInputType.emailAddress,
          iconeGauche: Icons.mail_outline_rounded,
        ),

        if (_isEditing) ...[
          const SizedBox(height: AppSpacing.xl),

          TkButton(
            libelle: 'Enregistrer les modifications',
            onPressed: _isSaving ? null : _saveInformation,
            enChargement: _isSaving,
          ),

          const SizedBox(height: AppSpacing.xs),

          TkButton(
            libelle: 'Annuler',
            onPressed: _isSaving ? null : _cancelEditing,
            variante: TkButtonVariante.tonal,
          ),
        ],

        const SizedBox(height: AppSpacing.xl),

        // Note explicative : en carte atténuée plutôt qu'en texte gris
        // perdu en bas de page.
        TkCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 17,
                color: AppColors.secondaire(context),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Ces informations sont utilisées pour vos réservations '
                  'et pour vous contacter en cas de besoin.',
                  style: AppText.petit(context).copyWith(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Avatar : pastille orange, cohérente avec le reste de l'application.
  Widget _avatar() {
    return Stack(
      children: [
        Container(
          width: 104,
          height: 104,
          decoration: const BoxDecoration(
            color: AppColors.orange,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_rounded,
            color: Colors.white,
            size: 50,
          ),
        ),

        if (_isEditing)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.bleuNuit,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.fond(context),
                  width: 2.5,
                ),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // ÉTAT D'ERREUR
  // ============================================================

  Widget _etatErreur() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        TkEmptyState(
          icone: Icons.wifi_off_rounded,
          titre: 'Impossible de récupérer vos informations',
          message: _errorMessage ?? 'Une erreur est survenue.',
          libelleAction: 'Réessayer',
          onAction: _loadUserInformation,
        ),
      ],
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