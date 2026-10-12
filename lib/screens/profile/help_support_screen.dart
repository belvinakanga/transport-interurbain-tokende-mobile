import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../support/support_screen.dart';
import '../../widgets/tk/tk.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({
    super.key,
  });

  // ============================================================
  // COULEURS TOKENTE
  // ============================================================

  static const Color primaryColor = Color(0xFF0A2A66);
  static const Color orangeColor = Color(0xFFFF6B00);
  static const Color backgroundColor = Color(0xFFF8F9FB);

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    BuildContext context,
    String message,
  ) {
    // Appelé lorsque le téléphone ou la messagerie ne s'ouvre pas.
    TkToast.erreur(context, message);
  }

  // ============================================================
  // BUILD
  // ============================================================

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

            // En-tête
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
                      'Aide & assistance',
                      style: AppText.sousTitre(context),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.margeEcran,
                  AppSpacing.xs,
                  AppSpacing.margeEcran,
                  AppSpacing.xxl,
                ),
                children: [

                  Text(
                    'Comment pouvons-nous vous aider ?',
                    style: AppText.titre(context),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  Text(
                    'Retrouvez les réponses aux questions les plus '
                    'fréquentes, ou contactez notre équipe.',
                    style: AppText.corps(context),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ----------------------------------------------------
                  // QUESTIONS FRÉQUENTES
                  // ----------------------------------------------------

                  const TkSectionHeader(titre: 'Questions fréquentes'),

                  TkCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _question(
                          context,
                          question: 'Comment réserver un voyage ?',
                          reponse:
                              'Recherchez votre trajet, choisissez une '
                              'agence, sélectionnez votre siège puis '
                              'confirmez votre réservation.',
                          premiere: true,
                        ),
                        _filet(context),
                        _question(
                          context,
                          question: 'Comment acheter mon billet ?',
                          reponse:
                              'Après avoir sélectionné votre trajet et '
                              'votre siège, procédez au paiement pour '
                              'recevoir votre billet électronique.',
                        ),
                        _filet(context),
                        _question(
                          context,
                          question: 'Où retrouver mes billets ?',
                          reponse:
                              'Vos réservations et vos achats sont '
                              'accessibles depuis l’onglet « Mes voyages ».',
                        ),
                        _filet(context),
                        _question(
                          context,
                          question: 'Comment annuler une réservation ?',
                          reponse:
                              'Ouvrez « Mes voyages », sélectionnez la '
                              'réservation concernée puis appuyez sur '
                              '« Annuler la réservation ».',
                          derniere: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ----------------------------------------------------
                  // NOUS CONTACTER
                  // ----------------------------------------------------

                  const TkSectionHeader(titre: 'Nous contacter'),

                  TkCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [

                        _contact(
                          context,
                          icone: Icons.phone_outlined,
                          titre: 'Téléphone',
                          sousTitre: 'Contacter le service client',
                          premiere: true,
                          onTap: () async {
                            final uri = Uri(
                              scheme: 'tel',
                              path: '+242068216025',
                            );

                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            } else {
                              if (!context.mounted) return;
                              _showMessage(
                                context,
                                'Impossible d’ouvrir le téléphone.',
                              );
                            }
                          },
                        ),

                        _filet(context),

                        _contact(
                          context,
                          icone: Icons.email_outlined,
                          titre: 'E-mail',
                          sousTitre: 'Envoyer un message à notre équipe',
                          onTap: () async {
                            final uri = Uri(
                              scheme: 'mailto',
                              path: 'appassistancetok@gmail.com',
                              queryParameters: {
                                'subject': 'Demande d’assistance TOKENDÉ',
                              },
                            );

                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            } else {
                              if (!context.mounted) return;
                              _showMessage(
                                context,
                                'Impossible d’ouvrir la messagerie.',
                              );
                            }
                          },
                        ),

                        _filet(context),

                        _contact(
                          context,
                          icone: Icons.chat_bubble_outline_rounded,
                          titre: 'Nous écrire',
                          sousTitre: 'Discuter avec notre équipe',
                          derniere: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SupportScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
// ============================================================
// FORMULAIRE DE CONTACT
// ============================================================

  void _showContactForm(BuildContext context) {
    final nomController = TextEditingController();
    final emailController = TextEditingController();
    final sujetController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Nous écrire',
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Nom',
                    hintText: 'Votre nom',
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: orangeColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: orangeColor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    hintText: 'Votre adresse e-mail',
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: orangeColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: orangeColor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: sujetController,
                  decoration: InputDecoration(
                    labelText: 'Objet',
                    hintText: 'Objet de votre demande',
                    prefixIcon: const Icon(
                      Icons.subject_outlined,
                      color: orangeColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: orangeColor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: messageController,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Message',
                    hintText: 'Écrivez votre demande...',
                    alignLabelWithHint: true,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 75),
                      child: Icon(
                        Icons.message_outlined,
                        color: orangeColor,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: orangeColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Annuler',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                final nom = nomController.text.trim();
                final email = emailController.text.trim();
                final sujet = sujetController.text.trim();
                final message = messageController.text.trim();

                if (nom.isEmpty ||
                    email.isEmpty ||
                    sujet.isEmpty ||
                    message.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Veuillez remplir tous les champs.',
                      ),
                    ),
                  );
                  return;
                }

                final uri = Uri(
                  scheme: 'mailto',
                  path: 'appassistancetok@gmail.com',
                  queryParameters: {
                    'subject': sujet,
                    'body':
                    'Nom : $nom\n'
                        'E-mail : $email\n\n'
                        'Message :\n$message',
                  },
                );

                if (await canLaunchUrl(uri)) {
                  Navigator.pop(dialogContext);
                  await launchUrl(uri);
                } else {
                  _showMessage(
                    context,
                    'Impossible d’ouvrir l’application e-mail.',
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: orangeColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Envoyer'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // QUESTION DÉPLIABLE
  // ============================================================

  /// Une question repliée par défaut.
  ///
  /// L'ancienne version affichait question et réponse côte à côte, ce qui
  /// faisait un mur de texte. Replié, on lit les quatre questions d'un coup.
  Widget _question(
    BuildContext context, {
    required String question,
    required String reponse,
    bool premiere = false,
    bool derniere = false,
  }) {
    return Theme(
      // ExpansionTile dessine ses propres filets : on les neutralise pour
      // garder les séparateurs de la carte.
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        iconColor: AppColors.orange,
        collapsedIconColor: AppColors.secondaire(context),
        title: Text(
          question,
          style: AppText.corpsFort(context).copyWith(fontSize: 15),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(reponse, style: AppText.corps(context)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MOYEN DE CONTACT
  // ============================================================

  Widget _contact(
    BuildContext context, {
    required IconData icone,
    required String titre,
    required String sousTitre,
    required VoidCallback onTap,
    bool premiere = false,
    bool derniere = false,
  }) {
    final rayon = BorderRadius.vertical(
      top: Radius.circular(premiere ? AppRadius.lg : 0),
      bottom: Radius.circular(derniere ? AppRadius.lg : 0),
    );

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: rayon,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.orangeDoux(context),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icone, size: 19, color: AppColors.orange),
              ),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      titre,
                      style: AppText.corpsFort(context).copyWith(
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      sousTitre,
                      style: AppText.petit(context).copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.secondaire(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filet(BuildContext context) {
    return Divider(height: 1, color: AppColors.inactifTheme(context));
  }
}
