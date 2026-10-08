import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../support/support_screen.dart';

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
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
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

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Aide & assistance',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ========================================================
      // CONTENU
      // ========================================================

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ====================================================
            // INTRODUCTION
            // ====================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.support_agent,
                    color: Colors.white,
                    size: 42,
                  ),

                  SizedBox(height: 15),

                  Text(
                    'Comment pouvons-nous vous aider ?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    'Retrouvez les réponses aux questions '
                        'les plus fréquentes ou contactez notre équipe.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ====================================================
            // QUESTIONS FRÉQUENTES
            // ====================================================

            _buildSectionTitle(
              'Questions fréquentes',
              Icons.help_outline,
            ),

            const SizedBox(height: 12),

            _buildQuestionTile(
              context,
              question: 'Comment réserver un voyage ?',
              answer:
              'Recherchez votre trajet, choisissez une agence, '
                  'sélectionnez votre siège puis confirmez votre réservation.',
            ),

            const SizedBox(height: 10),

            _buildQuestionTile(
              context,
              question: 'Comment acheter mon billet ?',
              answer:
              'Après avoir sélectionné votre trajet et votre siège, '
                  'choisissez votre moyen de paiement puis confirmez votre achat.',
            ),

            const SizedBox(height: 10),

            _buildQuestionTile(
              context,
              question: 'Où retrouver mes billets ?',
              answer:
              'Vos réservations et vos achats sont accessibles depuis '
                  'la rubrique « Mes voyages ».',
            ),

            const SizedBox(height: 10),

            _buildQuestionTile(
              context,
              question: 'Comment annuler une réservation ?',
              answer:
              'Ouvrez « Mes voyages », sélectionnez la réservation '
                  'concernée puis utilisez l’option d’annulation lorsqu’elle est disponible.',
            ),

            const SizedBox(height: 28),

            // ====================================================
            // CONTACT
            // ====================================================

            _buildSectionTitle(
              'Nous contacter',
              Icons.headset_mic_outlined,
            ),

            const SizedBox(height: 12),

            _buildContactTile(
              context,
              icon: Icons.phone_outlined,
              title: 'Téléphone',
              subtitle: 'Contacter le service client',
              onTap: () async {
                final uri = Uri(
                  scheme: 'tel',
                  path: '+242068216025',
                );

                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  _showMessage(
                    context,
                    'Impossible d’ouvrir le téléphone.',
                  );
                }
              },
            ),

            const SizedBox(height: 10),

            _buildContactTile(
              context,
              icon: Icons.email_outlined,
              title: 'E-mail',
              subtitle: 'Envoyer un message à notre équipe',
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
                  _showMessage(
                    context,
                    'Impossible d’ouvrir l’application e-mail.',
                  );
                }
              },
            ),

            const SizedBox(height: 10),

            _buildContactTile(
              context,
              icon: Icons.chat_outlined,
              title: 'Nous écrire',
              subtitle: 'Discuter avec notre équipe',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SupportScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),

            // ====================================================
            // INFORMATIONS
            // ====================================================

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3EA),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: orangeColor,
                    size: 24,
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      'Notre équipe est là pour vous accompagner '
                          'dans vos réservations, vos achats et vos voyages.',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
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
  // TITRE DE SECTION
  // ============================================================

  Widget _buildSectionTitle(
      String title,
      IconData icon,
      ) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3EA),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: orangeColor,
            size: 23,
          ),
        ),

        const SizedBox(width: 12),

        Text(
          title,
          style: const TextStyle(
            color: primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // QUESTION FAQ
  // ============================================================

  Widget _buildQuestionTile(
      BuildContext context, {
        required String question,
        required String answer,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 4,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          18,
          0,
          18,
          18,
        ),
        iconColor: orangeColor,
        collapsedIconColor: Colors.grey,
        title: Text(
          question,
          style: const TextStyle(
            color: primaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONTACT
  // ============================================================

  Widget _buildContactTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3EA),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: orangeColor,
                  size: 26,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}