import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../widgets/tk/tk_billet_sheet.dart';

/// Construit le document imprimable d'un billet.
///
/// Un PDF plutôt qu'une capture de l'écran : le billet reste lisible à
/// l'impression quelle que soit la taille du téléphone, et le QR code est
/// vectoriel, donc scannable même sur un petit format.
class BilletPdf {
  const BilletPdf._();

  static const PdfColor _bleuNuit = PdfColor.fromInt(0xFF0A2A66);
  static const PdfColor _orange = PdfColor.fromInt(0xFFFF6B00);
  static const PdfColor _gris = PdfColor.fromInt(0xFF5B6682);
  static const PdfColor _filet = PdfColor.fromInt(0xFFE1E5F0);

  /// Génère le document prêt à imprimer.
  static Future<pw.Document> construire({
    required BilletAffichage billet,
    required String urlPublique,
  }) async {
    final document = pw.Document(title: 'Billet ${billet.numero}');

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _enTete(billet),
            pw.SizedBox(height: 24),
            _trajet(billet),
            pw.SizedBox(height: 24),
            _informations(billet),
            pw.SizedBox(height: 28),
            _codeQr(billet, urlPublique),
            pw.Spacer(),
            _pied(),
          ],
        ),
      ),
    );

    return document;
  }

  // ----------------------------------------------------------------

  static pw.Widget _enTete(BilletAffichage billet) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.RichText(
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(
                    text: 'TOK',
                    style: pw.TextStyle(
                      fontSize: 26,
                      fontWeight: pw.FontWeight.bold,
                      color: _bleuNuit,
                    ),
                  ),
                  pw.TextSpan(
                    text: 'ENDE',
                    style: pw.TextStyle(
                      fontSize: 26,
                      fontWeight: pw.FontWeight.bold,
                      color: _orange,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Billet de voyage',
              style: const pw.TextStyle(fontSize: 11, color: _gris),
            ),
          ],
        ),

        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              billet.agence,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: _bleuNuit,
              ),
            ),
            if (billet.adresseAgence.isNotEmpty)
              pw.Text(
                billet.adresseAgence,
                style: const pw.TextStyle(fontSize: 10, color: _gris),
              ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _trajet(BilletAffichage billet) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: const pw.BoxDecoration(
        color: _bleuNuit,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Flexible(
                child: pw.Text(
                  billet.depart,
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 14),
                child: pw.Text(
                  '>',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: _orange,
                  ),
                ),
              ),
              pw.Flexible(
                child: pw.Text(
                  billet.arrivee,
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            '${billet.date} a ${billet.heure}',
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColor.fromInt(0xFFBFC9DD),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _informations(BilletAffichage billet) {
    final lignes = <List<String>>[
      [
        billet.voyageurs.length > 1 ? 'Voyageurs' : 'Voyageur',
        billet.voyageurs.isEmpty ? '-' : billet.voyageurs.join(', '),
      ],
      [
        billet.sieges.length > 1 ? 'Sieges' : 'Siege',
        billet.sieges.isEmpty ? '-' : billet.sieges.join(', '),
      ],
      ['Numero de billet', billet.numero],
    ];

    return pw.Column(
      children: [
        for (final ligne in lignes)
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 9),
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: _filet)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  ligne[0],
                  style: const pw.TextStyle(fontSize: 11, color: _gris),
                ),
                pw.Text(
                  ligne[1],
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: _bleuNuit,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static pw.Widget _codeQr(BilletAffichage billet, String urlPublique) {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Text(
            'CODE BILLET',
            style: pw.TextStyle(
              fontSize: 10,
              letterSpacing: 1.2,
              fontWeight: pw.FontWeight.bold,
              color: _gris,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _filet),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: urlPublique,
              width: 150,
              height: 150,
              drawText: false,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Presentez ce code lors du controle.',
            style: const pw.TextStyle(fontSize: 10, color: _gris),
          ),
        ],
      ),
    );
  }

  static pw.Widget _pied() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _filet)),
      ),
      child: pw.Text(
        'Tokende - Transport interurbain - Republique du Congo',
        style: const pw.TextStyle(fontSize: 9, color: _gris),
      ),
    );
  }
}
