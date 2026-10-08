import 'package:flutter/material.dart';

import '../../services/support_service.dart';

class NouvelleConversationScreen extends StatefulWidget {
  const NouvelleConversationScreen({super.key});

  @override
  State<NouvelleConversationScreen> createState() =>
      _NouvelleConversationScreenState();
}

class _NouvelleConversationScreenState
    extends State<NouvelleConversationScreen> {
  final SupportService _supportService = SupportService();

  final TextEditingController _subjectController =
  TextEditingController();

  final TextEditingController _messageController =
  TextEditingController();

  final FocusNode _subjectFocusNode = FocusNode();
  final FocusNode _messageFocusNode = FocusNode();

  bool _isSending = false;

  static const Color primaryColor = Color(0xFF0A2A66);
  static const Color orangeColor = Color(0xFFFF6B00);

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    _subjectFocusNode.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  Future<void> _sendConversation() async {
    FocusScope.of(context).unfocus();

    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    if (subject.isEmpty) {
      _showMessage(
        'Veuillez saisir le sujet de votre message.',
        isError: true,
      );

      _subjectFocusNode.requestFocus();
      return;
    }

    if (message.isEmpty) {
      _showMessage(
        'Veuillez saisir votre message.',
        isError: true,
      );

      _messageFocusNode.requestFocus();
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await _supportService.createConversation(
        subject: subject,
        message: message,
      );

      if (!mounted) return;

      _showMessage(
        'Votre message a été envoyé avec succès.',
      );

      await Future.delayed(
        const Duration(milliseconds: 700),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSending = false;
      });

      _showMessage(
        e.toString(),
        isError: true,
      );
    }
  }

  void _showMessage(
      String message, {
        bool isError = false,
      }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor:
          isError ? Colors.red.shade700 : primaryColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: primaryColor,
            size: 20,
          ),
          onPressed: _isSending
              ? null
              : () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Nouvelle conversation',
          style: TextStyle(
            color: primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            18,
            20,
            18,
            30,
          ),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              // ------------------------------------------------
              // PETITE INTRODUCTION
              // ------------------------------------------------

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(16),

                  border: Border.all(
                    color: const Color(0xFFD9E4F5),
                  ),
                ),

                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    Container(
                      width: 46,
                      height: 46,

                      decoration: BoxDecoration(
                        color:
                        const Color(0xFFEAF2FF),
                        borderRadius:
                        BorderRadius.circular(14),
                      ),

                      child: const Icon(
                        Icons.support_agent_outlined,
                        color: primaryColor,
                        size: 25,
                      ),
                    ),

                    const SizedBox(width: 13),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [
                          Text(
                            'Comment pouvons-nous vous aider ?',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 15.5,
                              fontWeight:
                              FontWeight.w800,
                            ),
                          ),

                          SizedBox(height: 5),

                          Text(
                            'Décrivez votre demande et notre équipe vous répondra dans cette conversation.',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 13,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ------------------------------------------------
              // SUJET
              // ------------------------------------------------

              const Text(
                'Sujet',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 9),

              TextField(
                controller: _subjectController,
                focusNode: _subjectFocusNode,

                textInputAction:
                TextInputAction.next,

                onSubmitted: (_) {
                  _messageFocusNode.requestFocus();
                },

                decoration: InputDecoration(
                  hintText:
                  'Ex. Problème avec ma réservation',

                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13.5,
                  ),

                  filled: true,
                  fillColor: Colors.white,

                  prefixIcon: const Icon(
                    Icons.subject_outlined,
                    color: primaryColor,
                  ),

                  contentPadding:
                  const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),

                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFFD9E4F5),
                    ),
                  ),

                  enabledBorder:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFFD9E4F5),
                    ),
                  ),

                  focusedBorder:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: primaryColor,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ------------------------------------------------
              // MESSAGE
              // ------------------------------------------------

              const Text(
                'Votre message',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 9),

              TextField(
                controller: _messageController,
                focusNode: _messageFocusNode,

                maxLines: 7,
                minLines: 5,

                textInputAction:
                TextInputAction.newline,

                decoration: InputDecoration(
                  hintText:
                  'Écrivez votre message ici...',

                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13.5,
                  ),

                  filled: true,
                  fillColor: Colors.white,

                  contentPadding:
                  const EdgeInsets.all(16),

                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFFD9E4F5),
                    ),
                  ),

                  enabledBorder:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFFD9E4F5),
                    ),
                  ),

                  focusedBorder:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: primaryColor,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ------------------------------------------------
              // BOUTON ENVOYER
              // ------------------------------------------------

              SizedBox(
                width: double.infinity,
                height: 54,

                child: ElevatedButton(
                  onPressed:
                  _isSending
                      ? null
                      : _sendConversation,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: orangeColor,
                    foregroundColor: Colors.white,

                    disabledBackgroundColor:
                    orangeColor.withValues(
                      alpha: 0.55,
                    ),

                    elevation: 0,

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                  ),

                  child: _isSending
                      ? const SizedBox(
                    width: 22,
                    height: 22,

                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                      : const Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,

                    children: [
                      Icon(
                        Icons.send_rounded,
                        size: 20,
                      ),

                      SizedBox(width: 9),

                      Text(
                        'Envoyer le message',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Center(
                child: Text(
                  'Votre message sera envoyé directement à notre équipe.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}