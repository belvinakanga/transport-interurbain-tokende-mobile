import 'dart:convert';

import 'package:flutter/material.dart';
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

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
          isError ? Colors.red : primaryColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
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

  Widget _buildStars(dynamic note) {
    int rating = 0;

    if (note is int) {
      rating = note;
    } else {
      rating = int.tryParse(
        note?.toString() ?? '',
      ) ??
          0;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
            (index) {
          return Icon(
            index < rating
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            color: orangeColor,
            size: 20,
          );
        },
      ),
    );
  }

  // ============================================================
  // CARTE AVIS
  // ============================================================

  Widget _buildAvisCard(
      Map<String, dynamic> avis,
      ) {
    final note = avis['note'];

    final commentaire =
        avis['commentaire']?.toString() ?? '';

    final date =
    _formatDate(avis['created_at']);

    return Container(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE8EBF0),
        ),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              // ------------------------------------------------
              // AVATAR
              // ------------------------------------------------

              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(
                    alpha: 0.10,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: primaryColor,
                  size: 25,
                ),
              ),

              const SizedBox(width: 12),

              // ------------------------------------------------
              // NOM + DATE
              // ------------------------------------------------

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName(avis),
                      style: const TextStyle(
                        color: primaryColor,
                        fontWeight:
                        FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    if (date.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        date,
                        style:
                        const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ------------------------------------------------
              // NOTE
              // ------------------------------------------------

              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                  orangeColor.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                  BorderRadius.circular(10),
                ),
                child: Text(
                  '${note ?? '-'} / 5',
                  style: const TextStyle(
                    color: orangeColor,
                    fontWeight:
                    FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          _buildStars(note),

          if (commentaire.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              commentaire,
              style: const TextStyle(
                color: Color(0xFF555555),
                fontSize: 14,
                height: 1.5,
              ),
            ),
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
      backgroundColor: backgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Avis',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ========================================================
      // BOUTON AJOUTER
      // ========================================================

      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: _openAddAvisDialog,
        backgroundColor: orangeColor,
        foregroundColor: Colors.white,
        icon: const Icon(
          Icons.rate_review_outlined,
        ),
        label: const Text(
          'Donner un avis',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: RefreshIndicator(
        color: orangeColor,
        onRefresh: _loadAvis,
        child: _loading
            ? const Center(
          child: CircularProgressIndicator(
            color: orangeColor,
          ),
        )
            : _error != null
            ? ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding:
          const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 100),
            Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Impossible de charger les avis',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primaryColor,
                fontWeight:
                FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _loadAvis,
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  primaryColor,
                  foregroundColor:
                  Colors.white,
                ),
                child:
                const Text('Réessayer'),
              ),
            ),
          ],
        )
            : _avis.isEmpty
            ? ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding:
          const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 90),

            Container(
              width: 100,
              height: 100,
              decoration:
              BoxDecoration(
                color:
                orangeColor.withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star_border_rounded,
                color: orangeColor,
                size: 55,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Aucun avis pour le moment',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                color: primaryColor,
                fontWeight:
                FontWeight.bold,
                fontSize: 20,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Soyez la première personne à partager votre expérience avec InterGO Congo.',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 25),

            ElevatedButton.icon(
              onPressed:
              _openAddAvisDialog,
              icon: const Icon(
                Icons.star_rounded,
              ),
              label: const Text(
                'Donner mon avis',
              ),
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                orangeColor,
                foregroundColor:
                Colors.white,
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal: 24,
                  vertical: 15,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                ),
              ),
            ),
          ],
        )
            : ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding:
          const EdgeInsets.fromLTRB(
            18,
            18,
            18,
            100,
          ),
          children: [
            // ------------------------------------------------
            // HEADER
            // ------------------------------------------------

            Container(
              padding:
              const EdgeInsets.all(
                20,
              ),
              decoration:
              BoxDecoration(
                color: primaryColor,
                borderRadius:
                BorderRadius.circular(
                  20,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration:
                    BoxDecoration(
                      color: Colors.white
                          .withValues(
                        alpha: 0.12,
                      ),
                      shape:
                      BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color:
                      orangeColor,
                      size: 32,
                    ),
                  ),

                  const SizedBox(
                    width: 14,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        const Text(
                          'Avis des voyageurs',
                          style:
                          TextStyle(
                            color:
                            Colors.white,
                            fontSize: 18,
                            fontWeight:
                            FontWeight
                                .bold,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          '${_avis.length} avis',
                          style:
                          TextStyle(
                            color: Colors
                                .white
                                .withValues(
                              alpha: 0.75,
                            ),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ------------------------------------------------
            // LISTE
            // ------------------------------------------------

            ..._avis.map(
              _buildAvisCard,
            ),
          ],
        ),
      ),
    );
  }
}