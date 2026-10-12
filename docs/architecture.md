# Architecture

## Organisation

```
lib/
├── main.dart                  point d'entrée
├── firebase_options.dart      généré par FlutterFire
│
├── config/
│   └── app_config.dart        adresse de l'API selon la plateforme
│
├── theme/                     socle visuel — voir stylisation.md
│   ├── app_colors.dart        palette
│   ├── app_spacing.dart       espacements, rayons, tailles
│   ├── app_text.dart          échelle typographique
│   └── theme_controller.dart  (non branché, voir plus bas)
│
├── widgets/
│   ├── tk/                    composants Tokende — voir composants-tk.md
│   └── custom_*.dart          anciens composants, remplacés
│
├── screens/                   un dossier par domaine
│   ├── splash/  onboarding/  auth/
│   ├── home/    search/      booking/
│   ├── voyages/ profile/     avis/
│
├── support/                   messagerie avec l'administration
├── services/                  appels réseau
└── utils/
    └── format_trajet.dart     lecture des dates et heures
```

65 fichiers Dart, environ 20 400 lignes.

## Démarrage

```
main()
 ├─ Firebase.initializeApp()
 ├─ runApp(TokendeApp)
 └─ NotificationService.initialize()

TokendeApp ──▶ SplashScreen
                  │
                  ├─ onboarding déjà vu ? ──▶ LoginScreen
                  └─ sinon ────────────────▶ OnboardingScreen
```

La clé `onboarding_vu` est lue dans `SharedPreferences`.

## État et navigation

Pas d'architecture imposée : **`StatefulWidget` et `setState`**, avec
`Navigator` pour passer d'un écran à l'autre. `provider` est déclaré en
dépendance mais très peu utilisé.

Conséquence : chaque écran gère son propre chargement réseau et son état
local. C'est simple à lire écran par écran, mais cela multiplie les appels
et les variantes de gestion d'erreur.

## Deux générations de composants

Le dossier `widgets/` contient deux familles :

| Famille | Fichiers | État |
|---|---|---|
| **TK** | `widgets/tk/*` | socle actuel, à utiliser |
| Ancienne | `custom_button.dart`, `custom_card.dart`, `custom_textfield.dart`, `loading_widget.dart` | remplacée |

Un écran neuf importe uniquement :

```dart
import '../../widgets/tk/tk.dart';
```

Ce fichier barillet réexporte les trois fichiers de thème **et** tous les
composants TK.

## Thème : ce qui est branché et ce qui ne l'est pas

`main.dart` construit son `ThemeData` en ligne :

```dart
MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF8F9FB),
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A2A66)),
  ),
  home: const SplashScreen(),
)
```

**Aucun `darkTheme`, aucun `themeMode`.** Trois conséquences :

1. `lib/theme/theme_controller.dart` (bascule clair/sombre persistée) n'est
   **jamais instancié**.
2. `lib/config/app_theme.dart` (`AppTheme.lightTheme`, avec Poppins) n'est
   **jamais utilisé** — la police Google Fonts déclarée là ne s'applique
   pas.
3. Toutes les variantes sombres de `AppColors` sont **inatteignables** :
   `Theme.of(context).brightness` vaut toujours `Brightness.light`.

Le code sombre est écrit et correct ; il ne s'exécute pas. Pour l'activer,
il faut fournir un `darkTheme` et piloter `themeMode` depuis
`ThemeController`. Voir [etat-des-lieux.md](etat-des-lieux.md).

## Deux fichiers `app_colors.dart`

Attention au chemin :

| Fichier | État |
|---|---|
| `lib/theme/app_colors.dart` | **la palette actuelle**, 102 lignes |
| `lib/config/app_colors.dart` | ancienne, 11 lignes, utilisée seulement par `app_theme.dart` (lui-même mort) |

## Réseau

`http` en direct, pas de client centralisé. Le jeton est relu depuis
`flutter_secure_storage` à chaque appel :

```dart
final token = await _storage.read(key: 'auth_token');
```

Voir [services-api.md](services-api.md).

## Stockage local

| Mécanisme | Contenu |
|---|---|
| `flutter_secure_storage` | `auth_token`, et les champs de profil |
| `SharedPreferences` | `onboarding_vu`, `dark_mode` (inutilisé) |
