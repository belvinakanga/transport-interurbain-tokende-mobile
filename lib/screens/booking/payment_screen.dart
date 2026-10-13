import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../widgets/tk/tk.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../config/app_config.dart';
import '../../services/tarif_service.dart';
import '../home/home_screen.dart';

class PaymentScreen extends StatefulWidget {
  // ============================================================
  // IDENTIFIANTS BACKEND
  // ============================================================

  final int trajetId;

  final int? reservationId;

  // true  = achat direct
  // false = paiement d'une réservation
  final bool isPurchase;

  // ============================================================
  // INFORMATIONS DU VOYAGE
  // ============================================================

  final String agency;
  final String departure;
  final String destination;
  final String departureTime;
  final String arrivalTime;
  final String price;
  final int travelers;
  final List<int> selectedSeats;

  // ============================================================
  // INFORMATIONS VOYAGEURS
  // ============================================================

  final List<Map<String, dynamic>> passengers;

  const PaymentScreen({
    super.key,
    required this.trajetId,
    this.reservationId,
    this.isPurchase = false,
    required this.agency,
    required this.departure,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.travelers,
    required this.selectedSeats,
    this.passengers = const [],
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // ============================================================
  // STOCKAGE
  // ============================================================

  static const FlutterSecureStorage _storage =
  FlutterSecureStorage();

  // ============================================================
  // ÉTAT
  // ============================================================

  String selectedPaymentMethod = 'mobile_money';

  // OpenPay
  final TextEditingController _phoneController = TextEditingController();
  String _selectedProvider = 'MTN'; // MTN | AIRTEL
  // Suit la configuration : à faux, le mobile money part vers /achats
  // comme les autres modes, et le backend valide sans paiement réel.
  final bool _useOpenPay = AppConfig.paiementEnLigneActif;

  bool _isProcessing = false;

  // ============================================================
  // URL API
  // ============================================================

  String get apiBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }

    return 'http://10.0.2.2:8000/api';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
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
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.margeEcran,
                  AppSpacing.xs,
                  AppSpacing.margeEcran,
                  AppSpacing.lg,
                ),
                children: [

                  Text(
                    widget.isPurchase
                        ? 'Finalisez votre achat'
                        : 'Finalisez votre réservation',
                    style: AppText.titre(context),
                  ),

                  const SizedBox(height: AppSpacing.xxs),

                  Text(
                    widget.isPurchase
                        ? 'Finalisez l’achat de votre billet.'
                        : 'Effectuez le paiement de votre réservation.',
                    style: AppText.corps(context),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  _resume(),

                  const SizedBox(height: AppSpacing.xl),

                  const TkSectionHeader(titre: 'Moyen de paiement'),

                  _choixMoyen(),

                  const SizedBox(height: AppSpacing.md),

                  if (selectedPaymentMethod == 'mobile_money')
                    _sectionMobileMoney(),

                  if (selectedPaymentMethod == 'card') _sectionCarte(),
                ],
              ),
            ),

            _barreAction(),
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
            icone: Icons.arrow_back_rounded,
            infobulle: 'Retour',
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text('Paiement', style: AppText.sousTitre(context)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RÉSUMÉ
  // ============================================================

  Widget _resume() {
    final sieges = widget.selectedSeats.map((s) => 'N° $s').join(', ');

    return TkCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            widget.agency,
            style: AppText.corpsFort(context).copyWith(fontSize: 15),
          ),

          const SizedBox(height: AppSpacing.sm),

          _ligne('Trajet', '${widget.departure} → ${widget.destination}'),
          _ligne('Horaire', '${widget.departureTime} – ${widget.arrivalTime}'),
          _ligne(
            'Voyageurs',
            widget.travelers == 1
                ? '1 voyageur'
                : '${widget.travelers} voyageurs',
          ),
          if (sieges.isNotEmpty) _ligne('Sièges', sieges),
          if (widget.reservationId != null)
            _ligne('Réservation', 'N° ${widget.reservationId}'),

          const SizedBox(height: AppSpacing.sm),

          Divider(height: 1, color: AppColors.inactifTheme(context)),

          const SizedBox(height: AppSpacing.sm),

            // Le détail remplace le total sec : le voyageur doit voir les
            // frais de service avant de valider.
            FutureBuilder<double>(
              future: TarifService.charger(),
              initialData: TarifService.fraisParBillet,
              builder: (context, instantane) {
                return TkMontantDetail(
                  prixUnitaire: _prixUnitaire(),
                  fraisParBillet:
                      instantane.data ?? TarifService.fraisParDefaut,
                  nombreBillets: widget.travelers,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _ligne(String intitule, String valeur) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              intitule,
              style: AppText.petit(context).copyWith(fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              valeur,
              style: AppText.corpsFort(context).copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CHOIX DU MOYEN DE PAIEMENT
  // ============================================================

  Widget _choixMoyen() {
    return Column(
      children: [
        _moyen(
          valeur: 'mobile_money',
          icone: Icons.smartphone_rounded,
          titre: 'Mobile Money',
          sousTitre: 'MTN Money ou Airtel Money',
        ),
        const SizedBox(height: AppSpacing.xs),
        _moyen(
          valeur: 'card',
          icone: Icons.credit_card_rounded,
          titre: 'Carte bancaire',
          sousTitre: 'Visa ou Mastercard',
        ),
      ],
    );
  }

  Widget _moyen({
    required String valeur,
    required IconData icone,
    required String titre,
    required String sousTitre,
  }) {
    final choisi = selectedPaymentMethod == valeur;

    return TkCard(
      accentuee: choisi,
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () {
        setState(() => selectedPaymentMethod = valeur);
      },
      child: Row(
        children: [
          Icon(
            icone,
            size: 21,
            color: choisi
                ? AppColors.orange
                : AppColors.secondaire(context),
          ),

          const SizedBox(width: AppSpacing.sm),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titre,
                  style: AppText.corpsFort(context).copyWith(fontSize: 15),
                ),
                Text(
                  sousTitre,
                  style: AppText.petit(context).copyWith(fontSize: 13),
                ),
              ],
            ),
          ),

          Icon(
            choisi
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 20,
            color: choisi
                ? AppColors.orange
                : AppColors.inactifTheme(context),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MOBILE MONEY
  // ============================================================

  Widget _sectionMobileMoney() {
    return TkCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text('Opérateur', style: AppText.label(context)),

          const SizedBox(height: AppSpacing.xs),

          // Deux opérateurs : des pastilles côte à côte se visent mieux
          // qu'une liste de boutons radio.
          Row(
            children: [
              Expanded(child: _operateur('MTN', 'MTN Money')),
              const SizedBox(width: AppSpacing.xs),
              Expanded(child: _operateur('AIRTEL', 'Airtel Money')),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          TkField(
            label: 'Numéro de téléphone',
            placeholder: '242066203420',
            controller: _phoneController,
            clavier: TextInputType.phone,
            iconeGauche: Icons.phone_outlined,
          ),

          const SizedBox(height: AppSpacing.xs),

          // Sans paiement en ligne, annoncer une demande de confirmation
          // serait mensonger : aucune ne partira.
          Text(
            _useOpenPay
                ? 'Format attendu : 242XXXXXXXXX. Vous recevrez une demande '
                    'de confirmation sur ce numéro.'
                : 'Mode test : l’achat est validé sans paiement réel. '
                    'Aucune demande de confirmation ne sera envoyée.',
            style: AppText.petit(context).copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _operateur(String valeur, String libelle) {
    final choisi = _selectedProvider == valeur;

    return Material(
      color: choisi
          ? AppColors.orangeDoux(context)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: () {
          if (mounted) setState(() => _selectedProvider = valeur);
        },
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          height: AppSize.controleCompact,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: choisi
                  ? AppColors.orange
                  : AppColors.inactifTheme(context),
              width: choisi ? 1.5 : 1,
            ),
          ),
          child: Text(
            libelle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: choisi
                  ? AppColors.orange
                  : AppColors.titre(context),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CARTE BANCAIRE
  // ============================================================

  Widget _sectionCarte() {
    return TkCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const TkField(
            label: 'Numéro de carte',
            placeholder: '1234 5678 9012 3456',
            iconeGauche: Icons.credit_card_rounded,
          ),

          const SizedBox(height: AppSpacing.sm),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: TkField(
                  label: 'Expiration',
                  placeholder: 'MM/AA',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Expanded(
                child: TkField(
                  label: 'CVV',
                  placeholder: '123',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BARRE D'ACTION
  // ============================================================

  Widget _barreAction() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.margeEcran,
        AppSpacing.sm,
        AppSpacing.margeEcran,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.fond(context),
        border: Border(
          top: BorderSide(color: AppColors.inactifTheme(context)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          TkButton(
            libelle: _isProcessing
                ? 'Traitement…'
                : 'Confirmer le paiement',
            onPressed: _isProcessing ? null : _confirmPayment,
            enChargement: _isProcessing,
          ),

          const SizedBox(height: AppSpacing.xs),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 13,
                color: AppColors.secondaire(context),
              ),
              const SizedBox(width: 4),
              Text(
                'Paiement sécurisé',
                style: AppText.petit(context).copyWith(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONFIRMATION DU PAIEMENT
  // ============================================================

  void _confirmPayment() {
    if (_isProcessing) return;

    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(20),
          ),

          icon: const Icon(
            Icons.payment_outlined,
            color: Color(0xFFFF6B00),
            size: 45,
          ),

          title: const Text(
            'Confirmer le paiement',
            textAlign: TextAlign.center,

            style: TextStyle(
              color: Color(0xFF0A2A66),
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Text(
            'Vous êtes sur le point de payer '
                '$_totalAvecFrais '
                  '(frais de service compris)'
                'pour votre '
                '${widget.isPurchase ? 'billet' : 'réservation'}.\n\n'
                'Voulez-vous continuer ?',

            textAlign: TextAlign.center,

            style: const TextStyle(
              color: Colors.grey,
              height: 1.5,
            ),
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },

              child: const Text(
                'Annuler',

                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );

                _processPayment();
              },

              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFFFF6B00),
                foregroundColor:
                Colors.white,
              ),

              child:
              const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // TRAITEMENT DU PAIEMENT
  // ============================================================

  Future<void> _processPayment() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // ========================================================
      // TOKEN
      // ========================================================

      final token =
      await _storage.read(
        key: 'auth_token',
      );

      if (token == null ||
          token.trim().isEmpty) {
        _showError(
          'Votre session a expiré. '
              'Veuillez vous reconnecter.',
        );

        return;
      }
      // ========================================================
      // VALIDATION TÉLÉPHONE (OpenPay)
      // ========================================================

      // Sans paiement en ligne, le numéro ne sert à rien : l'exiger
      // bloquerait les tests sans rien valider côté serveur.
      if (selectedPaymentMethod == 'mobile_money' && _useOpenPay) {
        final phone = _phoneController.text.trim();
        if (phone.isEmpty) {
          _showError('Veuillez saisir votre numéro de téléphone.');
          return;
        }
        if (!phone.startsWith('242') || phone.length < 12) {
          _showError('Numéro invalide. Utiliser le format 242XXXXXXXXX.');
          return;
        }
      }



      // ========================================================
      // DONNÉES
      // ========================================================

      Map<String, dynamic> data;

      // ========================================================
      // ACHAT DIRECT
      // ========================================================

      if (widget.isPurchase) {
        if (widget.trajetId <= 0) {
          _showError(
            'Le trajet sélectionné est invalide.',
          );

          return;
        }

        if (widget.travelers <= 0) {
          _showError(
            'Le nombre de voyageurs est invalide.',
          );

          return;
        }

        if (widget.selectedSeats.length !=
            widget.travelers) {
          _showError(
            'Le nombre de sièges sélectionnés '
                'ne correspond pas au nombre de voyageurs.',
          );

          return;
        }

        // ======================================================
        // VOYAGEURS
        // ======================================================

        if (widget.passengers.length !=
            widget.travelers) {
          _showError(
            'Les informations des voyageurs '
                'sont incomplètes.\n\n'
                'Veuillez revenir à l’étape '
                'Informations voyageurs.',
          );

          return;
        }

        final List<Map<String, dynamic>>
        voyageurs = [];

        for (
        int i = 0;
        i < widget.passengers.length;
        i++
        ) {
          final passenger =
          widget.passengers[i];

          // ----------------------------------------------------
          // PRÉNOM
          // ----------------------------------------------------

          final String prenom =
          _getPassengerString(
            passenger,
            [
              'prenom',
              'prénom',
              'firstName',
              'firstname',
              'first_name',
            ],
          );

          // ----------------------------------------------------
          // NOM
          // ----------------------------------------------------

          final String nom =
          _getPassengerString(
            passenger,
            [
              'nom',
              'lastName',
              'lastname',
              'last_name',
            ],
          );

          // ----------------------------------------------------
          // EMAIL
          // ----------------------------------------------------

          final String email =
          _getPassengerString(
            passenger,
            [
              'email',
              'mail',
            ],
          );

          // ----------------------------------------------------
          // TÉLÉPHONE
          // ----------------------------------------------------

          final String telephone =
          _getPassengerString(
            passenger,
            [
              'telephone',
              'téléphone',
              'phone',
              'phoneNumber',
              'phone_number',
            ],
          );

          // ----------------------------------------------------
          // SIÈGE
          // ----------------------------------------------------

          dynamic siege =
          passenger['siege'];

          siege ??=
          passenger['seat'];

          siege ??=
          passenger['seatNumber'];

          siege ??=
          passenger['seat_number'];

          if (siege == null &&
              i <
                  widget.selectedSeats.length) {
            siege =
            widget.selectedSeats[i];
          }

          // ----------------------------------------------------
          // VÉRIFICATIONS
          // ----------------------------------------------------

          if (prenom.trim().isEmpty) {
            _showError(
              'Le prénom du voyageur '
                  '${i + 1} est manquant.',
            );

            return;
          }

          if (nom.trim().isEmpty) {
            _showError(
              'Le nom du voyageur '
                  '${i + 1} est manquant.',
            );

            return;
          }

          if (siege == null) {
            _showError(
              'Le siège du voyageur '
                  '${i + 1} est manquant.',
            );

            return;
          }

          // ----------------------------------------------------
          // DONNÉES ENVOYÉES À LARAVEL
          // ----------------------------------------------------

          voyageurs.add({
            'prenom':
            prenom.trim(),

            'nom':
            nom.trim(),

            'email':
            email.trim().isEmpty
                ? null
                : email.trim(),

            'telephone':
            telephone.trim().isEmpty
                ? null
                : telephone.trim(),

            'siege':
            int.tryParse(
              siege.toString(),
            ) ??
                siege,
          });
        }

        // ======================================================
        // REQUÊTE ACHAT DIRECT
        // ======================================================

        data = {
          'trajet_id':
          widget.trajetId,

          'nombre_places':
          widget.travelers,

          'sieges':
          widget.selectedSeats,

          // IMPORTANT
          // Les informations saisies dans
          // Informations voyageurs arrivent ici.
          'voyageurs':
          voyageurs,
        };
      }

      // ========================================================
      // PAIEMENT D'UNE RÉSERVATION
      // ========================================================

      else {
        if (widget.reservationId == null) {
          _showError(
            'La réservation est introuvable.',
          );

          return;
        }

        data = {
          'reservation_id':
          widget.reservationId,
        };
      }

      // ========================================================
      // AFFICHAGE DEBUG
      // ========================================================
      //
      // Très utile pendant notre test.
      // On vérifie exactement ce qui part vers Laravel.
      //

      debugPrint(
        '================ ACHAT =================',
      );

      debugPrint(
        const JsonEncoder.withIndent('  ')
            .convert(data),
      );

      debugPrint(
        '=========================================',
      );

      // ========================================================
      // REQUÊTE API
      // ========================================================

      late http.Response response;
      if (selectedPaymentMethod == 'mobile_money' && _useOpenPay) {
        // Appel OpenPay via backend Laravel
        final Map<String, dynamic> openpayPayload = {
          ...data,
          'payment_phone_number': _phoneController.text.trim(),
          'provider': _selectedProvider,
        };
        response = await http.post(
          Uri.parse('$apiBaseUrl/openpay/initiate'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(openpayPayload),
        );
      } else {
        response = await http.post(
          Uri.parse(
            '$apiBaseUrl/achats',
          ),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(data),
        );
      }

      if (!mounted) return;

      // ========================================================
      // DEBUG RÉPONSE LARAVEL
      // ========================================================

      debugPrint(
        '=========== RÉPONSE LARAVEL ============',
      );

      debugPrint(
        'STATUS : ${response.statusCode}',
      );

      debugPrint(
        response.body,
      );

      debugPrint(
        '=========================================',
      );

      // ========================================================
      // SUCCÈS
      // ========================================================

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        _showPaymentSuccess(
          response.body,
        );

        return;
      }

      // ========================================================
      // ERREUR
      // ========================================================

      final message =
      _extractApiMessage(
        response.body,
      );

      _showPurchaseError(
        response.statusCode,
        message,
      );
    }

    // ==========================================================
    // ERREUR RÉSEAU / EXCEPTION
    // ==========================================================

    catch (e, stackTrace) {
      debugPrint(
        '============== EXCEPTION ==============',
      );

      debugPrint(
        e.toString(),
      );

      debugPrint(
        stackTrace.toString(),
      );

      debugPrint(
        '=======================================',
      );

      if (!mounted) return;

      _showError(
        'Impossible de contacter le serveur.\n\n'
            '$e',
      );
    }

    finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // ============================================================
  // RÉCUPÉRER UNE VALEUR VOYAGEUR
  // ============================================================

  String _getPassengerString(
      Map<String, dynamic> passenger,
      List<String> keys,
      ) {
    for (final key in keys) {
      final value =
      passenger[key];

      if (value != null &&
          value
              .toString()
              .trim()
              .isNotEmpty) {
        return value.toString();
      }
    }

    return '';
  }

  // ============================================================
  // EXTRAIRE MESSAGE API
  // ============================================================

  String _extractApiMessage(
      String responseBody,
      ) {
    try {
      final data =
      jsonDecode(responseBody);

      if (data is Map &&
          data['message'] != null) {
        final message =
        data['message']
            .toString()
            .trim();

        if (message.isNotEmpty) {
          return message;
        }
      }

      if (data is Map &&
          data['error'] != null) {
        final error =
        data['error']
            .toString()
            .trim();

        if (error.isNotEmpty) {
          return error;
        }
      }

      // Laravel validation
      if (data is Map &&
          data['errors'] is Map) {
        final errors =
        data['errors'] as Map;

        final messages =
        <String>[];

        for (final entry
        in errors.entries) {
          final value =
              entry.value;

          if (value is List) {
            for (final item
            in value) {
              messages.add(
                item.toString(),
              );
            }
          } else {
            messages.add(
              value.toString(),
            );
          }
        }

        if (messages.isNotEmpty) {
          return messages.join('\n');
        }
      }
    } catch (_) {}

    if (responseBody
        .trim()
        .isNotEmpty) {
      return responseBody;
    }

    return 'L’opération n’a pas pu être effectuée.';
  }

  // ============================================================
  // ERREUR ACHAT
  // ============================================================

  void _showPurchaseError(
      int statusCode,
      String message,
      ) {
    String finalMessage =
        message;

    if (statusCode == 409) {
      finalMessage =
      message.isNotEmpty
          ? message
          : 'Ce siège est déjà réservé ou acheté '
          'par un autre voyageur.\n\n'
          'Veuillez choisir un autre siège.';
    }

    if (statusCode == 422) {
      finalMessage =
      message.isNotEmpty
          ? message
          : 'Les informations envoyées sont invalides.';
    }

    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(20),
          ),

          icon: Icon(
            statusCode == 409
                ? Icons.event_seat_outlined
                : Icons.error_outline,

            color: Colors.red,
            size: 50,
          ),

          title: Text(
            statusCode == 409
                ? 'Billet indisponible'
                : 'Achat impossible',

            textAlign:
            TextAlign.center,

            style: const TextStyle(
              color: Color(0xFF0A2A66),
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Text(
            finalMessage,

            textAlign:
            TextAlign.center,

            style: const TextStyle(
              color: Colors.grey,
              height: 1.5,
            ),
          ),

          actions: [

            SizedBox(
              width: double.infinity,

              child:
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                  );
                },

                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF0A2A66),

                  foregroundColor:
                  Colors.white,
                ),

                child:
                const Text('Fermer'),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // SUCCÈS
  // ============================================================

  void _showPaymentSuccess(
      String responseBody,
      ) {
    String reference = '';

    try {
      final data =
      jsonDecode(responseBody);

      if (data is Map &&
          data['data'] is Map) {
        reference =
            data['data']['reference']
                ?.toString() ??
                '';
      }
    } catch (_) {}

    showDialog(
      context: context,

      barrierDismissible: false,

      builder: (dialogContext) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(20),
          ),

          icon: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 60,
          ),

          title: const Text(
            'Achat confirmé',

            textAlign:
            TextAlign.center,

            style: TextStyle(
              color: Color(0xFF0A2A66),
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Text(
            reference.isNotEmpty
                ? 'Votre achat a été enregistré '
                'avec succès.\n\n'
                'Référence : $reference'
                : 'Votre achat a été enregistré '
                'avec succès.',

            textAlign:
            TextAlign.center,

            style: const TextStyle(
              color: Colors.grey,
              height: 1.5,
            ),
          ),

          actions: [

            Column(
              mainAxisSize:
              MainAxisSize.min,

              children: [

                SizedBox(
                  width: double.infinity,

                  child:
                  ElevatedButton.icon(
                    onPressed: () {

                      Navigator.pop(
                        dialogContext,
                      );

                      Navigator.pushReplacement(
                        context,

                        MaterialPageRoute(
                          builder: (_) =>
                          const HomeScreen(
                            initialIndex: 2,
                            initialVoyagesTabIndex: 1,
                          ),
                        ),
                      );
                    },

                    icon: const Icon(
                      Icons.confirmation_num_outlined,
                    ),

                    label:
                    const Text(
                      'Voir mes achats',
                    ),

                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFFFF6B00),

                      foregroundColor:
                      Colors.white,

                      padding:
                      const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,

                  child:
                  OutlinedButton.icon(
                    onPressed: () {

                      Navigator.pop(
                        dialogContext,
                      );

                      Navigator.popUntil(
                        context,
                            (route) =>
                        route.isFirst,
                      );
                    },

                    icon: const Icon(
                      Icons.home_outlined,
                    ),

                    label:
                    const Text(
                      'Accueil',
                    ),

                    style:
                    OutlinedButton.styleFrom(
                      foregroundColor:
                      const Color(0xFF0A2A66),

                      side:
                      const BorderSide(
                        color:
                        Color(0xFF0A2A66),
                      ),

                      padding:
                      const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // ERREUR GÉNÉRALE
  // ============================================================

  void _showError(
      String message,
      ) {
    if (!mounted) return;

    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(20),
          ),

          icon: const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 50,
          ),

          title: const Text(
            'Erreur',

            textAlign:
            TextAlign.center,

            style: TextStyle(
              color: Color(0xFF0A2A66),
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Text(
            message,

            textAlign:
            TextAlign.center,

            style: const TextStyle(
              color: Colors.grey,
              height: 1.5,
            ),
          ),

          actions: [

            SizedBox(
              width: double.infinity,

              child:
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                  );
                },

                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF0A2A66),

                  foregroundColor:
                  Colors.white,
                ),

                child:
                const Text('Fermer'),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // CALCUL TOTAL
  // ============================================================

  /// Prix de l'agence, extrait de la chaîne reçue (« 15 000 FCFA »).
  double _prixUnitaire() {
    final nettoye = widget.price
        .replaceAll('FCFA', '')
        .replaceAll('\u202F', '')
        .replaceAll(' ', '')
        .replaceAll(',', '');

    return double.tryParse(nettoye) ?? 0;
  }

  /// Total réellement débité, frais de service compris.
  String get _totalAvecFrais {
    final frais = TarifService.fraisParBillet * widget.travelers;

    return TkMontantDetail.formater(
      _prixUnitaire() * widget.travelers + frais,
    );
  }

}
