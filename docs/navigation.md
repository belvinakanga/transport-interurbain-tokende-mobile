# Navigation

## Le démarrage

```
SplashScreen
   ├─ onboarding_vu == true  ──▶ LoginScreen
   └─ sinon ─────────────────▶ OnboardingScreen ──▶ LoginScreen
```

`onboarding_vu` est une clé `SharedPreferences` posée à la fin de
l'onboarding : il ne s'affiche qu'une fois.

## Après connexion : la navigation en bulle

`HomeScreen` n'est pas un simple écran, c'est **le conteneur des quatre
onglets**.

```
HomeScreen
 ├─ PageView            ← les quatre écrans, glissables
 │    ├─ 0  Accueil
 │    ├─ 1  Rechercher
 │    ├─ 2  Mes voyages
 │    └─ 3  Profil
 └─ barre flottante     ← pilule posée par-dessus
```

### La barre

Une pilule flottante, pas une barre collée au bas de l'écran.
`extendBody: true` laisse le contenu défiler **dessous**, ce qui donne la
sensation de flottement.

L'onglet actif **s'élargit pour afficher son libellé** ; les autres restent
réduits à leur icône. Cela évite quatre libellés simultanés dans une barre
étroite tout en gardant l'onglet courant nommé.

C'est **la seule ombre portée de l'application** : la barre surplombe du
contenu qui défile, il lui faut un décollement réel.

```dart
boxShadow: [
  BoxShadow(
    color: AppColors.bleuNuit.withValues(alpha: sombre ? 0.45 : 0.10),
    blurRadius: 20,
    offset: const Offset(0, 6),
  ),
],
```

Les listes réservent **108 px en bas** pour que le dernier élément ne
passe pas sous la barre.

### Appui et glissement

Les deux pilotent la même vue : un appui anime le `PageView`, un glissement
met à jour l'onglet actif.

## Ouvrir « Mes voyages » sur un onglet précis

« Mes voyages » a deux sous-onglets : **Réservations** et **Achats**.
Plusieurs raccourcis doivent y mener directement.

```dart
void _openMesVoyages(int tabIndex) {
  setState(() {
    _voyagesTabIndex = tabIndex.clamp(0, 1);
  });

  _onNavigationItemTapped(2);
}
```

L'écran restant monté dans la `PageView`, un simple changement de paramètre
ne le reconstruit pas. D'où un `didUpdateWidget` côté `MesVoyagesScreen`
qui déplace le `TabController` existant :

```dart
@override
void didUpdateWidget(covariant MesVoyagesScreen oldWidget) {
  super.didUpdateWidget(oldWidget);

  if (widget.initialTabIndex != oldWidget.initialTabIndex) {
    final cible = widget.initialTabIndex.clamp(0, 1);
    if (_tabController.index != cible) {
      _tabController.animateTo(cible);
    }
  }
}
```

> Ce mécanisme a déjà été cassé deux fois : une fois en ignorant le
> paramètre `tabIndex`, une fois en oubliant de déplacer la `PageView`. Les
> deux moitiés sont nécessaires.

## Limite connue

Sur « Mes voyages », **le glissement horizontal est capté par les
sous-onglets** Réservations/Achats, pas par la `PageView`. On ne peut donc
pas quitter cet onglet au doigt : il faut appuyer sur la barre.

C'est le comportement normal de deux zones de glissement imbriquées. Le
corriger demanderait de changer la gestion des gestes, donc de toucher à la
logique existante.

## Reste de la navigation

Partout ailleurs, `Navigator.push` classique.

```
Accueil ──▶ Résultats ──▶ Détails trajet ──▶ Sélection sièges
                                                   │
                            Informations voyageurs ◀┘
                                     │
                            Récapitulatif ──▶ Paiement
```

Voir [parcours-reservation.md](parcours-reservation.md).
