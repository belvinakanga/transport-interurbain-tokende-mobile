/// Lecture des dates et heures d'un trajet renvoyé par l'API.
///
/// Le backend expose désormais des champs déjà mis en forme
/// (`date_depart_libelle`, `heure_depart_libelle`, `heure_arrivee_libelle`).
/// On les utilise en priorité : le serveur connaît la donnée brute et sa
/// variabilité. Le repli local n'existe que pour un backend plus ancien ;
/// il ne fabrique jamais de valeur inventée.
class FormatTrajet {
  const FormatTrajet._();

  static const List<String> _mois = [
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
  ];

  /// Date de départ, par exemple « 12 octobre 2026 ».
  ///
  /// Renvoie `null` si la donnée est absente, pour que l'appelant puisse
  /// masquer la ligne au lieu d'afficher un tiret.
  static String? date(Map<String, dynamic>? trajet) {
    if (trajet == null) return null;

    final libelle = _texte(trajet['date_depart_libelle']);
    if (libelle != null) return libelle;

    final iso = _dateTime(trajet['depart_iso']);
    if (iso != null) return dateDepuisDateTime(iso);

    final brut = _texte(trajet['date_depart']);
    if (brut == null) return null;

    final analysee = DateTime.tryParse(brut);
    return analysee != null ? dateDepuisDateTime(analysee) : brut;
  }

  /// Heure de départ, par exemple « 08h00 ».
  static String? heureDepart(Map<String, dynamic>? trajet) {
    if (trajet == null) return null;

    final libelle = _texte(trajet['heure_depart_libelle']);
    if (libelle != null) return libelle;

    return _heureDepuisBrut(trajet['heure_depart']);
  }

  /// Heure d'arrivée, ou `null` si l'agence ne l'a pas renseignée.
  static String? heureArrivee(Map<String, dynamic>? trajet) {
    if (trajet == null) return null;

    final libelle = _texte(trajet['heure_arrivee_libelle']);
    if (libelle != null) return libelle;

    final iso = _dateTime(trajet['arrivee_iso']);
    if (iso != null) return heureDepuisDateTime(iso);

    return _heureDepuisBrut(trajet['heure_fin']);
  }

  /// Met en forme une heure brute isolée : « 08:00:00 » devient « 08h00 ».
  ///
  /// Renvoie `null` si la valeur est absente, pour que l'appelant choisisse
  /// son propre texte de remplacement.
  static String? heureBrute(dynamic valeur) => _heureDepuisBrut(valeur);

  /// Durée du trajet, par exemple « 4 h 30 ».
  static String? duree(Map<String, dynamic>? trajet) {
    if (trajet == null) return null;
    return _texte(trajet['duree_libelle']);
  }

  /// Date et heure réunies : « 12 octobre 2026 · 08h00 ».
  ///
  /// Si l'heure manque, seule la date est renvoyée.
  static String? dateEtHeure(Map<String, dynamic>? trajet) {
    final d = date(trajet);
    final h = heureDepart(trajet);

    if (d == null) return h;
    if (h == null) return d;

    return '$d · $h';
  }

  /// Instant du départ, utile pour trier ou calculer un délai.
  static DateTime? momentDepart(Map<String, dynamic>? trajet) {
    if (trajet == null) return null;

    final iso = _dateTime(trajet['depart_iso']);
    if (iso != null) return iso;

    final jour = DateTime.tryParse(_texte(trajet['date_depart']) ?? '');
    if (jour == null) return null;

    final (h, m) = _decouperHeure(trajet['heure_depart']);

    return DateTime(jour.year, jour.month, jour.day, h, m);
  }

  // ----------------------------------------------------------------

  /// « 12 octobre 2026 ».
  static String dateDepuisDateTime(DateTime d) {
    return '${d.day} ${_mois[d.month - 1]} ${d.year}';
  }

  /// « 08h00 ».
  static String heureDepuisDateTime(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${h}h$m';
  }

  static String? _texte(dynamic valeur) {
    final t = valeur?.toString().trim();
    return (t == null || t.isEmpty) ? null : t;
  }

  static DateTime? _dateTime(dynamic valeur) {
    final t = _texte(valeur);
    return t == null ? null : DateTime.tryParse(t);
  }

  static String? _heureDepuisBrut(dynamic valeur) {
    if (_texte(valeur) == null) return null;

    final (h, m) = _decouperHeure(valeur);

    return '${h.toString().padLeft(2, '0')}h'
        '${m.toString().padLeft(2, '0')}';
  }

  /// Tolère « 08:00:00 », « 08:00 », « 8h30 » et « 8 ».
  static (int, int) _decouperHeure(dynamic valeur) {
    final texte = _texte(valeur);
    if (texte == null) return (0, 0);

    final correspondance =
        RegExp(r'^(\d{1,2})\s*[:h]\s*(\d{1,2})?').firstMatch(texte);

    if (correspondance != null) {
      final h = int.tryParse(correspondance.group(1) ?? '') ?? 0;
      final m = int.tryParse(correspondance.group(2) ?? '0') ?? 0;
      return (h.clamp(0, 23), m.clamp(0, 59));
    }

    final seul = int.tryParse(texte);
    return seul != null ? (seul.clamp(0, 23), 0) : (0, 0);
  }
}
