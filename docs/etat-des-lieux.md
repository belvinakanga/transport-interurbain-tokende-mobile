# État des lieux

Ce que le code porte encore et qu'il faudrait traiter. Rien ici n'est
bloquant au quotidien ; tout est vérifiable avec `flutter analyze lib`.

```
21 issues found    0 erreur
```

---

## 1. Le mode sombre n'est pas branché

**Impact : toute la palette sombre est morte.**

`main.dart` construit son thème en ligne, sans `darkTheme` ni `themeMode` :

```dart
MaterialApp(
  theme: ThemeData(useMaterial3: true, …),
  home: const SplashScreen(),
)
```

Conséquences en chaîne :

| Fichier | État |
|---|---|
| `lib/theme/theme_controller.dart` | écrit, **jamais instancié** |
| `lib/config/app_theme.dart` | écrit, **jamais utilisé** (la police Poppins ne s'applique donc pas) |
| branches sombres de `AppColors` | **inatteignables** — `brightness` vaut toujours `light` |
| clé `dark_mode` de `SharedPreferences` | écrite par personne |

**Pour l'activer :** fournir un `darkTheme`, instancier `ThemeController`,
piloter `themeMode`.

---

## 2. Adresses d'API dispersées

`AppConfig` existe, mais **une dizaine d'écrans redéfinissent l'adresse chez
eux**. Changer de serveur impose de modifier tous ces fichiers.

Le cas le plus gênant : `services/support_service.dart` pointe sur
`http://192.168.1.84:8000/api`, **une adresse morte**.

Les écrans qui codent `127.0.0.1` en dur **ne fonctionnent pas sur
émulateur Android**, qui exige `10.0.2.2`.

Liste complète dans [services-api.md](services-api.md).

---

## 3. Fichiers vides

Six fichiers font **0 ligne** :

```
lib/config/app_routes.dart
lib/services/auth_service.dart
lib/services/reservation_service.dart
lib/screens/home/widgets/bottom_nav_bar.dart
lib/screens/home/widgets/popular_trip_card.dart
lib/screens/home/widgets/promo_banner.dart
```

Des intentions jamais réalisées. À supprimer.

---

## 4. Code mort

| Élément | Fichier |
|---|---|
| `otp_screen.dart` | ancien parcours SMS, plus appelé |
| `quick_service_card.dart` | remplacé |
| `assets/images/logo_tokende_old.png` | remplacé par `transparent-logo.png` |
| `_statusBadge`, `_ticketInfoRow`, `_tripDate`, `_tripTime`, `_reloadAll` | `mes_voyages_screen.dart` |
| `_showContactForm` | `help_support_screen.dart` |

### Couleurs déclarées et inutilisées

Reliquats de la refonte : `orangeColor`, `backgroundColor`,
`lightBackground`, `primaryColor` subsistent dans `avis_screen.dart`,
`seat_selection_screen.dart`, `home_screen.dart`,
`personal_information_screen.dart`, `mes_voyages_screen.dart`.

La palette est maintenant dans `AppColors` ; ces champs ne servent plus.

### Imports inutilisés

`mes_voyages_screen.dart` importe encore `qr_flutter` et `url_launcher`,
dont il ne se sert plus depuis que le billet est passé par
`TkBilletSheet`.

---

## 5. Fonctionnalité non terminée

`_changePassword` dans `settings_screen.dart` est **un bouchon** :

> « sera connectée à Laravel prochainement »

Le changement de mot de passe depuis les paramètres ne fait rien. À noter :
la **récupération** de mot de passe, elle, fonctionne de bout en bout — voir
[mot-de-passe-oublie.md](mot-de-passe-oublie.md).

Dans le même écran, les deux interrupteurs de notification —
« Notifications » et « Réservations » — n'écrivent que dans
`SharedPreferences`. Le serveur ne les lit pas : les couper n'empêche
aujourd'hui aucune notification de partir. Il faudrait soit les remonter au
serveur, soit les filtrer à l'affichage.

L'interrupteur « Promotions » a été retiré le 14 octobre 2026 : il n'avait
rien derrière lui et la fonctionnalité est abandonnée.

---

## 6. Avertissements d'analyse restants

| Type | Occurrences |
|---|---|
| champs ou déclarations non utilisés | 13 |
| `BuildContext` à travers un `await` | 2 (`help_support_screen.dart`) |
| `withOpacity` déprécié | 2 (`quick_service_card.dart`, `custom_card.dart`) |
| imports inutilisés | 2 |

Les deux `use_build_context_synchronously` méritent un regard : utiliser un
`BuildContext` après un `await` sans vérifier `mounted` peut planter si
l'écran a été quitté entre-temps.

`withOpacity` est remplacé par `withValues()` — les deux occurrences sont
dans des fichiers par ailleurs morts.

---

## 7. Limite d'interface connue

Sur « Mes voyages », **le glissement horizontal est capté par les
sous-onglets** Réservations/Achats : impossible de quitter cet onglet au
doigt, il faut appuyer sur la barre.

Comportement normal de deux zones de glissement imbriquées. Le corriger
demanderait de retoucher la gestion des gestes. Voir
[navigation.md](navigation.md).

---

## 8. Anomalie côté serveur qui casse une fonctionnalité

`billets.qr_code` vaut `NULL` en base. Le QR encode une adresse sans
identifiant et **le billet est inscannable**.

Rien à corriger côté Flutter : la génération doit être réparée côté
Laravel.

---

## 9. Deux générations de composants

`widgets/custom_button.dart`, `custom_card.dart`, `custom_textfield.dart`
et `loading_widget.dart` sont remplacés par les composants TK mais toujours
présents, et encore importés par endroits.

Voir [composants-tk.md](composants-tk.md).

---

## Ordre de traitement suggéré

1. Supprimer les six fichiers vides — sans risque.
2. Retirer le code mort et les imports inutilisés — sans risque.
3. Faire passer tous les écrans par `AppConfig` — corrige l'émulateur
   Android et l'adresse morte du support.
4. Brancher le mode sombre — la palette est déjà écrite.
5. Terminer `_changePassword`, et décider du sort des deux interrupteurs de
   notification.
6. Retirer l'ancienne génération de composants une fois les derniers usages
   migrés.
