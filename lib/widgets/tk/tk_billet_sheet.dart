import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text.dart';
import '../../services/billet_pdf.dart';
import 'tk_button.dart';
import 'tk_toast.dart';

/// Données affichées sur un billet.
///
/// Objet de présentation : l'extraction depuis les réponses de l'API reste
/// à la charge de l'appelant, qui connaît la forme de ses données.
class BilletAffichage {
  final String numero;
  final String qrCode;

  final String agence;
  final String adresseAgence;

  final String depart;
  final String arrivee;

  final String date;
  final String heure;

  final List<String> voyageurs;
  final List<int> sieges;

  const BilletAffichage({
    required this.numero,
    required this.qrCode,
    required this.agence,
    required this.adresseAgence,
    required this.depart,
    required this.arrivee,
    required this.date,
    required this.heure,
    required this.voyageurs,
    required this.sieges,
  });
}

/// Billet de voyage, présenté en feuille glissante depuis le bas.
///
/// Partagé par « Mes voyages » et par la carte « prochain départ » de
/// l'accueil, pour que le billet soit identique d'où qu'on l'ouvre.
class TkBilletSheet extends StatelessWidget {
  final BilletAffichage billet;

  /// Adresse de la page publique du billet, encodée dans le QR code.
  final String urlPublique;

  const TkBilletSheet({
    super.key,
    required this.billet,
    required this.urlPublique,
  });

  /// Ouvre le billet.
  static Future<void> afficher(
    BuildContext context, {
    required BilletAffichage billet,
    required String urlPublique,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TkBilletSheet(
        billet: billet,
        urlPublique: urlPublique,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sombre = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        decoration: BoxDecoration(
          color: sombre ? AppColors.fondSombre : Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            _poignee(context),

            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xs,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                children: [
                  _enTete(context),

                  const SizedBox(height: AppSpacing.lg),

                  _trajet(context),

                  const SizedBox(height: AppSpacing.md),

                  _informations(context),

                  const SizedBox(height: AppSpacing.lg),

                  _codeQr(context),
                ],
              ),
            ),

            _actions(context),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------

  Widget _poignee(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.xs,
      ),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.inactifTheme(context),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _enTete(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.orangeDoux(context),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Icon(
            Icons.confirmation_number_rounded,
            size: 21,
            color: AppColors.orange,
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Billet de voyage', style: AppText.sousTitre(context)),
              Text(
                billet.agence,
                style: AppText.petit(context).copyWith(fontSize: 13),
              ),
              if (billet.adresseAgence.isNotEmpty)
                Text(
                  billet.adresseAgence,
                  style: AppText.petit(context).copyWith(fontSize: 12),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Villes et horaire, sur fond accentué : c'est ce que le contrôleur
  /// lit en premier.
  Widget _trajet(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bleuNuit,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  billet.depart,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 17,
                  color: AppColors.orange,
                ),
              ),
              Flexible(
                child: Text(
                  billet.arrivee,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xs),

          Text(
            '${billet.date} · ${billet.heure}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _informations(BuildContext context) {
    final lignes = <(IconData, String, String)>[
      (
        Icons.person_outline_rounded,
        billet.voyageurs.length > 1 ? 'Voyageurs' : 'Voyageur',
        billet.voyageurs.isEmpty ? '—' : billet.voyageurs.join(', '),
      ),
      (
        Icons.event_seat_outlined,
        billet.sieges.length > 1 ? 'Sièges' : 'Siège',
        billet.sieges.isEmpty ? '—' : billet.sieges.join(', '),
      ),
      (
        Icons.confirmation_number_outlined,
        'N° de billet',
        billet.numero,
      ),
    ];

    return Column(
      children: [
        for (var i = 0; i < lignes.length; i++) ...[
          if (i > 0)
            Divider(height: 1, color: AppColors.inactifTheme(context)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                Icon(
                  lignes[i].$1,
                  size: 17,
                  color: AppColors.secondaire(context),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    lignes[i].$2,
                    style: AppText.corps(context).copyWith(fontSize: 14),
                  ),
                ),
                Flexible(
                  child: Text(
                    lignes[i].$3,
                    textAlign: TextAlign.right,
                    style: AppText.corpsFort(context).copyWith(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _codeQr(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.orangeDoux(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Text('Code billet', style: AppText.label(context)),

          const SizedBox(height: AppSpacing.sm),

          // Fond blanc obligatoire : un QR sur fond coloré ou sombre
          // devient illisible pour beaucoup de lecteurs.
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: QrImageView(
              data: urlPublique,
              version: QrVersions.auto,
              size: 180,
              backgroundColor: Colors.white,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            'Présentez ce code lors du contrôle.',
            textAlign: TextAlign.center,
            style: AppText.petit(context).copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.inactifTheme(context)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TkButton(
              libelle: 'Fermer',
              variante: TkButtonVariante.tonal,
              onPressed: () => Navigator.pop(context),
            ),
          ),

          const SizedBox(width: AppSpacing.xs),

          Expanded(
            child: TkButton(
              libelle: 'Imprimer',
              icone: Icons.print_rounded,
              onPressed: () => _imprimer(context),
            ),
          ),
        ],
      ),
    );
  }

  /// Ouvre la boîte d'impression du système avec le billet en PDF.
  ///
  /// Un PDF plutôt que l'impression de la page : seul le billet sort,
  /// et le QR reste vectoriel donc scannable.
  Future<void> _imprimer(BuildContext context) async {
    try {
      final document = await BilletPdf.construire(
        billet: billet,
        urlPublique: urlPublique,
      );

      await Printing.layoutPdf(
        name: 'billet-${billet.numero}',
        onLayout: (format) => document.save(),
      );
    } catch (e) {
      if (!context.mounted) return;

      TkToast.erreur(
        context,
        'Impression impossible : ${e.toString()}',
      );
    }
  }
}
