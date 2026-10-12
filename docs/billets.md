# Billet, QR code et impression

## Un composant partagé

Le billet est rendu par **`TkBilletSheet`**, utilisé à la fois par « Mes
voyages » et par la carte « prochain départ » de l'accueil — pour qu'il soit
identique d'où qu'on l'ouvre.

```dart
TkBilletSheet.afficher(
  context,
  billet: billetAffichage,
  urlPublique: AppConfig.urlBillet(qrCode),
);
```

Il s'ouvre en feuille glissante, plafonnée à 88 % de la hauteur d'écran.

## `BilletAffichage`

Objet de présentation. **L'extraction depuis les réponses de l'API reste à
la charge de l'appelant**, qui seul connaît la forme de ses données — le
composant ne devine rien.

```dart
const BilletAffichage({
  required this.numero,          // TOK-2026-000001
  required this.qrCode,
  required this.agence,
  required this.adresseAgence,
  required this.depart,
  required this.arrivee,
  required this.date,
  required this.heure,
  required this.voyageurs,       // List<String>
  required this.sieges,          // List<int>
});
```

## Composition

| Bloc | Contenu |
|---|---|
| En-tête | agence et son adresse |
| Trajet | villes et horaire, **sur fond bleu nuit** |
| Informations | voyageurs, sièges, numéro de billet |
| QR code | sur fond blanc obligatoire |
| Actions | Fermer, Imprimer |

Le bloc trajet est sur fond accentué parce que **c'est ce que le contrôleur
lit en premier**.

Le QR est posé sur un **fond blanc**, pas sur le fond orange atténué de son
encart : un QR sur fond coloré ou sombre devient illisible pour beaucoup de
lecteurs.

## Le QR code

Il encode **l'adresse de la page publique du billet**, pas le numéro :

```dart
AppConfig.urlBillet(qrCode)   // http://…/billet/{qr_code}
```

Le contrôleur scanne, son téléphone ouvre la page, le billet s'affiche sans
qu'il ait à installer quoi que ce soit.

### Anomalie bloquante

`billets.qr_code` vaut **`NULL`** en base sur les billets existants. Le QR
encode alors `…/billet/` sans identifiant, et la page publique ne trouve
rien.

**Le billet est inscannable tant que ce n'est pas corrigé côté Laravel.**
Voir `docs/reservations-billets.md` du dépôt backend.

## Impression

Bouton **Imprimer** → `BilletPdf.construire()` → boîte d'impression du
système.

```dart
final document = await BilletPdf.construire(
  billet: billet,
  urlPublique: urlPublique,
);

await Printing.layoutPdf(
  name: 'billet-${billet.numero}',
  onLayout: (format) => document.save(),
);
```

### Pourquoi un PDF plutôt qu'une capture d'écran

Deux raisons :

1. Le billet reste lisible à l'impression **quelle que soit la taille du
   téléphone**.
2. Le QR est **vectoriel** (`pw.BarcodeWidget`), donc scannable même réduit.

Une capture d'écran donnerait un QR pixelisé, souvent illisible une fois
imprimé.

### Le document

`lib/services/billet_pdf.dart` produit un A4 : en-tête TOKENDE bicolore,
bloc trajet bleu nuit, tableau d'informations, QR de 150 pt encadré, pied
de page.

> Le PDF est volontairement **sans accents** (`Sieges`, `Presentez`,
> `Numero`) : les polices par défaut du paquet `pdf` ne couvrent pas tous
> les caractères accentués, ce qui produisait des carrés vides. Pour
> rétablir les accents, il faut embarquer une police TTF complète via
> `pw.Font.ttf()`.

Paquets : `printing` ^5.15.1, `pdf` ^3.13.1.

## Adresses

`lib/config/app_config.dart` :

```dart
AppConfig.baseUrl              // http://127.0.0.1:8000/api
AppConfig.siteUrl              // http://127.0.0.1:8000
AppConfig.urlBillet(qrCode)    // http://127.0.0.1:8000/billet/{qr}
```

Ces trois accesseurs ont remplacé une adresse IP morte
(`192.168.1.84`) codée en dur dans les écrans.
