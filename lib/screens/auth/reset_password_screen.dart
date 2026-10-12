import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/password_reset_service.dart';
import '../../widgets/tk/tk.dart';

/// Étape 2 de la récupération : saisie du code reçu et du nouveau mot de
/// passe, sur un seul écran.
///
/// Le code et le mot de passe sont demandés ensemble plutôt qu'en deux
/// écrans : l'utilisateur a le code sous les yeux, autant terminer d'un coup.
class ResetPasswordScreen extends StatefulWidget {
  final String email;

  /// Durée de validité annoncée par le serveur, en minutes.
  final int validiteMinutes;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    this.validiteMinutes = 15,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _codeController = TextEditingController();
  final _motDePasseController = TextEditingController();
  final _confirmationController = TextEditingController();

  final _service = PasswordResetService();

  bool _envoiEnCours = false;
  bool _renvoiEnCours = false;
  bool _voirMotDePasse = false;
  bool _voirConfirmation = false;

  String? _erreurCode;
  String? _erreurMotDePasse;

  /// Secondes restantes avant de pouvoir redemander un code.
  int _attenteRenvoi = 0;
  Timer? _minuteur;

  @override
  void initState() {
    super.initState();
    _lancerAttenteRenvoi();
  }

  @override
  void dispose() {
    _minuteur?.cancel();
    _codeController.dispose();
    _motDePasseController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  /// Empêche de marteler le bouton « Renvoyer » : le serveur limite à
  /// 5 envois par heure, autant le rendre visible.
  void _lancerAttenteRenvoi() {
    _minuteur?.cancel();
    setState(() => _attenteRenvoi = 60);

    _minuteur = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _attenteRenvoi--;
        if (_attenteRenvoi <= 0) t.cancel();
      });
    });
  }

  Future<void> _renvoyerCode() async {
    setState(() {
      _renvoiEnCours = true;
      _erreurCode = null;
    });

    try {
      await _service.demanderCode(widget.email);

      if (!mounted) return;

      _lancerAttenteRenvoi();
      _afficherMessage('Un nouveau code vous a été envoyé.');
    } on PasswordResetException catch (e) {
      if (!mounted) return;
      setState(() => _erreurCode = e.message);
    } finally {
      if (mounted) setState(() => _renvoiEnCours = false);
    }
  }

  Future<void> _valider() async {
    setState(() {
      _erreurCode = null;
      _erreurMotDePasse = null;
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() => _envoiEnCours = true);

    try {
      final message = await _service.reinitialiser(
        email: widget.email,
        code: _codeController.text,
        motDePasse: _motDePasseController.text,
        confirmation: _confirmationController.text,
      );

      if (!mounted) return;

      _afficherMessage(message);

      // On revient à la connexion : tous les jetons ont été révoqués
      // côté serveur, l'utilisateur doit se reconnecter.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on PasswordResetException catch (e) {
      if (!mounted) return;

      // Un message qui parle du code s'affiche sous le champ code ;
      // les autres sous le champ mot de passe.
      final parleDuCode = e.message.toLowerCase().contains('code');

      setState(() {
        if (parleDuCode) {
          _erreurCode = e.message;
        } else {
          _erreurMotDePasse = e.message;
        }
      });
    } finally {
      if (mounted) setState(() => _envoiEnCours = false);
    }
  }

  void _afficherMessage(String message) {
    TkToast.succes(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fond(context),

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
                      'Nouveau mot de passe',
                      style: AppText.sousTitre(context),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.margeEcran,
                    AppSpacing.xs,
                    AppSpacing.margeEcran,
                    AppSpacing.xxl,
                  ),
                  children: [

                    Text(
                      'Vérifiez votre boîte mail',
                      style: AppText.titre(context),
                    ),

                    const SizedBox(height: AppSpacing.xxs),

                    Text.rich(
                      TextSpan(
                        style: AppText.corps(context),
                        children: [
                          const TextSpan(
                            text: 'Un code à 6 chiffres a été envoyé à ',
                          ),
                          TextSpan(
                            text: widget.email,
                            style: AppText.corpsFort(context)
                                .copyWith(fontSize: 16),
                          ),
                          TextSpan(
                            text: '. Il expire dans '
                                '${widget.validiteMinutes} minutes.',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    TkField(
                      label: 'Code de vérification',
                      placeholder: '000000',
                      controller: _codeController,
                      clavier: TextInputType.number,
                      iconeGauche: Icons.pin_outlined,
                      messageErreur: _erreurCode,
                      validateur: (valeur) {
                        final v = (valeur ?? '').trim();
                        if (v.isEmpty) {
                          return 'Veuillez entrer le code reçu.';
                        }
                        if (v.length != 6) {
                          return 'Le code comporte 6 chiffres.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    _ligneRenvoi(),

                    const SizedBox(height: AppSpacing.lg),

                    TkField(
                      label: 'Nouveau mot de passe',
                      placeholder: 'Au moins 8 caractères',
                      controller: _motDePasseController,
                      motDePasse: true,
                      motDePasseVisible: _voirMotDePasse,
                      onBasculerVisibilite: () {
                        setState(() => _voirMotDePasse = !_voirMotDePasse);
                      },
                      iconeGauche: Icons.lock_outline_rounded,
                      messageErreur: _erreurMotDePasse,
                      validateur: (valeur) {
                        final v = valeur ?? '';
                        if (v.isEmpty) {
                          return 'Veuillez choisir un mot de passe.';
                        }
                        if (v.length < 8) {
                          return 'Au moins 8 caractères sont nécessaires.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.md),

                    TkField(
                      label: 'Confirmer le mot de passe',
                      placeholder: 'Retapez le mot de passe',
                      controller: _confirmationController,
                      motDePasse: true,
                      motDePasseVisible: _voirConfirmation,
                      onBasculerVisibilite: () {
                        setState(
                          () => _voirConfirmation = !_voirConfirmation,
                        );
                      },
                      iconeGauche: Icons.lock_reset_rounded,
                      validateur: (valeur) {
                        if ((valeur ?? '').isEmpty) {
                          return 'Veuillez confirmer le mot de passe.';
                        }
                        if (valeur != _motDePasseController.text) {
                          return 'Les deux mots de passe ne correspondent '
                              'pas.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    TkButton(
                      libelle: 'Réinitialiser le mot de passe',
                      onPressed: _envoiEnCours ? null : _valider,
                      enChargement: _envoiEnCours,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 15,
                          color: AppColors.secondaire(context),
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        Expanded(
                          child: Text(
                            'Changer votre mot de passe vous déconnecte de '
                            'tous vos autres appareils.',
                            style: AppText.petit(context)
                                .copyWith(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ligneRenvoi() {
    final peutRenvoyer = _attenteRenvoi <= 0 && !_renvoiEnCours;

    return Row(
      children: [
        Expanded(
          child: Text(
            'Vous n’avez rien reçu ?',
            style: AppText.petit(context).copyWith(fontSize: 13),
          ),
        ),

        TextButton(
          onPressed: peutRenvoyer ? _renvoyerCode : null,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.orange,
            disabledForegroundColor: AppColors.secondaire(context),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            _renvoiEnCours
                ? 'Envoi…'
                : _attenteRenvoi > 0
                    ? 'Renvoyer dans $_attenteRenvoi s'
                    : 'Renvoyer le code',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
