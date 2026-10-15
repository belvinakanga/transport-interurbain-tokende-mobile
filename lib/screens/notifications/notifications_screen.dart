import 'package:flutter/material.dart';

import '../../services/notification_service.dart';
import '../../services/notifications_service.dart';
import '../../support/conversation_screen.dart';
import '../voyages/mes_voyages_screen.dart';
import '../../widgets/tk/tk.dart';

/// Liste des notifications reçues.
///
/// Elles viennent de la base du serveur, pas de Firebase : une alerte push
/// manquée ne fait pas disparaître l'information.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationTokende> _notifications = const [];
  bool _chargement = true;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    setState(() {
      _chargement = true;
      _erreur = null;
    });

    try {
      final liste = await NotificationsService.charger();

      if (!mounted) return;

      setState(() {
        _notifications = liste;
        _chargement = false;
      });

      await NotificationService.rafraichirCompteur();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _chargement = false;
        _erreur = 'Vérifiez votre connexion.';
      });
    }
  }

  Future<void> _toutMarquerLu() async {
    await NotificationsService.toutMarquerLu();

    if (!mounted) return;

    TkToast.succes(context, 'Tout est marqué comme lu');
    await _charger();
  }

  Future<void> _ouvrir(NotificationTokende notification) async {
    if (!notification.lue) {
      await NotificationsService.marquerLue(notification.id);
      await NotificationService.rafraichirCompteur();
    }

    if (!mounted) return;

    // Le serveur indique l'écran à ouvrir. Une notification sans
    // destination reste une simple information : l'appui la marque lue,
    // et rien de plus.
    final conversation = notification.conversationId;

    if (conversation != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ConversationScreen(
            conversationId: conversation,
            // Le titre réel est rechargé par l'écran lui-même ; cette
            // valeur n'est qu'un repère le temps de l'ouverture.
            subject: notification.titre,
          ),
        ),
      );
    } else if (notification.ecran == 'voyages' ||
        notification.ecran == 'billets') {
      // Les billets d'un achat direct sont dans l'onglet « Achats » ;
      // tout le reste dans « Réservations ».
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MesVoyagesScreen(
            initialTabIndex: notification.achatId != null ? 1 : 0,
          ),
        ),
      );
    }

    if (mounted) _charger();
  }

  @override
  Widget build(BuildContext context) {
    final nonLues = _notifications.where((n) => !n.lue).length;

    return Scaffold(
      backgroundColor: AppColors.fond(context),
      appBar: AppBar(
        backgroundColor: AppColors.fond(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.titre(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Notifications', style: AppText.sousTitre(context)),
        actions: [
          if (nonLues > 0)
            TextButton(
              onPressed: _toutMarquerLu,
              child: Text(
                'Tout lire',
                style: AppText.petit(context).copyWith(
                  color: AppColors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.orange,
        onRefresh: _charger,
        child: _corps(),
      ),
    );
  }

  Widget _corps() {
    if (_chargement) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (_erreur != null) {
      return ListView(
        children: [
          const SizedBox(height: AppSpacing.xxl),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.margeEcran),
            child: TkEmptyState(
              icone: Icons.wifi_off_rounded,
              titre: 'Notifications indisponibles',
              message: _erreur!,
              libelleAction: 'Réessayer',
              onAction: _charger,
            ),
          ),
        ],
      );
    }

    if (_notifications.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: AppSpacing.xxl),
          Padding(
            padding: EdgeInsets.all(AppSpacing.margeEcran),
            child: TkEmptyState(
              icone: Icons.notifications_none_rounded,
              titre: 'Aucune notification',
              message: 'Les réponses de l’assistance et le suivi de vos '
                  'voyages apparaîtront ici.',
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.margeEcran,
        AppSpacing.sm,
        AppSpacing.margeEcran,
        AppSpacing.xxl,
      ),
      itemCount: _notifications.length,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: _carte(_notifications[i]),
      ),
    );
  }

  Widget _carte(NotificationTokende notification) {
    // Une notification non lue est accentuée : c'est ce que l'utilisateur
    // cherche en ouvrant cet écran.
    return TkCard(
      accentuee: !notification.lue,
      onTap: () => _ouvrir(notification),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _fondIcone(notification.type, context),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              // Les fonds atténués sont transparents : sans ce trait, la
              // pastille se dissoudrait dans le crème d'une carte non lue,
              // qui est de la même famille.
              border: Border.all(
                color: _couleurIcone(notification.type)
                    .withValues(alpha: 0.30),
              ),
            ),
            child: Icon(
              _icone(notification.type),
              size: 18,
              color: _couleurIcone(notification.type),
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.titre,
                        style: AppText.corpsFort(context)
                            .copyWith(fontSize: 15),
                      ),
                    ),
                    if (!notification.lue)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 2),

                Text(
                  notification.corps,
                  style: AppText.petit(context).copyWith(fontSize: 13),
                ),

                if (notification.recueLe != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    _quand(notification.recueLe!),
                    style: AppText.petit(context).copyWith(fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _icone(String type) {
    switch (type) {
      case 'message':
        return Icons.chat_bubble_outline_rounded;

      case 'voyage_rappel':
        return Icons.event_available_outlined;

      case 'voyage_imminent':
        return Icons.directions_bus_outlined;

      case 'billet_emis':
        return Icons.confirmation_number_outlined;

      case 'reservation_enregistree':
      case 'reservation':
        return Icons.bookmark_border_rounded;

      case 'reservation_attente':
        return Icons.schedule_rounded;

      case 'reservation_derniere_chance':
        return Icons.warning_amber_rounded;

      case 'reservation_expiree':
        return Icons.event_busy_outlined;

      case 'trajet_modifie':
        return Icons.update_rounded;

      case 'trajet_supprime':
        return Icons.block_rounded;

      case 'vente_agence':
        return Icons.trending_up_rounded;

      case 'paiement':
        return Icons.payments_outlined;

      default:
        return Icons.notifications_none_rounded;
    }
  }

  /// La couleur dit l'urgence avant que le texte soit lu : vert pour ce qui
  /// est acquis, ambre pour ce qui attend, rouge pour ce qui est perdu.
  Color _couleurIcone(String type) {
    switch (type) {
      case 'billet_emis':
      case 'vente_agence':
        return AppColors.vert;

      case 'reservation_attente':
      case 'reservation_derniere_chance':
      case 'trajet_modifie':
        return AppColors.ambre;

      case 'reservation_expiree':
      case 'trajet_supprime':
        return AppColors.rouge;

      default:
        return AppColors.orange;
    }
  }

  Color _fondIcone(String type, BuildContext context) {
    final couleur = _couleurIcone(type);

    if (couleur == AppColors.vert) return AppColors.vertDoux(context);
    if (couleur == AppColors.ambre) return AppColors.ambreDoux(context);
    if (couleur == AppColors.rouge) return AppColors.rougeDoux(context);

    return AppColors.orangeDoux(context);
  }

  /// « il y a 5 min », « hier »… Une date absolue serait moins parlante
  /// pour une notification récente.
  String _quand(DateTime moment) {
    final ecart = DateTime.now().difference(moment);

    if (ecart.inMinutes < 1) return 'à l’instant';
    if (ecart.inMinutes < 60) return 'il y a ${ecart.inMinutes} min';
    if (ecart.inHours < 24) return 'il y a ${ecart.inHours} h';
    if (ecart.inDays == 1) return 'hier';
    if (ecart.inDays < 7) return 'il y a ${ecart.inDays} jours';

    return '${moment.day.toString().padLeft(2, '0')}/'
        '${moment.month.toString().padLeft(2, '0')}/${moment.year}';
  }
}
