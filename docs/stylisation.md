# Stylisation de l'application mobile

## Le principe

Le socle visuel tient en **trois fichiers de jetons** et **huit
composants**. La règle unique :

> Aucune valeur en dur dans un écran. Pas de couleur hexadécimale, pas de
> `EdgeInsets.all(17)`, pas de `TextStyle(fontSize: 15)`.

Un écran importe un seul fichier :

```dart
import '../../widgets/tk/tk.dart';
```

qui réexporte les jetons **et** les composants.

## Les partis pris

Quatre décisions qui expliquent le reste :

| Décision | Raison |
|---|---|
| **Pas de dégradés** | ils brouillent la lecture du texte posé dessus |
| **Pas de photos décoratives** | elles vieillissent mal et alourdissent l'application |
| **Pas d'ombres portées** | elles empilaient des cartes flottantes sans hiérarchie réelle |
| **Séparation par filet 1 px** | un trait suffit à séparer deux surfaces |

**Une seule exception à l'absence d'ombre** : la barre de navigation
flottante, qui surplombe du contenu défilant et a besoin d'un décollement
réel.

## Les couleurs

`lib/theme/app_colors.dart`.

### Marque

| Nom | Valeur | Usage |
|---|---|---|
| `AppColors.orange` | `#FF6B00` | action : boutons, accents, onglet actif |
| `AppColors.bleuNuit` | `#0A2A66` | titres et texte fort |

### Surfaces et texte

| Nom | Clair | Sombre |
|---|---|---|
| fond | `#FFFFFF` | `#101828` |
| texte secondaire | `#667085` | `#98A2B3` |
| inactif | `#E4E7EC` | `#344054` |

Trois fonctions adaptent au thème : `AppColors.titre(context)`,
`AppColors.secondaire(context)`, `AppColors.inactifTheme(context)`,
`AppColors.fond(context)`.

### Couleurs d'état

Distinctes de l'orange de marque. **L'orange signifie « action », ces
trois-là signifient « état ».** Les confondre rend les statuts illisibles.

| Nom | Valeur | Sens |
|---|---|---|
| `AppColors.vert` | `#11805A` | payé, confirmé |
| `AppColors.ambre` | `#B4690E` | en attente |
| `AppColors.rouge` | `#C0392B` | refusé, annulé, erreur |

Chacune a une version atténuée pour les fonds : `vertDoux(context)`,
`ambreDoux(context)`, `rougeDoux(context)`, plus `orangeDoux(context)` pour
les boutons secondaires.

L'opacité change selon le thème — 10 % en clair, 22 % en sombre : un voile
trop léger disparaît sur fond sombre.

## Les espacements

`lib/theme/app_spacing.dart`.

| Jeton | Valeur | Usage |
|---|---|---|
| `AppSpacing.xxs` | 4 | icône et son libellé |
| `AppSpacing.xs` | 8 | intérieur d'un petit composant |
| `AppSpacing.sm` | 12 | deux lignes d'un même bloc |
| `AppSpacing.md` | 16 | respiration dans une carte |
| `AppSpacing.lg` | 20 | marge horizontale d'écran |
| `AppSpacing.xl` | 24 | deux blocs liés |
| `AppSpacing.xxl` | 32 | deux sections |
| `AppSpacing.xxxl` | 40 | avant une action finale |

> Une valeur absente de l'échelle est une valeur à discuter, pas à inventer
> sur place : c'est ce qui avait produit des dizaines de nuances
> différentes dans l'ancien code.

### Rayons

| Jeton | Valeur | Usage |
|---|---|---|
| `AppRadius.sm` | 10 | puces, étiquettes |
| `AppRadius.md` | 14 | boutons secondaires, champs |
| `AppRadius.lg` | 18 | boutons principaux, cartes |
| `AppRadius.xl` | 28 | feuilles, vignettes de logo |
| `AppRadius.pleinRond` | 999 | cercle |

Trois paliers suffisent : un composant qui réclame un quatrième rayon est
en général un composant mal découpé.

### Tailles tactiles

| Jeton | Valeur |
|---|---|
| `AppSize.controle` | 56 — bouton principal, champ |
| `AppSize.controleCompact` | 46 — bouton secondaire |
| `AppSize.cibleTactileMin` | 44 — plancher absolu |

Aucune valeur ne descend sous 44 px, minimum recommandé pour une cible
tactile.

## La typographie

`lib/theme/app_text.dart`. Huit styles, chacun portant déjà sa couleur
adaptée au thème — un écran n'a jamais à recomposer un `TextStyle`.

| Style | Taille | Usage |
|---|---|---|
| `AppText.display` | 34 | ouverture d'accueil |
| `AppText.titre` | 28 | titre d'écran |
| `AppText.sousTitre` | 20 | titre de section ou de carte |
| `AppText.corps` | 16 | texte courant |
| `AppText.corpsFort` | 16 gras | valeur, ville, montant |
| `AppText.petit` | 14 | aide sous un champ |
| `AppText.label` | 12 capitales | intitulé de champ |
| `AppText.bouton` | 16 | libellé dans un bouton plein |

```dart
Text('Brazzaville', style: AppText.corpsFort(context))
```

## Utiliser le socle

```dart
import '../../widgets/tk/tk.dart';

Scaffold(
  backgroundColor: AppColors.fond(context),
  body: Padding(
    padding: const EdgeInsets.all(AppSpacing.lg),
    child: Column(
      children: [
        Text('Mes voyages', style: AppText.titre(context)),
        const SizedBox(height: AppSpacing.md),
        TkCard(child: Text('…', style: AppText.corps(context))),
        const SizedBox(height: AppSpacing.xl),
        TkButton(libelle: 'Continuer', onPressed: _continuer),
      ],
    ),
  ),
)
```

## Le mode sombre n'est pas actif

Toutes les variantes sombres sont écrites, mais `main.dart` ne fournit
**aucun `darkTheme`** et ne pilote pas `themeMode`.
`Theme.of(context).brightness` vaut donc toujours `Brightness.light`, et
les branches sombres ne s'exécutent jamais.

Pour l'activer : fournir un `darkTheme`, brancher `ThemeController`
(déjà écrit, `lib/theme/theme_controller.dart`) sur `themeMode`. Voir
[etat-des-lieux.md](etat-des-lieux.md).

## Le logo

`assets/images/transparent-logo.png` (617 × 405, RGBA). Utilisé par l'écran
de démarrage et « À propos ». Le fond transparent a permis de supprimer la
carte blanche qui servait auparavant de contournement.
