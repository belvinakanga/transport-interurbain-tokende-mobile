import 'package:flutter/material.dart';

import '../../services/password_reset_service.dart';
import '../../widgets/tk/tk.dart';
import 'reset_password_screen.dart';

/// Étape 1 de la récupération : l'utilisateur saisit son adresse e-mail et
/// reçoit un code à 6 chiffres.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _service = PasswordResetService();

  bool _envoiEnCours = false;
  String? _erreur;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _envoyerCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _envoiEnCours = true;
      _erreur = null;
    });

    final email = _emailController.text.trim();

    try {
      final validite = await _service.demanderCode(email);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(
            email: email,
            validiteMinutes: validite,
          ),
        ),
      );
    } on PasswordResetException catch (e) {
      if (!mounted) return;
      setState(() => _erreur = e.message);
    } finally {
      if (mounted) setState(() => _envoiEnCours = false);
    }
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
                      'Mot de passe oublié',
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

                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.orangeDoux(context),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        size: 30,
                        color: AppColors.orange,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    Text(
                      'Récupérez votre compte',
                      style: AppText.titre(context),
                    ),

                    const SizedBox(height: AppSpacing.xxs),

                    Text(
                      'Indiquez l’adresse e-mail de votre compte. Nous vous '
                      'enverrons un code de vérification à 6 chiffres.',
                      style: AppText.corps(context),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    TkField(
                      label: 'Adresse e-mail',
                      placeholder: 'vous@exemple.com',
                      controller: _emailController,
                      clavier: TextInputType.emailAddress,
                      iconeGauche: Icons.mail_outline_rounded,
                      messageErreur: _erreur,
                      validateur: (valeur) {
                        if (valeur == null || valeur.trim().isEmpty) {
                          return 'Veuillez entrer votre adresse e-mail.';
                        }
                        if (!valeur.contains('@')) {
                          return 'Cette adresse e-mail n’est pas valide.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    TkButton(
                      libelle: 'Envoyer le code',
                      icone: Icons.send_rounded,
                      onPressed: _envoiEnCours ? null : _envoyerCode,
                      enChargement: _envoiEnCours,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Dit pourquoi la réponse est la même dans tous les cas,
                    // sinon l'utilisateur croit que l'envoi a échoué.
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
                            'Par sécurité, le même message s’affiche que '
                            'l’adresse existe ou non.',
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
}
