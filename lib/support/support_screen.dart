import 'package:flutter/material.dart';

import '../../services/support_service.dart';

import 'nouvelle_conversation_screen.dart';
import 'conversation_screen.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final SupportService _supportService = SupportService();

  List<dynamic> _conversations = [];

  bool _isLoading = true;

  String? _errorMessage;

  // =========================================================
  // COULEURS TOKENDÉ
  // =========================================================

  static const Color primaryColor = Color(0xFF0A2A66);
  static const Color orangeColor = Color(0xFFEE5807);

  // =========================================================
  // INITIALISATION
  // =========================================================

  @override
  void initState() {
    super.initState();

    _loadConversations();
  }

  // =========================================================
  // CHARGER LES CONVERSATIONS
  // =========================================================

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final conversations =
      await _supportService.getConversations();

      if (!mounted) return;

      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
        'Impossible de charger vos conversations.';
      });
    }
  }

  // =========================================================
  // FORMATER LA DATE
  // =========================================================

  String _formatDate(dynamic value) {
    if (value == null) return '';

    try {
      final date =
      DateTime.parse(value.toString()).toLocal();

      final day =
      date.day.toString().padLeft(2, '0');

      final month =
      date.month.toString().padLeft(2, '0');

      final hour =
      date.hour.toString().padLeft(2, '0');

      final minute =
      date.minute.toString().padLeft(2, '0');

      return '$day/$month à $hour:$minute';
    } catch (_) {
      return '';
    }
  }

  // =========================================================
  // DERNIER MESSAGE
  // =========================================================

  String _lastMessage(
      Map<String, dynamic> conversation,
      ) {
    final messages = conversation['messages'];

    if (messages is List && messages.isNotEmpty) {
      final message = messages.first;

      if (message is Map<String, dynamic>) {
        return message['message']?.toString() ?? '';
      }
    }

    return '';
  }

  // =========================================================
  // NOMBRE DE MESSAGES NON LUS
  // =========================================================

  int _unreadMessages(
      Map<String, dynamic> conversation,
      ) {
    final value =
    conversation['unread_messages_count'];

    if (value is int) {
      return value;
    }

    return int.tryParse(
      value?.toString() ?? '0',
    ) ??
        0;
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),

      // =====================================================
      // APP BAR
      // =====================================================

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
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Nous écrire',
          style: TextStyle(
            color: primaryColor,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      // =====================================================
      // BODY
      // =====================================================

      body: RefreshIndicator(
        color: orangeColor,
        onRefresh: _loadConversations,
        child: _buildBody(),
      ),

      // =====================================================
      // NOUVELLE CONVERSATION
      // =====================================================

      floatingActionButton:
      FloatingActionButton.extended(
        backgroundColor: orangeColor,
        foregroundColor: Colors.white,

        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
              const NouvelleConversationScreen(),
            ),
          );

          if (result == true) {
            _loadConversations();
          }
        },

        icon: const Icon(
          Icons.add_comment_outlined,
        ),

        label: const Text(
          'Nouvelle conversation',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // BODY
  // =========================================================

  Widget _buildBody() {
    // -------------------------------------------------------
    // CHARGEMENT
    // -------------------------------------------------------

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: orangeColor,
        ),
      );
    }

    // -------------------------------------------------------
    // ERREUR
    // -------------------------------------------------------

    if (_errorMessage != null) {
      return ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),

        children: [
          SizedBox(
            height:
            MediaQuery.of(context).size.height *
                0.30,
          ),

          Icon(
            Icons.cloud_off_outlined,
            size: 55,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 18),

          const Center(
            child: Text(
              'Une erreur est survenue',
              style: TextStyle(
                color: primaryColor,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Center(
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(height: 18),

          Center(
            child: TextButton(
              onPressed: _loadConversations,
              child: const Text(
                'Réessayer',
                style: TextStyle(
                  color: orangeColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // -------------------------------------------------------
    // AUCUNE CONVERSATION
    // -------------------------------------------------------

    if (_conversations.isEmpty) {
      return ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),

        children: [
          SizedBox(
            height:
            MediaQuery.of(context).size.height *
                0.20,
          ),

          Center(
            child: Container(
              width: 82,
              height: 82,

              decoration: const BoxDecoration(
                color: Color(0xFFEAF2FF),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.chat_bubble_outline,
                color: primaryColor,
                size: 38,
              ),
            ),
          ),

          const SizedBox(height: 22),

          const Center(
            child: Text(
              'Aucune conversation',
              style: TextStyle(
                color: primaryColor,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Padding(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 40,
            ),

            child: Text(
              'Vous n’avez pas encore de conversation avec notre équipe.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child: Text(
              'Appuyez sur « Nouvelle conversation » pour nous écrire.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      );
    }

    // -------------------------------------------------------
    // LISTE DES CONVERSATIONS
    // -------------------------------------------------------

    return ListView.builder(
      physics:
      const AlwaysScrollableScrollPhysics(),

      padding: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        100,
      ),

      itemCount: _conversations.length,

      itemBuilder: (context, index) {
        final conversation =
        Map<String, dynamic>.from(
          _conversations[index],
        );

        final subject =
            conversation['subject']
                ?.toString() ??
                'Conversation';

        final lastMessage =
        _lastMessage(conversation);

        final date =
        _formatDate(
          conversation['updated_at'],
        );

        final status =
            conversation['status']
                ?.toString() ??
                'open';

        final isClosed =
            status == 'closed';

        // ⭐ NOUVEAU
        final unreadCount =
        _unreadMessages(conversation);

        return _buildConversationCard(
          conversation: conversation,
          subject: subject,
          lastMessage: lastMessage,
          date: date,
          isClosed: isClosed,
          unreadCount: unreadCount,
        );
      },
    );
  }

  // =========================================================
  // CARTE CONVERSATION
  // =========================================================

  Widget _buildConversationCard({
    required Map<String, dynamic> conversation,
    required String subject,
    required String lastMessage,
    required String date,
    required bool isClosed,

    // ⭐ NOUVEAU
    required int unreadCount,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(17),

        border: Border.all(
          color: const Color(0xFFD9E4F5),
        ),

        boxShadow: [
          BoxShadow(
            color:
            primaryColor.withValues(
              alpha: 0.06,
            ),

            blurRadius: 12,

            offset:
            const Offset(0, 4),
          ),
        ],
      ),

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          borderRadius:
          BorderRadius.circular(17),

          onTap: () async {
            final conversationId =
            int.tryParse(
              conversation['id'].toString(),
            );

            if (conversationId == null) {
              return;
            }

            await Navigator.push(
              context,

              MaterialPageRoute(
                builder: (_) =>
                    ConversationScreen(
                      conversationId:
                      conversationId,
                      subject: subject,
                    ),
              ),
            );

            // Après avoir ouvert la conversation,
            // les messages admin deviennent lus.
            if (mounted) {
              _loadConversations();
            }
          },

          child: Padding(
            padding:
            const EdgeInsets.all(16),

            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                // =================================================
                // ICÔNE
                // =================================================

                Container(
                  width: 48,
                  height: 48,

                  decoration:
                  BoxDecoration(
                    color:
                    const Color(
                      0xFFEAF2FF,
                    ),

                    borderRadius:
                    BorderRadius.circular(
                      14,
                    ),
                  ),

                  child: const Icon(
                    Icons.chat_outlined,
                    color: primaryColor,
                    size: 23,
                  ),
                ),

                const SizedBox(width: 13),

                // =================================================
                // CONTENU
                // =================================================

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [
                      // =================================================
                      // SUJET + DATE
                      // =================================================

                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                        children: [
                          Expanded(
                            child: Text(
                              subject,

                              maxLines: 1,

                              overflow:
                              TextOverflow
                                  .ellipsis,

                              style:
                              const TextStyle(
                                color:
                                primaryColor,
                                fontSize: 15.5,
                                fontWeight:
                                FontWeight.w800,
                              ),
                            ),
                          ),

                          if (date.isNotEmpty) ...[
                            const SizedBox(
                              width: 8,
                            ),

                            Text(
                              date,

                              style: TextStyle(
                                color: Colors
                                    .grey
                                    .shade500,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(
                        height: 7,
                      ),

                      // =================================================
                      // DERNIER MESSAGE
                      // =================================================

                      Text(
                        lastMessage.isEmpty
                            ? 'Aucun message'
                            : lastMessage,

                        maxLines: 2,

                        overflow:
                        TextOverflow.ellipsis,

                        style: TextStyle(
                          color:
                          Colors.grey.shade600,
                          fontSize: 13.5,
                          height: 1.35,
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      // =================================================
                      // STATUT + MESSAGES NON LUS
                      // =================================================

                      Row(
                        children: [
                          // ---------------------------------------------
                          // STATUT
                          // ---------------------------------------------

                          Container(
                            padding:
                            const EdgeInsets
                                .symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),

                            decoration:
                            BoxDecoration(
                              color: isClosed
                                  ? const Color(
                                0xFFF1F3F5,
                              )
                                  : const Color(
                                0xFFFFF1E8,
                              ),

                              borderRadius:
                              BorderRadius
                                  .circular(
                                20,
                              ),
                            ),

                            child: Text(
                              isClosed
                                  ? 'Fermée'
                                  : 'Ouverte',

                              style: TextStyle(
                                color: isClosed
                                    ? Colors
                                    .grey
                                    .shade600
                                    : orangeColor,

                                fontSize: 11,

                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),
                          ),

                          // =================================================
                          // ⭐ BADGE MESSAGES NON LUS
                          // =================================================

                          if (unreadCount > 0) ...[
                            const SizedBox(
                              width: 8,
                            ),

                            Container(
                              padding:
                              const EdgeInsets
                                  .symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),

                              decoration:
                              BoxDecoration(
                                color:
                                orangeColor,

                                borderRadius:
                                BorderRadius
                                    .circular(
                                  20,
                                ),

                                boxShadow: [
                                  BoxShadow(
                                    color:
                                    orangeColor
                                        .withValues(
                                      alpha: 0.20,
                                    ),

                                    blurRadius: 7,

                                    offset:
                                    const Offset(
                                      0,
                                      3,
                                    ),
                                  ),
                                ],
                              ),

                              child: Row(
                                mainAxisSize:
                                MainAxisSize.min,

                                children: [
                                  const Icon(
                                    Icons
                                        .chat_bubble_rounded,
                                    color:
                                    Colors.white,
                                    size: 12,
                                  ),

                                  const SizedBox(
                                    width: 5,
                                  ),

                                  Text(
                                    '$unreadCount',

                                    style:
                                    const TextStyle(
                                      color:
                                      Colors.white,

                                      fontSize: 11,

                                      fontWeight:
                                      FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const Spacer(),

                          // =================================================
                          // FLÈCHE
                          // =================================================

                          const Icon(
                            Icons
                                .arrow_forward_ios_rounded,
                            color:
                            primaryColor,
                            size: 15,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}