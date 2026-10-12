# Réserver un voyage

## Le parcours

```
Accueil
   │  départ, arrivée, date
   ▼
Résultats de recherche
   │  choix d'un trajet
   ▼
Détails du trajet
   │
   ▼
Sélection des sièges
   │  un siège par voyageur
   ▼
Informations voyageurs
   │  nom, téléphone, pièce
   ▼
Récapitulatif
   │  vérification du total
   ▼
Paiement
   │  mobile money
   ▼
Billet avec QR code
```

## 1. Recherche

`home/widgets/home_search_card.dart` : départ, arrivée, date.

Les villes viennent du **référentiel partagé** avec le back-office, via
`GET /api/villes` et `VillesService` (cache en mémoire, repli local si
l'API est injoignable). Avant, chaque côté avait sa propre liste et les
orthographes divergeaient.

## 2. Résultats

`search/search_results_screen.dart` consomme `GET /api/trajets`.

**Seuls les trajets d'agences actives sont renvoyés** : suspendre une
agence retire ses trajets de la vente sans rien supprimer.

Les horaires affichés viennent des champs déjà mis en forme par le serveur
(`heure_depart_libelle`, `duree_libelle`…), lus par
`lib/utils/format_trajet.dart`. Ce dernier garde un repli local, mais
**n'invente jamais de valeur** : quand la donnée manque, il renvoie `null`
et l'écran masque la ligne au lieu d'afficher un tiret.

## 3. Sélection des sièges

`booking/seat_selection_screen.dart`, alimenté par
`GET /api/trajets/{id}/sieges`.

Un siège peut être occupé par une réservation **ou** par un achat au
guichet — la table `sieges` porte les deux rattachements.

## 4. Informations voyageurs

`booking/passenger_information_screen.dart` : un formulaire par siège
retenu.

## 5. Récapitulatif

`booking/booking_summary_screen.dart` : trajet, voyageurs, sièges, total.

## 6. Paiement

`booking/payment_screen.dart` — 1599 lignes, le plus gros écran du
parcours.

```
Flutter                     Laravel                  OpenPay
   ├─ POST /api/openpay/initiate ──────────────────────▶│
   │◀──────────── référence ────────────────────────────│
   │                                                     │
   │        (le client valide sur son téléphone)         │
   │                                                     │
   │   ◀──── webhook ─── Laravel ◀───────────────────────│
   ├─ GET /api/openpay/status/{ref} ─▶ statut            │
```

L'application interroge l'état jusqu'à confirmation. Les trois issues sont
signalées par un toast du ton correspondant :

```dart
TkToast.succes(context,  'Paiement confirmé');
TkToast.attente(context, 'Paiement en cours de validation');
TkToast.erreur(context,  'Paiement refusé');
```

## 7. Billet

Voir [billets.md](billets.md).

## Statuts et vocabulaire

Les statuts arrivent avec des casses variables. `TkChip.statut()` normalise
avant de choisir la couleur.

| Statut | Traité comme | Puce |
|---|---|---|
| `payée` | honoré | vert |
| `Confirmée` | **honoré** | vert |
| `en attente` | en cours | ambre |
| `annulée`, `failed` | échec | rouge |

Un voyage honoré débloque « Voir mon billet » et « Donner mon avis ».
