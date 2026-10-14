import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../config/app_config.dart';
import '../../../utils/format_trajet.dart';
import '../../../widgets/tk/tk.dart';
import '../../search/trip_details_screen.dart';

/// Trajets déjà programmés par les agences.
///
/// Affichés directement sous la carte de recherche : un voyageur qui ne
/// sait pas quoi chercher voit d'abord ce qui existe, et ne recourt au
/// formulaire que s'il ne trouve pas son trajet.
///
/// L'API ne renvoie que les trajets d'agences actives.
class TrajetsProgrammes extends StatefulWidget {
  /// Nombre de voyageurs transmis à l'écran de détail.
  final int voyageurs;

  const TrajetsProgrammes({super.key, this.voyageurs = 1});

  @override
  State<TrajetsProgrammes> createState() => _TrajetsProgrammesState();
}

class _TrajetsProgrammesState extends State<TrajetsProgrammes> {
  List<Map<String, dynamic>> _trajets = const [];
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
      final reponse = await http
          .get(
            Uri.parse('${AppConfig.baseUrl}/trajets'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (reponse.statusCode != 200) {
        setState(() {
          _chargement = false;
          _erreur = 'Impossible de charger les trajets.';
        });
        return;
      }

      final brut = jsonDecode(reponse.body);
      final liste = brut is List ? brut : (brut['data'] ?? []);

      final trajets = <Map<String, dynamic>>[
        for (final t in liste)
          if (t is Map<String, dynamic>) t,
      ];

      // Les départs les plus proches en premier : c'est ce qu'on réserve.
      trajets.sort((a, b) {
        final da = FormatTrajet.momentDepart(a);
        final db = FormatTrajet.momentDepart(b);
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return da.compareTo(db);
      });

      setState(() {
        _trajets = trajets;
        _chargement = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _chargement = false;
        _erreur = 'Vérifiez votre connexion.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_chargement) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_erreur != null) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.margeEcran),
        child: TkEmptyState(
          icone: Icons.wifi_off_rounded,
          titre: 'Trajets indisponibles',
          message: _erreur!,
          libelleAction: 'Réessayer',
          onAction: _charger,
        ),
      );
    }

    if (_trajets.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.margeEcran),
        child: TkEmptyState(
          icone: Icons.event_busy_rounded,
          titre: 'Aucun trajet programmé',
          message: 'Les agences n’ont pas encore publié de départ. '
              'Revenez bientôt ou lancez une recherche.',
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.margeEcran,
            AppSpacing.xl,
            AppSpacing.margeEcran,
            0,
          ),
          child: TkSectionHeader(
            titre: _trajets.length > 1
                ? '${_trajets.length} trajets programmés'
                : '1 trajet programmé',
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.margeEcran,
            0,
            AppSpacing.margeEcran,
            AppSpacing.sm,
          ),
          child: Text(
            'Départs publiés par les agences. '
            'Utilisez la recherche si le vôtre n’y figure pas.',
            style: AppText.petit(context).copyWith(fontSize: 13),
          ),
        ),

        for (final trajet in _trajets)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.margeEcran,
              0,
              AppSpacing.margeEcran,
              AppSpacing.sm,
            ),
            child: _carte(trajet),
          ),
      ],
    );
  }

  Widget _carte(Map<String, dynamic> trajet) {
    final depart = (trajet['depart'] ?? '—').toString();
    final arrivee = (trajet['arrivee'] ?? '—').toString();

    final date = FormatTrajet.date(trajet);
    final heure = FormatTrajet.heureDepart(trajet);

    // prix_total inclut les frais de service : c'est ce que le voyageur
    // paiera réellement.
    final total = trajet['prix_total'] ?? trajet['prix'];
    final places = trajet['places_disponibles'];

    return TkCard(
      onTap: () => _ouvrir(trajet),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$depart → $arrivee',
                  overflow: TextOverflow.ellipsis,
                  style: AppText.corpsFort(context),
                ),
              ),
              Text(
                TkMontantDetail.formater(
                  (total is num) ? total.toDouble() : 0,
                ),
                style: AppText.corpsFort(context).copyWith(
                  color: AppColors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xs),

          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 15,
                color: AppColors.secondaire(context),
              ),
              const SizedBox(width: AppSpacing.xxs),
              Expanded(
                child: Text(
                  [?date, ?heure].join(' · '),
                  overflow: TextOverflow.ellipsis,
                  style: AppText.petit(context).copyWith(fontSize: 13),
                ),
              ),

              if (places is num)
                TkChip(
                  libelle: places > 0
                      ? '$places place${places > 1 ? 's' : ''}'
                      : 'Complet',
                  ton: places > 0 ? TkChipTon.succes : TkChipTon.echec,
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _ouvrir(Map<String, dynamic> trajet) {
    final identifiant = trajet['id'];
    if (identifiant is! int) return;

    final agence = trajet['agence'];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TripDetailsScreen(
          trajetId: identifiant,
          agency: (agence is Map ? agence['nom_agence'] : null)?.toString() ??
              'Agence partenaire',
          departure: (trajet['depart'] ?? '').toString(),
          destination: (trajet['arrivee'] ?? '').toString(),
          departureTime: FormatTrajet.heureDepart(trajet) ?? '—',
          arrivalTime: FormatTrajet.heureArrivee(trajet) ?? '—',
          duration: FormatTrajet.duree(trajet) ?? 'Transport interurbain',
          price: (trajet['prix'] ?? '0').toString(),
          rating: '—',
          departureDate:
              FormatTrajet.momentDepart(trajet) ?? DateTime.now(),
          travelers: widget.voyageurs,
        ),
      ),
    );
  }
}
