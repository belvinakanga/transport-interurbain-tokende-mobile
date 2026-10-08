import 'package:flutter/material.dart';

import '../services/support_service.dart';

class ConversationScreen extends StatefulWidget {
  final int conversationId;
  final String subject;

  const ConversationScreen({
    super.key,
    required this.conversationId,
    required this.subject,
  });

  @override
  State<ConversationScreen> createState() =>
      _ConversationScreenState();
}

class _ConversationScreenState
    extends State<ConversationScreen> {
  final SupportService _supportService = SupportService();

  final TextEditingController _messageController =
  TextEditingController();

  final ScrollController _scrollController =
  ScrollController();

  List<dynamic> _messages = [];

  bool _isLoading = true;
  bool _isSending = false;
  String? _errorMessage;

  static const Color primaryColor = Color(0xFF0A2A66);
  static const Color orangeColor = Color(0xFFFF6B00);

  @override
  void initState() {
    super.initState();
    _loadConversation();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadConversation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final conversation =
      await _supportService.getConversation(
        widget.conversationId,
      );

      if (!mounted) return;

      setState(() {
        _messages = conversation['messages'] ?? [];
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
        'Impossible de charger cette conversation.';
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();

    if (message.isEmpty || _isSending) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final newMessage =
      await _supportService.sendMessage(
        conversationId: widget.conversationId,
        message: message,
      );

      if (!mounted) return;

      setState(() {
        _messages.add(newMessage);
        _messageController.clear();
        _isSending = false;
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSending = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  Widget _buildMessageBubble(
      Map<String, dynamic> message,
      ) {
    final senderType =
        message['sender_type']?.toString() ?? '';

    final isAdmin = senderType == 'admin';

    final text =
        message['message']?.toString() ?? '';

    final createdAt =
    message['created_at']?.toString();

    String time = '';

    if (createdAt != null) {
      try {
        final date =
        DateTime.parse(createdAt).toLocal();

        time =
        '${date.hour.toString().padLeft(2, '0')}:'
            '${date.minute.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    return Align(
      alignment: isAdmin
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 310,
        ),
        margin: EdgeInsets.only(
          left: isAdmin ? 0 : 45,
          right: isAdmin ? 45 : 0,
          bottom: 12,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isAdmin
              ? Colors.white
              : primaryColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(
              isAdmin ? 4 : 16,
            ),
            bottomRight: Radius.circular(
              isAdmin ? 16 : 4,
            ),
          ),
          border: isAdmin
              ? Border.all(
            color: const Color(0xFFD9E4F5),
          )
              : null,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(
                alpha: 0.05,
              ),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              isAdmin ? 'Équipe TOKENDÉ' : 'Vous',
              style: TextStyle(
                color: isAdmin
                    ? primaryColor
                    : Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              text,
              style: TextStyle(
                color: isAdmin
                    ? const Color(0xFF333333)
                    : Colors.white,
                fontSize: 14.5,
                height: 1.4,
              ),
            ),

            if (time.isNotEmpty) ...[
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  time,
                  style: TextStyle(
                    color: isAdmin
                        ? Colors.grey.shade500
                        : Colors.white70,
                    fontSize: 10.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: orangeColor,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_outlined,
                size: 50,
                color: Colors.grey.shade400,
              ),

              const SizedBox(height: 16),

              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 14),

              TextButton(
                onPressed: _loadConversation,
                child: const Text(
                  'Réessayer',
                  style: TextStyle(
                    color: orangeColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_messages.isEmpty) {
      return const Center(
        child: Text(
          'Aucun message dans cette conversation.',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(
        16,
        20,
        16,
        20,
      ),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message =
        Map<String, dynamic>.from(
          _messages[index],
        );

        return _buildMessageBubble(message);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

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

        title: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            const Text(
              'Conversation',
              style: TextStyle(
                color: primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),

            Text(
              widget.subject,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: _buildBody(),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(
              12,
              10,
              12,
              12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: const Color(0xFFD9E4F5),
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                crossAxisAlignment:
                CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction:
                      TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText:
                        'Écrire un message...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13.5,
                        ),
                        filled: true,
                        fillColor:
                        const Color(0xFFF7F9FC),
                        contentPadding:
                        const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  SizedBox(
                    width: 48,
                    height: 48,
                    child: FloatingActionButton(
                      heroTag: null,
                      backgroundColor:
                      orangeColor,
                      elevation: 0,
                      onPressed:
                      _isSending
                          ? null
                          : _sendMessage,
                      child: _isSending
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2.3,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 21,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
