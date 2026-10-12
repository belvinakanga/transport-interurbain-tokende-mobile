import 'dart:convert';

import 'package:flutter/material.dart';

import '../../widgets/tk/tk.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AvisScreen extends StatefulWidget {
  const AvisScreen({super.key});

  @override
  State<AvisScreen> createState() => _AvisScreenState();
}

class _AvisScreenState extends State<AvisScreen> {
  // ============================================================
  // COULEURS INTERGO CONGO
  // ============================================================

  static const Color primaryColor = Color(0xFF0A2A66);
  static const Color orangeColor = Color(0xFFFF6B00);
  static const Color backgroundColor = Color(0xFFF8F9FB);

  // ============================================================
  // API
  // ============================================================

  static const String baseUrl = 'http://127.0.0.1:8000/api';

  static const FlutterSecureStorage storage =
  FlutterSecureStorage();

  // ============================================================
  // VARIABLES
  // ============================================================

  List<Map<String, dynamic>> _avis = [];

  bool _loading = true;
  bool _sending = false;

  String? _error;

  int _selectedNote = 0;

  final TextEditingController _commentaireController =
  TextEditingController();

  // ============================================================
  // INITIALISATION
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadAvis();
  }

  @override
  void dispose() {
    _commentaireController.dispose();
    super.dispose();
  }

  // ============================================================
  // TOKEN
  // ============================================================

  Future<String?> _getToken() async {
    return storage.read(key: 'auth_token');
  }

  // ============================================================
  // RÉCUPÉRER LES AVIS
  // ============================================================

  Future<void> _loadAvis() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/avis'),
        headers: {
          'Accept': 'application/json',
        },
      );

      debugPrint('======================================');
      debugPrint('AVIS STATUS : ${response.statusCode}');
      debugPrint('AVIS RESPONSE : ${response.body}');
      debugPrint('======================================');

      dynamic decoded;

      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = {};
      }

      if (response.statusCode != 200) {
        throw Exception(
          _extractMessage(decoded) ??
              'Impossible de récupérer les avis.',
        );
      }

      final List<dynamic> list;

      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map && decoded['data'] is List) {
        list = decoded['data'];
      } else if (decoded is Map && decoded['avis'] is List) {
        list = decoded['avis'];
      } else {
        list = [];
      }

      final avis = list
          .whereType<Map>()
          .map(
            (item) => Map<String, dynamic>.from(item),
      )
          .toList();

      if (!mounted) return;

      setState(() {
        _avis = avis;
        _loading = false;
      });
    } catch (e) {
      debugPrint('ERREUR AVIS : $e');

      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = _cleanExceptionMessage(e);
      });
    }
  }

  // ============================================================
  // AJOUTER UN AVIS
  // ============================================================

  Future<void> _submitAvis() async {
    if (_selectedNote < 1 || _selectedNote > 5) {
      _showMessage(
        'Veuillez sélectionner une note.',
        isError: true,
      );
      return;
    }

    final commentaire =
    _commentaireController.text.trim();

    if (commentaire.length > 1000) {
      _showMessage(
        'Le commentaire ne doit pas dépasser 1000 caractères.',
        isError: true,
      );
      return;
    }

    final token = await _getToken();

    if (token == null || token.isEmpty) {
      _showMessage(
        'Votre session a expiré. Veuillez vous reconnecter.',
        isError: true,
      );
      return;
    }

    if (mounted) {
      setState(() {
        _sending = true;
      });
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/avis'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'note': _selectedNote,
          'commentaire':
          commentaire.isEmpty ? null : commentaire,
        }),
      );

      debugPrint('======================================');
      debugPrint('POST AVIS STATUS : ${response.statusCode}');
      debugPrint('POST AVIS RESPONSE : ${response.body}');
      debugPrint('======================================');

      dynamic decoded;

      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = {};
      }

      if (response.statusCode == 201 ||
          response.statusCode == 200) {
        _commentaireController.clear();

        if (!mounted) return;

        setState(() {
          _selectedNote = 0;
          _sending = false;
        });

        Navigator.of(context).pop();

        _showMessage(
          decoded is Map && decoded['message'] != null
              ? decoded['message'].toString()
              : 'Avis ajouté avec succès.',
        );

        await _loadAvis();

        return;
      }

      throw Exception(
        _extractMessage(decoded) ??
            'Impossible d’ajouter votre avis.',
      );
    } catch (e) {
      debugPrint('ERREUR AJOUT AVIS : $e');

      if (!mounted) return;

      setState(() {
        _sending = false;
      });

      _showMessage(
        _cleanExceptionMessage(e),
        isError: true,
      );
    }
  }

  // ============================================================
  // DIALOGUE AJOUT AVIS
  // ============================================================

  void _openAddAvisDialog() {
    _selectedNote = 0;
    _commentaireController.clear();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ------------------------------------------------
                    // ICÔNE
                    // ------------------------------------------------

                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: orangeColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        color: orangeColor,
                        size: 36,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ------------------------------------------------
                    // TITRE
                    // ------------------------------------------------

                    const Text(
                      'Donnez votre avis',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Votre expérience nous aide à améliorer TOKENDE.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ------------------------------------------------
                    // ÉTOILES
                    // ------------------------------------------------

                    const Text(
                      'Quelle note donnez-vous ?',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: List.generate(
                        5,
                            (index) {
                          final note = index + 1;

                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                _selectedNote = note;
                              });
                            },
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Icon(
                                note <= _selectedNote
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                color: orangeColor,
                                size: 42,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    if (_selectedNote > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        _noteText(_selectedNote),
                        style: const TextStyle(
                          color: orangeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],

                    const SizedBox(height: 22),

                    // ------------------------------------------------
                    // COMMENTAIRE
                    // ------------------------------------------------

                    TextField(
                      controller: _commentaireController,
                      maxLines: 5,
                      maxLength: 1000,
                      decoration: InputDecoration(
                        labelText: 'Votre commentaire',
                        hintText:
                        'Partagez votre expérience...',
                        alignLabelWithHint: true,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(
                            bottom: 65,
                          ),
                          child: Icon(
                            Icons.comment_outlined,
                            color: primaryColor,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(16),
                        ),
                        focusedBorder:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(16),
                          borderSide:
                          const BorderSide(
                            color: primaryColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ------------------------------------------------
                    // BOUTONS
                    // ------------------------------------------------

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _sending
                                ? null
                                : () {
                              Navigator.pop(
                                dialogContext,
                              );
                            },
                            style:
                            OutlinedButton.styleFrom(
                              minimumSize:
                              const Size(
                                double.infinity,
                                50,
                              ),
                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(
                                  14,
                                ),
                              ),
                              side:
                              const BorderSide(
                                color: primaryColor,
                              ),
                            ),
                            child: const Text(
                              'Annuler',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: _sending
                                ? null
                                : () {
                              _submitAvis();
                            },
                            style:
                            ElevatedButton.styleFrom(
                              backgroundColor:
                              orangeColor,
                              foregroundColor:
                              Colors.white,
                              minimumSize:
                              const Size(
                                double.infinity,
                                50,
                              ),
                              elevation: 0,
                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(
                                  14,
                                ),
                              ),
                            ),
                            child: _sending
                                ? const SizedBox(
                              width: 22,
                              height: 22,
                              child:
                              CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color:
                                Colors.white,
                              ),
                            )
                                : const Text(
                              'Publier',
                              style: TextStyle(
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // TEXTE DE LA NOTE
  // ============================================================

  String _noteText(int note) {
    switch (note) {
      case 1:
        return 'Très mauvaise expérience';
      case 2:
        return 'Mauvaise expérience';
      case 3:
        return 'Expérience moyenne';
      case 4:
        return 'Bonne expérience';
      case 5:
        return 'Excellente expérience ⭐';
      default:
        return '';
    }
  }

  // ============================================================
  // EXTRAIRE MESSAGE API
  // ============================================================

  String? _extractMessage(dynamic decoded) {
    if (decoded is Map) {
      if (decoded['message'] != null) {
        return decoded['message'].toString();
      }

      if (decoded['error'] != null) {
        return decoded['error'].toString();
      }

      if (decoded['errors'] is Map) {
        final errors = decoded['errors'] as Map;

        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) {
            return value.first.toString();
          }
        }
      }
    }

    return null;
  }

  // ============================================================
  // NETTOYER ERREUR
  // ============================================================

  String _cleanExceptionMessage(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(11);
    }

    return message;
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
  // NOM UTILISATEUR
  // ============================================================

  String _userName(Map<String, dynamic> avis) {
    final user = avis['user'];

    if (user is Map) {
      final prenom = user['prenom']?.toString() ?? '';
      final nom = user['nom']?.toString() ?? '';

      final fullName =
      '$prenom $nom'.trim();

      if (fullName.isNotEmpty) {
        return fullName;
      }

      if (user['name'] != null) {
        return user['name'].toString();
      }
    }

    return 'Utilisateur';
  }

  // ============================================================
  // DATE
  // ============================================================

  String _formatDate(dynamic value) {
    if (value == null) {
      return '';
    }

    try {
      final date = DateTime.parse(
        value.toString(),
      );

      final day =
      date.day.toString().padLeft(2, '0');
      final month =
      date.month.toString().padLeft(2, '0');
      final year =
      date.year.toString();

      return '$day/$month/$year';
    } catch (_) {
      return '';
    }
  }

  // ============================================================
  // CONSTRUIRE LES ÉTOILES
  // ============================================================

  // ============================================================
  // ÉTOILES
  // ============================================================

  Widget _etoiles(dynamic note, {double taille = 15}) {
    int rating = 0;

    if (note is int) {
      rating = note;
    } else {
      rating = int.tryParse(note?.toString() ?? '') ?? 0;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star_rounded : Icons.star_border_rounded,
          color: AppColors.orange,
          size: taille,
        );
      }),
    );
  }

  // ============================================================
  // CARTE D'AVIS
  // ============================================================

  Widget _carteAvis(Map<String, dynamic> avis) {
    final note = avis['note'];
    final commentaire = avis['commentaire']?.toString() ?? '';
    final date = _formatDate(avis['created_at']);
    final nom = _userName(avis);

    return TkCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              // Initiale plutôt qu'une icône générique : deux avis
              // voisins se distinguent au premier coup d'œil.
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.orangeDoux(context),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  nom.isEmpty ? '?' : nom.characters.first.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.orange,
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      nom,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.corpsFort(context)
                          .copyWith(fontSize: 15),
                    ),
                    Text(
                      date,
                      style: AppText.petit(context).copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),

              _etoiles(note),
            ],
          ),

          if (commentaire.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(commentaire, style: AppText.corps(context)),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fond(context),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddAvisDialog,
        backgroundColor: AppColors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
        highlightElevation: 0,
        icon: const Icon(Icons.rate_review_outlined, size: 19),
        label: const Text('Donner un avis', style: AppText.bouton),
      ),

      body: SafeArea(
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.margeEcran,
                AppSpacing.xs,
                AppSpacing.margeEcran,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  TkIconButton(
                    icone: Icons.arrow_back_rounded,
                    infobulle: 'Retour',
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Avis des voyageurs',
                      style: AppText.sousTitre(context),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                color: AppColors.orange,
                onRefresh: _loadAvis,
                child: _contenu(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contenu() {
    if (_loading) {
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

    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          TkEmptyState(
            icone: Icons.wifi_off_rounded,
            titre: 'Impossible de charger les avis',
            message: _error!,
            libelleAction: 'Réessayer',
            onAction: _loadAvis,
          ),
        ],
      );
    }

    if (_avis.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          TkEmptyState(
            icone: Icons.rate_review_outlined,
            titre: 'Aucun avis pour le moment',
            message: 'Soyez la première personne à partager votre '
                'expérience de voyage avec Tokende.',
            libelleAction: 'Donner mon avis',
            onAction: _openAddAvisDialog,
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.margeEcran,
        AppSpacing.xs,
        AppSpacing.margeEcran,
        // Laisse la place au bouton flottant.
        96,
      ),
      itemCount: _avis.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        if (index == 0) return _resume();
        return _carteAvis(_avis[index - 1]);
      },
    );
  }

  /// Note moyenne et nombre d'avis, en tête de liste.
  Widget _resume() {
    final notes = _avis
        .map((a) => int.tryParse(a['note']?.toString() ?? '') ?? 0)
        .where((n) => n > 0)
        .toList();

    final moyenne = notes.isEmpty
        ? 0.0
        : notes.reduce((a, b) => a + b) / notes.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: TkCard(
        accentuee: true,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Text(
              moyenne == 0 ? '—' : moyenne.toStringAsFixed(1),
              style: AppText.display(context).copyWith(
                fontSize: 38,
                color: AppColors.orange,
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _etoiles(moyenne.round(), taille: 17),
                  const SizedBox(height: 2),
                  Text(
                    _avis.length > 1
                        ? '${_avis.length} avis de voyageurs'
                        : '1 avis de voyageur',
                    style: AppText.petit(context).copyWith(fontSize: 13),
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
