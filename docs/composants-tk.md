# Les composants TK

Huit composants dans `lib/widgets/tk/`, tous exportés par le barillet
`tk.dart`.

```dart
import '../../widgets/tk/tk.dart';
```

---

## TkButton

Bouton standard. La hiérarchie passe par **l'intensité de l'orange, jamais
par la forme** : les trois variantes partagent arrondi et absence d'ombre.

| Variante | Apparence | Usage |
|---|---|---|
| `principal` | orange plein | **une seule** action principale par écran |
| `tonal` | orange à 11 %, texte orange | actions de second rang |
| `contour` | contour seul | action neutre ou destructive |

```dart
TkButton(
  libelle: 'Réserver',
  onPressed: _reserver,
)

TkButton(
  libelle: 'Retour',
  variante: TkButtonVariante.tonal,
  onPressed: () => Navigator.pop(context),
)

TkButton(
  libelle: 'Payer',
  icone: Icons.lock_rounded,
  enChargement: _envoiEnCours,
  onPressed: _payer,
)
```

| Paramètre | Défaut | Rôle |
|---|---|---|
| `libelle` | requis | texte |
| `onPressed` | requis | `null` désactive |
| `variante` | `principal` | voir ci-dessus |
| `icone` | `null` | posée à droite du libellé |
| `pleineLargeur` | `true` | sur mobile, plus facile à viser |
| `enChargement` | `false` | remplace le contenu et bloque l'appui |

## TkIconButton

Bouton carré ne portant qu'une icône — retour, fermeture, action d'en-tête.
Côté `AppSize.controleCompact` (46 px).

```dart
TkIconButton(
  icone: Icons.arrow_back_rounded,
  infobulle: 'Retour',
  onPressed: () => Navigator.pop(context),
)
```

---

## TkCard

Surface de contenu, séparée du fond par **un filet 1 px, jamais par une
ombre**.

```dart
TkCard(child: Text('…'))

TkCard(
  accentuee: true,          // fond orange atténué
  onTap: _ouvrir,           // rend la carte cliquable
  child: …,
)
```

---

## TkChip

Puce d'état : statut de réservation, de paiement, de billet.

| Ton | Couleur |
|---|---|
| `succes` | vert |
| `attente` | ambre |
| `echec` | rouge |
| `accent` | orange |
| `neutre` | gris |

### Le constructeur important : `TkChip.statut()`

Les statuts arrivent de l'API avec **des casses et des orthographes
variables** : `Confirmée`, `payée`, `en attente`, `failed`. Ce constructeur
normalise avant de choisir le ton, pour qu'un statut ne finisse jamais en
puce grise par accident.

```dart
TkChip.statut(reservation['statut'])
```

Valeurs reconnues :

| Entrée | Rendu |
|---|---|
| `payée`, `payee`, `payé`, `paye` | **Payée**, vert |
| `confirmée`, `confirmee` | **Confirmée**, vert |
| `en attente`, `pending` | **En attente**, ambre |
| `annulée`, `annulee` | **Annulée**, rouge |
| `échoué`, `echoue`, `failed` | **Échoué**, rouge |

---

## TkField

Champ de saisie.

```dart
TkField(
  label: 'Adresse e-mail',
  placeholder: 'vous@exemple.com',
  controller: _emailController,
  clavier: TextInputType.emailAddress,
  messageErreur: _erreurEmail,
)

TkField(
  label: 'Mot de passe',
  motDePasse: true,
  motDePasseVisible: _visible,
  onBasculerVisibilite: () => setState(() => _visible = !_visible),
  controller: _mdpController,
)
```

| Paramètre | Rôle |
|---|---|
| `label` | intitulé au-dessus |
| `placeholder` | texte d'exemple |
| `controller` | contrôleur |
| `motDePasse` | masque la saisie |
| `motDePasseVisible` / `onBasculerVisibilite` | œil de révélation |
| `clavier` | type de clavier |
| `messageErreur` | passe le champ en état d'erreur |
| `iconeGauche` | icône de tête |
| `validateur`, `onChanged` | validation |

---

## TkEmptyState

Écran vide : aucune réservation, aucun résultat, aucun avis.

```dart
TkEmptyState(
  icone: Icons.confirmation_number_outlined,
  titre: 'Aucun voyage',
  message: 'Vos réservations apparaîtront ici.',
  libelleAction: 'Rechercher un trajet',
  onAction: _ouvrirRecherche,
)
```

L'action est facultative, mais un écran vide **sans porte de sortie** est
une impasse : la proposer quand c'est possible.

---

## TkSectionHeader

Titre de section, avec action facultative à droite (« Tout voir »).

```dart
TkSectionHeader(
  titre: 'Prochains départs',
  libelleAction: 'Tout voir',
  onAction: _ouvrirListe,
)
```

---

## TkToast

Messages éphémères. Remplace les `SnackBar` par défaut, qui arrivaient en
bleu nuit plein ou en rouge Material, sans rapport avec le reste.

**Le ton ne se devine pas, il se déclare :**

```dart
TkToast.succes(context,  'Réservation confirmée');
TkToast.erreur(context,  'Paiement refusé');
TkToast.attente(context, 'Paiement en cours de validation');
TkToast.info(context,    'Code envoyé par e-mail');
```

Pour du code qui dispose déjà d'un booléen :

```dart
TkToast.selonErreur(context, message, erreur: aEchoue);
```

Une erreur reste affichée **5 secondes**, le reste 3 : une erreur se lit,
un succès se constate.

Le composant vérifie que le `ScaffoldMessenger` existe encore — un écran
peut être démonté avant l'arrivée de la réponse réseau.

---

## TkMontantDetail

Détail d'un montant à payer : billets, frais de service, total.

```dart
TkMontantDetail(
  prixUnitaire: 15000,
  fraisParBillet: 100,
  nombreBillets: 2,
)
```

Rend :

```
Billets           2 × 15 000 FCFA      30 000 FCFA
Frais de service  2 × 100 FCFA            200 FCFA
──────────────────────────────────────────────────
Total à payer                          30 200 FCFA
```

`TkMontantDetail.formater(30200)` donne `30 200 FCFA` (espace fine
insécable entre les milliers).

Le tarif se récupère avec `TarifService.charger()`, pas en dur.

---

## TkBilletSheet

Billet de voyage, en feuille glissante. Voir [billets.md](billets.md).
